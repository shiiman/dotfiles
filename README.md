# ドットファイル管理用リポジトリ

▼ ドットファイル管理の導入・更新

1. githubに管理用のリポジトリを作成

2. ローカルにdotfile管理用のディレクトリ作成

```
mkdir ~/dotfiles
cd ~/dotfiles
```

3. 管理したいドットファイルを2.で作成したディレクトリに移動

```
mv ~/.zshrc ./
```

4. シンボリックリンクを貼る(面倒なのでシェル化)

```
vi ~/dotfiles/dotfile_setup.sh
```

シェル内で「ln -sf ~/dotfiles/.zshrc ~/.zshrc」みたいなことをやる

```
chmod +x ~/dotfiles/dotfile_setup.sh
sh ~/dotfiles/dotfile_setup.sh
```

5. gitに上げる

```
git init
git add .
git commit -m "first commit"
git remote add origin https://github.com/xxxx/dotfiles.git
git push -u origin master
```

6. 更新
ドットファイルに追加/変更があったら、同手順でgitにpushしておく

---

▼ セットアップ手順

```
git clone https://github.com/xxxx/dotfiles.git  ~/dotfiles
cd ~/dotfiles
sh ~/dotfiles/dotfile_setup.sh
```

---

▼ macの初期設定

```
curl https://raw.githubusercontent.com/xxxx/dotfiles/master/mac_setup.sh | bash
```

※ 内部でdotfile_setup.shも呼んでいる
