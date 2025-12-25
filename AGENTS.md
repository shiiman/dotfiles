# Agent Guide (AI Standard Agent)

This file defines **mandatory behavior rules** for AI agents working on the dotfiles project.

---

## Language

- **Always respond in Japanese.**
- Use Japanese for all explanations, reviews, and descriptions.
- Proper nouns, API names, identifiers, and code symbols may remain in English.
- **Do not switch to English unless explicitly requested by the user.**
- Author rules/instructions for AI agents in English to keep wording consistent across files.

---

## Output Requirements

- All explanations, review comments, and plans must be written in Japanese.
- Code comments may be in English if they follow existing project conventions.
- Do not output English-only explanations.

---

## Core Policies

- **Do not hardcode sensitive information**:
  - Passwords, API keys, and tokens must be managed via environment variables.
  - Never expose secrets in shell configuration files.

- **Maintain shell compatibility**:
  - `.bashrc` must work with Bash 3.2+ (macOS default).
  - `.zshrc` must work with Zsh 5.0+.
  - Prefer POSIX-compatible syntax when possible.

- **Follow shellcheck guidelines**:
  - All shell scripts should pass `shellcheck` without errors.
  - Use proper quoting and error handling.

---

## Implementation Rules

### Shell Scripts

- Run `shellcheck` on all `.sh` files
- Use `set -e` for scripts that should fail on errors
- Use `set -u` to catch undefined variables
- Quote all variable expansions: `"$variable"` not `$variable`
- Use `$()` instead of backticks for command substitution
- Prefer `[[ ]]` over `[ ]` in Bash/Zsh scripts
- Use `local` for function-local variables

### Configuration Files

- Add comments explaining non-obvious settings
- Group related configurations together
- Use consistent indentation (2 or 4 spaces)
- Test changes in a new shell session before committing

### Brewfile

- Keep packages sorted alphabetically within sections
- Add comments for packages that aren't self-explanatory
- Group by type: `tap`, `brew`, `cask`, `mas`

---

## Development Flow

1. Edit configuration files
2. Run `shellcheck` on modified shell scripts
3. Test changes in a new shell session
4. Commit with descriptive message

---

## Review Guidelines

When performing code reviews, follow these guidelines.

### Review Perspectives

1. **Security**
   - Hardcoded credentials (passwords, API keys, tokens)
   - Insecure file permissions
   - Command injection vulnerabilities
   - Sensitive data exposure

2. **Shell Best Practices**
   - Proper variable quoting
   - shellcheck compliance
   - Error handling
   - POSIX compatibility

3. **Maintainability**
   - Clear comments
   - Consistent style
   - No dead code

### Severity Levels

- **Critical**: Security vulnerabilities, credential exposure
- **High**: Scripts that may fail silently, compatibility issues
- **Medium**: Code quality issues, missing error handling
- **Low**: Style violations, improvement suggestions

---

## References

For detailed rules and guidelines, refer to:

- **Project Overview / Quick Start**: [README.md](README.md)
- **Claude Code Guidelines**: [CLAUDE.md](CLAUDE.md)
- **Gemini Guidelines**: [GEMINI.md](GEMINI.md)
