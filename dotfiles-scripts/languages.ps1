#
# python
#

function Get-Python {
    winget install --id 'Python.Python.3.13' --source winget
}

#
# dotnet
#

function Get-Dotnet {
    winget install --id 'Microsoft.DotNet.SDK.10' --source winget
}

################
## Install all
################

function Install-AllLanguages {
    Get-Python
    Get-Dotnet
}