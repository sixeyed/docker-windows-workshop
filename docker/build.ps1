docker image build -t dwwx/signup-web -f .\docker\frontend-web\v1\Dockerfile .

docker image build -t dwwx/reference-data-api -f .\docker\backend-rest-api\reference-data-api\Dockerfile .

docker image build -t dwwx/save-handler -f .\docker\backend-async-messaging\save-handler\Dockerfile .

docker image build -t dwwx/homepage -f .\docker\frontend-reverse-proxy\homepage\Dockerfile .

docker image build -t dwwx/reverse-proxy -f .\docker\frontend-reverse-proxy\reverse-proxy\Dockerfile .

