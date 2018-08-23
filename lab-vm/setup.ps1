$ErrorActionPreference = "SilentlyContinue"

# turn off firewall and Defender *this is meant for short-lived lab VMs*
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
Set-MpPreference -DisableRealtimeMonitoring $true

Write-Output '-VM setup script starting-'

$images = 
'microsoft/windowsservercore:ltsc2016',
'microsoft/nanoserver:sac2016',
'microsoft/dotnet-framework:4.7.2-sdk',
'microsoft/dotnet-framework:4.7.2-runtime',
'microsoft/dotnet:2.0-sdk-nanoserver-sac2016',
'microsoft/dotnet:2.0-runtime-nanoserver-sac2016',
'microsoft/aspnetcore:2.0-nanoserver-sac2016',
'microsoft/iis:nanoserver-sac2016',
'microsoft/aspnet:4.7.2-windowsservercore-ltsc2016',
'microsoft/mssql-server-windows-express:2016-sp1',
'nats:1.1.0-nanoserver'

Write-Output '* Pulling  images'
foreach ($tag in $images) {
    Write-Output "** Processing tag: $tag"
    & docker image pull $tag
}

Write-Output '* Installing Docker Compose'
iwr -useb https://raw.githubusercontent.com/sixeyed/docker-init/master/windows/install-docker-compose.ps1 | iex
iwr -useb https://raw.githubusercontent.com/sixeyed/docker-init/master/windows/install-docker-compose.ps1 | iex
iwr -useb https://raw.githubusercontent.com/sixeyed/docker-init/master/windows/install-docker-compose.ps1 | iex

Write-Output '* Installing Chocolatey'
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

Write-Output '* Installing tools'
choco install -y poshgit
choco install -y visualstudiocode
choco install -y firefox

Write-Output '* Configuring environment'
refreshenv
$env:PATH=$env:PATH + ';C:\Program Files\Mozilla Firefox;C:\Program Files\Git\bin'
[Environment]::SetEnvironmentVariable('PATH', $env:PATH, [EnvironmentVariableTarget]::Machine)
$env:workshop='C:\scm\docker-windows-workshop'
[Environment]::SetEnvironmentVariable('workshop', $env:workshop, [EnvironmentVariableTarget]::Machine)

New-ItemProperty -Path HKLM:\Software\Microsoft\ServerManager -Name DoNotOpenServerManagerAtLogon -PropertyType DWORD -Value "1" -Force
New-ItemProperty -Path HKLM:\Software\Microsoft\ServerManager\Oobe -Name DoNotOpenInitialConfigurationTasksAtLogon -PropertyType DWORD -Value "1" -Force

Write-Output '* Cloning the workshop repo'
mkdir C:\scm -ErrorAction Ignore
cd C:\scm
git clone https://github.com/sixeyed/docker-windows-workshop.git

Write-Output '* Creating desktop shortcuts'
Get-ChildItem $env:Public\Desktop\*.lnk | ForEach-Object { Remove-Item $_ }

$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$Home\Desktop\Firefox.lnk")
$Shortcut.TargetPath = "C:\Program Files\Mozilla Firefox\firefox.exe"
$shortcut.Arguments = "http://slcnet.dwwx.space"
$Shortcut.Save()

$Shortcut = $WshShell.CreateShortcut("$Home\Desktop\PowerShell.lnk")
$Shortcut.TargetPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$shortcut.WorkingDirectory = "C:\scm\docker-windows-workshop"
$Shortcut.Save()

$Shortcut = $WshShell.CreateShortcut("$Home\Desktop\Code.lnk")
$Shortcut.TargetPath = "C:\Program Files\Microsoft VS Code\Code.exe"
$shortcut.Arguments = "C:\scm\docker-windows-workshop"
$Shortcut.Save()

# turn off firewall and Defender *this is meant for short-lived lab VMs*
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
Set-MpPreference -DisableRealtimeMonitoring $true

Write-Output '-VM setup script done-'