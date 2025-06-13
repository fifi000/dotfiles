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

    [Microsoft.PowerShell.PSConsoleReadLine]::DeleteLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($command)
}

Invoke-Expression (& { (zoxide init powershell | Out-String) })

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

function ask {
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromRemainingArguments = $true)]        
        [Alias("q")]
        [string]$Question,

        [Parameter(Mandatory = $false)]
        [ValidateSet('sonar', 'sonar-pro')]
        [Alias("m")]
        [string]$Model = 'sonar',
        
        [Parameter(Mandatory = $false)]
        [int]$MaxTokens = 2048,
        
        [Parameter(Mandatory = $false)]
        [Alias("t")]
        [double]$Temperature = 0.5,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("low", "medium", "high")]
        [string]$ReasoningEffort = "medium"
    )

    $api_url = 'https://api.perplexity.ai'
    $completions_url = "$api_url/chat/completions"

    $auth_token = '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'

    $system_prompt = @'
You are a helpful assistant. Answer the users question to the best of your ability.
Your answers should be concise and to the point. Your responses should be fit for a terminal interface.
'@

    $headers = @{
        'Authorization' = "Bearer $auth_token"
        'Content-Type'  = 'application/json'
    }

    $messages = @(
        @{
            'role'    = 'system'
            'content' = $system_prompt
        },
        @{
            'role'    = 'user'
            'content' = $Question
        }
    )

    $body = @{
        'model'            = $Model
        'messages'         = $messages
        'max_tokens'       = $MaxTokens
        'temperature'      = $Temperature
        'reasoning_effort' = $ReasoningEffort
    } | ConvertTo-Json -Depth 10

    try {
        $response = Invoke-RestMethod -Uri $completions_url -Method Post -Headers $headers -Body $body -ErrorAction Stop

        Write-Host $response.choices[0].message.content
    }
    catch {
        Write-Error "An error occurred: $_"
    }    
}
