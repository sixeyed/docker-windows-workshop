Write-Output '*** App Build: '

cd part-5

$gatewayAddress = Get-NetRoute -DestinationPrefix '0.0.0.0/0' | Select NextHop

$config = '--host', "tcp://$($gatewayAddress):2376", '--tlsverify', `
          '--tlscacert', $env:DOCKER_CA,'--tlscert', $env:DOCKER_CERT, '--tlskey', $env:DOCKER_KEY

& docker-compose $config `
 -f .\app\docker-compose.yml -f .\app\docker-compose.build.yml build