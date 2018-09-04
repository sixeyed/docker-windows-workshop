param(
    [Parameter(Mandatory=$true)]
    [string]$entryList,

    [Parameter()]
    [string]$separator
)

if ("$separator" -eq ""){
    $separator = ','
}
$entries = $entryList.Split($separator)
$random = New-object -Type System.Random -ArgumentList (Get-Date).millisecond
$winner = $entries[$random.Next($entries.count)]

Write-Output 'The winner is...'
Start-Sleep -Seconds 1
Write-Output '----------------'
Start-Sleep -Seconds 2
Write-Output '------------'
Start-Sleep -Seconds 1
Write-Output '-----'
Start-Sleep -Seconds 1
Write-Output "$winner!`n"