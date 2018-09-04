docker image build `
 --tag $env:dockerID/docker-workshop-verify `
 $pwd\verify

docker container run --rm $env:dockerID/docker-workshop-verify

docker image push $env:dockerID/docker-workshop-verify
