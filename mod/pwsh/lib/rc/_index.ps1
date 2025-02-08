function which {
    param(
        [Parameter(Mandatory=$true)]
        [string]$command
    )

    $cmd = Get-Command $command -ErrorAction SilentlyContinue
    if ($cmd) {
        Write-Output $cmd.Source
    } else {
        Write-Host "$command not found"
    }

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

function ___x_cmd____rcpwsh_get_msysbash(){
    if ($env:___X_CMD_RCPWSH_MSYSBASH_PATH) {
        return $env:___X_CMD_RCPWSH_MSYSBASH_PATH
    } else {
        $xcmdbash_path = "$HOME\.x-cmd.root\data\git-for-windows\bin\bash.exe"
        $msysbash_paths = @(
            $xcmdbash_path,
            "C:\Program Files\Git\bin\bash.exe",
            "C:\Program Files (x86)\Git\bin\bash.exe",
            "$HOME\scoop\apps\git\current\bin\bash.exe",
            "$HOME\AppData\Local\Programs\Git\bin\bash.exe"
        )

        $msysbash_found = $false
        foreach ($msysbash_path in $msysbash_paths) {
            if (Test-Path $msysbash_path -PathType Leaf) {
                $msysbash_found = $true
                break
            }
        }

        if (-not $msysbash_found) {
            $xbatfile = "$HOME\x-cmd.bat"
            if (-not (Test-Path $xbatfile -PathType Leaf)) {
                $xbaturl = "https://get.x-cmd.com/x-cmd.bat"
                Write-Host "- I|x: Download the x-cmd.bat script file from '$xbaturl' to '$xbatfile'"
                Invoke-WebRequest -Uri "$xbaturl" -OutFile "$xbatfile"
            }
            & $xbatfile "$HOME\.x-cmd.root\bin\x" pwsh --setup *>&1 | ForEach-Object { Write-Host $_ }

            $msysbash_path = ""
            if (Test-Path $xcmdbash_path -PathType Leaf) {
                $msysbash_path = $xcmdbash_path
            }
        }

        $env:___X_CMD_RCPWSH_MSYSBASH_PATH = $msysbash_path
        return $msysbash_path
    }
}

function msysbash(){
    param(
        [Parameter(Mandatory=$true)]
        [string]$command,
        [Parameter(Mandatory=$false)]
        [string[]]$args
    )

    $msysbash_path = ___x_cmd____rcpwsh_get_msysbash
    if (-not (Test-Path $msysbash_path)) {
        Write-Error "msysbash not found"
    } else {
        & $msysbash_path "$command" @args
    }
}

function ___x_cmd___rcpwsh_time {
    param (
        [Parameter(Mandatory=$true)]
        [string]$command,
        [Parameter(Mandatory=$false)]
        [int]$num = 10
    )

    $times = @()
    Write-Host "- I|x: Executing command -> '$command'"
    for ($i = 1; $i -le $num; $i++) {
        $executionTime = Measure-Command {
            Invoke-Expression $command | Out-Null
        }
        Write-Host "- I|x: Run $i - $executionTime"
        $times += $executionTime.TotalMilliseconds
    }

    $averageTime = ($times | Measure-Object -Average).Average
    Write-Output "- I|x: Average execution time over $num runs - $averageTime ms"
}

function ___x_cmd___rcpwsh_path_win_to_linux(){
    param(
        [string]$ps_fp
    )

    if ($ps_fp -match '^[A-Za-z]:') {
        $ls_fp = $ps_fp -replace '\\', '/'
        $ls_fp = "/" + $ls_fp.Substring(0, 1).ToLower() + $ls_fp.Substring(2)
    } elseif ($ps_fp -match '(\\\\wsl\.localhost\\[^\\]*)(\\.*)') {
        $env:___X_CMD_RCPWSH_WSL_DISTRO_PATH = $matches[1]
        $ls_fp = $matches[2] -replace '\\', '/'
    } else {
        $ls_fp = $ps_fp -replace '\\', '/'
    }

    return $ls_fp
}

function ___x_cmd___rcpwsh_path_linux_to_win(){
    param(
        [string]$ls_fp
    )

    if ($env:___X_CMD_RCPWSH_WSL_DISTRO_PATH) {
        $ps_fp = $ls_fp -replace '/', '\'
        if (-not ($ps_fp -match '(\\\\wsl\.localhost\\[^\\]*)(\\.*)')) {
            $ps_fp = $env:___X_CMD_RCPWSH_WSL_DISTRO_PATH + $ps_fp
        }
    } elseif ($ls_fp -match '^/([A-Za-z])/(.*)$') {
        $ps_fp = $matches[2] -replace '/', '\'
        $ps_fp = $matches[1].ToLower() + ":\" + $ps_fp
    } else {
        $ps_fp = $ls_fp -replace '/', '\'
    }

    return $ps_fp
}

function ___x_cmd___rcpwsh_addp_prepend(){
    $env:Path = $args[0] + ";$env:Path"
}

function ___x_cmd___rcpwsh_addp_append(){
    $env:Path = "$env:Path;" + $args[0]
}

function ___x_cmd___rcpwsh_addpifd(){
    if (Test-Path $args[0] -PathType Container){
        ___x_cmd___rcpwsh_addp_prepend $args[1]
    }
}

function ___x_cmd___rcpwsh_addpifh(){
    if (Get-Command $args[0] -ErrorAction SilentlyContinue){
        ___x_cmd___rcpwsh_addp_prepend $args[1]
    }
}

function ___x_cmd___rcpwsh_addpython(){
    ___x_cmd___rcpwsh_addpifh  python   "$HOME\.local\bin"

    $singleton_fp = "$HOME\.x-cmd.root\local\data\pkg\sphere\X\.x-cmd\singleton\python"
    if (Test-Path $singleton_fp -PathType Leaf){
        $tgtdir = "$HOME\.x-cmd.root\local\data\pkg\sphere\X\$((Get-Content -Path $singleton_fp))"
        if ($env:OS -eq "Windows_NT") {
            $binpath = "$tgtdir\Scripts"
        } else {
            $binpath = "$tgtdir\bin"
        }
        ___x_cmd___rcpwsh_addpifd   $binpath
    }
}

if (Test-Path "$HOME\.x-cmd.root\boot\pixi" -PathType Leaf){
    ___x_cmd___rcpwsh_addp_append   "$HOME\.pixi\bin"
}

___x_cmd___rcpwsh_addp_prepend      "$HOME\.x-cmd.root\bin"
___x_cmd___rcpwsh_addp_prepend      "$HOME\.x-cmd.root\local\data\pkg\sphere\X\l\j\h\bin"

___x_cmd___rcpwsh_addpifd           "$HOME\.cargo\bin"
___x_cmd___rcpwsh_addpifh  go       "$HOME\go\bin"
___x_cmd___rcpwsh_addpifh  deno     "$HOME\.deno\bin"
___x_cmd___rcpwsh_addpifh  bun      "$HOME\.bun\bin"
___x_cmd___rcpwsh_addpifh  npm      "$HOME\.npm\bin"
___x_cmd___rcpwsh_addpython


$env:___X_CMD_CD_RELM_0 = ___x_cmd___rcpwsh_path_win_to_linux $(Get-Location).Path
$env:___X_CMD_THEME_RELOAD_DISABLE = 1
# Using gitbash
# We cannot use WSL here.
function ___x_cmd(){
    $env:___X_CMD_XBINEXP_FP = "$HOME\.x-cmd.root\local\data\xbinexp\pwsh\$($PID)_$((Get-Random ))"

    if (-not $env:OLDPWD) {
        $env:___X_CMD_XBINEXP_INITENV_OLDPWD = ___x_cmd___rcpwsh_path_win_to_linux $env:OLDPWD
    } else {
        $env:___X_CMD_XBINEXP_INITENV_OLDPWD = ___x_cmd___rcpwsh_path_win_to_linux $(Get-Location).Path
    }

    $Global:___X_CMD_XBINEXP_EVAL = ""
    msysbash -command "$HOME\.x-cmd.root\bin\___x_cmdexe_exp" $args


    if (Test-Path $env:___X_CMD_XBINEXP_FP -PathType Container) {
        Get-ChildItem -Path $env:___X_CMD_XBINEXP_FP -File | ForEach-Object {
            $varname = $_.Name -replace '^[^_]+_', ''
            $varval = Get-Content -Path $_.FullName
            if ($varname -eq "PWD") {
                $varval = ___x_cmd___rcpwsh_path_linux_to_win $varval
                $env:OLDPWD = $(Get-Location).Path
                Set-Location $varval
            } else {
                Write-Debug "Set variable -> `$Global:$varname"
                Set-Variable -Name $varname -Value $varval -Scope Global
            }
        }
        Remove-Item -Path $env:___X_CMD_XBINEXP_FP -Recurse -Force
    }

    if ($Global:___X_CMD_XBINEXP_EVAL) {
        $data = $Global:___X_CMD_XBINEXP_EVAL
        $Global:___X_CMD_XBINEXP_EVAL = ""
        Write-Host "===================
>>>  $data

-------------------"
        Invoke-Expression $data
        Write-Host "==================="
    }
}

function x(){
    ___x_cmd @args
}

if ($Host.Name -ne "ConsoleHost") {
    # non-interactive
    $env:___X_CMD_RUNMODE = 0
} else {
    # interactive
    $env:___X_CMD_RUNMODE = 9

    function c(){
        if ( $args[0] -eq "-" ){
            if ($env:OLDPWD){
                Set-Location $env:OLDPWD
            }
            return
        } elseif (-not [string]::IsNullOrWhiteSpace($args[0]) -and (Test-Path $args[0] -PathType Container)){
            Set-Location $args[0]
            return
        }

        ___x_cmd cd @args
    }

    if (-not (Test-Path "$HOME\.x-cmd.root\boot\alias\xx.disable" -PathType Leaf)) {
        function xx(){
            ___x_cmd xx @args
        }
    }
    if (-not (Test-Path "$HOME\.x-cmd.root\boot\alias\xw.disable" -PathType Leaf)) {
        function xw(){
            ___x_cmd ws @args
        }
    }
    if (-not (Test-Path "$HOME\.x-cmd.root\boot\alias\xd.disable" -PathType Leaf)) {
        function xd(){
            ___x_cmd docker @args
        }
    }
    if (-not (Test-Path "$HOME\.x-cmd.root\boot\alias\xg.disable" -PathType Leaf)) {
        function xg(){
            ___x_cmd git @args
        }
    }
    if (-not (Test-Path "$HOME\.x-cmd.root\boot\alias\xp.disable" -PathType Leaf)) {
        function xp(){
            ___x_cmd pwsh @args
        }
    }
    if (-not (Test-Path "$HOME\.x-cmd.root\boot\alias\xwt.disable" -PathType Leaf)) {
        function xwt(){
            ___x_cmd webtop @args
        }
    }
    if (-not (Test-Path "$HOME\.x-cmd.root\boot\alias\co.disable" -PathType Leaf)) {
        function co(){
            ___x_cmd co --exec @args
        }
    }
    if (-not (Test-Path "$HOME\.x-cmd.root\boot\alias\coco.disable" -PathType Leaf)) {
        function coco(){
            ___x_cmd coco --exec @args
        }
    }
    if (-not (Test-Path "$HOME\.x-cmd.root\boot\alias\chat.disable" -PathType Leaf)) {
        try {
            if (-not (Test-Path "$HOME\.x-cmd.root\local\cache\chat\bootcode.ps1" -PathType Leaf)) {
                ___x_cmd pwsh --setup-rcshortcut-file
            }
            . "$HOME\.x-cmd.root\local\cache\chat\bootcode.ps1"
        } catch {
            Write-Host "- E|x: Failed to load command functions related to the chat module alias init"
        }
    }
    if (-not (Test-Path "$HOME\.x-cmd.root\boot\alias\writer.disable" -PathType Leaf)) {
        try {
            if (-not (Test-Path "$HOME\.x-cmd.root\local\cache\writer\bootcode.ps1" -PathType Leaf)) {
                ___x_cmd pwsh --setup-rcshortcut-file
            }
            . "$HOME\.x-cmd.root\local\cache\writer\bootcode.ps1"
        } catch {
            Write-Host "- E|x: Failed to load command functions related to the writer module alias init"
        }
    }
}


