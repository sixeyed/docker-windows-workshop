# Workshop Setup

You'll need to follow the steps below to setup your machine for the workshop.

## Steps

* [1. Get a Docker ID](#1)
* [2. Get Docker](#2)
* [3. Pull the Windows base images](#3)
* [4. Tool up!](#4)
* [5. Get the source](#5)
* [6. Test your setup](#6)


## <a name="1"></a>Step 1: Get a Docker ID

You will build images and push them to Docker Hub during the workshop, so they are available to use later. You'll need a Docker ID to push images.

- Sign up for a free Docker ID on [Docker Cloud](https://cloud.docker.com/)

## <a name="2"></a>Step 2. Get Docker

We are using new features in Docker 17.06. For the workshp we will provide you with a VM running in Azure which is already configured with everything you need.

If you want to use your own laptop or a VM running Windows 10 or Windows Server 2016, you'll need to install Docker for Windows - use the Edge release - and follow the rest of the steps in this page to get your environment set up.

### Azure VM

You are welcome to use one of our hosted VMs on Microsoft's Azure cloud. This is a Windows Server 2016 VM with Docker already installed. You will be provided with the VM credentials at the workshop.

> Your Azure VM will be destoyed after the workshop, so your work will be lost - but the images you push to Docker Hub will still be available.

You do not need Docker running on your laptop for this option, but you will need a Remote Desktop client to connect to the VM.

- Windows - use the built-in Remote Desktop Connection app.
- Mac - install [Microsoft Remote Desktop](https://itunes.apple.com/us/app/microsoft-remote-desktop/id715768417?mt=12) from the app store.
- Linux - install [Remmina](http://www.remmina.org/wp/), or any RDP client you prefer.

Once you've connected to your Azure VM, skip to [Step 5](#5).

### OPTIONAL - Windows 10

Install [Docker CE for Windows](https://store.docker.com/editions/community/docker-ce-desktop-windows?tab=description) from Docker Store, making sure to choose the Edge build to get the latest version. Run Docker for Windows and from the taskbar switch to Windows containers.

### OPTIONAL - Windows Server 2016

Install [Docker EE for Windows Server](https://store.docker.com/editions/enterprise/docker-ee-server-windows?tab=description) from Docker Store. The installation deploys Docker as a Windows service and starts the service for you. Then you need to replace the EE version with 17.05 CE:

```
Stop-Service docker
$version = "17.05.0-ce-rc1"

$wc = New-Object net.webclient
$wc.DownloadFile("https://test.docker.com/builds/Windows/x86_64/docker-$version.zip", "$env:TEMP\docker.zip")
Expand-Archive -Path "$env:TEMP\docker.zip" -DestinationPath $env:ProgramFiles -Force
Remove-Item "$env:TEMP\docker.zip"

Start-Service docker
```

## <a name="3"></a>Step 3. Pull the Windows base images

We will use Docker images based on Windows Server Core and Nano Server, so be sure you have these image versions available.

> If you're using one of the lab VMs, these images are already pulled.

```
docker pull microsoft/nanoserver:10.0.14393.693
docker pull microsoft/windowsservercore:10.0.14393.693
```

And tag them as `latest` in case you have any older versions of the image:

```
docker tag microsoft/nanoserver:10.0.14393.693 microsoft/nanoserver:latest
docker tag microsoft/windowsservercore:10.0.14393.693 microsoft/windowsservercore:latest
```

Now pull a couple of other big images, which will save time later:

```
docker pull microsoft/mssql-server-windows-express
docker pull sixeyed/msbuild:4.5.2-webdeploy
```

## <a name="4"></a>Step 4. Tool up!

Also you'll need some tools - Git to pull the workshop repo, and a text editor. Visual Studio isn't required for this workshop.

> If you're using one of the lab VMs, these tools are already installed.

The PowerShell Git module and Visual Studio code are nice options. You can install them with [Chocolatey](https://chocolatey.org/):

```
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install -y poshgit
choco install -y visualstudiocode
choco install -y firefox
```

## <a name="5"></a>Step 5. Get the source

Source code for the workshop is on a public GitHub repo. The lab VM has the repo set up, so just pull to make sure the latest changes are downloaded - use the PowerShell link from `C:\shortcuts`:

```
cd $Env:workshopRoot
git pull
```

If you're using your own machine, you can clone the repo wherever you like, but the instructions assume a known directory structure. You can setup your environment to match with:

```
mkdir -p C:\scm\github\sixeyed
cd C:\scm\github\sixeyed
git clone https://github.com/sixeyed/docker-windows-workshop
$Env:workshopRoot='C:\scm\github\sixeyed\docker-windows-workshop'
```

> Now save your Docker ID to an environment variable, so it works with all the lab scripts:

```
$Env:dockerId='<my-docker-Id>'
```

## <a name="6"></a>Step 6. Test your setup

Open a PowerShell prompt **using Run as Administrator** (or from `C:\shortcuts` on the lab VM, and run the verification script:

```
cd C:\scm\github\sixeyed\dc-mta-workshop
.\verify.ps1
```

You should see a useful message, proving your Docker setup is working correctly.

# Next Up

On to [Part 1](part-1.md)!
