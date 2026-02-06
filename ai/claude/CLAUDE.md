# Global CLAUDE.md

This file applies to all Claude Code sessions.

---

## Output Language

- Always respond in Japanese.
- Technical terms and API names may remain in English.
- Write code comments and error messages in Japanese.
- Write todo items (TodoWrite tool) in Japanese.
- Write tool descriptions (Bash description, etc.) in Japanese.
- Write plan mode outputs in Japanese.
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

---

## Testing Discipline

- NEVER leave failing tests - fix them before moving to the next task.
- Run the project's test suite after code modifications that could affect behavior.
- If tests cannot be fixed within reasonable effort, revert the change and explain why.
- Do not mark tasks as "completed" (TodoWrite) while tests are failing.

---

## Code Modification Safety

- Before modifying architecture-level code, READ the existing implementation first.
- Do NOT remove or rewrite code you don't understand - ask first.
- When reporting task completion, VERIFY the result is actually working (don't just check command exit code).

---

## Session Scoping

- One session = one focused deliverable with clear success criteria.
- Complete current TodoWrite items fully (including tests) before starting new ones.
- If scope expands beyond initial request, confirm with user before proceeding.
