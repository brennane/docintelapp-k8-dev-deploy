#!/bin/bash

# https://gist.github.com/yuanying/3aa7d59dcce65470804ab43def646ab6
# attach to a volume for on-the-fly work

IMAGE="gcr.io/google-containers/ubuntu-slim:0.14"
COMMAND="/bin/bash"
SUFFIX=$(date +%s | shasum | base64 | fold -w 10 | head -1 | tr '[:upper:]' '[:lower:]')
NAMESPACE=$(kubectl config view --minify | pcregrep -o 'namespace: \K.*' || echo 'default')

usage_exit() {
    echo "Usage: $0 [-c command] [-i image] [-n namespace] PVC ..." 1>&2
    exit 1
}

while getopts n:c:i:h OPT
do
    case $OPT in
        i)  IMAGE=$OPTARG
            ;;
        c)  COMMAND=$OPTARG
            ;;
        n)  NAMESPACE=$OPTARG
            ;;
        h)  usage_exit
            ;;
        \?) usage_exit
            ;;
    esac
done
shift $(($OPTIND - 1))

VOL_MOUNTS=""
VOLS=""
COMMA=""

for i in $@
do
  VOL_MOUNTS="${VOL_MOUNTS}${COMMA}{\"name\": \"${i}\",\"mountPath\": \"/pvcs/${i}\"}"
  VOLS="${VOLS}${COMMA}{\"name\": \"${i}\",\"persistentVolumeClaim\": {\"claimName\": \"${i}\"}}"
  COMMA=","
done

kubectl --namespace ${NAMESPACE} run -it --rm --restart=Never --image=${IMAGE} pvc-mounter-${SUFFIX} --overrides "
{
  \"spec\": {
    \"hostNetwork\": true,
    \"containers\":[
      {
        \"args\": [\"${COMMAND}\"],
        \"stdin\": true,
        \"tty\": true,
        \"name\": \"pvc\",
        \"image\": \"${IMAGE}\",
        \"volumeMounts\": [
          ${VOL_MOUNTS}
        ]
      }
    ],
    \"volumes\": [
      ${VOLS}
    ]
  }
}
" -- ${COMMAND}
