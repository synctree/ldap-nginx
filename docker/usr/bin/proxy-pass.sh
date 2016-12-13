#!/bin/bash

REQUIRED=(
  TARGET_URL
)
for unique in "${REQUIRED[@]}"; do
  eval unique_value=\$$unique
  if [ "$unique_value" ]; then
    echo "Updating Value in Config: $unique"
    sed_escaped_value="$(echo "$unique_value" | sed 's/[\/&]/\\&/g')"
    sed -ri "s/$unique/$sed_escaped_value/" /usr/proxy/configs/proxy-pass.conf
  else
    echo >&2 "Required Value '$unique' must be set"
    echo >&2 "Goodbye!"
    exit 1
  fi
done

rm /etc/nginx/conf.d/default.conf
cp /usr/proxy/configs/proxy-pass.conf /etc/nginx/conf.d/

/usr/bin/nginx.sh
