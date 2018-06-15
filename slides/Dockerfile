FROM sixeyed/nginx

WORKDIR C:/nginx/html
COPY ./reveal.js-3.6.0/ .
COPY *.md ./sections
COPY ./index.html .

# move to nginx base
WORKDIR C:/nginx