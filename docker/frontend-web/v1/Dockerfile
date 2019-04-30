# escape=`
FROM mcr.microsoft.com/dotnet/framework/sdk:4.7.2-20190312-windowsservercore-ltsc2019 AS builder

WORKDIR C:\src
COPY src .
RUN .\build-web.bat

# app image
FROM mcr.microsoft.com/dotnet/framework/aspnet:4.7.2-windowsservercore-ltsc2019
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';"]

WORKDIR C:\web-app
RUN New-WebApplication -Name 'app' -Site 'Default Web Site' -PhysicalPath C:\web-app

COPY --from=builder C:\out\_PublishedWebsites\SignUp.Web .