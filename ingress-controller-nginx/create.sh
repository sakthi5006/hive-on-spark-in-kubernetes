#!/bin/sh

cd {{ tempDirectory }};

kubectl apply -f ingress-nginx-deploy.yaml --kubeconfig={{ kubeconfig }};