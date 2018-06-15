[CmdletBinding()]
param(
    [Parameter(Mandatory=$True)]
    [string]$branch
)

Write-Output "Building branch: $branch"
$rawUrl = "https://raw.githubusercontent.com/sixeyed/docker-windows-workshop/$branch/"
$repoUrl = "https://github.com/sixeyed/docker-windows-workshop/blob/$branch/"

$contentList = Get-Content ".\contents\$branch.txt"
$content = ""
foreach ($contentFile in $contentList){
    Write-Output "Adding content from: $contentFile"
    $section = "<section data-markdown=`"sections/$contentFile`"></section>`n"
    #$section += "`n---`n"
    #$section = $section.Replace('---', ".footnote[Source: [$contentFile](./$contentFile)] `n---")
    $content += $section    
}

$content = $content.Replace('](/', "]($rawUrl")
$content = $content.Replace('](./', "]($repoUrl")

$(Get-Content template.html).Replace('${content}', $content) | Out-File .\index.html

#docker image build -t "dwwx/slides:$branch" .

#docker container rm -f dwwx-slides

# sleep so HNS releases the port
#Start-Sleep -Seconds 3

#docker container run -d -p 8099:80 --name dwwx-slides "dwwx/slides:$branch"