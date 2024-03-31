REGION := $(AWS_REGION)

UNAME := $(shell uname)
ifeq ($(UNAME), Darwin)
SED_ARGS := -i ''
else
SED_ARGS := -i
endif

.PHONY: help all deps init applyprep applyandmigrate update destroyprep destroy

help:
	@echo 'Manage Keycloak Infrastructure'
	@echo ''
	@echo 'Requirements:'
	@echo '  terraform'
	@echo ''
	@echo 'Usage:'
	@echo '  make all             create environment with remote state'
	@echo '  make update          update environment'
	@echo '  make destroy         destroy environment'

all: deps init applyandmigrate

deps:
	@echo 'Checking dependencies...'
	@which terraform

init:
	terraform init

applyprep:
	@sed $(SED_ARGS) \
		-e 's/\(terraform_backend_config_file_path.*=\).*/\1 "."/g' \
		-e 's/\(\s*\)#\(\s*terraform_backend_config_file_name.*\)/\1\2/g' \
		-e 's/\(force_destroy.*=\).*/\1 false/g' main.tf

applyandmigrate: applyprep
	terraform apply -parallelism=20 -auto-approve
	terraform init -force-copy

update: applyprep
	terraform apply -parallelism=20

destroyprep:
	@sed $(SED_ARGS) \
		-e 's/\(terraform_backend_config_file_path.*=\).*/\1 ""/g' \
		-e 's/\(\s*\).*\(terraform_backend_config_file_name.*\)/\1#\2/g' \
		-e 's/\(force_destroy.*=\).*/\1 true/g' main.tf

destroy: destroyprep
	terraform apply -target module.terraform_state_backend -auto-approve
	terraform init -force-copy
	terraform destroy -parallelism=20

clean: applyprep
	@rm -f backend.tf
	@terraform destroy
