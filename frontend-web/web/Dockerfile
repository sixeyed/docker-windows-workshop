# escape=`
FROM microsoft/dotnet-framework:4.7.2-sdk AS builder

WORKDIR C:\src
COPY signup\src\SignUp.sln .
COPY signup\src\SignUp.Core\SignUp.Core.csproj .\SignUp.Core\
COPY signup\src\SignUp.Entities\SignUp.Entities.csproj .\SignUp.Entities\
COPY signup\src\SignUp.Messaging\SignUp.Messaging.csproj .\SignUp.Messaging\
COPY signup\src\SignUp.Model\SignUp.Model.csproj .\SignUp.Model\
COPY signup\src\SignUp.Web\SignUp.Web.csproj .\SignUp.Web\
COPY signup\src\SignUp.Model\packages.config .\SignUp.Model\
COPY signup\src\SignUp.Web\packages.config .\SignUp.Web\
RUN nuget restore SignUp.sln

COPY signup\src C:\src
RUN msbuild SignUp.Web\SignUp.Web.csproj /p:OutputPath=c:\out /p:Configuration=Release

# app image
FROM microsoft/aspnet:4.7.2-windowsservercore-ltsc2016
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';"]

ENV APP_ROOT=C:\web-app

WORKDIR ${APP_ROOT}
RUN Remove-Website -Name 'Default Web Site';`
    New-Website -Name 'web-app' -Port 80 -PhysicalPath $env:APP_ROOT; `
    New-WebApplication -Name 'app' -Site 'web-app' -PhysicalPath $env:APP_ROOT

COPY --from=builder C:\out\_PublishedWebsites\SignUp.Web .