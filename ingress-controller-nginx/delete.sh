#!/bin/sh

cd {{ tempDirectory }};

kubectl delete -f ingress-nginx-deploy.yaml --kubeconfig={{ kubeconfig }};