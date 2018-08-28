### ASP.NET WebForms Apps in Docker

You'll learn how to build and run full .NET Framework apps in Windows containers.

---

The architecture is simple - we'll hav e a monolithic web application connecting to SQL Server. Both running in containers.

---

## Now - connect to your VM 

You'll be given the connection details for your Windows Server 2016 VM during the workshop.

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

.\lab-vm\update.ps1
```

> **Do not use PowerShell ISE for the workshop!** It has a strange relationship with some `docker` commands.

---

## We're ready!

Here we go :)

