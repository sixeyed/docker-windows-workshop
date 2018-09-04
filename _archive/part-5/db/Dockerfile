# escape=`
FROM microsoft/mssql-server-windows-express:2016-sp1
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ENV ACCEPT_EULA=Y `
    DATA_PATH="C:\data"

VOLUME ${DATA_PATH}

WORKDIR C:\init
COPY Initialize-Database.ps1 .

CMD ./Initialize-Database.ps1 -sa_password $env:sa_password -data_path $env:data_path  -Verbose