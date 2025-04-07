# 
# Powershell
# 

function Get-Powershell {
    winget install --id 'Microsoft.PowerShell'
}

# 
# Scoop
# 

function Get-Scoop {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    Invoke-RestMethod -Uri 'https://get.scoop.sh' | Invoke-Expression
}

# 
# FiraCode
# 

function Get-FiraCode {
    scoop bucket add nerd-fonts
    scoop install firacode
}

#
# RipGrep
#

function Get-RipGrep {
    winget install --id BurntSushi.ripgrep.MSVC
}

#
# fzf
#

function Get-Fzf {
    winget install --id 'junegunn.fzf'
}

#
# bat
#

function Get-Bat {
    winget install --id 'sharkdp.bat'
}

#
# tldr
#

function Get-Tldr {
    pip install tldr
}

#
# git
#

function Get-Git {
    winget install --id 'Git.Git'
}

#
# GitHub CLI
#

function Get-GithubCli {
    winget install --id 'GitHub.cli'
}


#
# starship
#

function Get-Starship {
    winget install --id 'Startship.Starship'
}

# 
# yazi
# 
function Get-Yazi {
    winget install sxyazi.yazi
    winget install Gyan.FFmpeg 7zip.7zip jqlang.jq sharkdp.fd BurntSushi.ripgrep.MSVC junegunn.fzf ajeetdsouza.zoxide ImageMagick.ImageMagick
    scoop install poppler
    
    #requires -RunAsAdministrator
    [System.Environment]::SetEnvironmentVariable("YAZI_CONFIG_HOME", "~/.config/yazi", "User")
    [System.Environment]::SetEnvironmentVariable("YAZI_FILE_ONE", "C:\Program Files\Git\usr\bin\file.exe", "User")
}