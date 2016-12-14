#!/bin/bash

REQUIRED=(
  TARGET_URL
  USERNAME
  PASSWORD
)
for unique in "${REQUIRED[@]}"; do
  eval unique_value=\$$unique
  if [ "$unique_value" ]; then
    echo "Required value set: $unique"
  else
    echo >&2 "Required Value '$unique' must be set"
    echo >&2 "Goodbye!"
    exit 1
  fi
done

NGINX=(
  TARGET_URL
)
for unique in "${NGINX[@]}"; do
  eval unique_value=\$$unique
  if [ "$unique_value" ]; then
    echo "Updating Value in Config: $unique"
    sed_escaped_value="$(echo "$unique_value" | sed 's/[\/&]/\\&/g')"
    sed -ri "s/$unique/$sed_escaped_value/" /usr/proxy/configs/basic-auth.conf
  else
    echo >&2 "Required Value '$unique' must be set"
    echo >&2 "Goodbye!"
    exit 1
  fi
done

echo "Creating passwords file..."
printf "${USERNAME}:$(openssl passwd -crypt ${PASSWORD})\n" > /usr/local/nginx/passwords

cp /usr/proxy/configs/basic-auth.conf /usr/local/nginx/conf.d/

/usr/bin/nginx.sh
