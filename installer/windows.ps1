# d_anime_discord_presence installer for Windows (PowerShell)
# This download latest version

$NAME="d_anime_discord_presence"
$EXTENSION_DOMEIN="com.dadp.discord.presence"
$EXTENSION_ID="ifenbhbjocjihjlmbbmdegolkpjmecag"
$JSON_NAME="main.json"
$TEMP_DIR="$env:TEMP/$NAME"

# Define the path to download
if (Test-Path $env:ProgramFiles) {
    $PROGRAM_FILES_DIR=$env:ProgramFiles
} else {
    Write-Host "[Error] env:ProgramFiles is not exist" -ForegroundColor Red
    exit 1
}
Write-Host "[Info] Install to $PROGRAM_FILES_DIR"
$INSTALL_DIR="$PROGRAM_FILES_DIR\$NAME"

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

# Download binary files
Write-Host "`r`n[Info] Downloading`r`n"

# Check fetch URL
$LATEST_DATA = (curl.exe -L "https://api.github.com/repos/kitashimauni/d_anime_discord_presence/releases/latest" | ConvertFrom-Json)

foreach ($asset in $LATEST_DATA.assets) {
    $FILE_NAME = $asset.name
    curl.exe -L -H 'Accept: application/octet-stream' -o "$TEMP_DIR/$FILE_NAME" $asset.url
}
if ($LastExitCode -ne 0) {
    Write-Host "[Error] Filed to download files" -ForegroundColor Red
    exit 1
}

Write-Host "`r`n[Info] Download finished`r`n"

# JSON data for native app
$JSON_CONTENT = @"
{
    "name": "$EXTENSION_DOMEIN",
    "description": "d-Anime Discord Presence",
    "path": "$NAME.exe",
    "type": "stdio",
    "allowed_origins": [
        "chrome-extension://$EXTENSION_ID/"
    ]
}
"@

$JSON_CONTENT | Out-File -FilePath "$TEMP_DIR/$JSON_NAME" -Encoding UTF8
Write-Host "[Info] Created main.json"

# Copy the files to the destination directory
robocopy "$TEMP_DIR" "$INSTALL_DIR" /E /PURGE /r:0 | Out-Null
if ($LastExitCode -ge 8) {
    Write-Host "[Error] Filed to copy directory from $TEMP_DIR to $INSTALL_DIR" -ForegroundColor Red
    exit 1
}
Write-Host "[info] Copy succeeded"

# Clean up
Remove-Item "$TEMP_DIR" -Force -Recurse
if (Test-Path $TEMP_DIR) {
    Write-Host "[info] Failed to clean up, but install finished successfully" -ForegroundColor Yellow
}
Write-Host "[info] Clean up finished"

# Regist to register
reg add "HKEY_CURRENT_USER\Software\Google\Chrome\NativeMessagingHosts\$EXTENSION_DOMEIN" /t "REG_SZ" /d "$INSTALL_DIR\$JSON_NAME" /f | Out-Null
if ($LastExitCode -ne 0) {
    Write-Host "[Error] Filed to regist config" -ForegroundColor Red
    exit 1
}
Write-Host "[info] Config registed"

Write-Host "========================================"
Write-Host "Installation completed successfully!" -ForegroundColor Green