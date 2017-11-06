
$dockerVersion = '17.06'
$composeVersion = '1.16'
$currentWindowsTag = '10.0.14393.1770'
$previousWindowsTag = '10.0.14393.1715'

# run Windows Update
# TODO - you will need to do this manually with `sconfig`, if the update needs a reboot
Install-Module PSWindowsUpdate -Force
Import-Module PSWindowsUpdate
Get-WUInstall -AcceptAll -IgnoreReboot | Out-File C:\PSWindowsUpdate.log

# install Chocolatey 
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# update Docker & install Compose
iwr -useb https://raw.githubusercontent.com/sixeyed/docker-init/master/windows/install-docker-ce_$dockerVersion.ps1 | iex
iwr -useb https://raw.githubusercontent.com/sixeyed/docker-init/master/windows/install-docker-compose_$composeVersion.ps1 | iex

# update base images
docker image pull "microsoft/windowsservercore:$currentWindowsTag"
docker image pull "microsoft/nanoserver:$currentWindowsTag"
docker image tag "microsoft/windowsservercore:$currentWindowsTag" microsoft/windowsservercore:latest
docker image tag "microsoft/nanoserver:$currentWindowsTag" microsoft/nanoserver:latest

# install tools
choco install -y poshgit
choco install -y visualstudiocode
choco install -y firefox

# configure Server Manager 
New-ItemProperty -Path HKLM:\Software\Microsoft\ServerManager -Name DoNotOpenServerManagerAtLogon -PropertyType DWORD -Value "1" -Force
New-ItemProperty -Path HKLM:\Software\Microsoft\ServerManager\Oobe -Name DoNotOpenInitialConfigurationTasksAtLogon -PropertyType DWORD -Value "1" -Force

# turn off firewall and Defender *this is meant for short-lived lab VMs*
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
Set-MpPreference -DisableRealtimeMonitoring $true

# pull lab images
docker image pull "microsoft/iis:windowsservercore-$currentWindowsTag"
docker image pull "microsoft/iis:nanoserver-$currentWindowsTag"
docker image pull "microsoft/iis:nanoserver-$previousWindowsTag"
docker image pull "microsoft/aspnet:windowsservercore-$currentWindowsTag"
docker image pull "microsoft/aspnet:windowsservercore-$previousWindowsTag"
docker image pull microsoft/mssql-server-windows-express:2016-sp1
docker image pull nats:nanoserver

docker image pull stefanscherer/dockertls-windows
docker image pull dockersamples/aspnet-monitoring-prometheus

docker image pull sixeyed/msbuild:netfx-4.5.2
docker image pull sixeyed/msbuild:netfx-4.5.2-webdeploy
docker image pull sixeyed/elasticsearch:nanoserver
docker image pull sixeyed/kibana:nanoserver
docker image pull sixeyed/git:2.13.0
docker image pull sixeyed/docker-ce:17.05.0-ce
docker image pull sixeyed/jenkins:2.46.2
docker image pull sixeyed/registry:2.6.0-nanoserver
docker image pull sixeyed/bonobo:6.1.0-windowsservercore
docker image pull sixeyed/nunit:3.6.1

# tag Windows images
docker image tag "microsoft/iis:windowsservercore-$currentWindowsTag" microsoft/iis:windowsservercore
docker image tag "microsoft/iis:nanoserver-$currentWindowsTag" microsoft/iis:nanoserver
docker image tag "microsoft/aspnet:windowsservercore-$currentWindowsTag" microsoft/aspnet:latest