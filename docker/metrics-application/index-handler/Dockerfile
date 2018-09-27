# escape=`
FROM microsoft/dotnet:2.1-sdk-nanoserver-sac2016 as builder

WORKDIR C:\src\SignUp.MessageHandlers.IndexProspect
COPY src\SignUp.MessageHandlers.IndexProspect\SignUp.MessageHandlers.IndexProspect.csproj .
RUN dotnet restore

COPY src C:\src
RUN dotnet publish -c Release -o C:\out SignUp.MessageHandlers.IndexProspect.csproj

# app image
FROM microsoft/dotnet:2.1-runtime-nanoserver-sac2016

WORKDIR /index-prospect-handler
ENTRYPOINT ["dotnet", "SignUp.MessageHandlers.IndexProspect.dll"]

ENV Metrics:Enabled=true `
    Metrics:Port=50505
    
COPY --from=builder C:\out\ .