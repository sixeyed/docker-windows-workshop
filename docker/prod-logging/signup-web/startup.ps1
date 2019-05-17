Write-Output 'STARTUP: Starting IIS with HTTP GET'
mkdir $env:APP_LOGS; echo '--init' > "$env:APP_LOGS\SignUp.log"
Invoke-WebRequest http://localhost/app -UseBasicParsing | Out-Null

Write-Output 'STARTUP: Running metrics exporter'
Start-Process -NoNewWindow C:\aspnet-exporter\aspnet-exporter.exe

Write-Output 'STARTUP: Tailing log'
Get-Content -Path "$env:APP_LOGS\SignUp.log" -Tail 1 -Wait