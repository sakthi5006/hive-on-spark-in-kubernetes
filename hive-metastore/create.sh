#!/bin/sh

cd {{ tempDirectory }};

export KUBECONFIG={{ kubeconfig }};

# create mysql server.
kubectl apply -f mysql.yaml;

# wait for mysql pod being ready.
while [[ $(kubectl get pods -n {{ namespace }} -l app=mysql -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for mysql pod being ready" && sleep 1; done

# Update configmaps
kubectl create configmap metastore-cfg --dry-run --from-file=metastore-site.xml --from-file=core-site.xml -o yaml -n {{ namespace }} | kubectl apply -f -

# create secret for aws keys.
kubectl create secret generic my-s3-keys --from-literal=access-key='{{ accessKey }}' --from-literal=secret-key='{{ secretKey }}' -n {{ namespace }};

# create db schemas.
kubectl apply -f init-schema.yaml;

# create metastore.
kubectl apply -f metastore.yaml;

# wait for finishing creating schemas.
while [[ $(kubectl get pods -n {{ namespace }} -l job-name=hive-initschema -o jsonpath={..status.phase}) != *"Succeeded"* ]]; do echo "waiting for finishing init schema job" && sleep 2; done

# restart hive metastore: not efficient, but...
kubectl rollout restart deployment.apps/metastore -n {{ namespace }};


