#!/bin/sh

cd {{ tempDirectory }};

export KUBECONFIG={{ kubeconfig }};

# create minio tenant.
## Create Secret for Tenant Credentials
kubectl create secret generic {{ tenantName }}-secret \
--from-literal=accesskey={{ accessKey }} \
--from-literal=secretkey={{ secretKey }} \
--namespace {{ namespace }} \
--kubeconfig={{ kubeconfig }};

## Create MinIO Tenant.
kubectl minio tenant create \
--name {{ tenantName }} \
--secret {{ tenantName }}-secret \
--servers {{ servers }} \
--volumes {{ volumes }} \
--capacity {{ capacity }}Gi \
--namespace={{ namespace }} \
--image=minio/minio:{{ minioVersion }} \
--storage-class=direct.csi.min.io;