# dアニメ Discord Presence

dアニメストアで再生中の作品名と時間をDiscordのPresenceに表示するChrome拡張&NativeHost(Rust製).

## 仕組み
Chrome拡張は作品名などを取得し, ローカルのホストアプリケーションにデータを送信.
NativeHostは標準入力を介してChrome拡張からデータを受け取りDiscord側に送信.

## 使い方
+ このレポジトリをクローンしてビルド
+ Chromeに拡張(`extension`)を追加
+ (Windowsの場合)`main.json`のパスをレジストリ`HKEY_CURRENT_USER\Software\Google\Chrome\NativeMessagingHosts\com.dadp.discord.presence`に追加
+ `main.json`に拡張のIDを追加

## TODO
- [x] タブが2つ以上あっても問題なく動くようにする
- [x] 通信のデータ構造整理
- [ ] Abemaなど他のサイトでも機能するようにする
- [ ] 公式ウェブサイトへのリンク表示等
- [ ] Chrome拡張のパッケージ化
