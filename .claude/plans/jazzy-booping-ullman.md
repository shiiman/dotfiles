# Ghostty SSH互換性設定の追加

## 概要
SSH先で `Ctrl+R`（reverse-i-search）の表示が乱れる問題を修正する。

## 原因
Ghosttyのデフォルト `TERM=xterm-ghostty` がSSH先のサーバーで認識されないため。

## 修正内容

### 対象ファイル
- [ghostty/config](ghostty/config)

### 変更
ファイル末尾に以下を追加：

```
# SSH先での互換性のためTERMをxterm-256colorに設定
term = xterm-256color
```

## 検証方法
1. Ghosttyを再起動（または新しいタブを開く）
2. `echo $TERM` で `xterm-256color` と表示されることを確認
3. SSH接続して `Ctrl+R` が正常に動作することを確認
