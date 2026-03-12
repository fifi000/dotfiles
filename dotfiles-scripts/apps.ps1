#
# Terminal
#

function Get-Terminal {
    winget install --id 'Microsoft.WindowsTerminal' --source winget
}

#
# Zen
#

function Get-Zen {
    winget install --id 'Zen-Team.Zen-Browser' --source winget
}

#
# Neovim
#

function Get-Neovim {
    winget install --id 'Neovim.Neovim' --source winget
}

#
# PowerToys
#

function Get-PowerToys {
    winget install --id 'Microsoft.PowerToys' --source winget
}

#
# VS Code
#

function Get-VSCode {
    winget install --id 'Microsoft.VisualStudioCode' --source winget
}

#
# Monitorian
#

function Get-Monitorian {
    winget install --id 'emoacht.Monitorian' --source winget
}

#
# Spotify
#

function Get-Spotify {
    winget install --id 'Spotify.Spotify' --source winget
}

#
# flux
#

function Get-Flux {
    winget install --id 'Flux.Flux' --source winget
}

################
## Install all
################

function Install-AllApps {
    Get-Terminal
    Get-Zen
    Get-Neovim
    Get-PowerToys
    Get-VSCode
    Get-Monitorian
    Get-Spotify
    Get-Flux
}
