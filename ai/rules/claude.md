## Development Support Skills

以下のSkillsで開発効率を向上できます。Slash Commandで呼び出せます。

### Lint

```bash
/lint              # シェルスクリプトをlint（shellcheck）
/lint --check      # チェックのみ（修正しない）
```

### Codex Sync

```bash
/codex-sync                  # 最近のPR一覧を表示して選択
/codex-sync 196              # PR #196 のみ確認・取り込み
/codex-sync 182 190 196      # 複数のPRを一括確認・取り込み
```

---

## Custom Subagents

| Subagent        | 目的               |
| --------------- | ------------------ |
| `lint-executor` | Lint実行・自動修正 |

Subagentの詳細は `.claude/agents/` を参照してください。

---

## Skills

| Skill        | 目的                                          | 呼び出し方法  |
| ------------ | --------------------------------------------- | ------------- |
| `lint`       | シェルスクリプトのlint実行                    | `/lint`       |
| `codex-sync` | claude-code-plugins の PR を codex に取り込む | `/codex-sync` |

Skillsの詳細は `.claude/skills/` を参照してください。

---

## Claude Code Global Configuration

Global instructions are symlinked from `ai/claude/`. Runtime settings are local files copied from the tracked template on first setup; existing settings are preserved.

| ファイル                           | 配置先                    | 内容                       |
| ---------------------------------- | ------------------------- | -------------------------- |
| `ai/claude/settings.json.template` | `~/.claude/settings.json` | モデル・権限・フック       |
| `ai/claude/CLAUDE.md`              | `~/.claude/CLAUDE.md`     | 全プロジェクト共通の指示   |
| `ai/claude/scripts/`               | -                         | statusline・プラグイン更新 |

Track only `settings.json.template`. Keep machine-specific integrations in the local runtime settings. Run `bash ai/claude/scripts/plugin-update.sh` explicitly to update plugins; session startup does not update them.
