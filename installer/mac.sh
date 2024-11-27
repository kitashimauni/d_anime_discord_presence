#!/bin/sh
# d_anime_discord_presence installer for Mac
# This download latest version

NAME="d_anime_discord_presence"
EXTENSION_DOMEIN="com.dadp.discord.presence"
EXTENSION_ID="ifenbhbjocjihjlmbbmdegolkpjmecag"
EXTENSION_DIR="~/Library/Application\ Support/Google/Chrome/External\ Extensions"
CONFIG_JSON_DIR="~/Library/Application\ Support/Google/Chrome/NativeMessagingHosts"
TEMP_DIR="/tmp/$NAME"

# Create temp directory
[ -d $TEMP_DIR ] && rm -rf $TEMP_DIR
mkdir -p $TEMP_DIR
echo "[Info] Initialized $TEMP_DIR"

# Create extension directory
[ -d "$EXTENSION_DIR" ] || mkdir -p "$EXTENSION_DIR"

# Add extension
echo '{ "external_update_url": "https://clients2.google.com/service/update2/crx" }' > $EXTENSION_DIR/$EXTENSION_ID.json

echo "[info] Added extension"

$JSON_CONTENT = '{
  "name": "com.my_company.my_application",
  "description": "My Application",
  "path": "C:\\Program Files\\My Application\\chrome_native_messaging_host.exe",
  "type": "stdio",
  "allowed_origins": ["chrome-extension://knldjmfmopnpolahpmmgbagdohdnhkik/"]
}
'

# Create config json directory
[ -d "$CONFIG_JSON_DIR" ] || mkdir -p "$CONFIG_JSON_DIR"

# Add config json
echo $JSON_CONTENT > $CONFIG_JSON_DIR/$EXTENSION_DOMEIN.json
echo "[info] Added config json"

# Clean up
rm -rf "$TEMP_DIR"
echo "[info] Clean up finished"

echo "========================================"
echo "Installation completed successfully"