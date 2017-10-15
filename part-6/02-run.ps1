Write-Output '*** Start App: '

cd part-6

$gatewayAddress = (Get-NetRoute -DestinationPrefix '0.0.0.0/0').NextHop

$config = '--host', "tcp://$($gatewayAddress):2376", '--tlsverify', `
          '--tlscacert', $env:DOCKER_CA,'--tlscert', $env:DOCKER_CERT, '--tlskey', $env:DOCKER_KEY

& docker-compose $config `
 -f .\app\docker-compose.yml -f .\app\docker-compose.local.yml up -d

Write-Output '*** Containers: '

& docker $config container ls

Write-Output '*** Sleeping'

Start-Sleep -Seconds 20

$ip = & docker $config inspect --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' app_signup-web_1

Write-Output '*** Checking website'

iwr -UseBasicParsing "http://$ip"