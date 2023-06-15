#!/bin/bash

set -e

echo "This script will create a Service Principal for Terraform to use to authenticate to your Azure subscription."

echo "Checking if Azure CLI is installed..."
if ! [ -x "$(command -v az)" ]; then
	echo "Azure CLI is not installed. Please install it from https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
	exit 1
fi

echo "Checking if account extension is installed..."

	EXT=$(az config get --query "extension.use_dynamic_install")
	if [ -z $EXT ]
	then
		az config set extension.use_dynamic_install=yes_without_prompt
	else
		echo "Enter a Service Principal Name to authenticate Terraform to your Azure subscription"
		read -p "Service Principal Name:  " spName
	fi
	SUBSCRIPTION_ID=$(az account show --query "id" -o tsv)

	createServiceprincipal
}

function createServiceprincipal {
	SERVICE_PRINCIPAL=$(az ad sp create-for-rbac --name $spName --role contributor --scopes /subscriptions/$SUBSCRIPTION_ID)
	echo $SERVICE_PRINCIPAL
}

initScript