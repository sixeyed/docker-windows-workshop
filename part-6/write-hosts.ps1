
$ip = docker container inspect --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' jenkins
Add-Content -Path 'C:\Windows\System32\drivers\etc\hosts' "$ip jenkins.local"

$ip = docker container inspect --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' bonobo
Add-Content -Path 'C:\Windows\System32\drivers\etc\hosts' "$ip bonobo.local"

$ip = docker container inspect --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' registry
Add-Content -Path 'C:\Windows\System32\drivers\etc\hosts' "$ip registry.local"