# escape=`
FROM microsoft/dotnet:2.1-sdk-nanoserver-1809 as builder

WORKDIR C:\src\SignUp.Api.ReferenceData
COPY src\SignUp.Api.ReferenceData\SignUp.Api.ReferenceData.csproj .
RUN dotnet restore

COPY src C:\src
RUN dotnet publish -c Release -o C:\out SignUp.Api.ReferenceData.csproj

# app image
FROM  microsoft/dotnet:2.1-aspnetcore-runtime-nanoserver-1809

EXPOSE 80
WORKDIR /reference-data-api
ENTRYPOINT ["dotnet", "SignUp.Api.ReferenceData.dll"]

COPY --from=builder C:\out\ .