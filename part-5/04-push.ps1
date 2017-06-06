Write-Output '*** Tagging and pushing images'

$gatewayAddress = (Get-NetRoute -DestinationPrefix '0.0.0.0/0').NextHop

$config = '--host', "tcp://$($gatewayAddress):2376", '--tlsverify', `
          '--tlscacert', $env:DOCKER_CA,'--tlscert', $env:DOCKER_CERT, '--tlskey', $env:DOCKER_KEY

$repositories = 'signup-db', 'signup-web', 'signup-save-handler', 'signup-index-handler'

foreach ($repository in $repositories) {

    $sourceTag = "$($env:dockerId)/$($repository)"
    $targetTag = "registry.local:5000/$($env:dockerId)/$($repository):$($env:BUILD_TAG)"

    & docker $config tag $sourceTag $targetTag

    & docker $config push $targetTag
}