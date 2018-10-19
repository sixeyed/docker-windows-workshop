# escape=`
FROM microsoft/dotnet:2.1-sdk-nanoserver-sac2016 as builder

WORKDIR C:\src\SignUp.MessageHandlers.ReferenceData
COPY src\SignUp.MessageHandlers.ReferenceData\SignUp.MessageHandlers.ReferenceData.csproj .
RUN dotnet restore

COPY src C:\src
RUN dotnet publish -c Release -o C:\out SignUp.MessageHandlers.ReferenceData.csproj

# app image
FROM microsoft/dotnet:2.1-runtime-nanoserver-sac2016

WORKDIR /reference-data-handler
ENTRYPOINT ["dotnet", "SignUp.MessageHandlers.ReferenceData.dll"]

COPY --from=builder C:\out\ .