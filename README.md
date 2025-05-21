# K8S-scale-namespace

This script provides a way to **scale down or scale up all Deployments and StatefulSets** in a specified Kubernetes namespace, within a given cluster context. It is useful for saving cluster resources or pausing workloads in non-production environments.

---

## 🔧 Features

- **Scale down**: Saves current replica counts as a label, then scales resources to 0.
- **Scale up**: Restores resources to their original replica counts using saved labels.
- Supports both `deployments` and `statefulsets`.
- Uses `kubectl` and `jq`.

---

## 📋 Requirements

- `kubectl` must be installed and configured with access to your clusters.
- `jq` must be installed.
- Sufficient Kubernetes RBAC permissions to `get`, `scale`, and `label` resources.

---

## 🚀 Usage

```bash
./scale-ns.sh <cluster-name> <namespace> [up|down]
```

### Parameters

- `<cluster-name>`: The name of the Kubernetes context (as shown by `kubectl config get-contexts`)
- `<namespace>`: The Kubernetes namespace to scale
- `[up|down]`: `down` to scale resources to 0, `up` to restore them

### Examples

```bash
# Scale down all resources in staging namespace on dev-cluster
./scale-ns.sh dev-cluster staging down

# Scale up previously scaled down resources
./scale-ns.sh dev-cluster staging up
```

---

## 🧩 Improvements You Could Add

- Dry-run mode to simulate changes
- Support for more Kubernetes resource types
- Logging to file or JSON output
- Shell completion or flag parsing using `getopts` or `argbash`

---

## 🔐 License

MIT License. Free to use and adapt as needed.
