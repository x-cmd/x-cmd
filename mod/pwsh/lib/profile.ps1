# PowerShell Profile Example - $PROFILE

# Set up a custom prompt that shows the current directory and the time
function prompt {
    $currentPath = (Get-Location).Path
    $timeStamp = Get-Date -Format "HH:mm:ss"
    "$currentPath [$timeStamp]> "
}

# Add some commonly used function shortcuts (aliases)
Set-Alias ll Get-ChildItem
Set-Alias cdd Set-Location
Set-Alias up "Set-Location .."

# Load a custom module or snap-in if needed
# Import-Module MyCustomModule -ErrorAction SilentlyContinue

# Set the default location when PowerShell starts
Set-Location C:\Users\$env:USERNAME\Documents

# Increase the command history size
$MaximumHistoryCount = 1000
Set-PSReadlineOption -HistorySaveStyle SaveNothing

# Set a custom color for error messages
$host.PrivateData.ErrorForegroundColor = 'Red'
$host.PrivateData.ErrorBackgroundColor = 'Black'

# Add a greeting message
Write-Host "Welcome to PowerShell, $env:USERNAME!" -ForegroundColor Cyan

# Define custom functions
function Get-ScriptDirectory {
    Split-Path $script:MyInvocation.MyCommand.Path
}

function Open-Profile {
    $profilePath = $PROFILE
    if (!(Test-Path $profilePath)) {
        New-Item -ItemType File -Path $profilePath -Force
    }
    notepad.exe $profilePath
}

function x {
    Write-Host "Welcome to PowerShell, $env:USERNAME!" -ForegroundColor Cyan
}

# Create a new PowerShell drive for quick access to a frequent folder
New-PSDrive -Name "Projects" -PSProvider FileSystem -Root "C:\Users\$env:USERNAME\Projects"

# Add environment paths
$env:Path += ";C:\MyCustomTools\"

# Ensure the profile script itself is not editable by other users
If (!(Test-Path $PROFILE)) {
  New-Item -ItemType File -Path $PROFILE -Force
}
$acl = Get-Acl $PROFILE
$permission = "$env:USERDOMAIN\$env:USERNAME","FullControl","Allow"
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
$acl.SetAccessRule($accessRule)
Set-Acl $PROFILE $acl
