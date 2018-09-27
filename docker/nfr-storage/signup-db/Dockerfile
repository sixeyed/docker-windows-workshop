# escape=`
FROM microsoft/mssql-server-windows-express:2016-sp1
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ENV ACCEPT_EULA="Y" `
    DATA_PATH="C:\data" `
    sa_password="DockerCon!!!"

VOLUME ${DATA_PATH}

WORKDIR C:\init
COPY .\docker\nfr-storage\signup-db\Initialize-Database.ps1 .
ENTRYPOINT ["powershell", "./Initialize-Database.ps1"]