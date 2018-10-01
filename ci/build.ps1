param(    
    [string] $version = 'v3'
)

Write-Host "Building version: $version"

docker-compose `
 -f ./ci/docker-compose.yml `
 -f ./ci/docker-compose-local.yml `
 -f ./ci/docker-compose-build.yml `
 -f "./ci/docker-compose-build-$version.yml" `
build