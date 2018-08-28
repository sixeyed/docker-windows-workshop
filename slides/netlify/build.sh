#!/bin/bash
echo "Building branch: $BRANCH"

rawUrl="https://raw.githubusercontent.com/sixeyed/docker-windows-workshop/$BRANCH/"
repoUrl="https://github.com/sixeyed/docker-windows-workshop/blob/$BRANCH/"

markdownList=$(<"./contents/$BRANCH.txt")
html=""
for markdownFile in $markdownList
do
    echo "Adding content from: $markdownFile"    
    sed -i -e "s#](/#]($rawUrl#g" $markdownFile
    section="<section data-markdown="\""sections/$markdownFile"\""></section>\n"
    html=$html$section    
done

#$(Get-Content template.html).Replace('${content}', $html) | Out-File .\index.html -Encoding UTF8