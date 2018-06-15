FROM sixeyed/nginx

WORKDIR C:/nginx/html
COPY ./reveal/ ./reveal/
COPY *.md ./sections
COPY ./index.html .

# move to nginx base
WORKDIR C:/nginx