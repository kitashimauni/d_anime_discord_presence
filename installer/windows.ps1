# d_anime_discord_presence installer for Windows (PowerShell)
# This download v0.1.0-beta 

$NAME="d_anime_discord_presence"
$EXTENSION_DOMEIN="com.dadp.discord.presence"
$EXTENSION_ID="annngonnefpokjedciknbbnbngdjfdnk"
$JSON_NAME="main.json"
$EXTENSION_ASSET_ID="208979921"
$NATIVE_APP_ASSET_ID="208977294"
$TEMP_DIR="$env:TEMP/$NAME"

# Define the path to download
if (Test-Path $env:ProgramFiles) {
    $DOWNLOAD_DIR=$env:ProgramFiles
} else {
    Write-Host "[Error] env:ProgramFiles is not exist" -ForegroundColor Red
    exit 1
}
Write-Host "[Info] Install to $DOWNLOAD_DIR"
$INSTALL_DIR="$DOWNLOAD_DIR/$NAME"

# Check temp directory to download binary
while (Test-Path $TEMP_DIR) {
    Write-Host "$TEMP_DIR is already exist and delete this to continue" -ForegroundColor Yellow
    $input = Read-Host "Delete '${TEMP_DIR}'?(y/n)"
    if ($input -match "^(y|Y|Yes)$") {
        Remove-Item "$TEMP_DIR" -Force -Recurse
        break
    } elseif ($input -match "^(n|N|No)$") {
        Write-Host "Canceled"
        exit 1
    } else {
        Write-Host "Invalid character"
    }
}

# Create temp directory
New-Item -Path "$TEMP_DIR" -ItemType "directory" | Out-Null


# Download files
Write-Host "`r`n[Info] Downloading`r`n"
curl -o "$TEMP_DIR/$NAME.exe" "https://api.github.com/repos/kitashimauni/d_anime_discord_presence/releases/assets/$NATIVE_APP_ASSET_ID"
curl -o "$TEMP_DIR/$NAME.crx" "https://api.github.com/repos/kitashimauni/d_anime_discord_presence/releases/assets/$EXTENSION_ASSET_ID"
Write-Host "`r`n[Info] Download finished`r`n"

# JSON data for native app
$JSON_CONTENT = @"
{
    "name": "$EXTENSION_DOMEIN",
    "description": "d-Anime Discord Presence",
    "path": "$INSTALL_DIR/$NAME.exe",
    "type": "stdio",
    "allowed_origins": [
        "chrome-extension://$EXTENSION_ID/"
    ]
}
"@

# JSON をファイルに書き込み
$JSON_CONTENT | Out-File -FilePath "$TEMP_DIR/$JSON_NAME" -Encoding UTF8

Write-Host "[Info] Created main.json"
