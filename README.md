# dアニメ Discord Presence

dアニメストアで再生中の作品名と時間をDiscordのPresenceに表示するChrome拡張&NativeHost.

## 仕組み
Chrome拡張は作品名などを取得し, ローカルのホストアプリケーションにデータを送信.
ホストアプリケーションは標準入力を介してChrome拡張からデータを受け取りDiscord側に送信.

## 使い方
+ このレポジトリをクローンしてビルド
+ Chromeに拡張(`extension`)を追加
+ (Windowsの場合)main.jsonのパスをレジストリ`com.dssp.discord.presence`に追加
