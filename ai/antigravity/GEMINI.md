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
