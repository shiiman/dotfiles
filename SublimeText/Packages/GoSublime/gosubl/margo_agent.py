from . import _dbg
from . import sh, gs, gsq
from .margo_common import TokenCounter, OutputLogger, Chan
from .margo_state import State, make_props, actions
import os
import sublime
import subprocess
import threading
import time

ipc_codec = 'msgpack'

if ipc_codec == 'msgpack':
	from .vendor import umsgpack
	ipc_dec = umsgpack.load
	ipc_enc = umsgpack.dump
	ipc_ignore_exceptions = (umsgpack.InsufficientDataException, BrokenPipeError)
elif ipc_codec == 'cbor':
	from .vendor.cbor_py import cbor
	ipc_dec = cbor.load
	ipc_enc = cbor.dump
	ipc_ignore_exceptions = (BrokenPipeError)
else:
	raise Exception('impossibru')

class MargoAgent(threading.Thread):
	def __init__(self, mg):
		threading.Thread.__init__(self)
		self.daemon = True

		self.mg = mg
		_, self.domain = mg.agent_tokens.next()
		self.cookies = TokenCounter('%s,request' % self.domain)
		self.proc = None
		self.lock = threading.Lock()
		self.out = OutputLogger(self.domain, parent=mg.out)
		self.global_handlers = {}
		self.req_handlers = {}
		self.req_chan = Chan()
		self.starting = threading.Event()
		self.starting.set()
		self.started = threading.Event()
		self.stopped = threading.Event()
		self.ready = threading.Event()
		gopaths = [
			os.path.join(sublime.packages_path(), 'User', 'margo'),
			mg.package_dir,
		]
		psep = os.pathsep
		self._env = {
			'GOPATH': psep.join(gopaths),
			'PATH': psep.join([os.path.join(p, 'bin') for p in gopaths]) + psep + os.environ.get('PATH'),
		}

		self._mod_ev = threading.Event()
		self._mod_view = None
		self._pos_view = None

	def __del__(self):
		self.stop()

	def stop(self):
		if self.stopped.is_set():
			return

		self.starting.clear()
		self.stopped.set()
		self.req_chan.close()
		self._stop_proc()
		self._release_handlers()
		self.mg.agent_stopped(self)

	def ok(self):
		return self.proc and self.proc.poll() is None

	def _release_handlers(self):
		with self.lock:
			hdls, self.req_handlers = self.req_handlers, {}

		rs = AgentRes(error='agent stopping. request aborted', agent=self)
		for rq in hdls.values():
			rq.done(rs)

	def run(self):
		self._start_proc()

	def _start_proc(self):
		self.mg.agent_starting(self)
		self.out.println('starting')

		gs_gopath = sh.psep.join((gs.user_path(), gs.dist_path()))
		gs_gobin = gs.dist_path('bin')
		install_cmd = ['go', 'install', '-v', 'disposa.blue/margo/cmd/margo']
		cmd = sh.Command(install_cmd)
		cmd.env = {
			'GOPATH': gs_gopath,
			'GOBIN': gs_gobin,
		}
		cr = cmd.run()
		for v in (cr.out, cr.err, cr.exc):
			if v:
				self.out.println('%s:\n%s' % (install_cmd, v))

		mg_cmd = [
			sh.which('margo', m={'PATH': gs_gobin}) or 'margo',
			'sublime', '-codec', ipc_codec,
		]
		self.out.println(mg_cmd)
		cmd = sh.Command(mg_cmd)
		cmd.env = {
			'GOPATH': gs_gopath,
			'PATH': gs_gobin,
		}
		pr = cmd.proc()
		if not pr.ok:
			self.stop()
			self.out.println('Cannot start margo: %s' % pr.exc)
			return

		self.proc = pr.p
		gsq.launch(self.domain, self._handle_send)
		gsq.launch(self.domain, self._handle_send_mod)
		gsq.launch(self.domain, self._handle_recv)
		gsq.launch(self.domain, self._handle_log)
		self.started.set()
		self.starting.clear()
		self.proc.wait()

	def _stop_proc(self):
		self.out.println('stopping')
		p = self.proc
		if not p:
			return

		for f in (p.stdin, p.stdout, p.stderr):
			try:
				f.close()
			except Exception as exc:
				self.out.println(exc)

	def _handle_send_ipc(self, rq):
		with self.lock:
			self.req_handlers[rq.cookie] = rq

		try:
			ipc_enc(rq.data(), self.proc.stdin)
			exc = None
		except ipc_ignore_exceptions as e:
			exc = e
		except Exception as e:
			exc = e
			if not self.stopped.is_set():
				gs.error_traceback(self.domain)

		if exc:
			with self.lock:
				self.req_handlers.pop(rq.cookie, None)

			rq.done(AgentRes(error='Exception: %s' % exc, rq=rq, agent=self))

	def send(self, action={}, cb=None, view=None):
		rq = AgentReq(self, action, cb=cb, view=view)
		timeout = 0.200
		if not self.started.wait(timeout):
			rq.done(AgentRes(error='margo has not started after %0.3fs' % (timeout), timedout=timeout, rq=rq, agent=self))
			return rq

		if not self.req_chan.put(rq):
			rq.done(AgentRes(error='chan closed', rq=rq, agent=self))

		return rq

	def view_modified(self, view):
		self._mod_view = view
		self._mod_ev.set()

	def view_pos_changed(self, view):
		self._pos_view = view
		self._mod_ev.set()

	def _send_mod(self):
		mod_v, self._mod_view = self._mod_view, None
		pos_v, self._pos_view = self._pos_view, None
		if mod_v is None and pos_v is None:
			return

		view = pos_v
		action = actions.ViewPosChanged
		if mod_v is not None:
			action = actions.ViewModified
			view = mod_v

		self.send(action=action, view=view).wait()

	def _handle_send_mod(self):
		delay = 0.500
		while not self.stopped.is_set():
			self._mod_ev.wait(delay)
			if self._mod_ev.is_set():
				self._mod_ev.clear()
				time.sleep(delay * 1.5)
				self._send_mod()

	def _handle_send(self):
		for rq in self.req_chan:
			self._handle_send_ipc(rq)

	def _nop_handler(self, rs):
		pass

	def _handler(self, rs):
		if not rs.cookie:
			return self._nop_handler

		with self.lock:
			rq = self.req_handlers.pop(rs.cookie, None)
			if rq:
				rs.set_rq(rq)
				return rq.done

		if rs.cookie in self.global_handlers:
			return self.global_handlers[rs.cookie]

		return lambda rs: self.out.println('unexpected response: %s' % rs)

	def _notify_ready(self):
		if self.ready.is_set():
			return

		self.ready.set()
		self.mg.agent_ready(self)

	def _handle_recv_ipc(self, v):
		self._notify_ready()
		rs = AgentRes(v=v, agent=self)
		# call the handler first. it might be on a timeout (like fmt)
		for handle in [self._handler(rs), self.mg.render]:
			try:
				handle(rs)
			except Exception:
				gs.error_traceback(self.domain)

	def _handle_recv(self):
		try:
			v = None
			while not self.stopped.is_set():
				v = ipc_dec(self.proc.stdout) or {}
				if v:
					self._handle_recv_ipc(v)
		except ipc_ignore_exceptions:
			pass
		except Exception as e:
			self.out.println('ipc: recv: %s: %s' % (e, v))
		finally:
			self.stop()

	def _handle_log(self):
		try:
			for ln in self.proc.stderr:
				try:
					self.out.println('log: %s' % self._decode_ln(ln))
				except (ValueError, OSError):
					pass
				except Exception:
					gs.error_traceback(self.domain)
		except (ValueError, OSError):
			pass
		except Exception:
			gs.error_traceback(self.domain)

	def _decode_ln(self, ln):
		if isinstance(ln, bytes):
			ln = ln.decode('utf-8', 'replace')

		return ln.rstrip('\r\n')

class AgentRes(object):
	def __init__(self, v={}, error='', timedout=0, rq=None, agent=None):
		self.data = v
		self.cookie = v.get('Cookie')
		self.state = State(v=v.get('State') or {})
		self.error = v.get('Error') or error
		self.timedout = timedout
		self.agent = agent
		self.set_rq(rq)

	def set_rq(self, rq):
		if self.error and rq:
			act = rq.action
			if act and act.get('Name'):
				self.error = 'action: %s, error: %s' % (act.get('Name'), self.error)
			else:
				self.error = 'error: %s' % self.error

	def get(self, k, default=None):
		return self.state.get(k, default)

class AgentReq(object):
	def __init__(self, agent, action, cb=None, view=None):
		self.start_time = time.time()
		_, cookie = agent.cookies.next()
		self.cookie = 'action:%s(%s)' % (action['Name'], cookie)
		self.domain = self.cookie
		self.action = action
		self.cb = cb
		self.props = make_props(view=view)
		self.rs = DEFAULT_RESPONSE
		self.lock = threading.Lock()
		self.ev = threading.Event()
		self.view = view

	def done(self, rs):
		with self.lock:
			if self.ev.is_set():
				return

			self.rs = rs
			self.ev.set()

		if self.cb:
			try:
				self.cb(self.rs)
			except Exception:
				gs.error_traceback(self.domain)

	def wait(self, timeout=None):
		if self.ev.wait(timeout):
			return self.rs

		return None

	def data(self):
		return {
			'Cookie': self.cookie,
			'Props': self.props,
			'Action': self.action,
		}

DEFAULT_RESPONSE = AgentRes(error='default agent response')
