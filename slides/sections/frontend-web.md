# Building and Running ASP.NET WebForms Apps in Docker

---

Our demo app is a simple ASP.NET WebForms app which uses SQL Server for storage. It's a full .NET Framework app, which uses .NET version `4.7.2`.

Right now the web app is a monolith. By the end of the workshop we'll have broken it down, but first we need to get it running.

---

## Build the web app image

Check out the [Dockerfile](https://github.com/sixeyed/docker-windows-workshop/blob/dcus18/frontend-web/web/Dockerfile) for the application. It uses Docker to compile the app from source, and package it into an image.

_Build the image:_

```
docker image build -t dwwx/signup-web `
  -f .\frontend-web\web\Dockerfile .
```

---

## Run the web app

That's it! 

You don't need Visual Studio or .NET 4.7.2 installed to build the app, you just need the source repo and Docker. 

_Try running the app in a container:_

```
docker container run `
  -d -p 8020:80 --name app `
  dwwx/signup-web
```

---

## Try it out

You can browse to port `8020` on your Docker host (that's your Windows Server 2016 VM or your Windows 10 laptop). Or you can browse direct to the container:

_Get the container's IP address and launch the browser:_

```
$ip = docker container inspect `
  --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' app

firefox "http://$ip"
```

---

## Tidy up before we try again

Oops. 

Remember the app needs SQL Server, and there's no SQL Server on this machine. We'll run it properly next, but first let's clean up that container. 

_Remove the `app` container:_

```
docker container rm -f app
```

---

## Run the app - with dependencies

Now  we'll run the database in a container too - using Docker Compose to manage the whole app. Check out the [v1 manifest](https://github.com/sixeyed/docker-windows-workshop/blob/dcus18/app/v1.yml), it specifies SQL Server and the web app. 

_Now run the app using compose:_

```
docker-compose -f .\app\v1.yml up -d
```

---

## Try the app again

As before, browse to port `8020` on your Docker host or browse direct to the container:

```
$ip = docker container inspect `
  --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' app_signup-web_1

firefox "http://$ip"
```

---

## Looking better :) 

But let's check it really works. Click the _Sign Up_ button, fill in the form and click _Go!_ to save your details.

_Check the data has been saved in the SQL container:_

```
docker container exec app_signup-db_1 `
  powershell `
  "Invoke-SqlCmd -Query 'SELECT * FROM Prospects' -Database SignUp"
```

---

## All good

We're in a good place now. This could be a 10-year old WebForms app, and now you can run it in Docker and move it to the cloud - **no code changes**!

It's also a great starting point for modernizing the application.
