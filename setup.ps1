# run Windows Update
# TODO - you will need to do this manually with `sconfig`, if the update needs a reboot
#Install-Module PSWindowsUpdate -Force
#Import-Module PSWindowsUpdate
#Get-WUInstall -AcceptAll -IgnoreReboot | Out-File C:\PSWindowsUpdate.log

# install Chocolatey 
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# update Docker
Stop-Service docker
dockerd --unregister-service
Add-WindowsFeature hyper-v
choco install -y docker-for-windows --pre

# update base images
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/sixeyed/devtest-lab-ddc/master/scripts/windows/pull-base-images.ps1'))

# install tools
choco install -y poshgit
choco install -y visualstudiocode
choco install -y firefox

# configure Server Manager 
New-ItemProperty -Path HKCU:\Software\Microsoft\ServerManager -Name DoNotOpenServerManagerAtLogon -PropertyType DWORD -Value "1" -Force

# pull lab images
docker pull microsoft/iis:windowsservercore
docker pull microsoft/aspnet:windowsservercore
docker pull sixeyed/msbuild:4.5.2-webdeploy
docker pull microsoft/mssql-server-windows-express
docker pull microsoft/aspnet:windowsservercore-10.0.14393.1198
docker pull microsoft/aspnet:windowsservercore-10.0.14393.1066