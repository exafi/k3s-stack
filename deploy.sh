#!/bin/bash

#OPTIONS

. local-config.sh

# BUG: There is a race in this setup.
# When OpenEBS is deployed, all the nodes must
# be ready.  It would be amazing if this wasn't
# satisfied in time but it could happen one day.
# Until then though, this is ultra-low priority.
#
# The solution is to wait for the nodes to all
# become ready at the end of k3sup.

MODULES='
krew
k3sup
cert-manager
haproxy-ingress
local-ca
openebs
seaweedfs
'

if [ $# -gt 0 ];then
MODULES="$@"
fi

set -e
cd "$(dirname "$0")"

asdf install

for MODULE in $MODULES;do
  if ! [ -d "$MODULE" ];then
    continue
  fi

  (cd "$MODULE"; . deploy.sh)
done
