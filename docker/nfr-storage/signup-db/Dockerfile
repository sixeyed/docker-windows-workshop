# escape=`
FROM dwwx/sql-server:2017

ENV DATA_PATH="C:\data" `
    sa_password="DockerCon!!!"

VOLUME ${DATA_PATH}

WORKDIR C:\init
COPY .\docker\nfr-storage\signup-db\Initialize-Database.ps1 .
ENTRYPOINT ["powershell", "./Initialize-Database.ps1"]