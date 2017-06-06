# Part 5 - The Outer Loop - Containerized CI with Docker



## Steps

* [1. Configure Docker for remote access](#1)
* [2. Prepare Jenkins](#2)
* [3. Run infrastructure services](#3)
* [4. Configure CI job](#4)


## <a name="1"></a>Step 1. Configure Docker for remote access

- get IP addresses:

```
ipconfig 

$ipAddress='10.0.0.4'
$gatewayAddress='172.19.240.1'
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

docker container run -d -P -v C:\jenkins:C:\data --name jenkins $env:dockerId/jenkins:prep
```

```
$ip = docker container inspect --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' jenkins

start "http://$($ip):8080"
```

get the password:

```
docker container logs jenkins
```

install

- select plugins to install
- none
- git plugin, Credentials Binding Plugin
- manage jenkins/manage plugins
- available
- powershell
- install without restart

Export:

```
docker container stop jenkins

docker container commit jenkins $env:dockerId/jenkins:configured

docker container rm jenkins
```

## <a name="3"></a>Step 3. Run infrastructure services

## 3.1 - start infra services

```
mkdir C:\registry

mkdir C:\bonobo

cd $env:workshopRoot\part-5\infrastructure

docker-compose up -d
```

host config `notepad C:\Windows\System32\drivers\etc\hosts`

```
172.19.240.200 registry.local
172.19.240.201 bonobo.local
172.19.240.202 jenkins.local
```

##3.2 - setup git server

bonobo:  http://bonobo.local/bonobo.git.server

admin/admin

create user jenkins-ci/jenkins

create repo docker-windows-workshop, jenkins-ci as contrib

```
cd $env:workshopRoot

git remote add bonobo.local http://bonobo.local/Bonobo.Git.Server/docker-windows-workshop.git

git push bonobo.local master
```

explore C:\bonobo

## 3.3 - configure jenkins job


http://jenkins.local:8080

credentials, global, add crddentials:

- username password, jenkins-bonobo
- secret file, ca, cert, key

manage - config - global props

- env, dockerId=<docekerId>

create job

- freestyle, signup

SCM

- repo url, http://bonobo/Bonobo.Git.Server/docker-windows-workshop.git

Bindings

- use secret files: DOCKER_CA, DOCKER_CERT, DOCKER_KEY


Build steps - PowerShell

```
.\part-5\01-build.ps1
```

```
.\part-5\02-run.ps1
```

```
.\part-5\03-test.ps1
```

```
.\part-5\04-push.ps1
```