# starship theme
Invoke-Expression (&starship init powershell)

Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

# Bind the function to a key combination (Ctrl+R in this case)
Set-PSReadLineKeyHandler -Chord 'shift+tab' -ScriptBlock {
    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    # Get-Content (Get-PSReadLineOption).HistorySavePath
    $command = tac (Get-PSReadLineOption).HistorySavePath | fzf.exe --ansi --height=40% --reverse --border --query=$line

    [Microsoft.PowerShell.PSConsoleReadLine]::DeleteLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($command)
}

Invoke-Expression (& { (zoxide init powershell | Out-String) })

# aliases
Set-Alias -Name vim -Value nvim
Set-Alias -Name less -Value 'C:\\Program Files\\Git\\usr\\bin\\less.exe'
Set-Alias -Name tac -Value 'C:\\Program Files\\Git\\usr\\bin\\tac.exe'


# functions
function fcd {
    param(
        [Alias("r")]
        [switch]$Recurse
    )

    if ($Recurse) {
        Set-Location (Get-ChildItem -Recurse -Force -Name | fzf)
    }
    else {
        Set-Location (Get-ChildItem -Name | fzf)
    }
}

function fnvim {
    nvim (fzf --walker "file,follow,hidden")
}

function fbat {
    bat (fzf --walker "file,follow,hidden")
}

function fprev {
    fzf --preview "bat --color=always --style=numbers --line-range=:500 {}"
}

function dotfiles {
    git --git-dir=$HOME/.dotfiles --work-tree=$HOME $args
}

function y {
    $tmp = [System.IO.Path]::GetTempFileName()
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp -Encoding UTF8
    if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
        Set-Location -LiteralPath ([System.IO.Path]::GetFullPath($cwd))
    }
    Remove-Item -Path $tmp
}

function dbmgr {
    # find newest Enova version
    $folder = Get-ChildItem 'C:\Enova Multi' | Sort-Object -Descending -Top 1

    # find dbmgr.exe
    $dbmgrPath = if (Get-Command fd.exe) {
        fd.exe 'dbmgr.exe' $folder | Sort-Object -Top 1
    }
    else {
        Get-ChildItem -Recurse -Name -Filter '*dbmgr.exe' $folder
    }

    if (-not $dbmgrPath) {
        throw "dbmgr.exe not found"
    }

    & $dbmgrPath $args
}

function Get-EnovaDbVersions {
    param(
        [int]$ThrottleLimit = 5
    )
    $dbs = dbmgr list -o json | ConvertFrom-Json

    $dbs | Foreach-Object -Parallel {
        function dbmgr {
            # find newest version
            $folder = Get-ChildItem 'C:\Enova Multi' | Sort-Object -Descending -Top 1

            # find dbmgr.exe
            $dbmgrPath = if (Get-Command fd.exe -ErrorAction SilentlyContinue) {
                fd.exe 'dbmgr.exe' $folder | Sort-Object -Top 1
            }
            else {
                Get-ChildItem -Recurse -Filter '*dbmgr.exe' $folder | ForEach-Object { $_.FullName }
            }

            if (-not $dbmgrPath) {
                throw "dbmgr.exe not found"
            }

            & $dbmgrPath $args
        }

        try {
            $status = dbmgr status $_.Name -o json | ConvertFrom-Json

            return [PSCustomObject]@{
                Name    = $status.Database
                Version = $status.DatabaseVersions.system
            }
        }
        catch {
            $status = [PSCustomObject]@{
                Name    = $_.Name
                Version = "(unknown)"
            }
        }

    } -ThrottleLimit $ThrottleLimit
}

function Set-SonetaSolution {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $false)]
        [string]$Sdk = "1.1.6",

        [Parameter(Mandatory = $false)]
        [string]$EnovaVersion = "2506.0.0",

        [Parameter(Mandatory = $false)]
        [string]$DotnetVersion = "net8"
    )

    # assert in ~/dev/
    $devPath = Join-Path -Path $HOME -ChildPath "dev"
    if ($PWD.Path -ne $devPath) {
        throw "You must be in '$devPath' to create a new Soneta solution."
    }

    if (-not $Name) {
        throw "Solution name is required."
    }

    #
    # create new solution
    #

    New-Item -Path $Name -ItemType Directory | Out-Null
    Set-Location $Name

    dotnet.exe new sln

    #
    # add solution items
    #

    ## global.json
    New-Item -Path "global.json" -ItemType File -Force | Out-Null
    Set-Content -Path "global.json" -Value (@{
            "msbuild-sdks" = @{
                "Soneta.Sdk" = $Sdk
            }
        } | ConvertTo-Json) -Encoding utf8

    ## Directory.Build.props
    New-Item -Path "Directory.Build.props" -ItemType File -Force | Out-Null
    Set-Content -Path "Directory.Build.props" -Value @(
        '<?xml version="1.0" encoding="utf-8"?>'
        '<Project ToolsVersion="14.0">'
        '  <PropertyGroup>'
        "    <SonetaPackageVersion>$EnovaVersion</SonetaPackageVersion>"
        "    <SonetaTargetFramework>$DotnetVersion</SonetaTargetFramework>"
        '  </PropertyGroup>'
        '</Project>'
    ) -Encoding utf8

    $solutionProject = @(
        'MinimumVisualStudioVersion = 10.0.40219.1'
        'Project("{2150E333-8FDC-42A3-9474-1A3956D46DE8}") = "Solution Items", "Solution Items", "{089100B1-113F-4E66-888A-E83F3999EAFD}"'
        '    ProjectSection(SolutionItems) = preProject'
        '        global.json = global.json'
        '        Directory.Build.props = Directory.Build.props'
        '    EndProjectSection'
        'EndProject'
    )

    $slnName = "$Name.sln"
    (Get-Content $slnName) -replace "^MinimumVisualStudioVersion.*`$" , ($solutionProject -join "`n")
    | Set-Content -Path $slnName -Encoding utf8

    #
    # add project
    #

    dotnet.exe new soneta-addon --force

    $csprojPath = Get-ChildItem -Recurse -Filter "*.csproj" | Select-Object -First 1
    dotnet.exe sln add $csprojPath.FullName
}

function Start-SonetaExplorer {
    param(
        [Parameter(Mandatory = $true)]
        [Alias("v")]
        [string]$EnovaVersion,
        [Parameter(Mandatory = $false)]
        [switch]$WithoutCodeEval,

        # standard parameters
        [Parameter(Mandatory = $false)]
        [switch]$NoDebug,
        [Parameter(Mandatory = $false)]
        [string]$Database = $null,
        [Parameter(Mandatory = $false)]
        [string]$Operator = "Administrator",
        [Parameter(Mandatory = $false)]
        [string[]]$Ext,
        [Parameter(Mandatory = $false)]
        [string[]]$ExtPath,
        [Parameter(Mandatory = $false)]
        [string[]]$ExtPathAll,
        [Parameter(Mandatory = $false)]
        [switch]$NoDbExtensions,
        [Parameter(Mandatory = $false)]
        [string]$Folder
    )

    if (-not $Database) {
        $Database = $EnovaVersion
    }

    $sonetaExplorer = Get-ChildItem 'C:\Program Files (x86)\Soneta\'
    | Where-Object { $_.Name.StartsWith("enova365 $EnovaVersion") }
    | Sort-Object -Descending
    | Select-Object -First 1

    if (-not $sonetaExplorer) {
        throw "Soneta Explorer for Enova version '$EnovaVersion' not found."
    }

    $exePath = Join-Path -Path $sonetaExplorer.FullName -ChildPath "sonetaexplorer.exe"

    if (-not (Test-Path -Path $exePath)) {
        throw "sonetaexplorer.exe not found in '$($sonetaExplorer.FullName)'."
    }

    $paramList = @(
        "--database", $Database,
        "--operator", $Operator
    )
    if (-not $NoDebug) {
        $paramList += "--debug"
    }
    if ($Folder) {
        $paramList += "--folder"
        $paramList += $Folder
    }
    if ($ExtPath) {
        foreach ($path in $ExtPath) {
            $dlls = Get-ChildItem -Path $path -Filter "*.dll"
            foreach ($dll in $dlls) {
                $Ext += $dll.FullName
            }
        }
    }
    if ($ExtPathAll) {
        foreach ($path in $ExtPathAll) {
            $dlls = Get-ChildItem -Path $path -Recurse -Filter "*.dll"
            foreach ($dll in $dlls) {
                $Ext += $dll.FullName
            }
        }
    }
    if (-not $WithoutCodeEval) {
        $Ext += "C:\Users\filip\dev\Datio.Tools.CodeEval\bin\Debug\net8\Datio.Tools.CodeEval.dll"
    }
    $tempAssemblyFolder = $null
    if ($Ext) {
        $tempAssemblyFolder = Join-Path -Path $env:TEMP -ChildPath "SonetaExplorerExt"
        if (Test-Path -Path $tempAssemblyFolder) {
            Remove-Item -Path $tempAssemblyFolder -Recurse -Force
        }

        New-Item -ItemType Directory -Path $tempAssemblyFolder -Force | Out-Null

        foreach ($e in $Ext) {
            Copy-Item $e $tempAssemblyFolder
        }
        $paramList += "--extpath"
        $paramList += "`"$tempAssemblyFolder`""

    }
    if ($NoDbExtensions) {
        $paramList += "--nodbextensions"
    }

    $keyColor = 'Cyan'
    $valueColor = 'DarkMagenta'

    Write-Host "Argument list" -NoNewline -ForegroundColor $keyColor
    Write-Host "  $paramList" -ForegroundColor $valueColor

    if ($paramList -contains "--extpath" -and $tempAssemblyFolder) {
        Write-Host "Loaded extensions from folder" -NoNewline -ForegroundColor $keyColor
        Write-Host " $tempAssemblyFolder" -ForegroundColor $valueColor
        foreach ($dll in Get-ChildItem -Path $tempAssemblyFolder -Filter "*.dll") {
            Write-Host "`t- $($dll.Name)" -ForegroundColor $valueColor
        }
    }

    Start-Process -FilePath $exePath -ArgumentList $paramList -WorkingDirectory $sonetaExplorer.FullName
}

function Invoke-InEnovaDbs {
    param(
        [Parameter(Mandatory)]
        [string]$Query
    )

    if (-not $Query) {
        throw "Empty Query"
    }

    dbmgr list -o json | ConvertFrom-Json | ForEach-Object {
        Write-Output $_.Database

        Invoke-Sqlcmd `
            -Query $Query `
            -Database $_.Database `
            -ServerInstance 'acer\enova' `
            -TrustServerCertificate
        | Format-Table
    }
}

#
# Clipboard files operations
#

function Copy-FilesToClipboard {
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ValueFromRemainingArguments = $true)]
        [string[]]$Path
    )
    Add-Type -AssemblyName System.Windows.Forms

    $files = New-Object System.Collections.Specialized.StringCollection
    foreach ($p in $Path) {
        $full = (Resolve-Path $p).ProviderPath
        [void]$files.Add($full)
    }
    [System.Windows.Forms.Clipboard]::SetFileDropList($files)
}

