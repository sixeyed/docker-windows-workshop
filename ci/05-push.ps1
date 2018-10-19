$images = 
'dwwx/signup-web:nsb',
'dwwx/save-handler:nsb',
'dwwx/index-handler:nsb',
'dwwx/reference-data-handler:nsb'

$images | foreach { docker image push $_ }