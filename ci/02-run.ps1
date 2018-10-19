Write-Host "Creating temp dir for NSB state..."
$env:TEST_STATE = Join-Path -Path C:\ -ChildPath $([System.Guid]::NewGuid().ToString().Substring(0,6))
New-Item -ItemType Directory -Path $env:TEST_STATE

Write-Host "Running..."
docker-compose `
 -f ./ci/docker-compose.yml `
 -f ./ci/docker-compose-ci.yml `
up -d

Write-Output '*** Containers: '
docker container ls
