# Intro

Welcome to the workshop :)

---

### Pre-requisites

You will be provided with a virtual machine which is already prepped for the lab.

You will build images and push them to Docker Hub during the workshop, so they are available to use later. You'll need a Docker ID to push images.

- Sign up for a free Docker ID on [Docker Hub](https://hub.docker.com)

---

## Workshop conventions

Exercises are shown like this:

_This is something you do yourself..._

```
copy and paste this code
```

---

## Now - connect to your VM 

You'll be given the connection details for your Windows Server 2016 VM during the workshop.

You can connect to the VM using RDP on Windows, [Microsoft Remote Desktop](https://itunes.apple.com/us/app/microsoft-remote-desktop-8-0/id715768417) from the Mac App Store or [Remmina](https://github.com/FreeRDP/Remmina/wiki#for-end-users) on Linux.

_RDP into the server VM. The server name will be something like:_

```
dwwx-dcus1800.centralus.cloudapp.azure.com
```

---

## Clone the workshop source code

The VM has a bunch of tools and Docker images pre-installed. But the Git install failed, so you'll need to do that manually.

_Open a PowerShell prompt from the start menu and run:_

```
choco install -y poshgit

$env:PATH="$env:PATH;C:\Program Files\Git\bin;"

cd C:\scm
    
git clone https://github.com/sixeyed/docker-windows-workshop.git

```

---

## Install Docker Compose

The VM setup script also deploys Docker Compose and that also failed, so here's another manual step:

_Open a PowerShell prompt from the start menu and run:_

```
iwr -useb `
  https://raw.githubusercontent.com/sixeyed/docker-init/master/windows/install-docker-compose.ps1 `
    | iex

```

---

## Update your VM setup

Now run a script to make sure everything is up to date.

The script will ask for your Docker ID - **be sure to use your Docker ID** (not your email address).

_Open a PowerShell prompt from the start menu and run:_

```
cd C:\scm\docker-windows-workshop

.\lab-vm\update.ps1
```

> **Do not use PowerShell ISE for the workshop!** It has a strange relationship with some `docker` commands.

---

## Log in to Docker Hub

Login to Docker Hub with your Docker credentials:

_Open a PowerShell prompt from the desktop shortcut and run:_

```
docker login --username $env:dockerId
```

---

## Check everything's OK

Now check the Docker setup by running a simple verify script.

```
cd $env:workshop

.\verify.ps1
```

> You should see a Docker image gets built, a container is run and the image is pushed to Docker Hub.

---

## We're ready!

Here we go :)

