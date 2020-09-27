#!/bin/sh

cd {{ tempDirectory }};

export KUBECONFIG={{ kubeconfig }};

## Delete tenant.
kubectl minio tenant delete \
--name {{ tenantName }} \
--namespace={{ namespace }};