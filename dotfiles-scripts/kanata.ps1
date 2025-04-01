$ErrorActionPreference = 'Stop'

# check if the script is running with administrator privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "This script requires administrator privileges. Please run it as an administrator." -ForegroundColor Red
    exit 1
}

# 
# create a directory for kanata
# 

$dirPath = Join-Path $env:ProgramFiles 'Kanata'

if (-not (Test-Path -Path $dirPath)) {
    Write-Host "Directory '$dirPath' does not exist. Creating it now..." -ForegroundColor Yellow
    New-Item -ItemType Directory $dirPath
    Write-Host "Directory '$dirPath' created successfully" -ForegroundColor Green
}

# 
# get exe files
# 

$files = @('kanata.exe', 'kanata_gui.exe')
$uri = 'https://github.com/jtroo/kanata/releases/latest/download'

Write-Host "Starting download of files..." -ForegroundColor Yellow
$files | ForEach-Object {
    Write-Host "Downloading file '$_' into $dirPath" -ForegroundColor Yellow
    Invoke-WebRequest -Uri "$uri/$_" -OutFile (Join-Path $dirPath $_)
    Write-Host "Downloaded file '$_' into $dirPath" -ForegroundColor Green
}

# 
# set the program to run on startup
# 

$gui = $files[-1]
$linkPath = Join-Path ([Environment]::GetFolderPath('Startup')) "$gui - link.lnk"
$configPath = Join-Path ([Environment]::GetFolderPath('User')) ".config\kanata.kbd"

if (-not (Test-Path $configPath)) {
    Write-Host "Creating kanata config file..." -ForegroundColor Yellow
    New-Item $configPath
    Write-Host "Created kanata config file '$configPath'"
}

Write-Host "Creating symbolic link for '$gui' in startup folder..." -ForegroundColor Yellow

$WSH = New-Object -ComObject WScript.Shell
$link = $WSH.CreateShortcut($linkPath)
$link.TargetPath = Join-Path $dirPath $gui
$link.WorkingDirectory = $dirPath
$link.Arguments = "-c $configPath"
$link.Save()

Write-Host "Symbolic link for '$gui' created successfully" -ForegroundColor Green
