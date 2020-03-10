aptly-api server
===

[![Docker Pulls](https://img.shields.io/docker/pulls/bonddim/aptly-api.svg)](https://hub.docker.com/r/bonddim/aptly-api)
[![Docker Automated build](https://img.shields.io/docker/automated/bonddim/aptly-api.svg)](https://hub.docker.com/r/bonddim/aptly-api/builds)
[![Docker Stars](https://img.shields.io/docker/stars/bonddim/aptly-api.svg)](https://hub.docker.com/r/bonddim/aptly-api)

Official docs:
 - [aptly.info](https://www.aptly.info/doc/overview/)
 - [nginx.org](https://nginx.org/en/docs/)
 - [docker.com](https://docs.docker.com)


## Image usage
The following command will download image from dockerhub and run `aptly-api server` in a container:

```bash
docker run \
  --detach=true \
  --restart=always \
  --publish 8080:8080 \
  --volume /srv/aptly_data/:/opt/aptly \
  --env FULL_NAME="First Last" \
  --env EMAIL="e-mail@example.com" \
  bonddim/aptly-api
```

Flag | Description
--- | ---
`--detach=true` | Run the container in the background
`--restart=always` | Start the container when the docker daemon starts
`--volume "$APTLY_FILES":/opt/aptly` | Path on host or volume name to store aptly data
`--publish 8080:8080` | Publish host port to aptly port in container
`--env FULL_NAME="First Last"` | Full name for the GPG signing key (optional)
`--env EMAIL="e-mail@example.com"` | E-mail address for the GPG apt signing key (optional)

## Compose file usage (recommended)
```bash
git clone https://github.com/bonddim/aptly-nginx && cd aptly-nginx
docker-compose up -d
```
This command will start aptly-api server and nginx server.
Nginx is used for:
- proxying requests to aptly api server
- serving aptly static files

### Defaults
#### Persistent data
All of aptly's data (including PGP keys and GPG keyrings) is mounted outside of the container to preserve it if the container is removed or rebuilt.

#### Networking
Docker will map port 80 on the Docker host to port 80 within the container where nginx is configured to listen. 

#### Security
To enable SSL, uncomment appropriate lines in `nginx/default.conf` file and add your private and public keys to `nginx/ssl` directory.

How to add authentication for api server you can found on [official aptly docs](https://www.aptly.info/doc/faq/) or [link from docs](https://github.com/sepich/nginx-ldap)

The GPG keyrings doesn't have password.
root user is the owner of all aptly's data on docker host.

## Using published repository

1. Add aptly public PGP key to your trusted repositories
    ```bash
    curl -fsSL http://aptly-host/public.key | sudo apt-key add -
    ```

2. Add repo to sources list
    ```bash
    echo "deb http://aptly-host distribution component" | sudo tee /etc/apt/sources.list.d/aptly-host.list
    apt-get update
    ```
