#!/bin/sh

BRICKS="
d6ef7314-1c2c-477b-81c0-9c009a61794d
870ea1c4-e863-4944-977b-830d3fe120e1
a0e476b8-f209-48b5-9004-37910d58e8e1
"

for BRICK in $BRICKS;do
  if [ "$1" = "-u" ];then
    helm uninstall weed-volume-$BRICK
  else
    helm upgrade -i weed-volume-$BRICK --set brickId=$BRICK .
  fi
done
