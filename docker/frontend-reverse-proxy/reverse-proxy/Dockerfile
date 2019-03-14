# uses Server Core at netapi32.dll not in Nano Server 1809
# usage
#  docker container run -d -p 80 -p 8080 -v \\.\pipe\docker_engine:\\.\pipe\docker_engine sixeyed/traefik:v1.7.8-windowsservercore-ltsc2019 --api --docker --docker.endpoint=npipe:////./pipe/docker_engine --logLevel=DEBUG
FROM mcr.microsoft.com/windows/servercore:ltsc2019

COPY --from=traefik:v1.7.8-nanoserver-sac2016 /traefik.exe /traefik.exe

EXPOSE 80 443
ENTRYPOINT ["/traefik"]