# escape=`
FROM mcr.microsoft.com/dotnet/framework/sdk:4.7.2-20190312-windowsservercore-ltsc2019 AS builder

WORKDIR C:\src
COPY src\SignUp.sln .
COPY src\SignUp.Core\SignUp.Core.csproj .\SignUp.Core\
COPY src\SignUp.Entities\SignUp.Entities.csproj .\SignUp.Entities\
COPY src\SignUp.Messaging\SignUp.Messaging.csproj .\SignUp.Messaging\
COPY src\SignUp.Model\SignUp.Model.csproj .\SignUp.Model\
COPY src\SignUp.Web\SignUp.Web.csproj .\SignUp.Web\
COPY src\SignUp.Model\packages.config .\SignUp.Model\
COPY src\SignUp.Web\packages.config .\SignUp.Web\
RUN nuget restore SignUp.sln

COPY src C:\src
RUN msbuild SignUp.Web\SignUp.Web.csproj /p:OutputPath=c:\out /p:Configuration=Release

# app image
FROM mcr.microsoft.com/dotnet/framework/aspnet:4.7.2-windowsservercore-ltsc2019
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';"]

ENV APP_ROOT=C:\web-app

EXPOSE 80 50505
WORKDIR ${APP_ROOT}
RUN New-WebApplication -Name 'app' -Site 'Default Web Site' -PhysicalPath $env:APP_ROOT

ENTRYPOINT ["powershell"]
CMD mkdir C:\logs; echo '--init' > C:\logs\SignUp.log; `
    Invoke-WebRequest http://localhost/app -UseBasicParsing | Out-Null; `
    Start-Process -NoNewWindow C:\aspnet-exporter\aspnet-exporter.exe; `
    Get-Content -Path "C:\logs\SignUp.log" -Tail 1 -Wait 

WORKDIR C:\aspnet-exporter
COPY --from=dockersamples/aspnet-monitoring-exporter:4.7.2-windowsservercore-ltsc2019 C:\aspnet-exporter .
ENV COLLECTOR_CONFIG_PATH="w3svc-collectors.json"

COPY --from=builder C:\out\_PublishedWebsites\SignUp.Web ${APP_ROOT}