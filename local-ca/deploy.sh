kubectl apply -k .
kubectl wait clusterissuer/local-ca --for=condition=Ready
