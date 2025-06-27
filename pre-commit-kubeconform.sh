#!/bin/bash

if ! command -v kubeconform > /dev/null 2>&1 ; then
  echo "Please install kubeconform - https://github.com/yannh/kubeconform"
  exit 1
fi

filename=$1

kubeconform -verbose \
  -schema-location default -schema-location \
  'https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json' \
  $filename
