Write-Output '*** Sleeping'
Start-Sleep -Seconds 20

Write-Output '*** Checking website'
$ip = docker inspect --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' ci_signup-web_1
iwr -UseBasicParsing "http://$ip/app"

Write-Host "End-to-end tests running..."
docker container run dwwx/e2e-tests:nsb

Write-Host "Tidying up..."
docker-compose `
 -f ./ci/docker-compose.yml `
 -f ./ci/docker-compose-ci.yml `
down

rm -fo -re $env:TEST_STATE