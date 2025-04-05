# starship theme
Invoke-Expression (&starship init powershell)

Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

# Bind the function to a key combination (Ctrl+R in this case)
Set-PSReadLineKeyHandler -Chord 'shift+tab' -ScriptBlock {
    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    # $content = Get-Content -Tail 2048 (Get-PSReadLineOption).HistorySavePath 
    $content = Get-Content (Get-PSReadLineOption).HistorySavePath
    
    $fzfInput = $content
    | ForEach-Object { [PSCustomObject]@{ Line = $_; Index = $Global:i++ } } 
    | Sort-Object -Property Index -Descending
    | ForEach-Object { $_.Line }
    | Select-Object -Unique

    $command = $fzfInput | fzf.exe --ansi --height=40% --reverse --border --query=$line

    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($command)
}


# aliases
Set-Alias -Name vim -Value nvim
Set-Alias -Name less -Value 'C:\\Program Files\\Git\\usr\\bin\\less.exe'

# functions
function fcd {
    param(
        [Alias("r")]
        [switch]$Recurse
    )

    if ($Recurse) {
        Set-Location ((Get-ChildItem -Recurse -Force -Name | fzf))
    }
    else {
        Set-Location ((Get-ChildItem -Name | fzf))
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