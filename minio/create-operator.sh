#!/bin/sh

cd {{ tempDirectory }};

export MINIO_OPERATOR_VERSION={{ version }};
export KUBECONFIG={{ kubeconfig }};

# install minio plugin.
wget https://github.com/minio/operator/releases/download/v${MINIO_OPERATOR_VERSION}/kubectl-minio_${MINIO_OPERATOR_VERSION}_linux_amd64;
sudo cp kubectl-minio_${MINIO_OPERATOR_VERSION}_linux_amd64 /usr/local/bin;
sudo chmod +x /usr/local/bin/kubectl-minio_${MINIO_OPERATOR_VERSION}_linux_amd64;
sudo mv /usr/local/bin/kubectl-minio_${MINIO_OPERATOR_VERSION}_linux_amd64 /usr/local/bin/kubectl-minio;

## first, delete resources related to operator.
kubectl delete customresourcedefinitions.apiextensions.k8s.io tenants.minio.min.io --kubeconfig={{ kubeconfig }};
kubectl delete clusterrole minio-operator-role --kubeconfig={{ kubeconfig }};
kubectl delete clusterrolebindings.rbac.authorization.k8s.io minio-operator-binding --kubeconfig={{ kubeconfig }};
kubectl delete po,deployment,sa --all -n minio-operator --kubeconfig={{ kubeconfig }};

kubectl create namespace minio-operator --kubeconfig={{ kubeconfig }};

## create operator.
kubectl minio operator create \
--image=minio/k8s-operator:v${MINIO_OPERATOR_VERSION} \
--namespace=minio-operator \
--cluster-domain=cluster.local;


# edit minio operator role.
cat <<EOF > minio-operator-role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: minio-operator-role
rules:
- apiGroups: [""]
  resources: ["persistentvolumes"]
  verbs: ["get", "list", "watch", "create", "delete"]
- apiGroups: [""]
  resources: ["persistentvolumeclaims"]
  verbs: ["get", "list", "watch", "update"]
- apiGroups:
  - ""
  resources:
  - namespaces
  - secrets
  - pods
  - services
  - events
  verbs:
  - get
  - watch
  - create
  - list
  - delete
  - deletecollection
- apiGroups:
  - apps
  resources:
  - statefulsets
  - deployments
  verbs:
  - get
  - create
  - list
  - patch
  - watch
  - update
  - delete
- apiGroups:
  - batch
  resources:
  - jobs
  verbs:
  - get
  - create
  - list
  - patch
  - watch
  - update
  - delete
- apiGroups:
  - certificates.k8s.io
  resources:
  - certificatesigningrequests
  - certificatesigningrequests/approval
  - certificatesigningrequests/status
  verbs:
  - update
  - create
  - get
  - delete
- apiGroups:
  - certificates.k8s.io
  resourceNames:
  - kubernetes.io/legacy-unknown
  resources:
  - signers
  verbs:
  - approve
  - sign
- apiGroups:
  - minio.min.io
  resources:
  - '*'
  verbs:
  - '*'
- apiGroups:
  - min.io
  resources:
  - '*'
  verbs:
  - '*'
EOF

kubectl apply -f minio-operator-role.yaml  --kubeconfig={{ kubeconfig }};