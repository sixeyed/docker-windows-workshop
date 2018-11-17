Write-Output 'STARTUP: Starting IIS with ServiceMonitor'
Start-Process -NoNewWindow -FilePath C:\ServiceMonitor.exe -ArgumentList w3svc; `

Write-Output 'STARTUP: Running metrics exporter'
Invoke-WebRequest http://localhost/app -UseBasicParsing | Out-Null
Start-Process -NoNewWindow C:\aspnet-exporter\aspnet-exporter.exe

Write-Output 'STARTUP: Tailing log'
Get-Content -Path "$env:APP_LOGS\SignUp.log" -Tail 1 -Wait