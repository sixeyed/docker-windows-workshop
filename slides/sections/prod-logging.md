# Production Readiness - Logging

---

<section data-background-image="/img/prod/Slide5.png">

---

This web app uses `log4net` which is [configured](./src/SignUp.Web/log4net.config) to write log entries to a file on the C drive.

Those log entries are being written inside the container, we just need to read them from the file back out to Docker.

---

[The new Dockerfile](./docker/prod-logging/signup-web/Dockerfile) uses a [Docker volume](https://docs.docker.com/storage/volumes/) for the path `C:\logs`, which is where the log file gets written. That means the log data is stored outside of the container using Docker's pluggable volume system.

And the [startup script](./docker/prod-logging/signup-web/startup.ps1) has been extended, so it ends by tailing the log file - relaying all the log entries to the console, which Docker is monitoring.

---

## Build the new image

_ Tag the image as `v4`, which includes logging: _

```
cd $env:workshop; `

docker image build -t dwwx/signup-web:v4 `
  -f ./docker/prod-logging/signup-web/Dockerfile .
```

---

## Run the app with logs

The [v7 manifest](./app/v7.yml) uses the upgraded web app, which echoes the existing `log4net` log entries back out to Docker. It also maps the log volume to a local directory on the VM.

_ Create the log folder and update the application: _

```
mkdir C:\web-logs

docker-compose -f .\app\v7.yml up -d
```

---

## Check the web logs

The container startup script writes some initial output. 

Check that before you open the website:

```
docker container logs app_signup-web_1
```

> You'll see the steps from the script prefixed with `STARTUP:`

---

## Browse to the app

When the app is running, there are additional log entries written by `log4net`.

Check out the app by browsing to the new container, and saving some data:

```
$ip = docker container inspect `
  --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' app_proxy_1

firefox "http://$ip"
```

---

## Check the logs again

Now look at the logs again:

```
docker container logs app_signup-web_1
```

> You'll see entries from `log4net` flagged with `DEBUG` and `INFO` levels

---

## Look at the logs on the host

The app is writing the log file at the path `C:\logs` inside the container, but that's a volume which is being mapped fo `C:\web-logs` on the VM.

It's transparent to the container, but that log file actually exists on the VM.

_ You can see the same data from the host: _

```
cat C:\web-logs\SignUp.log
```

> You can manage log storage outside of the container, and use a different storage device.

---

## Echoing logs to Docker

This is a simple pattern to get logs from existing apps into Docker, without changing application code. 

You can use it to echo logs from any source in the container - like log files or the [Event Log](https://github.com/Microsoft/mssql-docker/blob/a3020afeec9be1eb2d67645ac739438eb8f2c545/windows/mssql-server-windows-express/start.ps1#L75).

Docker has a pluggable logging system, so as long as you get your logs into Docker, it can automatically ship them to Splunk, Elasticsearch etc.