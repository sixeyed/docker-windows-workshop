# Lab VM

At a hosted workshop you will be given your own VM to use, running in the cloud.

If you're doing this at home, the easiest way to setup your own environment is to create a VM on Azure.

## Create and configure the VM

- create a DevTest lab (so the VM automatically shuts down and doesn't incur extra charges)
- create a VM from the **Windows Server 2016 - with Containers** image (any size will do, but D3V2 is a good choice)
- connect to the VM and run Windows Update (I use `sconfig`, and I also set updates to _Manual_ so there's no interruption later)
- run the [setup.ps1](lab-vm/setup.ps1) script which I use to prep the lab VM:

```
iwr -useb https://raw.githubusercontent.com/sixeyed/docker-windows-workshop/master/lab-vm/setup.ps1 | iex
```

That script does a few things:

- updates Docker to the latest version
- installs a few tools, like VS Code, Git and Firefox
- pulls all the Docker images used in the lab

## Clone the workshop repo

After the script completes, you have Git installed so you can clone the repo:

```
mkdir C:\scm
cd C:\scm
git clone https://github.com/sixeyed/docker-windows-workshop.git
```

The workshop also expects an environment variable for the repo path:

```
$env:workshop='C:\scm\docker-windows-workshop'
```