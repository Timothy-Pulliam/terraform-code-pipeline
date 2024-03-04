all: init plan build

init:
	terraform init -reconfigure -upgrade

plan:
	terraform plan -out tfplan.binary -refresh=true

json: init plan
	terraform show -json tfplan.binary > tfplan.json

apply:
	terraform apply -auto-approve tfplan

docs:
	terraform-docs markdown . > tfdocs.md

lint:
	tflint

cost: json
	infracost breakdown --path tfplan.json --usage-file infracost-usage.yml  --sync-usage-file --show-skipped

scan: json
	checkov -f tfplan.json

destroy:
	terraform destroy -force

graph:
	terraform graph | dot -Tpng > tfstate.png