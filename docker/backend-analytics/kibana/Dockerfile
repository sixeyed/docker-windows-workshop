#escape=`
FROM sixeyed/kibana:5.6.11-windowsservercore-ltsc2016
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';"]

COPY  .\docker\backend-analytics\kibana\init.ps1 .

ENTRYPOINT ["powershell"]
CMD ["./init.ps1"]