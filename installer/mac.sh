#!/bin/sh
# d_anime_discord_presence installer for Mac
# This download latest version

NAME="d_anime_discord_presence"
EXTENSION_DOMEIN="com.dadp.discord.presence"
EXTENSION_ID="ifenbhbjocjihjlmbbmdegolkpjmecag"
EXTENSION_DIR="${HOME}/Library/Application Support/Google/Chrome/External Extensions"
CONFIG_JSON_DIR="${HOME}/Library/Application Support/Google/Chrome/NativeMessagingHosts"
TEMP_DIR="/tmp/${NAME}"
FILE_NAME="d_anime_discord_presence_mac"
INSTALL_DIR="${HOME}/.local/lib"

# Create temp directory
[ -d $TEMP_DIR ] && rm -rf $TEMP_DIR
mkdir -p $TEMP_DIR
echo "[Info] Initialized $TEMP_DIR"

echo "Downloading"

# Fetch latest virsion data
LATEST_DATA=$(curl -L "https://api.github.com/repos/kitashimauni/d_anime_discord_presence/releases/latest")
IFS=$'\n'
for line in $LATEST_DATA
do
  if echo $line | grep -q '"url"';
  then
    NOW_URL=$(echo $line | grep -o -E 'https://[^"]+')
  fi
  if echo $line | grep -q "$FILE_NAME";
  then
    break
  fi
done

# Download binary
curl -L -H 'Accept: application/octet-stream' -o "${TEMP_DIR}/${FILE_NAME}" "$NOW_URL"

echo "Download finished"

# Create install directory
[ -d "$INSTALL_DIR" ] || mkdir -p "$INSTALL_DIR"

# Copy to install path
cp -r $TEMP_DIR $INSTALL_DIR
chmod +x "${INSTALL_DIR}/${NAME}/${FILE_NAME}"

# Create extension directory
[ -d "$EXTENSION_DIR" ] || mkdir -p "$EXTENSION_DIR"

# Add extension
echo '{ "external_update_url": "https://clients2.google.com/service/update2/crx" }' > "${EXTENSION_DIR}/${EXTENSION_ID}.json"

echo "[info] Added extension"

JSON_CONTENT=$(cat << EOF
{
  "name": "$EXTENSION_DOMEIN",
  "description": "d-Anime Discord Presence",
  "path": "${INSTALL_DIR}/${NAME}/${FILE_NAME}",
  "type": "stdio",
  "allowed_origins": ["chrome-extension://${EXTENSION_ID}/"]
}
EOF
)

# Create config json directory
[ -d "$CONFIG_JSON_DIR" ] || mkdir -p "$CONFIG_JSON_DIR"

# Add config json
echo "$JSON_CONTENT" > "$CONFIG_JSON_DIR/$EXTENSION_DOMEIN.json"
echo "[info] Added config json"

# Clean up
rm -rf "$TEMP_DIR"
echo "[info] Clean up finished"

echo "========================================"
echo "Installation completed successfully"