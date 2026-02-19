# dotfiles 修正対応計画書

## Context

project-analysis-report.md の調査結果に基づき、検出された問題を修正する。
H1（メールアドレスのハードコード）はユーザー指示により対応不要。コミットは行わない。

---

## チーム構成

| チームメイト | 担当 | 修正対象ファイル |
|-------------|------|-----------------|
| **fixer-shell** | High+Medium: シェルスクリプト修正 | `mac_setup.sh`, `statusline.sh`, `ai_setup.sh`, `sublime_setup.sh`, `.bashrc` |
| **fixer-zshrc** | High+Medium+Low: .zshrc修正 | `.zshrc` |
| **fixer-docs** | Medium: ドキュメント不整合修正 | `CLAUDE.md`, `.cursor/rules/CURSOR.mdc` |

---

## 修正タスク一覧

### チーム1: fixer-shell

#### High優先度

1. **H2. `cd` のエラーハンドリング統一** (`mac_setup.sh:84,88`)
   - `cd ~/git-worktree-runner && ./install.sh` → サブシェル `(cd ~/git-worktree-runner && ./install.sh)` に変更
   - `cd ~/git-worktree-runner && git pull && ./install.sh` も同様
   - `cd ~/dotfiles` の2箇所を削除（サブシェル化により不要に）

2. **H3. `SECONDS` 変数名変更** (`ai/claude/scripts/statusline.sh:83`)
   - `SECONDS=$((ELAPSED_SECONDS % 60))` → `SECS=$((ELAPSED_SECONDS % 60))`
   - 84行目の `$MINUTES` `$SECONDS` → `$MINUTES` `$SECS`

#### Medium優先度

3. **M1. `sh` → `bash` 呼び出し統一** (`mac_setup.sh:46,58,71,75,78`)
   - `sh ~/dotfiles/dotfile_setup.sh` → `bash ~/dotfiles/dotfile_setup.sh`
   - `sh ~/dotfiles/mise_setup.sh` → `bash ~/dotfiles/mise_setup.sh`
   - `sh ~/dotfiles/SublimeText/sublime_setup.sh` → `bash ~/dotfiles/SublimeText/sublime_setup.sh`
   - `sh ~/dotfiles/ghostty_setup.sh` → `bash ~/dotfiles/ghostty_setup.sh`
   - `sh ~/dotfiles/ai_setup.sh` → `bash ~/dotfiles/ai_setup.sh`

4. **M2. 未クォート変数展開修正** (`ai_setup.sh:149`)
   - `for ext_id in $ext_ids; do` → `while IFS= read -r ext_id; do ... done <<< "$ext_ids"` パターンに変更
   - （参考: `install_antigravity_extensions` の219行目が正しいパターン）

5. **M5. `set -e` 追加** (`SublimeText/sublime_setup.sh`)
   - 既にある（1行目: `#!/bin/bash`, 2行目: `set -e`）→ **対応不要**（報告書の誤検出）

#### Low優先度

6. **L5. `&>` → `>/dev/null 2>&1` 統一** (`ai_setup.sh:55,61,127,134,195,205`)
   - `&> /dev/null` → `>/dev/null 2>&1` に変更（6箇所）

### チーム2: fixer-zshrc

#### High優先度

7. **H4. history alias のクォーティング修正** (`.zshrc:108`)
   - `alias history='fc -lt '%F %T' 1'` → `alias history='fc -lt "%F %T" 1'`

#### Medium優先度

8. **M4. チルダ展開の修正** (`.zshrc:6`)
   - `export XDG_CONFIG_HOME=~/.config` → `export XDG_CONFIG_HOME="$HOME/.config"`

#### Low優先度

9. **L3. CLICOLOR 値修正** (`.zshrc:78`)
   - `export CLICOLOR=true` → `export CLICOLOR=1`

10. **L2. コメントアウトコード削除** (`statusline.sh:26-35, 97`) → fixer-shellに委任

### チーム3: fixer-docs

#### Medium優先度

11. **D1. CLAUDE.md Tech Stack 更新** (`CLAUDE.md:14-16`)
    - `Version Manager: anyenv (nodenv, rbenv, pyenv)` → `Version Manager: mise`
    - `Terminal: iTerm2` → `Terminal: iTerm2, Ghostty`
    - `Editor: VSCode, Sublime Text, Vim` → `Editor: VSCode, Cursor, Sublime Text, Vim`

12. **D2. CLAUDE.md anyenv_setup.sh 参照修正** (`CLAUDE.md:71`)
    - `./anyenv_setup.sh            # Install anyenv and language version managers`
    - → `./mise_setup.sh             # Install mise and language runtimes`

13. **D3. CURSOR.mdc Tech Stack 更新** (`.cursor/rules/CURSOR.mdc:11`)
    - `Bash, Zsh, Homebrew, anyenv` → `Bash, Zsh, Homebrew, mise`

14. **D4. CURSOR.mdc 参照パス修正** (`.cursor/rules/CURSOR.mdc:100`)
    - `.claude/commands/` → `.claude/skills/`

### 追加修正（各チームで対応）

15. **.bashrc の修正** (fixer-shell)
    - **M3. helm補完のプロセス置換** (`.bashrc:87`): `source <(helm completion bash)` → `eval "$(helm completion bash)"`
    - **M4. チルダ展開** (`.bashrc:3`): `export XDG_CONFIG_HOME=~/.config` → `export XDG_CONFIG_HOME="$HOME/.config"`
    - **M6. cdlspwd関数** (`.bashrc:72`): `builtin cd "$1"` → `builtin cd "${1:-$HOME}"`
    - **L3. CLICOLOR** (`.bashrc:43`): `export CLICOLOR=true` → `export CLICOLOR=1`
    - **L6. WORDCHARS削除** (`.bashrc:121`): `export WORDCHARS=...` 行を削除（Zsh専用変数）

16. **statusline.sh のコメントアウトコード削除** (fixer-shell)
    - 26-35行目のコメントアウトブロック削除
    - 97行目のコメントアウト行削除

17. **ファイルパーミッション統一** (fixer-shell)
    - `chmod 755 mise_setup.sh ai_setup.sh ai/claude/scripts/statusline.sh`

---

## 対応しない項目（除外）

- **H1**: メールアドレスのハードコード → ユーザー指示で対応不要
- **M7**: statusline.sh の数値チェック → 既に `// 0` のデフォルト値があり、実質問題ない
- **M8**: create_symlink 関数の共通化 → リファクタリングスコープが大きく今回は除外
- **M5**: sublime_setup.sh に set -e → 既にある（報告書の誤検出）
- **L1**: PATH重複除去 → 影響範囲が広く慎重な対応が必要
- **L4**: type → command -v 統一 → 動作上問題なし、今回は除外
- **L2 (.vimrc)**: .vimrc のコメントアウトコード → 最小限の変更に留める

---

## 検証方法

1. `shellcheck` で修正対象スクリプトのエラーがないことを確認
2. `.zshrc` の history alias が正しく動作することを確認（`zsh -n .zshrc` で構文チェック）
3. `.bashrc` の構文チェック（`bash -n .bashrc`）
4. ドキュメント内の Tech Stack が実際の構成と一致していることを目視確認
