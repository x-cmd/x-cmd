function which {
    param(
        [Parameter(Mandatory=$true)]
        [string]$command
    )
    Get-Command $command | Select-Object -ExpandProperty Source

    # Consider introducing alias
}

# introduce type command

# alias

# writing an equivent powershell function for touch
function touch(){
    param(
        [Parameter(Mandatory=$true)]
        [string]$file
    )
    if (Test-Path $file) {
        Set-ItemProperty -Path $file -Name LastAccessTime -Value (Get-Date)
        Set-ItemProperty -Path $file -Name LastWriteTime -Value (Get-Date)
    } else {
        New-Item $file -ItemType File
    }
}

function msysbash(){
    param(
        [Parameter(Mandatory=$true)]
        [string]$command,
        [Parameter(Mandatory=$false)]
        [string]$args
    )
    $msysbash = "C:\Program Files\Git\usr\bin\bash.exe"
    if (Test-Path $msysbash) {
        & $msysbash -c "$command $args"
    } else {
        Write-Error "msysbash not found"
    }
}

function x(){
    # Using gitbash
    msysbash $HOME/.x-cmd.root/.bin/xbin.sh $args
}

# inject env
# . $HOME\a.ps1 # # boot up x-cmd.
