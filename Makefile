.PHONY: init plan apply destroy verify clean

init:
	bash scripts/init-localstack.sh
	terraform init

plan:
	terraform plan

apply:
	terraform apply -auto-approve

destroy:
	terraform destroy -auto-approve

verify:
	bash scripts/verify.sh

clean:
	rm -rf .terraform .terraform.lock.hcl terraform.tfstate*
