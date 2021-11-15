#!/bin/bash
set -e

project_path=$(
    cd $(dirname $0)
    pwd
)
project_name=$(basename $0)

kubectl=kubectl
node=""
install=0
uninstall=0
temporary=0

function help() {
    echo "Usage:"
    echo "${project_name} {node} [options]"
    echo "  -h, --help: Print help"
    echo "  -n, --kubeconfig: The namespace scope for this CLI request"
    echo "  -i --install: If true, install the nodeshell daemonset"
    echo "  -u --uninstall: If true, uninstall the nodeshell daemonset"
    echo "  -t: If true, create a temporary nodeshell pod and exec"
    echo "  --kubeconfig: Path to kubeconfig file"
    exit 0
}

function install_ds() {
    ds_file="https://raw.githubusercontent.com/qingwave/kube-nodeshell/main/kube-nodeshell.yaml"
    $kubectl apply -f $ds_file
}

function uninstall_ds() {
    $kubectl delete ds kube-nodeshell
}

function exec_temporary_pod() {
    cmd='[ "nsenter", "--target", "1", "--mount", "--uts", "--ipc", "--net", "--pid", "--"]'
    overrides="$(
        cat <<EOT
{
  "spec": {
    "nodeName": "$node",
    "hostPID": true,
    "hostNetwork": true,
    "containers": [
      {
        "securityContext": {
          "privileged": true
        },
        "image": "alpine",
        "name": "nsenter",
        "stdin": true,
        "stdinOnce": true,
        "tty": true,
        "command": $cmd
      }
    ],
    "tolerations": [
      {
        "operator": "Exists"
      }
    ]
  }
}
EOT
    )"
    pod="kube-nodeshell-$(env LC_ALL=C tr -dc a-z0-9 </dev/urandom | head -c 6)"
    $kubectl run --image=alpine --restart=Never --rm --overrides="$overrides" -it $pod
}

function exec_daemonset_pod() {
    pod=$($kubectl get po --field-selector spec.nodeName=${node} -l app=kube-nodeshell -ojsonpath='{.items[?(@.status.phase=="Running")].metadata.name}')
    if [ -z $pod ]; then
        echo "failed to get pod in node/$node, please check daemonset kube-nodeshell status"
        exit
    fi
    $kubectl exec -it $pod bash
}

while [ $# -gt 0 ]; do
    key="$1"
    case $key in
    -h | --help)
        help
        ;;
    --kubeconfig)
        kubectl="$kubectl --kubeconfig $2"
        shift
        shift
        ;;
    -n | --namespace)
        kubectl="$kubectl --namespace $2"
        shift
        shift
        ;;
    -i | --install)
        install=1
        shift
        ;;
    -u | --uninstall)
        uninstall=1
        shift
        ;;
    -t)
        temporary=1
        shift
        ;;
    *)
        if [ -z "$node" ]; then
            node="$1"
            shift
        else
            echo "invalid parameter $key"
            exit 1
        fi
        ;;
    esac
done

if [ ${uninstall} -eq 1 ]; then
    uninstall_ds
    echo "success uninstall kube-nodeshell"
    exit 0
fi

if [ ${install} -eq 1 ]; then
    install_ds
    echo "success install kube-nodeshell"
    exit 0
fi

if [[ -z "$node" ]]; then
    echo "node is missing"
    help
fi

if [ "${temporary}" -eq 0 ]; then
    ds=$($kubectl get ds -l app=kube-nodeshell -ojsonpath='{.items[*].metadata.name}')
    if [ -z $ds ]; then
        temporary=1
    fi
fi

if [ "${temporary}" -eq 1 ]; then
    exec_temporary_pod
else
    exec_daemonset_pod
fi
