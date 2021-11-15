# Kube-nodeshell
Access to kubernetes node via nsenter

## Install
```bash
wget https://github.com/qingwave/kube-nodeshell/kube-nodeshell.sh
chmod +x ./kube-nodeshell.sh
```

## Usage
Access to a sepcial node temporarily, will create a pod and exec into it
```bash
./kube-nodeshell.sh {node_name}
```

Insatll kube-nodeshell daemonset on all node for frequently used
```bash
# install daemonset
./kube-nodeshell.sh -i

# access to node
./kube-nodeshell.sh {node_name}
```

Others:
```bash
./kube-nodeshell.sh -h
```

## Kubectl Plugin
Install kubectl plugin
```bash
chmod +x ./kube-nodeshell.sh
# make sure /usr/local/bin in your PATH
sudo mv ./kube-nodeshell.sh /usr/local/bin/kubectl-nodeshell
```

Using kubectl plugin
```bash
# access to a node
kubectl nodeshell {node_name}

# install daemonset
kubectl nodeshell -i
```

## Links
- https://qingwave.github.io/k8s-debug-nsenter
