#! /usr/bin/env bash

set -e

# create GPG keypair if not exist
if [[ ! -f /opt/aptly/secring.gpg ]] || [[ ! -f /opt/aptly/pubring.gpg ]]; then
  echo "Generating new GPG keys"
  # generate enough entropy
  cp -a /dev/urandom /dev/random
  # run unattended key generation
  gpg --batch --gen-key /root/.gnupg/gpg_batch
fi

# link created keys to /root/.gnupg
ln -sf /opt/aptly/pubring.gpg /root/.gnupg/pubring.gpg
ln -sf /opt/aptly/secring.gpg /root/.gnupg/secring.gpg

# export the GPG public key
if [[ ! -f /opt/aptly/public/public.key ]] || [[ "$(stat -c%s /opt/aptly/public/public.key)" == "0" ]]; then
  mkdir -p /opt/aptly/public
  gpg --export --armor > /opt/aptly/public/public.key
fi

# Import Ubuntu keyrings if they exist
if [[ -f /usr/share/keyrings/ubuntu-archive-keyring.gpg ]]; then
  gpg --list-keys
  gpg --no-default-keyring                                     \
      --keyring /usr/share/keyrings/ubuntu-archive-keyring.gpg \
      --export |                                               \
  gpg --no-default-keyring                                     \
      --keyring trustedkeys.gpg                                \
      --import
fi

# Import Debian keyrings if they exist
if [[ -f /usr/share/keyrings/debian-archive-keyring.gpg ]]; then
  gpg --list-keys
  gpg --no-default-keyring                                     \
      --keyring /usr/share/keyrings/debian-archive-keyring.gpg \
      --export |                                               \
  gpg --no-default-keyring                                     \
      --keyring trustedkeys.gpg                                \
      --import
fi

# start aptly api server
exec /usr/bin/aptly api serve -config=/etc/aptly.conf -no-lock
