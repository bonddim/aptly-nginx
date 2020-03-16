FROM debian:buster

LABEL maintainer="Dmytro Bondar"

ENV DEBIAN_FRONTEND=noninteractive
ENV GIN_MODE=release

# aptly installation https://www.aptly.info/download/
RUN apt-get update --quiet && \
    apt-get install --yes --quiet --no-install-recommends aptly gnupg1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# add config files
COPY --chown=root:root assets /
# ensure correct permissions
RUN chmod -R go-rwx /root/.gnupg && \
    chmod +x /entrypoint.sh

EXPOSE 8080
VOLUME [ "/opt/aptly" ]
ENTRYPOINT [ "/entrypoint.sh" ]
