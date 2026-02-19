# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## Project Overview

- **Project Name**: dotfiles
- **Purpose**: macOS 開発環境の設定ファイル管理リポジトリ
- **Tech Stack**:
  - Shell: Bash, Zsh
  - Package Manager: Homebrew
  - Version Manager: mise
  - Terminal: iTerm2, Ghostty
  - Editor: VSCode, Cursor, Sublime Text, Vim
- **Details**: Refer to [README.md](README.md)

---

## Output Language

- **Always respond in Japanese.**
- Proper nouns, API names, and technical terms may remain in English.
- Write comments in Japanese.
- **Do not switch to English unless explicitly requested by the user.**
- Author rules/instructions for AI agents in English to maintain consistency across rule files.

---

## Strict Prohibitions (Behavior Constraints)

1. **Do not hardcode sensitive information.**
   - Passwords, API keys, and tokens must be managed via environment variables.
   - Never commit `.env` files or files containing secrets.

2. **Do not leave debugging code.**
   - Remove all `echo` or `printf` debug output before committing.
   - Do not leave commented-out code blocks.

3. **Preserve existing shell compatibility.**
   - `.bashrc` changes must work with Bash 3.2+ (macOS default).
   - `.zshrc` changes must work with Zsh 5.0+.
   - Prefer POSIX-compatible syntax when possible.

4. **Do not modify system files.**
   - Only edit files within this repository.
   - Use symlinks to deploy configurations.

---

## Essential Commands

### Dotfiles Setup

```bash
./dotfile_setup.sh           # Create symlinks for dotfiles to home directory
```

### macOS Setup

```bash
./mac_setup.sh               # Run full macOS setup (Homebrew, apps, settings)
brew bundle                  # Install packages from Brewfile
brew bundle --file=Brewfile  # Explicit Brewfile path
```

### Development Environment

```bash
./mise_setup.sh             # Install mise and language runtimes
```

### AI Tools Setup

```bash
./ai_setup.sh              # AI tools configuration symlinks (Claude, Cursor, Codex, Antigravity)
```

### Terminal Setup

```bash
./ghostty_setup.sh         # Create symlinks for Ghostty terminal configuration
```

### Shell Configuration

```bash
source ~/.bashrc             # Reload Bash configuration
source ~/.zshrc              # Reload Zsh configuration
```

---

## Core Principles

1. **Keep Configurations Simple**
   - Avoid complex shell scripts when simpler alternatives exist.
   - Document any non-obvious configurations with comments.

2. **Maintain Cross-Shell Compatibility**
   - Test changes in both Bash and Zsh when applicable.
   - Use conditional blocks for shell-specific features.

3. **Follow Shell Best Practices**
   - Use `shellcheck` for linting shell scripts.
   - Quote variables to prevent word splitting.
   - Use `set -e` for scripts that should fail on errors.

4. **Document Changes**
   - Add comments explaining why configurations exist.
   - Update README.md for significant changes.

---

## Development Support Skills

以下のSkillsで開発効率を向上できます。Slash Command（`/review`など）で呼び出せます。

### Code Review

```bash
/review            # 変更内容の詳細レビュー
/review --staged   # staged変更のみ
/review --security # セキュリティ観点のみ
```

### Lint

```bash
/lint              # シェルスクリプトをlint（shellcheck）
/lint --check      # チェックのみ（修正しない）
```

### Git Operations

```bash
/commit            # 変更をコミット
/pr                # Pull Request作成
```

### Setup

```bash
/setup             # 開発環境セットアップ
/setup --check     # 現在の状態を確認
```

---

## Custom Subagents

以下のSubagentが開発を支援します。

| Subagent | 目的 |
|----------|------|
| `code-reviewer` | コード品質・セキュリティレビュー |
| `lint-executor` | Lint実行・自動修正 |

Subagentの詳細は `.claude/agents/` を参照してください。

---

## Skills

### 自動適用スキル

以下のSkillsがコード編集時に自動的に適用されます。

| Skill | 目的 | 自動適用条件 |
|-------|------|-------------|
| `security-review` | セキュリティ脆弱性検出 | すべてのコード変更時 |

### ユーザー呼び出しスキル

以下のSkillsはSlash Commandで呼び出せます。

| Skill | 目的 | 呼び出し方法 |
|-------|------|-------------|
| `review` | コードレビュー | `/review` |
| `lint` | シェルスクリプトのlint実行 | `/lint` |
| `commit` | 変更のコミット | `/commit` |
| `pr` | Pull Request作成 | `/pr` |
| `setup` | dotfilesの初期セットアップ | `/setup` |

Skillsの詳細は `.claude/skills/` を参照してください。

---

## Review Guidelines

### Review Perspectives

1. **Security**
   - Hardcoded credentials (passwords, API keys, tokens)
   - Insecure file permissions
   - Command injection vulnerabilities
   - Sensitive data exposure in logs

2. **Shell Best Practices**
   - Proper variable quoting
   - Use of shellcheck-compliant patterns
   - Error handling with `set -e` or explicit checks
   - POSIX compatibility where appropriate

3. **Maintainability**
   - Clear and descriptive comments
   - Consistent coding style
   - No redundant or dead code

### Severity Levels

- **Critical**: Security vulnerabilities, credential exposure
- **High**: Scripts that may fail silently, compatibility issues
- **Medium**: Code quality issues, missing error handling
- **Low**: Style violations, improvement suggestions
