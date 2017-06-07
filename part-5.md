# Part 5 - Containerized CI (and CD) with Docker

It's very simple to configure a full CI system using Docker - where the source control, automation server and build agents all run in containers. The multi-stage Dockerfiles for the SignUp app mean you only need Docker installed to compile, package, run and test the app. 

## Steps

* [1. Configure Docker for remote access](#1)
* [2. Prepare Jenkins](#2)
* [3. Run infrastructure services](#3)
* [4. Configure CI job](#4)


## <a name="1"></a>Step 1. Configure Docker for remote access

Docker comes in two parts - the `docker` command line talks to the Docker engine, using a REST API. In Windows the engine runs as a Windows Service. You can configure the engine to accept remote connections, so a user on a different machine can run `docker` commands against your server.

We'll set up the Docker engine to allow remote access, but only through a secure channel. First we need two IP addresses:

```
ipconfig
```

On Azure, the server's internal IP address will start with `10.0.0`. There will also be a virtual IP address used as a gateway by Docker containers - it's named _vEthernet (HNS Internal NIC)_ and starts `172`. Save those IP address as variables:

```
$ipAddress='<ip address - 10.0.0.x>'
$gatewayAddress='<gateway address - 172.x.x.x'
```

Now we'll run a task container whichs creates SSL certificates, and modifies the Docker engine configuration to allow remote connections with SSL only:

```
mkdir -p C:\certs\vm\client

docker container run --rm `
 -e SERVER_NAME=$(hostname) `
 -e IP_ADDRESSES=127.0.0.1,$ipAddress,$gatewayAddress `
 -v 'C:\ProgramData\docker:C:\ProgramData\docker' `
 -v 'C:\certs\vm\client:C:\Users\ContainerAdministrator\.docker' `
 stefanscherer/dockertls-windows
```

> This uses the image from [Docker Captain](https://www.docker.com/community/docker-captains) [Stefan Scherer](https://twitter.com/stefscherer), described in [How to protect a Windows 2016 Docker engine with TLS](https://stefanscherer.github.io/protecting-a-windows-2016-docker-engine-with-tls/)

To pick up the new configuration, restart the Docker Windows Service:

```
Restart-Service docker
```

On the local VM you use the `docker` commands in the same way, but on a remote machine (or through another container), you can connect to the Docker engine securely with mutual TLS.


## <a name="2"></a>Step 2. Prepare Jenkins


We'll use the [Jenkins] automation server to run the CI job to build the Docker solution. Jenkins has a basic install process, and then adds functionality with plug-ins.

Start by building a basic Jenkins Docker image, which contains Git and Docker clients, from this [Dockerfile]. That image will be used to prepare the full Jenkins setup:

```
cd $env:workshopRoot\part-5\jenkins

docker image build --tag $env:dockerId/jenkins:prep .
```

Run Jenkins in a container, mapping the data folder in a volume - so all the Jenkins data is stored on the host:

```
mkdir C:\jenkins

docker container run -d -P -v C:\jenkins:C:\data --name jenkins $env:dockerId/jenkins:prep
```

Now get the IP address and browse to it (Jenkins uses port `8080` by default):

```
$ip = docker container inspect --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' jenkins

start "http://$($ip):8080"
```

For each new install, Jenkins generates a random administrator password. You can see the password in the container logs:

```
docker container logs jenkins
```

Back in the Jenkins UI, configure the plugins we'll use:

- Select plugins to install
- Choose 'None'
- Add the `Git` and `Credentials Binding` plugins

> Note there's no build agent here. We don't need the MSBuild plugin because the compilation is all done in Docker.

Once the basic install completes, add one more plugin:

- Manage jenkins/manage plugins
- Choose 'Available'
- Filter on 'PowerShell'
- Select 'Install without restart

That gives us a fully configured Jenkins instance. We can export the container as an image, but we need to stop it first:

```
docker container stop jenkins

docker container commit jenkins $env:dockerId/jenkins:configured

docker container rm jenkins
```

## <a name="3"></a>Step 3. Run infrastructure services

## Start the Infrastructure Services

For our CI setup, we'll need a Git server and a local Docker registry, as well as Jenkins. The [infrastructure Docker Compose file] sets those up, using host mounts for the data volumes.

Start all the containers with compose:

```
mkdir C:\registry

mkdir C:\bonobo

cd $env:workshopRoot\part-5\infrastructure

docker-compose up -d
```

The containers used fixed IP addresses, so we can refer to them using hostnames. You'll see these entries in `notepad C:\Windows\System32\drivers\etc\hosts`:

```
172.19.240.200 registry.local
172.19.240.201 bonobo.local
172.19.240.202 jenkins.local
```

## Setup the Bonobo Git Server

[Bonobo] is an open-source ASP.NET Git server. Browse to the Bonobo app running in the container:

```
start http://bonobo.local/bonobo.git.server
```

Log in with the credentials `admin/admin`, and create a new user. This will be used by the Jenkins service, so the username will be `jenkins-ci`, and the password `jenkins`.

Then create a new repository for the source code - call it `docker-windows-workshop`, and add the `jenkins-ci` user as a contributor.

Now push the local source code on your machine to the Git server running in Docker:

```
cd $env:workshopRoot

git remote add bonobo.local http://bonobo.local/Bonobo.Git.Server/docker-windows-workshop.git

git push bonobo.local master
```

Explore `C:\bonobo` and you'll see the Bonobo database and the repo folders are stored on the host.


## Configure the Jenkins CI job

Browse to Jenkins on http://jenkins.local:8080.

Go to _Credentials/Global_ and click  Add Credential. You need to set up four new credentials:

1. a `Username with password` credential for Bonobo, username `jenkins-ci`, password `jenkins`
2. a `Secret file` credential for the generated CA certificate - upload `C:\certs\vm\client\ca.pem` and call it `docker-ca`
3. a `Secret file` credential for the generated certificate - upload `C:\certs\vm\client\cert.pem` and call it `docker-cert`
4. a `Secret file` credential for the generated key - upload `C:\certs\vm\client\key.pem` and call it `docker-key`

Now store your Docker ID in a global variable, so it's available as an environment variable to all the job steps. Under _Manage Jenkins/Configure Jenkins_ add an environment variable to _Global properties_:

- dockerId='my-docker-id'

Now back in the Jenkins homepage, add a job. Call it `signup` and select the _Freestyle_ job type.

In the SCM tab configure the connection to the Git server:

- Repository url - http://bonobo/Bonobo.Git.Server/docker-windows-workshop.git
- Credentials - select the `jenkins-ci` credential.

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