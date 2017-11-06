# escape=`
FROM sixeyed/msbuild:netfx-4.5.2 AS builder

WORKDIR C:\src\SignUp.MessageHandlers.IndexProspect
COPY signup\src\SignUp.MessageHandlers.IndexProspect\packages.config .
RUN nuget restore packages.config -PackagesDirectory ..\packages

COPY signup\src C:\src
RUN msbuild SignUp.MessageHandlers.IndexProspect.csproj /p:OutputPath=c:\out\index-prospect\IndexProspectHandler

# app image
FROM microsoft/windowsservercore:10.0.14393.1770
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

WORKDIR /index-prospect-handler
CMD .\SignUp.MessageHandlers.IndexProspect.exe

ENV MESSAGE_QUEUE_URL="nats://message-queue:4222" `
    ELASTICSEARCH_URL="http://elasticsearch:9200"

COPY --from=builder C:\out\index-prospect\IndexProspectHandler .