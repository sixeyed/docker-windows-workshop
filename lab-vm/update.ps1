param(
    [Parameter(Mandatory=$true)]
    [string]$dockerId
)

# set env vars:
$env:workshop='C:\scm\docker-windows-workshop'
$env:dockerId=$dockerId

# update tools
choco upgrade -y visualstudiocode
choco upgrade -y firefox
Get-ChildItem $env:Public\Desktop\*.lnk | ForEach-Object { Remove-Item $_ }

# create shortcuts
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$Home\Desktop\Firefox.lnk")
$Shortcut.TargetPath = "C:\Program Files\Mozilla Firefox\firefox.exe"
$shortcut.Arguments = "https://dockr.ly/windows-workshop"
$Shortcut.Save()

$Shortcut = $WshShell.CreateShortcut("$Home\Desktop\PowerShell.lnk")
$Shortcut.TargetPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$shortcut.WorkingDirectory = "C:\scm\docker-windows-workshop"
$Shortcut.Save()

$Shortcut = $WshShell.CreateShortcut("$Home\Desktop\Code.lnk")
$Shortcut.TargetPath = "C:\Program Files\Microsoft VS Code\Code.exe"
$shortcut.Arguments = "C:\scm\docker-windows-workshop"
$Shortcut.Save()

# set environment
[Environment]::SetEnvironmentVariable('workshop', $env:workshop, [EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable('dockerId', $env:dockerId, [EnvironmentVariableTarget]::Machine)
$path = $env:PATH + "C:\Program Files\Mozilla Firefox;"
[Environment]::SetEnvironmentVariable('PATH', $path, [EnvironmentVariableTarget]::Machine)

# update lab repo
cd $env:workshop
git pull

# set dockerd config
cp "$env:workshop\lab-vm\docker\daemon.json" C:\ProgramData\docker\config\

# turn off firewall and Defender *this is meant for short-lived lab VMs*
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
Set-MpPreference -DisableRealtimeMonitoring $true