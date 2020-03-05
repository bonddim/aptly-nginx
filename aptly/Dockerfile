FROM ubuntu:xenial

LABEL maintainer="Dmytro Bondar"

ENV DEBIAN_FRONTEND=noninteractive
ENV GIN_MODE=release

# aptly installation https://www.aptly.info/download/
RUN apt-key adv --keyserver pool.sks-keyservers.net --recv-keys ED75B5A4483DA07C && \
    echo "deb http://repo.aptly.info/ squeeze main" >> /etc/apt/sources.list && \
    apt-get update --quiet && \
    apt-get install --yes --quiet --no-install-recommends aptly && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# add config files
COPY --chown=root:root assets /
# ensure correct permissions
RUN chmod -R go-rwx /root/.gnupg

EXPOSE 8080
VOLUME [ "/opt/aptly" ]
ENTRYPOINT [ "/entrypoint.sh" ]
