[CmdletBinding()]
param(
    [string]$branch
)

if ("$branch" -eq "") {
    $branch = $env:BRANCH
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