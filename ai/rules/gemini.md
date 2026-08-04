## Gemini / Antigravity Specific

グローバル設定は `ai/antigravity/` から配置される。

| ファイル                         | 配置先                                      | 内容                     |
| -------------------------------- | ------------------------------------------- | ------------------------ |
| `ai/antigravity/GEMINI.md`       | `~/.gemini/GEMINI.md`                       | 全プロジェクト共通の指示 |
| `ai/antigravity/extensions.json` | `~/.antigravity/extensions/extensions.json` | 拡張機能リスト           |

Antigravity CLI は `~/.local/bin` と `~/.antigravity/antigravity/bin` に PATH を通す。
インストーラが `.zshrc` / `.bashrc` へ重複行を追記することがあるため、
シェル設定を更新する際は `$HOME/.local/bin` の重複追加に注意する。
