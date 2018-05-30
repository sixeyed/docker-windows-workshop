
# TODO - parameterize GH base link
$baseUrl = 'https://raw.githubusercontent.com/sixeyed/docker-windows-workshop/master/'

$content = Get-Content ..\part-*.md -Raw
#$content = Get-Content ..\part-1.md -Raw

$content = $content.Replace('](/', "]($baseUrl")
#$content = $content.Replace('{_x}', '<i class="fas fa-keyboard"></i>')
#$content = $content.Replace('{_i}', '<i class="fas fa-info-circle"></i>')
$(Get-Content template.html).Replace('${content}', $content) | Out-File .\index.html

docker image build -t dwwx .