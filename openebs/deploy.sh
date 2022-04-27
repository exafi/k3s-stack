helm repo add openebs https://openebs.github.io/charts
helm repo update
helm upgrade -n openebs --create-namespace -i openebs openebs/openebs -f values.yaml
until kubectl get -n openebs -o yaml statefulset/openebs-lvm-localpv-controller;do
  sleep 1
done
kubectl rollout status -n openebs statefulset openebs-lvm-localpv-controller -w

: "${K8S_VG_PREFIX:=k8s-}"
: "${DEFAULT_STORAGE_CLASS:=hdd}"

LVMNODESJSON="$(kubectl get lvmnode -A -o json | jq -c '.items[]')"

DEPLOYED_ANY=no

for VOLGROUP in $(echo "$LVMNODESJSON" | jq -rc --arg pfx "$K8S_VG_PREFIX" '. as $node|.volumeGroups[]|. as $vg | $vg.name |select(startswith($pfx))' | sort | uniq);do
  DEPLOYED_ANY=yes
  VOLHOSTS_JSON="$(echo $LVMNODESJSON | jq -cs --arg vg "$VOLGROUP" '[.[]|select(.volumeGroups[].name|select(. == $vg))|.metadata.name]')"
  STORAGECLASS="${VOLGROUP#$K8S_VG_PREFIX}"
  STORAGECLASS_JSON="$(echo -n "$STORAGECLASS" |tr A-Z a-z| jq -Rs .)"
  VOLGROUP_JSON="$(echo -n "$VOLGROUP" | jq -Rs .)"

  # build the is-default-class annotation value
  DEFAULT_STORAGE_CLASS_JSON="\"false\""
  if [ x"$STORAGECLASS" = x"$DEFAULT_STORAGE_CLASS" ];then
    DEFAULT_STORAGE_CLASS_JSON="\"true\""
  fi

  echo '{
    "apiVersion": "storage.k8s.io/v1",
    "kind": "StorageClass",
    "metadata": {
      "name": '"$STORAGECLASS_JSON"',
      "annotations": {
        "storageclass.kubernetes.io/is-default-class": '"$DEFAULT_STORAGE_CLASS_JSON"'
      }
    },
    "parameters": {
      "storage": "lvm",
      "volgroup": '"$VOLGROUP_JSON"'
    },
    "provisioner": "local.csi.openebs.io",
    "reclaimPolicy": "Delete",
    "volumeBindingMode": "WaitForFirstConsumer",
    "allowedTopologies": [
      {
        "matchLabelExpressions": [
          {
            "key": "kubernetes.io/hostname",
            "values": '"$VOLHOSTS_JSON"'
          }
        ]
      }
    ]
  }' \
  | kubectl apply -f -
done

if [ "$DEPLOYED_ANY" = no ];then
  echo "NOTICE: ------------------------------------------------------------------------"
  echo "You have not setup any nodes with compatible LVM volume groups."
  echo "To do so, create a volume group out of which OpenEBS will allocate volumes"
  echo "on each host where storage should be located.  Because they are LVM volumes,"
  echo "the pod associated with the storage will be run from the node as well."
  echo "Compatible volume groups must be named ${K8S_VG_PREFIX}STORAGE_CLASS_NAME where"
  echo "STORAGE_CLASS_NAME is the name of a storage class which will be created"
  echo "utilizing the LVM volume groups."
  echo ""
  echo "Because of the need to colocate the pod with the storage, it is recommended"
  echo "that only system-level pods use LVM storage as primitives for an appropriate"
  echo "networked storage solution."
  echo "--------------------------------------------------------------------------------"
fi
