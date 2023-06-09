.PHONY: all init plan apply destroy

all: init plan apply destroy

init:
	@terraform init

plan:
	@terraform plan -var-file variables.auto.tfvars -out tfplan

apply:
	@terraform apply tfplan

destroy:
	@terraform plan -destroy -var-file variables.auto.tfvars -out tfplan
	@terraform apply tfplan