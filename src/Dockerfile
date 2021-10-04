FROM python:3-alpine
MAINTAINER Dave Kaufman <dave@daveops.org>

ARG PORT
ENV PORT $PORT
EXPOSE $PORT

SHELL ["/bin/sh", "-c"]
STOPSIGNAL SIGTERM
HEALTHCHECK CMD curl -k -s https://localhost:$PORT/health || exit 1

WORKDIR /
RUN apk --no-cache add curl
COPY server.py /server.py

USER nobody
CMD python ./server.py $PORT
