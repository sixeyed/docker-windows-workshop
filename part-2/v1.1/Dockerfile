# escape=`
FROM microsoft/aspnet:windowsservercore-10.0.14393.576
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# disable DNS cache so container addresses always fetched from Docker
RUN Set-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters' -Name ServerPriorityTimeLimit -Value 0 -Type DWord
ENV DB_CONNECTION_STRING="sqlserver"

ENTRYPOINT ["powershell", "./bootstrap.ps1"]
COPY bootstrap.ps1 /

COPY ProductLaunch-1.1.msi /
RUN Start-Process msiexec.exe -ArgumentList '/i', 'C:\ProductLaunch-1.1.msi', '/quiet', '/norestart' -NoNewWindow -Wait