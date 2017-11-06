# escape=`
FROM microsoft/aspnet:windowsservercore-10.0.14393.1715
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ENTRYPOINT ["powershell", "./bootstrap.ps1"]
COPY bootstrap.ps1 /

COPY SignUp-1.0.msi /
RUN Start-Process msiexec.exe -ArgumentList '/i', 'C:\SignUp-1.0.msi', '/quiet', '/norestart' -NoNewWindow -Wait