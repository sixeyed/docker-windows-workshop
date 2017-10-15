
$ipFormat ='{{ .NetworkSettings.Networks.nat.IPAddress }}'
$hosts = 'C:\Windows\System32\drivers\etc\hosts'

$ip = docker container inspect --format $ipFormat infrastructure_jenkins_1
Add-Content -Path $hosts "$ip jenkins.local"

$ip = docker container inspect --format $ipFormat infrastructure_bonobo_1
Add-Content -Path $hosts "$ip bonobo.local"

$ip = docker container inspect --format $ipFormat infrastructure_registry_1
Add-Content -Path $hosts "$ip registry.local"

Get-Content -Path $hosts