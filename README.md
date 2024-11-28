# dアニメ Discord Presence

dアニメストアで再生中の作品名と時間をDiscordのPresenceに表示するChrome拡張&NativeMessagingHostアプリケーション(Rust製).

 <img src="https://github.com/kitashimauni/d_anime_discord_presence/blob/main/assets/screenshot1.png" width="40%" />


## 仕組み
Chrome拡張は作品名などを取得し, ローカルのホストアプリケーションにデータを送信します.

NativeMessagingHostは標準入力を介して[Chrome拡張](https://chromewebstore.google.com/detail/danimediscordpresence/ifenbhbjocjihjlmbbmdegolkpjmecag)からデータを受け取りDiscord側に送信します.

## インストール
いずれも自動でChromeに拡張が追加されるのでそれを有効にすることで使えます. 追加されない場合は再起動を試してください.
アニメを再生する際, 時間表示部分をクリックして {現在の再生時間/総再生時間} となるようにしてください(このようにしなくても動作するように修正予定です).
### Windows
以下のコマンドをPowerShell(管理者権限)で実行してください.

```
iwr "https://raw.githubusercontent.com/kitashimauni/d_anime_discord_presence/main/installer/windows.ps1" | iex
```
`Program Files`以下に必要なファイルを保存するため管理者権限で実行する必要があります.

### MacOS
以下のコマンドをターミナル上で実行してください.

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/kitashimauni/d_anime_discord_presence/main/installer/mac.sh)"
```

## 開発者向け
1. このレポジトリをクローンしてビルド
2. Chromeに拡張(`extension`)を追加
3. 以下のように`main.json`を制作し実行ファイルのパスと拡張のIDを記載
```
{
    "name": "com.dadp.discord.presence",
    "description": "d-Anime Discord Presence",
    "path": "path/to/d_anime_discord_presence.exe",
    "type": "stdio",
    "allowed_origins": [
        "chrome-extension://{拡張のID}/"
    ]
}
``` 
4. (Windowsの場合)`main.json`のパスをレジストリ`HKEY_CURRENT_USER\Software\Google\Chrome\NativeMessagingHosts\com.dadp.discord.presence`に追加

## TODO
- [x] タブが2つ以上あっても問題なく動くようにする
- [x] 通信のデータ構造整理
- [ ] Abemaなど他のサイトでも機能するようにする
- [ ] 公式ウェブサイトへのリンク表示等
- [ ] Chrome拡張のパッケージ化

## License
Licensed under the [MIT](https://github.com/kitashimauni/d_anime_discord_presence/blob/main/License.txt) license.
