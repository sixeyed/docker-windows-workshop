docker image build -t dwwx/signup-web -f .\frontend-web\web\Dockerfile .

docker image build -t dwwx/reference-data-api -f .\backend-rest-api\reference-data-api\Dockerfile .

docker image build -t dwwx/save-handler -f .\backend-async-messaging\save-handler\Dockerfile .

docker image build -t dwwx/homepage -f .\frontend-reverse-proxy\homepage\Dockerfile .

docker image build -t dwwx/reverse-proxy -f .\frontend-reverse-proxy\reverse-proxy\Dockerfile .

