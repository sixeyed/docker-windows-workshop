Write-Host "Tidying up..."
docker-compose `
 -f ./ci/docker-compose.yml `
 -f ./ci/docker-compose-ci.yml `
down

rm -fo -re $env:TEST_STATE