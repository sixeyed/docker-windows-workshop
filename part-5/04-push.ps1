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