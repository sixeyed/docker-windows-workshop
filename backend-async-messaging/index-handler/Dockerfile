# escape=`
FROM microsoft/dotnet:2.0-sdk-nanoserver-sac2016 as builder

WORKDIR C:\src\SignUp.MessageHandler.IndexProspect
COPY signup\src\SignUp.MessageHandler.IndexProspect\SignUp.MessageHandler.IndexProspect.csproj .
RUN dotnet restore

COPY signup\src C:\src
RUN dotnet publish -c Release -o C:\out SignUp.MessageHandler.IndexProspect.csproj

# app image
FROM microsoft/dotnet:2.0-runtime-nanoserver-sac2016

WORKDIR /index-prospect-handler
ENTRYPOINT ["dotnet", "SignUp.MessageHandler.IndexProspect.dll"]

COPY --from=builder C:\out\ .