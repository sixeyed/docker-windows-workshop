param(    
    [string] $branch = 'master'
)

$ErrorActionPreference = "SilentlyContinue"

Write-Output 'Set Windows Updates to manual'
Cscript $env:WinDir\System32\SCregEdit.wsf /AU 1
Net stop wuauserv
Net start wuauserv

# turn off firewall and Defender *this is meant for short-lived lab VMs*
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
Set-MpPreference -DisableRealtimeMonitoring $true

Write-Output '-VM setup script starting-'

$images = 
'mcr.microsoft.com/windows/servercore:ltsc2019',
'mcr.microsoft.com/windows/nanoserver:1809',
'mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2019',
'mcr.microsoft.com/dotnet/framework/sdk:4.7.2-20190312-windowsservercore-ltsc2019',
'mcr.microsoft.com/dotnet/framework/aspnet:4.7.2-windowsservercore-ltsc2019',
'mcr.microsoft.com/dotnet/framework/aspnet',
'microsoft/dotnet:2.1-runtime-nanoserver-1809',
'microsoft/dotnet:2.1-sdk-nanoserver-1809',
'microsoft/dotnet:2.1-aspnetcore-runtime-nanoserver-1809',
'dwwx/sql-server:2017',
'dwwx/message-queue',
'dockersamples/aspnet-monitoring-exporter:4.7.2-windowsservercore-ltsc2019',
'dockersamples/aspnet-monitoring-grafana:5.2.1-windowsservercore-ltsc2019',
'dockersamples/aspnet-monitoring-prometheus:2.3.1-windowsservercore-ltsc2019',
'sixeyed/elasticsearch:5.6.11-windowsservercore-ltsc2019',
'sixeyed/kibana:5.6.11-windowsservercore-ltsc2019',
'traefik:v1.7.8-nanoserver-sac2016',
'nats:1.4.1-nanoserver'

Write-Output '* Pulling images'
foreach ($tag in $images) {
    Write-Output "** Processing tag: $tag"
    & docker image pull $tag
}

Write-Output '* Installing Chocolatey'
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

Write-Output '* Installing tools'
choco install -y docker-compose
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
git checkout $branch
$branch | Out-File C:\branch.txt

Write-Output '-VM setup script done-'
