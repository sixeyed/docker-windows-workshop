param(    
    [int] $from = 1,
    [int] $to = 7
)

for ($i=$from; $i -le $to; $i++) {
    Write-Host "*** Building version: $i"

    docker-compose `
    -f ./ci/docker-compose.yml `
    -f ./ci/docker-compose-local.yml `
    -f ./ci/docker-compose-build.yml `
    -f "./ci/docker-compose-build-v$i.yml" `
    build
}