# Kube-nodeshell
Access to kubernetes node via `nsenter`, similar with `kubectl debug` but more powerful

## Install
```bash
wget https://github.com/qingwave/kube-nodeshell/kube-nodeshell.sh
chmod +x ./kube-nodeshell.sh
# [optional] install kubectl plugin, make sure /usr/local/bin in your PATH
sudo mv ./kube-nodeshell.sh /usr/local/bin/kubectl-nodeshell
```

## Usage
You can use the script `kube-nodeshell.sh` directly, or use kubectl plugin `kubectl nodeshell` 

Access to a special node temporarily, will create a pod and exec into it
```bash
kubectl nodeshell {node_name}
```

Install kube-nodeshell daemonset on all node for frequently used
```bash
# install daemonset
kubectl nodeshell -i

# access to node
kubectl nodeshell {node_name}
```

Others:
```bash
kubectl nodeshell -h
```

## Links
- https://qingwave.github.io/k8s-debug-nsenter
