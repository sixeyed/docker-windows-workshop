
docker network create --driver overlay signup-net

docker service create `
 --network signup-net --endpoint-mode dnsrr `
 --env-file db-credentials.env `
 --name signup-db `
 $env:dockerId/signup-db

docker service create `
 --network signup-net --endpoint-mode dnsrr `
 --name message-queue `
 nats:nanoserver

docker service create `
 --network signup-net --endpoint-mode dnsrr `
 --env ES_JAVA_OPTS=-Xms512m -Xmx512m `
 --name elasticsearch `
 sixeyed/elasticsearch:nanoserver

docker service create `
 --network signup-net --endpoint-mode dnsrr `
 --publish mode=host,target=80,published=80 `
 --env-file db-credentials.env `
 --name signup-web `
 $env:dockerId/signup-web:1.4

docker service create `
 --network signup-net --endpoint-mode dnsrr `
 --env-file db-credentials.env `
 --name signup-save-handler `
 $env:dockerId/signup-save-handler:2

docker service create `
 --network signup-net --endpoint-mode dnsrr `
 --name signup-index-handler `
 $env:dockerId/signup-index-handler:2

docker service create `
 --network signup-net --endpoint-mode dnsrr `
 --publish mode=host,target=5601,published=5601 `
 --name kibana `
 sixeyed/kibana:nanoserver