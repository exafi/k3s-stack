. ./lib.sh

if kubectl get nodes;then
  if [ x"$K3S_DEFINITELY_INSTALL_OVER_EXISTING_CLUSTER" = xyes ];then
    exit 0
  fi
  echo "About to deploy on the existing cluster:"
  kubectl cluster-info
  echo "Ctrl-C to cancel"
  sleep 30 || exit 1
  exit 0
fi

# expanding weirdly because zsh
install_servers $(echo "$SERVERS")
install_agents $(echo "$NODES")
