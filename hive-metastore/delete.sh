#!/bin/sh

export MY_NAMESPACE=my-namespace

# delete metastore.
kubectl delete -f metastore.yaml;

# delete job.
kubectl delete job hive-initschema -n ${MY_NAMESPACE};

# create secret for aws keys.
kubectl delete secret my-s3-keys -n ${MY_NAMESPACE};

# delete mysql server.
kubectl delete -f mysql.yaml;
