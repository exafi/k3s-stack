kubectl create ns haproxy-ingress || true
kubectl kustomize --enable-helm | kubectl ${ACTION:-apply} -f -
