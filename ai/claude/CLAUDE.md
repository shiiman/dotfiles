# Global Instructions

- Use Japanese for responses, plans, artifacts, code comments, and error messages. Keep technical terms and identifiers in their original form.
- Write AI instruction files in English.
- Keep changes minimal and within the requested scope; follow project conventions. Explain scope and risks before substantial changes.
- Read relevant code before editing. Investigate changes whose behavior or impact you do not understand; ask the user if uncertainty remains. Preserve user edits and unrelated changes; never revert them to fix a failure.
- Check security and performance risks relevant to the changes.
- Never hardcode or expose secrets. Use environment variables or untracked local configuration.
- Require explicit user authorization for destructive operations, commits, and PR creation. Authorization already given in the conversation is sufficient.
- Use Conventional Commits with concise Japanese descriptions. Never use `--no-verify`; remove temporary debugging code before committing.
- Write PR titles and descriptions in Japanese, including a change summary and validation results.
- Run relevant checks for behavior changes and fix regressions you introduce. Do not mark work complete while test failures you introduced remain unresolved; report their causes and outstanding issues. Report pre-existing failures and blocked checks separately.
- Verify before claiming completion; summarize changes, validation, and any remaining limitations.

## Automatic Japanese Proofreading

- At the start of each turn, check whether `~/.claude/skills/yomiyasu/SKILL.md` exists. When present, automatically use yomiyasu for Japanese user-facing prose, including explanations, reports, and final replies. This is an explicit standing request to invoke the skill; read its instructions before applying it.
- When that file is absent, do not load yomiyasu from another location, reinstall it, or apply previously loaded yomiyasu instructions. An explicit user request to disable proofreading takes precedence immediately.
- Return only the finished response during automatic use, without proofreading headings, change logs, or check records. Preserve factual certainty, citations, technical identifiers, code, commands, and required output formats. Do not rewrite project files merely to proofread a reply.
- For automatic proofreading of replies, do not save draft files, final-response files, or persistent check records. This is an explicit request to use the skill's no-file/no-record workflow: invoke `python3 ~/.claude/skills/yomiyasu/scripts/yomiyasu_check.py run --stdin --no-record` from the current working directory. Pass the complete draft and final text through a quoted heredoc, separated by the exact lines `<<<yomiyasu:original>>>` and `<<<yomiyasu:final>>>`. Add the appropriate `--doc-type` when known (`mail` for ordinary chat). Do not first try file paths or create a scratch directory.
- In this no-record workflow, `unrecorded` is expected when lint and diff ran successfully. Read their actual results, preserve meaning, and return exactly the checked final text. Do not run `verify`, claim a recorded hash match, retry merely to obtain a record, or request cleanup permission. The checker manages its own transient files; do not invoke `rm` or another cleanup command for automatic replies. Do not change tool permissions or send drafts to additional external services.
- If the user explicitly requests document-file editing or saved audit records, follow that requested file/recording workflow instead. Run file-based checks from a working directory that contains their inputs, or use stdin, and preserve requested outputs and records. Do not delete or retry deletion of existing scratch directories as part of this configuration change.
- For requests to switch proofreading on or off, or check its status, run `~/.local/bin/yomiyasu on`, `off`, or `status`. Explain that a new chat is needed to compare outputs without earlier proofreading context. If checks cannot run, do not claim they ran.
