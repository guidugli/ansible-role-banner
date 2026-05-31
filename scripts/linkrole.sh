#!/bin/bash

NAMESPACE=$( grep namespace: meta/main.yml  | awk '{ print $2 }' )
ROLE=$( grep role_name: meta/main.yml  | awk '{ print $2 }' )

mkdir -p .ansible/roles
ln -sfn "$(pwd)" .ansible/roles/${NAMESPACE}.${ROLE}

