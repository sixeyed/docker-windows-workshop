param(
    [Parameter(Mandatory=$true)]
    [string]$dockerId
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
$shortcut.Arguments = "C:\scm\docker-windows-workshop"
$Shortcut.Save()

# turn the firewall off again
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled $false

# update tools
choco upgrade -y visualstudiocode
choco upgrade -y firefox

# update images
docker image pull stefanscherer/dockertls-windows
docker image pull sixeyed/git:2.13.0
docker image pull sixeyed/docker-ce:17.05.0-ce
docker image pull sixeyed/jenkins:2.46.2
docker image pull sixeyed/registry:2.6.0-nanoserver
docker image pull sixeyed/bonobo:6.1.0-windowsservercore
docker image pull sixeyed/nunit:3.6.1

# set environment
[Environment]::SetEnvironmentVariable('workshop', $env:workshop, [EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable('dockerId', $env:dockerId, [EnvironmentVariableTarget]::Machine)

# set dockerd config

mkdir -path C:\ProgramData\docker\config
cp .\docker\daemon.json C:\ProgramData\docker\config\