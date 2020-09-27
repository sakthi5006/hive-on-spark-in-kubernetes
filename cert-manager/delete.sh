#!/bin/sh

cd {{ tempDirectory }};

export KUBECONFIG={{ kubeconfig }};

# delete cluster issuer.
kubectl delete -f prod-issuer.yaml;

# create cert-manager.
kubectl delete -f https://github.com/jetstack/cert-manager/releases/download/v{{ version }}/cert-manager.yaml;
