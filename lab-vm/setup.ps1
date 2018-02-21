# run Windows Update
# TODO - you will need to do this manually with `sconfig`, if the update needs a reboot
Install-Module PSWindowsUpdate -Force
Import-Module PSWindowsUpdate
Get-WUInstall -AcceptAll -IgnoreReboot | Out-File C:\PSWindowsUpdate.log

# install Chocolatey 
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# update Docker & install Compose
Install-Module DockerProvider -Force
Install-Package Docker -ProviderName DockerProvider -Force
iwr -useb https://raw.githubusercontent.com/sixeyed/docker-init/master/windows/install-docker-compose.ps1 | iex

# install tools
choco install -y poshgit
choco install -y visualstudiocode
choco install -y firefox
refreshenv

# configure Server Manager 
New-ItemProperty -Path HKLM:\Software\Microsoft\ServerManager -Name DoNotOpenServerManagerAtLogon -PropertyType DWORD -Value "1" -Force
New-ItemProperty -Path HKLM:\Software\Microsoft\ServerManager\Oobe -Name DoNotOpenInitialConfigurationTasksAtLogon -PropertyType DWORD -Value "1" -Force

# turn off firewall and Defender *this is meant for short-lived lab VMs*
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
Set-MpPreference -DisableRealtimeMonitoring $true

# clone lab repo
mkdir C:\scm -ErrorAction Ignore
cd C:\scm
git clone https://github.com/sixeyed/docker-windows-workshop.git

# pull lab images
$images = 
"microsoft/windowsservercore:ltsc2016",
'microsoft/nanoserver:sac2016',
'microsoft/dotnet-framework:4.7.1-windowsservercore-ltsc2016',
'microsoft/dotnet-framework-build:4.7.1-windowsservercore-ltsc2016',
'microsoft/iis:windowsservercore-ltsc2016',
'microsoft/iis:nanoserver-sac2016',
'microsoft/aspnet:4.7.1-windowsservercore-ltsc2016',
'microsoft/aspnet:4.7.1-windowsservercore-10.0.14393.1884',
'microsoft/mssql-server-windows-express:2016-sp1',
'nats:nanoserver',
'stefanscherer/dockertls-windows',
'dockersamples/mta-dev-web-builder:4.7.1',
'dockersamples/aspnet-monitoring-prometheus',
'dockersamples/elasticsearch:5.6.0-nanoserver-sac2016',
'dockersamples/kibana:5.6.0-windowsservercore-ltsc2016',
'sixeyed/git:2.15.1',
'sixeyed/docker-ee:17.06.2-ee-6',
'sixeyed/jenkins:2.89.2',
'sixeyed/registry:2.6.0-nanoserver',
'sixeyed/bonobo:6.1.0-windowsservercore',
'sixeyed/nunit:3.6.1'

foreach ($tag in $images) {
    Write-Output "** Processing tag: $tag"
    & docker image pull $tag
}

# tag Windows images
docker image tag microsoft/windowsservercore:ltsc2016 microsoft/windowsservercore:latest
docker image tag microsoft/nanoserver:sac2016 microsoft/nanoserver:latest
docker image tag microsoft/iis:windowsservercore-ltsc2016 microsoft/iis:windowsservercore
docker image tag microsoft/iis:nanoserver-sac2016 microsoft/iis:nanoserver
docker image tag microsoft/aspnet:4.7.1-windowsservercore-ltsc2016 microsoft/aspnet:latest