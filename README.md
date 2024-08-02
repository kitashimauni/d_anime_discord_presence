# dアニメ Discord Presence

dアニメストアで再生中の作品名と時間をDiscordのPresenceに表示するChrome拡張&NativeHost.

## 仕組み
Chrome拡張は作品名などを取得し, ローカルのホストアプリケーションにデータを送信.
ホストアプリケーションは標準入力を介してChrome拡張からデータを受け取りDiscord側に送信.

## 使い方
+ このレポジトリをクローンしてビルド
+ Chromeに拡張(`extension`)を追加
+ (Windowsの場合)main.jsonのパスをレジストリ`HKEY_CURRENT_USER\Software\Google\Chrome\NativeMessagingHosts\com.dadp.discord.presence`に追加

## TODO
- [ ] タブが2つ以上あっても問題なく動くようにする
- [ ] 通信のデータ構造整理
- [ ] Abemaなど他のサイトでも機能するようにする
- [ ] 公式ウェブサイトへのリンク表示等
