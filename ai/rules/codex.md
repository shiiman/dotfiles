## Codex Specific

グローバル設定は `ai/codex/` から `~/.codex/` へ配置される。

| 対象                            | 配置先                 | 方式                      |
| ------------------------------- | ---------------------- | ------------------------- |
| `ai/codex/AGENTS.md`            | `~/.codex/AGENTS.md`   | symlink                   |
| `ai/codex/skills/`              | `~/.codex/skills`      | symlink                   |
| `ai/codex/lib/`                 | `~/.codex/lib`         | symlink（共有ライブラリ） |
| `ai/codex/agents/`              | `~/.codex/agents`      | symlink                   |
| `ai/codex/config.toml.template` | `~/.codex/config.toml` | **コピー**                |

### config.toml はテンプレート方式

`ai/codex/config.toml` は**追跡対象外**。Codex CLI が実行時に以下を自動追記・更新するため、
symlink にするとマシン固有の絶対パスや作業中プロジェクト名がリポジトリへ流入する。

- `[projects."<絶対パス>"]` — trust_level
- `[hooks.state."<絶対パス>:..."]` — enabled / trusted_hash
- `[marketplaces.<name>]` — last_revision / last_updated
- `[notice.model_migrations]` / `[tui.model_availability_nux]`

そのため追跡するのは `config.toml.template` のみで、`ai_setup.sh` が実ファイルを生成する。
設定変更を dotfiles に残したい場合は、上記の自動生成セクションを含めずテンプレートへ転記する。

### Skills

`ai/codex/skills/.system/` は codex CLI が自動配置・更新するため追跡しない。
