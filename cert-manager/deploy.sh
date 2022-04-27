# deploy via cert-manager CLI
kubectl cert-manager x install

# deploy via OLM
#kubectl apply -k .

until kubectl get -o yaml crd/clusterissuers.cert-manager.io;do sleep 1; done
kubectl wait crd/clusterissuers.cert-manager.io --for condition=established 

until kubectl get -o yaml -n cert-manager deployment/cert-manager-webhook;do sleep 1; done
kubectl rollout status deployment -n cert-manager cert-manager-webhook -w
