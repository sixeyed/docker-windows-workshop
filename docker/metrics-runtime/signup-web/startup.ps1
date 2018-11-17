Write-Output 'STARTUP: Starting IIS'
Start-Service w3svc

Write-Output 'STARTUP: Running metrics exporter'
Invoke-WebRequest http://localhost/app -UseBasicParsing | Out-Null
Start-Process -NoNewWindow C:\aspnet-exporter\aspnet-exporter.exe

Write-Output 'STARTUP: Running ServiceMonitor'
& C:\ServiceMonitor.exe w3svc