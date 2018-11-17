function RedirectConfigFile {
    param([string] $sourcePath, [string] $targetPath)

    if ($sourcePath -And (Test-Path $sourcePath)) {
    
        Remove-Item -Force -Path $targetPath
            
        New-Item -Path $targetPath `
                -ItemType SymbolicLink `
                -Value $sourcePath

        Write-Output "STARTUP: Redirected $targetPath config to read from $sourcePath"
    }
}

Write-Output 'STARTUP: Loading config files'
RedirectConfigFile $env:CONNECTIONSTRINGS_CONFIG_PATH "$env:APP_ROOT\connectionStrings.config"

Write-Output 'STARTUP: Running app'
.\SignUp.MessageHandlers.SaveProspect.exe