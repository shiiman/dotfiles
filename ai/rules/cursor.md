## Cursor Specific

エディタ設定は `ai/cursor/` から配置される。

| 対象                              | 配置先                                                       |
| --------------------------------- | ------------------------------------------------------------ |
| `ai/cursor/User/settings.json`    | `~/Library/Application Support/Cursor/User/settings.json`    |
| `ai/cursor/User/keybindings.json` | `~/Library/Application Support/Cursor/User/keybindings.json` |
| `ai/cursor/User/snippets/`        | `~/Library/Application Support/Cursor/User/snippets`         |
| `ai/cursor/mcp.json`              | `~/.cursor/mcp.json`                                         |
| `ai/cursor/extensions.json`       | `~/.cursor/extensions/extensions.json`                       |

### Available Slash Commands

`.claude/skills/` の定義を共用する。

```bash
/lint              # シェルスクリプトをlint（shellcheck）
/codex-sync        # claude-code-plugins の PR を codex に取り込む
```
