# escape=`
FROM microsoft/aspnet:4.7.1-windowsservercore-10.0.14393.1884
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ENTRYPOINT ["powershell", "./bootstrap.ps1"]
COPY bootstrap.ps1 /

COPY SignUp-1.1.msi /
RUN Start-Process msiexec.exe -ArgumentList '/i', 'C:\SignUp-1.1.msi', '/quiet', '/norestart' -NoNewWindow -Wait