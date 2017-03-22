#!/bin/bash
set -e

VALUE="$1"

echo "Using input value: $VALUE"

case $VALUE in
basic-auth)
  echo "Starting Basic Auth Proxy..."
  /usr/bin/basic-auth.sh
  ;;
ldap-auth)
  echo "Starting LDAP Auth Proxy..."
  /usr/bin/ldap-auth.sh
  ;;
es-ldap-auth)
  echo "Starting ES LDAP Auth Proxy..."
  /usr/bin/es-ldap-auth.sh
  ;;
admin-es-ldap-auth)
  echo "Starting Admin ES LDAP Auth Proxy..."
  /usr/bin/admin-es-ldap-auth.sh
  ;;
proxy-pass)
  echo "Starting Proxy Pass..."
  /usr/bin/proxy-pass.sh
  ;;
redirect-all-traffic)
  echo "Starting the NGINX Blanket Redirect proxy..."
  /usr/bin/redirect-all-traffic.sh
  ;;
*)
  echo "Executing: $@"
  exec "$@"
  ;;
esac

echo "Goodbye!"
