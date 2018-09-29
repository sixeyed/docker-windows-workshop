#!/bin/bash
echo "Building branch: $BRANCH"

repoUrl="https://github.com/sixeyed/docker-windows-workshop/blob/$BRANCH/"

markdownList=$(<"./contents/$BRANCH.txt")
html=""
for markdownFile in $markdownList
do
    if [ ${markdownFile:0:1} != '#']; then
        echo "Adding content from: $markdownFile"    
        sed -i '' -e "s#](./#]($repoUrl#g" "./sections/$markdownFile"
        section="<section data-markdown="\""sections/$markdownFile"\""></section>"
        html=$html$section
    fi
done

placeholder='${content}'
sed -e "s#$placeholder#$html#g" template.html > index.html