# Part 5 - The Outer Loop - containerized CI



## Steps

* [1. Configure Docker for remote access](#1)
* [2. Prepare Jenkins](#2)
* [3. Run infrastructure services](#3)
* [4. Configure CI job](#4)


## <a name="1"></a>Step 1. Configure Docker for remote access

- get IP addresses:

```
ipconfig 

$ipAddress='10.211.55.3'
$gatewayAddress='172.24.0.1'
```
> change owner of daemon.json to admin & grant access to everyone (temp)

enable TLS:

```
mkdir -p C:\certs\vm\client

docker container run --rm `
 -e SERVER_NAME=$(hostname) `
 -e IP_ADDRESSES=127.0.0.1,$ipAddress,$gatewayAddress `
 -v 'C:\ProgramData\docker:C:\ProgramData\docker' `
 -v 'C:\certs\vm\client:C:\Users\ContainerAdministrator\.docker' `
 stefanscherer/dockertls-windows
```

clear down containers!!!

quit docker & launch again


## <a name="2"></a>Step 2. Prepare Jenkins

```
cd $env:workshopRoot\part-5\jenkins

docker image build --tag $env:dockerId/jenkins:prep .
```

start:

```
mkdir C:\jenkins

docker run -d -P -v C:\jenkins:C:\data --name jenkins $env:dockerId/jenkins:prep
```

```
$ip = docker container inspect --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' jenkins

start "http://$($ip):8080"
```



jenkins config:

- install git & powershell plugins

- add bonobo & engine creds

SCM

- use host IP

http://192.168.2.160/Bonobo.Git.Server/presentations.git

poll H/5 * * * *

Bindings

- use secret files: DOCKER_CA, DOCKER_CERT, DOCKER_KEY

```

```


```

```

```

```

```

 ```

 [registry.sixeyed -> container IP on host]