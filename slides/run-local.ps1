[CmdletBinding()]
param(
    [string]$branch
)

if ("$branch" -eq "") {
    $branch = $(git status -b --porcelain).Split("`n")[0].Substring(3)
}

docker image build `
 --build-arg BRANCH=$branch `
 -t "dwwx/slides:$branch" `
 -f ./docker/windows/Dockerfile .
 
docker container rm -f dwwx-slides
docker container run -d --name dwwx-slides "dwwx/slides:$branch"

$ip = docker container inspect `
  --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' dwwx-slides

firefox "http://$ip"