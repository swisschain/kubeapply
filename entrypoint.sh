#!/bin/bash

# exit when any command fails
set -e

# run checks
#git config --global --add safe.directory /github/workspace
LAST_COMMIT=$(git --no-pager log | head -1 | awk -F"it " '{print $2}')
echo LAST_COMMIT=$LAST_COMMIT
git --no-pager show $LAST_COMMIT

for i in $((
           for i in $(git --no-pager show $LAST_COMMIT | grep ^--- | awk -F"a/" '{print $2}');do echo $i; done
           for i in $(git --no-pager show $LAST_COMMIT | grep ^+++ | grep -v /dev/null | awk -F"b/" '{print $2}');do echo $i; done
           ) | sort | uniq )
do
  if [ -f $i ];then
    if grep "kind: Deployment\|kind: ConfigMap\|kind: Service\|kind: Secret" $i > /dev/null 2>&1;then
      echo $i
    fi
  fi
done
# apply
if [ "$APPLY" = "true" ];then
  echo APPLY
fi
