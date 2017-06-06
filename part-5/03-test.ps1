Write-Output '*** E2E tests'

cd  source\ch10\ch10-newsletter

$config = '--host', 'tcp://192.168.160.1:2376', '--tlsverify', `
          '--tlscacert', $env:DOCKER_CA,'--tlscert', $env:DOCKER_CERT, '--tlskey', $env:DOCKER_KEY

& docker $config build -t dockeronwindows/ch10-newsletter-e2e-tests -f docker\e2e-tests\Dockerfile .

& docker $config run --env-file app\db-credentials.env dockeronwindows/ch10-newsletter-e2e-tests

& docker-compose $config -f .\app\docker-compose.yml -f .\app\docker-compose.local.yml down