#
# Terminal
#

function Get-Terminal {
    winget install --id 'Microsoft.WindowsTerminal'
}

# 
# Zen 
# 

function Get-Zen {
    winget install --id 'Zen-Team.Zen-Browser'
}

# 
# Neovim
# 

function Get-Neovim {
    winget install --id 'Neovim.Neovim'
}

# 
# PowerToys
# 

function Get-PowerToys {
    winget install --id 'Microsoft.PowerToys'
}

# 
# VS Code
# 

function Get-VSCode {
    winget install --id 'Microsoft.VisualStudioCode'
}

# 
# Monitorian
# 

function Get-Monitorian {
    winget install --id 'emoacht.Monitorian'
}

# 
# Spotify
# 

function Get-Spotify {
    winget install --id 'Spotify.Spotify'
}

# 
# flux
# 

function Get-Flux {
    winget install --id 'Flux.Flux'
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
