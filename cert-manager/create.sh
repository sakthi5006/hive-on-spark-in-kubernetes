#!/bin/sh

cd {{ tempDirectory }};

export KUBECONFIG={{ kubeconfig }};

# create cert-manager.
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v{{ version }}/cert-manager.yaml;

# wait for pod being run.
while [[ $(kubectl get pods -n cert-manager -l app=webhook -o jsonpath={..status.phase}) != *"Running"* ]]; do echo "waiting for running webhook" && sleep 2; done

echo "sleep 10s....";
sleep 20;

# create cluster issuer.
kubectl apply -f prod-issuer.yaml;

