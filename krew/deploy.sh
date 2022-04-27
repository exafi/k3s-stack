MODULES='
cert-manager
openebs
'

for f in $MODULES;do
  kubectl krew install "$f"
done
