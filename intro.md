# Intro

Welcome to the workshop :)

---

### Pre-requisites

You will be provided with a virtual machine which is already prepped for the lab.

You will build images and push them to Docker Hub during the workshop, so they are available to use later. You'll need a Docker ID to push images.

- Sign up for a free Docker ID on [Docker Hub](https://hub.docker.com)

## Goals for the day

The morning workshop covers Parts 1-4:

- [Part 1](part-1.md) - running Docker on Windows
- [Part 2](part-2.md) - packaging an existing ASP.NET app in Docker
- [Part 3](part-3.md) - modernizing the ASP.NET app with Docker
- [Part 4](part-4.md) - preparing for production with instrumentation

The full day workshop continues in the afternoon with parts 5-7.

- [Part 5](part-5.md) - resilience and scalability with Docker Compose
- [Part 6](part-6.md) - containerized CI (and CD) with Docker
- [Part 7](part-7.md) - production-ready orchestration with Docker swarm mode

---

## Workshop conventions

Exercises are shown like this:

.exercise[
    - This is something you do yourself...

    ```
    copy and paste this code
    ```]

---

## Now - connect to your VM 

You'll be given the connection details for your Windows Server 2016 VM during the workshop.

You can connect to the VM using:

- RDP (Windows)
- Microsoft Remote Desktop (Mac)
- Remmina (linux)

.exercise[
    - RDP into the server VM. The server name will be something like:

    ```
    dwwx-dcus1800.centralus.cloudapp.azure.com
    ```]

---

## Update your VM setup

The VM has a bunch of tools and Docker images pre-installed. Start by running a script to make sure everything is up to date.

The script will ask for your Docker ID - **be sure to use your Docker ID** (not your email address).

.exercise[
    - Open a PowerShell prompt from the start menu and run:

    ```
    cd C:\scm\docker-windows-workshop

    .\lab-vm\update.ps1
    ```]

Now close that PowerShell prompt.

> **Do not use PowerShell ISE for the workshop!** It has a strange relationship with some `docker` commands, and you won't get far with it.

---

## Log in to Docker Hub

Login to Docker Hub with your Docker credentials:

.exercise[
    - Open a PowerShell prompt from the desktop shortcut and run:

    ```
    docker login --username $env:dockerId
    ```]
---

## Check everything's OK

Now check the Docker setup by running a simple verify script.

.exercise[
    ```
    cd $env:workshop

    .\verify.ps1
    ```]

> You should see a Docker image gets built, a container is run and the image is pushed to Docker Hub.

---

## We're ready!

Here we go :)

