param(    
    [string] $branch = 'master'
)

$ErrorActionPreference = "SilentlyContinue"

# turn off firewall and Defender *this is meant for short-lived lab VMs*
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
Set-MpPreference -DisableRealtimeMonitoring $true

Write-Output '-VM setup script starting-'

$images = 
'microsoft/windowsservercore:ltsc2016',
'microsoft/windowsservercore',
'microsoft/nanoserver:sac2016',
'microsoft/nanoserver',
'microsoft/iis:nanoserver-sac2016',
'microsoft/iis:nanoserver',
'microsoft/dotnet-framework:4.7.2-runtime',
'microsoft/dotnet-framework:4.7.2-sdk',
'microsoft/aspnet:4.7.2-windowsservercore-ltsc2016',
'microsoft/aspnet',
'microsoft/iis:windowsservercore',
'microsoft/dotnet:2.1-runtime-nanoserver-sac2016',
'microsoft/dotnet:2.1-sdk-nanoserver-sac2016',
'microsoft/dotnet:2.1-aspnetcore-runtime-nanoserver-sac2016',
'microsoft/mssql-server-windows-express:2016-sp1',
'nats:1.3.0-nanoserver',
'dockersamples/aspnet-monitoring-exporter:4.7.2',
'dockersamples/aspnet-monitoring-grafana:5.2.1',
'dockersamples/aspnet-monitoring-prometheus:2.3.1',
'sixeyed/elasticsearch:5.6.11-nanoserver-sac2016',
'sixeyed/kibana:5.6.11-windowsservercore-ltsc2016'

Write-Output '* Pulling images'
foreach ($tag in $images) {
    Write-Output "** Processing tag: $tag"
    & docker image pull $tag
}

Write-Output '* Installing Chocolatey'
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

Write-Output '* Installing tools'
choco install -y docker-compose --version 1.22.0
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
