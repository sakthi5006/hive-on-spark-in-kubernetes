#!/bin/sh

cd {{ tempDirectory }};

kubectl apply -f ingress-minio.yaml --kubeconfig={{ kubeconfig }};

