#!/bin/sh

cd {{ tempDirectory }};

export KUBECONFIG={{ kubeconfig }};

kubectl delete statefulsets.apps,deployment,svc,po --all -n minio-operator;

kubectl delete namespace minio-operator --kubeconfig={{ kubeconfig }};