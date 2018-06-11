# escape=`
FROM microsoft/dotnet-framework-build:4.7.1-windowsservercore-ltsc2016 AS builder

WORKDIR C:\src\SignUp.MessageHandlers.SaveProspect
COPY signup\src\SignUp.MessageHandlers.SaveProspect\packages.config .
RUN nuget restore packages.config -PackagesDirectory ..\packages

COPY signup\src C:\src
RUN msbuild SignUp.MessageHandlers.SaveProspect.csproj /p:OutputPath=c:\out\save-prospect\SaveProspectHandler

# app image
FROM microsoft/windowsservercore:ltsc2016
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

WORKDIR /save-prospect-handler
CMD .\SignUp.MessageHandlers.SaveProspect.exe

ENV MESSAGE_QUEUE_URL="nats://message-queue:4222"

COPY --from=builder C:\out\save-prospect\SaveProspectHandler .