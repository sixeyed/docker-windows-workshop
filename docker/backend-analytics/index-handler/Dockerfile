# escape=`
FROM microsoft/dotnet:2.1-sdk-nanoserver-1809 as builder

WORKDIR C:\src\SignUp.MessageHandlers.IndexProspect
COPY src\SignUp.MessageHandlers.IndexProspect\SignUp.MessageHandlers.IndexProspect.csproj .
RUN dotnet restore

COPY src C:\src
RUN dotnet publish -c Release -o C:\out SignUp.MessageHandlers.IndexProspect.csproj

# app image
FROM microsoft/dotnet:2.1-runtime-nanoserver-1809

WORKDIR /index-prospect-handler
ENTRYPOINT ["dotnet", "SignUp.MessageHandlers.IndexProspect.dll"]

COPY --from=builder C:\out\ .