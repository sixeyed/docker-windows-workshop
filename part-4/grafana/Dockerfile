# escape=`
FROM microsoft/windowsservercore:10.0.14393.1770
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN Set-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters' -Name ServerPriorityTimeLimit -Value 0 -Type DWord

EXPOSE 3000
ENV GRAFANA_VERSION="4.4.3"

RUN Invoke-WebRequest "https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-$($env:GRAFANA_VERSION).windows-x64.zip"  -OutFile grafana.zip -UseBasicParsing; `
    Expand-Archive grafana.zip -DestinationPath C:\; `
    Move-Item "grafana-$($env:GRAFANA_VERSION)" grafana; `
    Remove-Item grafana.zip

WORKDIR C:\grafana\bin
CMD ["grafana-server.exe"]