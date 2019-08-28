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

You'll be given the connection details for your Windows Server 2019 VM during the workshop.

You can connect to the VM using RDP on Windows, [Microsoft Remote Desktop](https://itunes.apple.com/us/app/microsoft-remote-desktop-8-0/id715768417) from the Mac App Store or [Remmina](https://github.com/FreeRDP/Remmina/wiki#for-end-users) on Linux.

_RDP into the server VM. The server name will be something like:_

```
dwwx-dcus1800.centralus.cloudapp.azure.com
```

---

## Update your VM setup

Now run a script to make sure everything is up to date.

_Open a PowerShell prompt from the start menu and run:_

```
cd C:\scm\docker-windows-workshop

.\workshop\lab-vm\update.ps1
```

> **Do not use PowerShell ISE for the workshop!** It has a strange relationship with some `docker` commands.

---

## We're ready!

Here we go :)

