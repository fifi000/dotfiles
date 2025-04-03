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
# create a task scheduler to run the task on login
# 

$guiPath = Join-Path $dirPath $files[-1]
$configPath = Join-Path ([Environment]::GetFolderPath('User')) ".config\kanata.kbd"
$action = New-ScheduledTaskAction -Execute $guiPath -Argument "-c $configPath" -WorkingDirectory $dirPath
$trigger = New-ScheduledTaskTrigger -AtLogOn
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

$taskName = 'Kanata startup'

if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
    Write-Host "Scheduled task '$taskName' already exists. Removing it..." -ForegroundColor Yellow
    Unregister-ScheduledTask -TaskName $taskName -Confirm
    Write-Host "Scheduled task '$taskName' removed successfully" -ForegroundColor Green
}

Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskName -RunLevel Highest -Settings $settings 

Start-ScheduledTask -TaskName 'Kanata startup'
Write-Host "Scheduled task '$taskName' created successfully" -ForegroundColor Green

