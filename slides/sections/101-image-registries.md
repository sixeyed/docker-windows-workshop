# Docker Images and Registries

Images are the portable package that contains your application - your binaries, all the dependencies and the default configuration.

You share images by pushing them to a registry. Docker Hub is the most popular public registry. Most enterprises run their own private registry. You work with them in the same way.

---

## Registry username

You've built two images but you can't push them to a registry yet. To push to Docker Hub your images need to have your username in the image tag.

_ Start by capturing your Docker ID in a variable: _

```
$env:dockerId='<insert-your-docker-id-here>'
```

> Make sure you use your Docker ID, which is the username you use on Docker Hub. Mine is `sixeyed`, so I run `$env:dockerId='sixeyed'`

---

## Image tags

Now you can tag your images. This is like giving them an alias - Docker doesn't copy the image, it just links a new tag to the existing image.

_ Add a new tag for your images which includes your Docker ID: _

```
docker image tag hostname-app "$env:dockerId/hostname-app"; `
docker image tag tweet-app "$env:dockerId/tweet-app"
```

---

## List your images

You can list all your local images tagged with your Docker ID. You'll see the images you've built, with the newest at the top:

```
docker image ls -f reference="$env:dockerId/*"
```

> The image tags start with your Docker ID, so these can be pushed to Docker Hub.

---

## Login to Docker Hub

You can use any tag for local images - you can use the `microsoft` tag if you want, but you can't push them to Docker Hub unless you have access.

_ Log in to Docker Hub with your Docker ID: _

```
docker login --username "$env:dockerId"
```

> You have access to your own user image repositories on Docker Hub, and you can also be granted access to organization repositories.

---

## Push images to Docker Hub

[Docker Hub](https://hub.docker.com) is the public registry for Docker images. 

_ Upload your images to the Hub: _

```
docker image push $env:dockerId/hostname-app; `
docker image push $env:dockerId/tweet-app
```

> You'll see the upload progress for each layer in the Docker image.

---

## Browse to Docker Hub

Open your user page on Docker Hub and you'll see the images are there.

```
firefox "https://hub.docker.com/r/$env:dockerId/"
```

> These are public images, so anyone can run containers from your images - and the apps will work in exactly the same way everywhere.

---

## What exactly gets uploaded?

The logical size of those images is over 10GB each, but the bulk of that is in the Windows Server Core base image.

Those layers are already stored in Docker Hub, so they don't get uploaded - only the new parts of the image get pushed. 

Docker shares layers between images, so every image that uses Windows Server Core will share the cached layers for that image.

---

## That's it for the 101

You have a good understanding of the Docker basics now: Dockerfiles, images, containers and registries.

That's really all you need to get started Dockerizing your own applications.