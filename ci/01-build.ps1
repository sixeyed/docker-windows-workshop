Write-Host "Building..."

docker-compose `
 -f ./ci/docker-compose.yml `
 -f ./ci/docker-compose-ci.yml `
 -f ./ci/docker-compose-build.yml `
build