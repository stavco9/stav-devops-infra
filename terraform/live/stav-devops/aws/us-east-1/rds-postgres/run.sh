#!/bin/bash

if [ $# -lt 1 ]; then
    echo "You must specify one of the following: plan | apply"

    exit 1
fi

TF_MODE=$1

terraform fmt
terraform init

if [[ $TF_MODE == "plan" ]]; then
    terraform plan -out "plan.txt"
elif [[ $TF_MODE == "apply" ]]; then
    terraform apply --auto-approve "plan.txt" || terraform apply

    rm -rf plan.txt
else
    echo "You must specify one of the following: plan | apply"

    exit 1
fi
