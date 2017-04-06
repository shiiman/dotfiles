# ドットファイル管理用リポジトリ


▼ 導入・更新

1. githubに管理用のリポジトリを作成

2. ローカルにdotfile管理用のディレクトリ作成
```
mkdir ~/dotfiles
cd ~/dotfiles
```

3. 管理したいドットファイルを2.で作成したディレクトリに移動

`mv ~/.zshrc ./`

4. シンボリックリンクを貼る(面倒なのでシェル化)

`vi ~/dotfiles/setup.sh`

    シェル内で「ln -sf ~/dotfiles/.zshrc ~/.zshrc」みたいなことをやる

```
chmod +x ~/dotfiles/setup.sh
sh ~/dotfiles/setup.sh
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
