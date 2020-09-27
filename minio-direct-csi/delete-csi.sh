#!/bin/sh

cd {{ tempDirectory }};

# delete direct csi.
kubectl delete -k . --kubeconfig={{ kubeconfig }};