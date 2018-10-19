Write-Output 'Pushing images...'
docker-compose `
 -f ./ci/docker-compose.yml `
 -f ./ci/docker-compose-ci.yml `
push --ignore-push-failures