#!/bin/sh

cd {{ tempDirectory }};

# install direct csi.
DIRECT_CSI_DRIVES=data{1...{{ dataDirCount }}} DIRECT_CSI_DRIVES_DIR={{ dataRootPath }} kubectl apply -k . --kubeconfig={{ kubeconfig }};