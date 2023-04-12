#!/bin/bash

# exit when any command fails
set -e

# functions
check_for_kube_file() {
  if grep "kind: Deployment\|kind: ConfigMap\|kind: Service\|kind: Secret" $FILE > /dev/null 2>&1;then
    return 0
  else
    return 1
  fi
}

check_and_apply() {
if check_for_kube_file;then
  echo dry run client
  /usr/local/bin/kubectl apply --dry-run='client' -f $FILE
  echo dry run server
  /usr/local/bin/kubectl apply --dry-run='server' -f $FILE
  if [ "$APPLY" = "true" ];then
    echo APPLY $FILE
    /usr/local/bin/kubectl apply -f $FILE
  fi
else
  echo $FILE not valid kube file
fi
}

#check_and_delete() {
#if check_for_kube_file;then
#  echo dry run client
#  /usr/local/bin/kubectl delete --dry-run='client' -f $FILE
#  echo dry run server
#  /usr/local/bin/kubectl delete --dry-run='server' -f $FILE
#  if [ "$APPLY" = "true" ];then
#    echo DELETE $FILE
#    /usr/local/bin/kubectl delete -f $FILE
#  fi
#else
#  echo $FILE not valid kube file
#fi
#}

# run checks
#DELETED_FILES=/tmp/deleted_files
#echo > $DELETED_FILES
#rm $DELETED_FILES
echo get kube config
echo "$KUBE_CONFIG_DATA" | /bin/base64 -d > /tmp/config
export KUBECONFIG=/tmp/config
echo get kube nodes
/usr/local/bin/kubectl get nodes
echo get git changes
/usr/bin/git config --global --add safe.directory /github/workspace
if [ "$LOG" = "DEBUG" ];then
  echo GITHUB_EVENT=$GITHUB_EVENT
fi
LAST_COMMIT=$(echo $GITHUB_EVENT | /usr/bin/jq -r .after)
echo LAST_COMMIT=$LAST_COMMIT
PREV_COMMIT=$(echo $GITHUB_EVENT | /usr/bin/jq -r .before)
echo PREV_COMMIT=$PREV_COMMIT
#
echo found commits...
echo $GITHUB_EVENT | /usr/bin/jq -r '.commits[] | "\"\(.message)\" (\(.id))"'
echo get changed files...
for FILE in $((
                /usr/bin/git diff --name-only $PREV_COMMIT $LAST_COMMIT
              ) | sort | grep $PATH)
do
  echo -=[ processing $FILE ]=-
  if [ -f $FILE ];then
    check_and_apply
  else
    echo file $FILE looks like deleted - will check
    echo $FILE >> $DELETED_FILES
  fi
done
# 
#if [ -f "$DELETED_FILES" ];then
#  echo check for deleted files
#  /usr/bin/git checkout $PREV_COMMIT > /dev/null 2>&1
#  if [ "$LOG" = "DEBUG" ];then
#    echo cat DELETED_FILES=$DELETED_FILES
#    cat $DELETED_FILES
#  fi
#  for FILE in $(cat $DELETED_FILES)
#  do
#    echo -=[ processing $FILE ]=-
#    if [ -f $FILE ];then
#      check_and_delete
#    else
#      echo can not find $FILE
#    fi
#  done
#  rm $DELETED_FILES
#else
#  echo check for deleted files skipped
#fi
rm $KUBECONFIG
