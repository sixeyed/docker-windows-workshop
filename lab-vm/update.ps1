param(
    [Parameter(Mandatory=$true)]
    [string]$dockerId,
)

# set env vars:
$env:workshop='C:\scm\docker-windows-workshop'
$env:dockerId=$dockerId

# update content:
cd $env:workshop
git pull

# create shortcuts
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$Home\Desktop\Firefox.lnk")
$Shortcut.TargetPath = "C:\Program Files\Mozilla Firefox\firefox.exe"
$shortcut.Arguments = "https://dockr.ly/windows-workshop"
$Shortcut.Save()

$Shortcut = $WshShell.CreateShortcut("$Home\Desktop\PowerShell.lnk")
$Shortcut.TargetPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$Shortcut.Save()

$Shortcut = $WshShell.CreateShortcut("$Home\Desktop\Code.lnk")
$Shortcut.TargetPath = "C:\Program Files\Microsoft VS Code\Code.exe"
$Shortcut.Save()

# update tools
choco upgrade -y visualstudiocode
choco upgrade -y firefox

# set environment
[Environment]::SetEnvironmentVariable('workshop', $env:workshop, [EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable('dockerId', $env:dockerId, [EnvironmentVariableTarget]::Machine)