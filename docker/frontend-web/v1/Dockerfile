# escape=`
FROM microsoft/dotnet-framework:4.7.2-sdk AS builder

WORKDIR C:\src
COPY src .
RUN nuget restore SignUp.sln; `
    msbuild SignUp.Web\SignUp.Web.csproj /p:OutputPath=c:\out /p:Configuration=Release

# app image
FROM microsoft/aspnet:4.7.2-windowsservercore-ltsc2016
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';"]

WORKDIR C:\web-app
RUN New-WebApplication -Name 'app' -Site 'Default Web Site' -PhysicalPath C:\web-app

COPY --from=builder C:\out\_PublishedWebsites\SignUp.Web .