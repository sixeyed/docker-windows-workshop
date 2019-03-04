# Windows Container Basics

---

We'll start with the basics and get a feel for running Docker on Windows. 

You'll see how to run task containers, interactive containers and background containers, and explore the filesystem and processes inside Docker containers.

---

## Run a task in a container

Task containers just do one thing and then exit. Useful for automation, but we'll start with a simple example.

_Print out the host name from a Windows container: _

```
docker container run mcr.microsoft.com/windows/nanoserver:1809 hostname
```

---

## Check for running containers

When the process in a container ends, the container stops too. Your task container still exists, but its in the 'Exited' state.

_List all containers: _

```
docker container ls --all
```

> Note that the container ID *is* the container's hostname.

---

## Run an interactive container

Interactive containers start and connect your console to the container. You can use it like an RDP session, to explore a container.

_Start a Windows Server Core container and connect to it:_

```
docker container run --interactive --tty --rm `
  mcr.microsoft.com/windows/servercore:ltsc2019 powershell
```

---

## Explore Windows Server Core

The Windows Server Core container is pretty much Windows Server 2016 without the GUI. 

_ Explore the container environment: _

```
ls C:\
Get-Process
Get-WindowsFeature
```

> Now run `exit` to leave the PowerShell session, which stops the container process. 

---

## Run a background SQL container

Background or "detached" containers are how you'll run most applications. They start in the background and keep running, like a Windows Service.

_Run SQL Server as a detached container:_

```
docker container run --detach --name sql `
  --env sa_password=DockerCon!!! `
  dwwx/sql-server:2017
```

---

## Exploring SQL Server

As long as SQL Server keeps running, Docker keeps the container running in the background.

You can check what's happening inside a container from the host, using the Docker CLI.

_ Check the logs and processes in the SQL container: _

```
docker container top sql
```

```
docker container logs sql
```

---

## Running SQL commands

You can't connect to this SQL container, because you started it without making ports accessible.

We'll see how to do that later - but for now you can run commands inside the container using the CLI.

_ Check what the time is inside the SQL container:_

```
docker container exec sql `
  powershell "Invoke-SqlCmd -Query 'SELECT GETDATE()'"
```

---

## Connect to a background container

The SQL Server container is stil running in the background. 

_ Connect a PowerShell session to the container_ :

```
docker container exec -it sql powershell
```

---

## Explore the SQL filesystem

The SQL data files live inside the container - you can find the MDF data and LDF log files for the standard databaes.

_ Look at the default SQL data directory: _

```
cd 'C:\Program Files\Microsoft SQL Server'
```

```
ls .\MSSQL14.SQLEXPRESS\MSSQL\data
```

---

## Processes in the SQL container

Processes in a Windows Server container are actually running on the server. 

_ Check the processes running in the container: _

```
Get-Process
```

> One is `sqlservr`. There are two `powershell` processes, one is the container startup script and the other is this PowerShell session. 

---

## Windows users in the SQL container

Processes in containers run as standard Windows user accounts. 

_ Compare the user accounts for the processes:_

```
Get-Process -Name sqlservr,powershell -IncludeUser
```

> Containers have the usual Windows accounts, and a special `ContainerAdministrator` user.

---

## Check processes on the Windows host

On the Windows Server host, you can see the container processes.

_ Open **another PowerShell terminal** and run:_

```
Get-Process -Name powershell -IncludeUserName
```

> You'll see the PowerShell sessions from the container - with the same IDs but with a blank username. The container user doesn't map to any user on the host.

---

## Things to remember about Windows Server containers

- Windows Server container processes run natively on the host, which is why they are so efficient

- Container processes run as an unknown user on the host, so a rogue container process wouldn't be able to access host files or other processes.

---

## Disconnect from the container

Close the second PowerShell window, and exit the interactive Docker session in the first PowerShell window:

```
exit
```

> The container is still running.

---

## Clean up all containers

We don't need any of these containers, so you can remove them all

_ The `-force` flag removes containers even if they're still running: _

```
docker container rm --force `
  $(docker container ls --quiet --all)
```

---

## That's the basics

Now you should understand different ways of running containers and connecting to containers, and how container processes run natively on the server.

So far we've used Microsoft's container images. Next you'll learn how to build your own.
