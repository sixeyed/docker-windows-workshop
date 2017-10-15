
# update tools
choco upgrade -y visualstudiocode
choco upgrade -y firefox

# add shortcuts
$shell = new-object -com "Shell.Application"

$folder = $shell.Namespace('C:\Program Files\Mozilla Firefox')    
$item = $folder.Parsename('firefox.exe')
$verb = $item.Verbs() | ? {$_.Name -eq 'Pin to Tas&kbar'}
if ($verb) {$verb.DoIt()}

$folder = $shell.Namespace('C:\Windows\System32\WindowsPowerShell\v1.0')
$item = $folder.Parsename('powershell.exe')
$verb = $item.Verbs() | ? {$_.Name -eq 'Pin to Tas&kbar'}
if ($verb) {$verb.DoIt()}

$folder = $shell.Namespace('C:\Program Files\Microsoft VS Code')
$item = $folder.Parsename('Code.exe')
$verb = $item.Verbs() | ? {$_.Name -eq 'Pin to Tas&kbar'}
if ($verb) {$verb.DoIt()}

