#!/bin/sh
#
# Obscenely copied from http://is.gd/sH2FLk
#

config_fail () {
	echo "Failed to start due to config error"
	exit 1
}

if [ -z "$ETCD_NODE" ]; then
  echo "Missing ETCD_NODE env var"
  exit 1
fi

# confd will start haproxy, since conf will be different than existing (which is null)
echo "[haproxy-confd] Booting container. ETCD node: $ETCD_NODE"

touch /var/run/haproxy.state

# Loop until confd has updated the haproxy config
n=0
until confd -onetime -node "$ETCD_NODE"; do
  [ "$n" -gt "4" ] && config_fail
  echo "[haproxy-confd] Waiting for confd to refresh haproxy.cfg"
  n=$((n+1))
  sleep $n
done

echo "[haproxy-confd] Initial HAProxy config created. Starting confd"

confd -node "$ETCD_NODE"
