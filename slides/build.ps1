[CmdletBinding()]
param(
    [string]$branch
)

if ("$branch" -eq "") {
    $branch = $(git status -b --porcelain).Split("`n")[0].Substring(3)
}

Write-Output "Building branch: $branch"
$rawUrl = "https://raw.githubusercontent.com/sixeyed/docker-windows-workshop/$branch/"
$repoUrl = "https://github.com/sixeyed/docker-windows-workshop/blob/$branch/"

$markdownList = Get-Content ".\contents\$branch.txt"
$html = ""
foreach ($markdownFile in $markdownList){
    Write-Output "Adding content from: $markdownFile"
    $markdown = Get-Content ".\sections\$markdownFile"
    $markdown.Replace('](/', "]($rawUrl").Replace('](./', "]($repoUrl") | Out-File ".\sections\$markdownFile" -Encoding UTF8
    $section = "<section data-markdown=`"sections/$markdownFile`"></section>`n"
    $html += $section    
}

$(Get-Content template.html).Replace('${content}', $html) | Out-File .\index.html -Encoding UTF8

docker image build -t "dwwx/slides:$branch" .
docker container rm -f dwwx-slides

# sleep so HNS releases the port
Start-Sleep -Seconds 3
docker container run -d -p 8099:80 --name dwwx-slides "dwwx/slides:$branch"

$ip = docker container inspect `
  --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' dwwx-slides

firefox "http://$ip"