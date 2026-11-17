# yomiyasu の共通設定

Claude Code と Codex で、公式の日本語推敲スキルを共用します。
両方のグローバル指示で、日本語の返答に自動適用するよう指定しています。
スキル本体は日本語のまま保持し、Git では追跡しません。

- 配布元: [nanaism/yomiyasu](https://github.com/nanaism/yomiyasu)
- 導入版: v3.1.0
- ライセンス: MIT（本体の LICENSE、UNICODE-LICENSE.txt も保持）

```bash
yomiyasu status
yomiyasu off
yomiyasu on
```

切り替えは Claude Code と Codex の両方に反映されます。
OFF はこの設定が作成したスキルのリンクだけを外し、本体は残します。
別のファイルやリンクが同じ場所にあれば、上書きせず停止します。
ON/OFF を切り替えたら新しいチャットを開いてください。OFF でも既存の共通指示は残るため、推敲スキル以外のカスタマイズまで解除するものではありません。

推敲には追加の処理時間とモデルのトークンが必要です。
通常の返答は付属のローカルスクリプトに標準入力で渡し、`run --stdin --no-record` で検査します。エージェント側で下書き・最終稿のファイルや検査記録を保存せず、削除コマンドも実行しません。
スクリプト内部では一時ファイルを使いますが、正常終了時はスクリプト自身が回収します。検証では作業領域へのファイル追加と内部一時ファイルの残存がないことを確認します。
lint と diff の結果、原文との読み比べで確認し、記録を使う `verify`（最終稿のハッシュ照合）は通常の返答では行いません。`unrecorded` はこの設定で想定した状態であり、検査が失敗したという意味ではありません。検査そのものの失敗は区別して扱います。
文書ファイルの編集や検査記録の保存を明示的に依頼した場合は、その依頼に合わせた保存・照合の手順を使います。ファイル方式では入力を含むフォルダを作業フォルダにするか、標準入力を使います。
すでに残っている一時フォルダは、この設定変更では削除しません。
各モデルが指示に従って動く方式であり、すべての返答への適用を機械的に保証するフックは追加していません。

## 導入手順

`ai_setup.sh` で Claude Code と Codex の共通設定を配置済みの環境を対象にします。
以下は dotfiles リポジトリのルートで実行してください。
本体が未導入の場合は、Codex に付属する skill-installer で配置します。導入済みの場合はこの手順を省略してください。既存の本体を上書きする更新処理は含めていません。

```bash
python3 "$HOME/.codex/skills/.system/skill-installer/scripts/install-skill-from-github.py" \
  --repo nanaism/yomiyasu --ref v3.1.0 --path skills/yomiyasu \
  --dest "$PWD/ai/yomiyasu/skills"
```

続いて切り替えコマンドを配置します。既存のコマンドが別の場所を指していれば、上書きせず停止します。

```bash
(
  set -eu
  command_path="$HOME/.local/bin/yomiyasu"
  command_source="$PWD/ai/yomiyasu/toggle.sh"
  if [ -e "$command_path" ] || [ -L "$command_path" ]; then
    if [ ! -L "$command_path" ] || [ "$(readlink "$command_path")" != "$command_source" ]; then
      echo "既存の yomiyasu コマンドがあるため停止します。" >&2
      exit 1
    fi
  fi
  source lib/symlink.sh
  create_symlink "$command_source" "$command_path"
  "$command_path" on
)
```

`~/.local/bin` を PATH に含めてください。このリポジトリの `.zshrc` では設定済みです。
