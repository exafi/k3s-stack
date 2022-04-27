helm upgrade -i -n seaweedfs --create-namespace seaweedfs         ./seaweedfs
helm upgrade -i -n seaweedfs                    seaweedfs-sc-hdd  ./seaweedfs-volume --set storageClass=hdd --set volumes=4 --set weedmaster=seaweedfs-master:9333 --set size=4Gi
helm upgrade -i -n seaweedfs                    seaweedfs-sc-ssd  ./seaweedfs-volume --set storageClass=ssd --set volumes=2 --set weedmaster=seaweedfs-master:9333 --set size=1Gi
