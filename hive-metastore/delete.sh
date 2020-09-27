#!/bin/sh

cd {{ tempDirectory }};

export KUBECONFIG={{ kubeconfig }};

# delete metastore.
kubectl delete -f metastore.yaml;

# delete job.
kubectl delete job hive-initschema -n {{ namespace }};

# create secret for aws keys.
kubectl delete secret my-s3-keys -n {{ namespace }};

# delete mysql server.
kubectl delete -f mysql.yaml;
