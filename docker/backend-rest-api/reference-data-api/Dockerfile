# escape=`
FROM microsoft/dotnet:2.1-sdk-nanoserver-sac2016 as builder

WORKDIR C:\src\SignUp.Api.ReferenceData
COPY src\SignUp.Api.ReferenceData\SignUp.Api.ReferenceData.csproj .
RUN dotnet restore

COPY src C:\src
RUN dotnet publish -c Release -o C:\out SignUp.Api.ReferenceData.csproj

# app image
FROM microsoft/dotnet:2.1-aspnetcore-runtime-nanoserver-sac2016

WORKDIR /reference-data-api
ENTRYPOINT ["dotnet", "SignUp.Api.ReferenceData.dll"]

COPY --from=builder C:\out\ .