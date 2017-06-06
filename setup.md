# Workshop Setup

You have a VM running with Docker installed, in this step you'll add your Docker ID to the VM.

## Steps

* [1. Get a Docker ID](#1)
* [2. Connect to your VM](#2)
* [3. Test your setup](#3)

## <a name="1"></a>Step 1: Get a Docker ID

You will build images and push them to Docker Hub during the workshop, so they are available to use later. You'll need a Docker ID to push images.

- Sign up for a free Docker ID on [Docker Cloud](https://cloud.docker.com/)

## <a name="2"></a>Step 2. Connect to your VM

You have a dedicated VM running in Azure. This is a Windows Server 2016 VM with Docker and some useful tools installed (using [this setup script](setup.ps1)). You will be provided with the VM credentials at the workshop.

> Your Azure VM will be destoyed after the workshop, so your work will be lost - but the images you push to Docker Hub will still be available.

You do not need Docker running on your laptop, but you will need a Remote Desktop client to connect to the VM.

- Windows - use the built-in Remote Desktop Connection app
- Mac - install [Microsoft Remote Desktop](https://itunes.apple.com/us/app/microsoft-remote-desktop/id715768417?mt=12) from the app store
- Linux - install [Remmina](http://www.remmina.org/wp/), or any RDP client you prefer.

## <a name="3"></a>Step 3. Test your setup

Open a PowerShell prompt **using Run as Administrator** (or from `C:\shortcuts` on the lab VM). 

> Save your Docker ID into an environment variable

```
$Env:dockerId='my-docker-id'
```

Then check the Docker stuo by running:

```
cd $env:workshopRoot
.\verify.ps1
```

You should see a useful message, proving your Docker setup is working correctly.

# Next Up

On to [Part 1](part-1.md)!
