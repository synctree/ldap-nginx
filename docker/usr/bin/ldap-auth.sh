#!/bin/bash

REQUIRED=(
  TARGET_URL
  LDAP_SEARCH_URL
  LDAP_BINDDN
  LDAP_BINDDN_PASSWORD
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
    echo "Updating Value in LDAP Config: $unique"
    sed_escaped_value="$(echo "$unique_value" | sed 's/[\/&]/\\&/g')"
    sed -ri "s/$unique/$sed_escaped_value/" /usr/proxy/configs/ldap-auth.conf
  else
    echo >&2 "Required Value '$unique' must be set"
    echo >&2 "Goodbye!"
    exit 1
  fi
done

LDAP=(
  TARGET_URL
  LDAP_SEARCH_URL
  LDAP_BINDDN
  LDAP_BINDDN_PASSWORD
)
for unique in "${LDAP[@]}"; do
  eval unique_value=\$$unique
  if [ "$unique_value" ]; then
    search_value="$(echo "__${unique}__")"
    echo "Updating Value in NGINX Config: $search_value"
    sed_escaped_value="$(echo "$unique_value" | sed 's/[\/&]/\\&/g')"
    sed -ri "s/$search_value/$sed_escaped_value/" /usr/proxy/configs/ldap-nginx.conf
  else
    echo >&2 "Required Value '$unique' must be set"
    echo >&2 "Goodbye!"
    exit 1
  fi
done

mv /usr/local/nginx/nginx.conf /usr/local/nginx/nginx.conf.BAK
cp /usr/proxy/configs/ldap-nginx.conf /usr/local/nginx/nginx.conf
cp /usr/proxy/configs/ldap-auth.conf /usr/local/nginx/conf.d/

/usr/bin/nginx.sh
