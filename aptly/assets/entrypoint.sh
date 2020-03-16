#! /usr/bin/env bash

set -e

# create GPG keypair if not exist
if [[ ! -f /opt/aptly/secring.gpg ]] || [[ ! -f /opt/aptly/pubring.gpg ]]; then
  echo "Generating new GPG keys"
  # generate enough entropy
  cp -a /dev/urandom /dev/random

  # create batch file
  cat > /root/.gnupg/gpg_batch <<-EOF
	%echo Generating a default key
	Key-Type: RSA
	Key-Length: 4096
	Subkey-Type: ELG-E
	Subkey-Length: 1024
	Name-Real: ${FULL_NAME:-"Aptly Repo"}
	Name-Comment: self-hosted deb repository
	Name-Email: ${EMAIL:-"aptly@repo.local"}
	Expire-Date: 0
	%pubring /opt/aptly/pubring.gpg
	%secring /opt/aptly/secring.gpg
	%commit
	%echo done
EOF

  # run unattended key generation
  gpg1 --batch --gen-key /root/.gnupg/gpg_batch
fi

# link created keys to /root/.gnupg
ln -sf /opt/aptly/pubring.gpg /root/.gnupg/pubring.gpg
ln -sf /opt/aptly/secring.gpg /root/.gnupg/secring.gpg

# export the GPG public key
if [[ ! -f /opt/aptly/public/public.key ]] || [[ "$(stat -c%s /opt/aptly/public/public.key)" == "0" ]]; then
  mkdir -p /opt/aptly/public
  gpg1 --export --armor > /opt/aptly/public/public.key
fi

# Import Debian keyrings if they exist
if [[ -f /usr/share/keyrings/debian-archive-keyring.gpg ]]; then
  gpg1 --list-keys
  gpg1 --no-default-keyring                                     \
      --keyring /usr/share/keyrings/debian-archive-keyring.gpg \
      --export |                                               \
  gpg1 --no-default-keyring                                     \
      --keyring trustedkeys.gpg                                \
      --import
fi

# start aptly api server
exec /usr/bin/aptly api serve -config=/etc/aptly.conf -no-lock
