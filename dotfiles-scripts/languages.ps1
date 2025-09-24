# 
# python
# 

function Get-Python {    
    winget install --id 'Python.Python.3.13'
}

# 
# dotnet 
# 

function Get-Dotnet {
    winget install --id 'Microsoft.DotNet.SDK.9'
}

################
## Install all
################

function Install-AllLanguages {
    Get-Python
    Get-Dotnet
}