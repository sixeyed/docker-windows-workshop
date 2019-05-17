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

# Dependency check utility
FROM mcr.microsoft.com/dotnet/framework/sdk:4.7.2-20190312-windowsservercore-ltsc2019 AS dependency-check-builder

WORKDIR C:\src
COPY src\Utilities.sln .
COPY src\Utilities.DependencyCheck\Utilities.DependencyCheck.csproj .\Utilities.DependencyCheck\
COPY src\Utilities.DependencyCheck\packages.config .\Utilities.DependencyCheck\
RUN nuget restore Utilities.sln

COPY src\Utilities.DependencyCheck C:\src\Utilities.DependencyCheck
RUN msbuild Utilities.DependencyCheck\Utilities.DependencyCheck.csproj /p:OutputPath=c:\out /p:Configuration=Release

# app image
FROM mcr.microsoft.com/dotnet/framework/aspnet:4.7.2-windowsservercore-ltsc2019
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';"]

ENV APP_ROOT=C:\web-app `
    APP_LOGS=C:\logs `
    COLLECTOR_CONFIG_PATH="w3svc-collectors.json" `
    LOG4NET_CONFIG_PATH="" `
    CONNECTIONSTRINGS_CONFIG_PATH="" `
    DEPENDENCY_CHECK_ENABLED=""

WORKDIR ${APP_ROOT}
RUN Import-Module WebAdministration; `
    Set-ItemProperty 'IIS:\AppPools\DefaultAppPool' -Name processModel.identityType -Value LocalSystem; `
    New-WebApplication -Name 'app' -Site 'Default Web Site' -PhysicalPath $env:APP_ROOT

WORKDIR C:\aspnet-exporter
COPY --from=dockersamples/aspnet-monitoring-exporter:4.7.2-windowsservercore-ltsc2019 C:\aspnet-exporter .

VOLUME ${APP_LOGS}
COPY .\docker\prod-dependencies\signup-web\startup.ps1 /
ENTRYPOINT ["powershell", "/startup.ps1"]

COPY --from=dependency-check-builder C:\out ${APP_ROOT}
COPY --from=builder C:\out\_PublishedWebsites\SignUp.Web ${APP_ROOT}