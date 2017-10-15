Write-Output '*** E2E tests'

$gatewayAddress = (Get-NetRoute -DestinationPrefix '0.0.0.0/0').NextHop

$config = '--host', "tcp://$($gatewayAddress):2376", '--tlsverify', `
          '--tlscacert', $env:DOCKER_CA,'--tlscert', $env:DOCKER_CERT, '--tlskey', $env:DOCKER_KEY

& docker $config image build -t $env:dockerId/signup-e2e-tests -f part-6\e2e-tests\Dockerfile .

& docker $config container run --env-file .\part-6\app\db-credentials.env $env:dockerId/signup-e2e-tests

& docker-compose $config -f .\app\docker-compose.yml -f .\app\docker-compose.local.yml down