# escape=`
FROM microsoft/windowsservercore:ltsc2016 AS build
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ARG BRANCH="master"

WORKDIR /slides
COPY . .
RUN Write-Host "Running build script for branch: $env:BRANCH"; `
    ./docker/local/build.ps1

FROM sixeyed/nginx
COPY --from=build /slides /nginx/html