# use configured Elasticsearch URL
if ($env:ELASTICSEARCH_URL -ne $null) {
    $configPath = 'C:\kibana\config\kibana.yml'
    $in = 'elasticsearch.url: "http://elasticsearch:9200"'
    $out = "elasticsearch.url: `"$($env:ELASTICSEARCH_URL)`""
    (Get-Content $configPath) -replace $in, $out | Set-Content $configPath
}

# start Kibana and give it time to spin up
& c:\kibana\bin\kibana.bat
Start-Sleep 10

# create index pattern
Invoke-RestMethod `
 -Method Post `
 -ContentType 'application/json' `
 -Headers @{'kbn-version'='5.6.11'} `
 -Body '{ "title":"prospects", "timeFieldName":"signUpDate" }' `
 -Uri http://172.18.240.93:5601/es_admin/.kibana/index-pattern/prospects/_create

# set as default
Invoke-RestMethod `
 -Method Post `
 -ContentType 'application/json' `
 -Headers @{'kbn-version'='5.6.11'} `
 -Body '{ "value":"prospects" }' `
 -Uri http://172.18.240.93:5601/api/kibana/settings/defaultIndex
