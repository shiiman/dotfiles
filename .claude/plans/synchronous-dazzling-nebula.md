# tmux 挙動改善プラン

## Context

tmux の3つの挙動について改善を検討。`copy-pipe-no-clear` への変更で問題2は解決済み。
問題1（選択消失）は未解決のため、追加の設定変更が必要。

## 現状

- [.tmux.conf:29](.tmux.conf#L29) は `copy-pipe-no-clear` に変更済み
- 問題2（改行問題）は解決済み
- 問題1（選択消失）は未解決

---

## 問題2が解決された理由

`copy-pipe-and-cancel` → `copy-pipe-no-clear` で改行問題が解決した仕組み:

1. **`copy-pipe-and-cancel` の場合**: コピー → コピーモード終了 → **iTerm2 が独自の選択/コピーを実行** → 画面幅で折り返した改行がクリップボードに入る
2. **`copy-pipe-no-clear` の場合**: コピー → コピーモード継続 → **tmux が選択を保持しているため iTerm2 の介入なし** → tmux の論理行（実際の改行位置）でテキストが処理される

つまり、`cancel` でコピーモードが終了すると iTerm2 側のマウス処理が介入し、画面幅ベースの改行が入っていた。

---

## 問題1: コピー後の選択消失（追加修正が必要）

### 原因
マウスドラッグ後にボタンを離すと、2つのイベントが順番に発火する:

1. **`MouseDragEnd1Pane`** → `copy-pipe-no-clear` 実行（選択を保持してコピー）
2. **`MouseUp1Pane`** → **デフォルトバインディングが選択をクリア/コピーモードを終了**

つまり、`copy-pipe-no-clear` で選択を保持しても、直後の `MouseUp1Pane` のデフォルト動作で選択が消される。

### 修正内容
[.tmux.conf](.tmux.conf) に以下を追加:

```bash
# MouseDragEnd後のMouseUpで選択がクリアされるのを防ぐ
unbind -T copy-mode-vi MouseUp1Pane
```

### 対象ファイル
- [.tmux.conf](.tmux.conf) の29行目付近に1行追加

---

## 問題3: ペインズーム時の過去出力リフロー（修正不可）

tmux の設計上の制約で、設定での改善は困難。

**回避策:**
- `clear` コマンドで画面をクリアしてから操作する
- 最初からウィンドウ全体で作業し、後から分割する運用にする

---

## 実施内容

[.tmux.conf](.tmux.conf) の29行目付近に `unbind -T copy-mode-vi MouseUp1Pane` を1行追加。

## 検証方法

1. `tmux source-file ~/.tmux.conf` で設定をリロード
2. マウスドラッグでテキストを選択 → 選択状態が保持されることを確認
3. `pbpaste` でクリップボードにコピーされていることを確認
4. 通常のクリック操作（ドラッグなし）が正常に動作することを確認
