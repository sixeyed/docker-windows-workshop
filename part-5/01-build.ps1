Write-Output '*** App Build: '

cd source\ch10\ch10-newsletter

$config = '--host', 'tcp://192.168.160.1:2376', '--tlsverify', `
          '--tlscacert', $env:DOCKER_CA,'--tlscert', $env:DOCKER_CERT, '--tlskey', $env:DOCKER_KEY

& docker-compose $config `
 -f .\app\docker-compose.yml -f .\app\docker-compose.build.yml build