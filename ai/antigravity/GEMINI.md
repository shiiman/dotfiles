# Global GEMINI.md

This file applies to all Gemini (Antigravity) sessions.

---

## Output Language

- Always respond in Japanese.
- Technical terms and API names may remain in English.
- Write code comments and error messages in Japanese.
- Write implementation plans, task lists, and artifacts in Japanese.
- Write AI instruction files (CLAUDE.md, AGENTS.md, CURSOR.md, GEMINI.md) in English.

---

## Strict Prohibitions

1. **No hardcoded secrets** - Use environment variables for sensitive data.
2. **No debugging code** - Remove debug output and commented-out code before committing.
3. **No destructive operations without confirmation** - Don't run dangerous commands (rm -rf, DROP, force push) without explicit approval.

---

## Core Principles

1. **Keep it simple** - Avoid over-engineering. Only make requested changes.
2. **Security first** - Check for OWASP Top 10 vulnerabilities. Validate inputs.
3. **Explain before large changes** - Clarify scope and risks for multi-file changes.

---

## Development Workflow

- Work in small, testable increments.
- Discuss plans before implementation unless told otherwise.

---

## Commit Guidelines

- NEVER use `--no-verify` when committing.
- Write commit messages in Japanese, concise and descriptive in one line.
- Do not commit without user's explicit request.

---

## PR Guidelines

- Write PR titles and descriptions in Japanese.
- Include a summary of changes in bullet points.
- Include a test plan describing how to verify the changes.
- Reference related issues if applicable.
- Do not create PR without user's explicit request.

---

## Review Guidelines

Check for: Security (OWASP Top 10), Code quality, Performance (N+1, leaks).
