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
    winget install --id 'ScoopInstaller.Scoop'
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

    # run as admin !!!
    [System.Environment]::SetEnvironmentVariable("YAZI_CONFIG_HOME", "~/.config/yazi", "User")
}