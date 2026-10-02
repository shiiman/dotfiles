---
name: codex-settings
description: Codex 設定の表示・更新を統合管理する。「Codex 設定管理」「設定を表示」「settings を更新」「権限設定を変更」「設定ファイル管理」「codex settings」などで起動。引数があれば優先し、なければ発話内容から view/update を判定。
---

# Codex Settings Manage

View or update Codex configuration while preserving unrelated settings.

## Help

If the user input includes `--help`, display the following and stop:

```text
/codex-settings - Codex 設定管理

概要:
  Codex 設定の表示・更新を統合管理する。
  引数があれば優先し、なければ発話内容から操作を判定。

使用方法:
  /codex-settings [操作] [オプション]

操作:
  view          設定を表示
  update        config.toml を更新

オプション:
  --help        このヘルプを表示

例:
  /codex-settings              # 発話内容から操作を判定
  /codex-settings view         # 設定を表示
  /codex-settings update       # config.toml を更新
```

## Configuration Targets

- The active user configuration is `$CODEX_HOME/config.toml`, defaulting to
  `~/.codex/config.toml` when `CODEX_HOME` is unset.
- In this dotfiles repository, `ai/codex/config.toml.template` is the tracked
  source. `ai_setup.sh` deploys a copy as the active configuration. Check the
  setup script before relying on its overwrite behavior.
- Updating the active configuration and preserving a change in the repository
  are separate operations. Follow the user's requested scope and report which
  files changed. Do not silently update both or replace the active file with a
  symlink.
- When reflecting an active setting into the tracked template, copy only the
  intended portable setting. Exclude secrets, personal identifiers, absolute
  machine paths, and runtime-managed sections such as `projects`, `hooks.state`,
  marketplace revision/timestamp metadata, `notice.model_migrations`, and
  `tui.model_availability_nux`.

## Workflow

Prefer an explicit `view` or `update` argument; otherwise infer the operation
from the user's request.

### View

Read the target configuration and summarize settings by section. Mask secrets
before displaying them, including credentials in environment tables and URLs.
Avoid printing the entire unredacted file into tool output.

### Update

1. Inspect the existing file and preserve unrelated settings and the current
   model. Set or change `model` only when the user explicitly specifies it; when
   creating a file, omit `model` to use Codex's default unless instructed otherwise.
2. Check the installed Codex version and validate requested keys and values
   against its configuration schema or matching official documentation. Prefer
   local evidence; if it is insufficient, consult official OpenAI documentation.
   TOML parsing proves syntax and table placement, not support by Codex.
3. Use `approval_policy` and `sandbox_mode`, not the obsolete `approval_mode`
   and `sandbox` keys. Do not translate old values mechanically when their
   intended permissions are unclear. Apply the user's intended permissions and
   respect any environment-enforced restrictions.
4. Merge the requested changes. Place top-level keys before the first TOML table
   header; blank lines and comments do not end a table. Preserve existing model,
   MCP, profile, and runtime-managed settings unless the requested change concerns
   them. Do not unconditionally overwrite the whole configuration.
5. Parse the resulting TOML and confirm changed keys are in the intended tables.
   Check supported keys and enum values against the schema or documentation from
   step 2. Report any validation limitations without claiming runtime verification
   from parsing alone.
6. Report the target, changes, and validation results in Japanese.

## Creating a Missing Configuration

Create the parent directory if needed. Use the repository template when the user
requests the dotfiles configuration; otherwise the minimal example below is a
starting point. Do not introduce unrelated settings or fix a model version.

```toml
# Codex 設定ファイル

# トップレベル設定は最初のテーブル見出しより前に配置する
approval_policy = "on-request"
sandbox_mode = "workspace-write"
```

For a file that also has section settings, keep the same placement:

```toml
# 承認とサンドボックス
approval_policy = "on-request"
sandbox_mode = "workspace-write"

# 履歴設定
[history]
persistence = "save-all"
```

For MCP credentials, use the supported environment-variable mechanism for the
installed version (for example, an HTTP server's `bearer_token_env_var` or a stdio
server's `env_vars`). Never put token values in TOML examples or the tracked
template. Preserve existing MCP definitions unless the user requests a change.

## Output Example

```markdown
## Codex Settings 管理

### 実行モード

- update

### 結果

- 対象ファイル: ~/.codex/config.toml
- 変更点: 承認ポリシーを on-request に更新
- 検証: TOML 構文・キーの配置と対応バージョンのスキーマを確認
- ステータス: 成功
```
