
jenkins config:

- install git & powershell plugins

- add bonobo & engine creds

SCM

- use host IP

http://192.168.2.160/Bonobo.Git.Server/presentations.git

poll H/5 * * * *

Bindings

- use secret files: DOCKER_CA, DOCKER_CERT, DOCKER_KEY

```
Write-Output '*** App Build: '

cd  source\ch10\ch10-newsletter

$config = '--host', 'tcp://192.168.160.1:2376', '--tlsverify', `
          '--tlscacert', $env:DOCKER_CA,'--tlscert', $env:DOCKER_CERT, '--tlskey', $env:DOCKER_KEY

& docker-compose $config `
 -f .\app\docker-compose.yml -f .\app\docker-compose.build.yml build
```


```
Write-Output '*** Start App: '

cd  source\ch10\ch10-newsletter

$config = '--host', 'tcp://192.168.160.1:2376', '--tlsverify', `
          '--tlscacert', $env:DOCKER_CA,'--tlscert', $env:DOCKER_CERT, '--tlskey', $env:DOCKER_KEY

& docker-compose $config `
 -f .\app\docker-compose.yml -f .\app\docker-compose.local.yml up -d

Write-Output '*** Containers: '

& docker $config container ls

Write-Output '*** Sleeping'

Start-Sleep -Seconds 20

$ip = & docker $config inspect --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' app_signup-app_1

Write-Output '*** Checking website'

iwr -UseBasicParsing "http://$ip/SignUp"
```

```
Write-Output '*** E2E tests'

cd  source\ch10\ch10-newsletter

$config = '--host', 'tcp://192.168.160.1:2376', '--tlsverify', `
          '--tlscacert', $env:DOCKER_CA,'--tlscert', $env:DOCKER_CERT, '--tlskey', $env:DOCKER_KEY

& docker $config build -t dockeronwindows/ch10-newsletter-e2e-tests -f docker\e2e-tests\Dockerfile .

& docker $config run --env-file app\db-credentials.env dockeronwindows/ch10-newsletter-e2e-tests

& docker-compose $config -f .\app\docker-compose.yml -f .\app\docker-compose.local.yml down
```

```
Write-Output '*** Tagging and pushing images'

$config = '--host', 'tcp://192.168.160.1:2376', '--tlsverify', `
          '--tlscacert', $env:DOCKER_CA,'--tlscert', $env:DOCKER_CERT, '--tlskey', $env:DOCKER_KEY

& docker $config `
 tag dockeronwindows/ch10-newsletter-web "registry.sixeyed:5000/dockeronwindows/ch10-newsletter-web:$($env:BUILD_TAG)"

& docker $config `
 push "registry.sixeyed:5000/dockeronwindows/ch10-newsletter-web:$($env:BUILD_TAG)"

& docker $config `
 tag dockeronwindows/ch10-newsletter-save-handler "registry.sixeyed:5000/dockeronwindows/ch10-newsletter-save-handler:$($env:BUILD_TAG)"

& docker $config `
 push "registry.sixeyed:5000/dockeronwindows/ch10-newsletter-save-handler:$($env:BUILD_TAG)"

& docker $config `
 tag dockeronwindows/ch10-newsletter-index-handler registry.sixeyed:5000/dockeronwindows/ch10-newsletter-index-handler:$env:BUILD_TAG

& docker $config `
 push "registry.sixeyed:5000/dockeronwindows/ch10-newsletter-index-handler:$($env:BUILD_TAG)"
 ```

 [registry.sixeyed -> container IP on host]