REGION := $(AWS_REGION)
VAULT_CMD := aws-vault exec $(AWS_PROFILE) --duration=1h --
TF_CMD := terraform
CMD := $(VAULT_CMD) $(TF_CMD)

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
	@echo '  aws-vault, terraform'
	@echo ''
	@echo 'Usage:'
	@echo '  make all             create environment with remote state'
	@echo '  make update          update environment'
	@echo '  make destroy         destroy environment'

all: deps init applyandmigrate

deps:
	@echo 'Checking dependencies...'
	@which aws-vault
	@which terraform

init:
	$(CMD) init

applyprep:
	@sed $(SED_ARGS) \
		-e 's/\(terraform_backend_config_file_path.*=\).*/\1 "."/g' \
		-e 's/\(\s*\)#\(\s*terraform_backend_config_file_name.*\)/\1\2/g' \
		-e 's/\(force_destroy.*=\).*/\1 false/g' main.tf

applyandmigrate: applyprep
	$(CMD) apply -parallelism=20 -auto-approve
	$(CMD) init -force-copy

update: applyprep
	$(CMD) apply -parallelism=20

destroyprep:
	@sed $(SED_ARGS) \
		-e 's/\(terraform_backend_config_file_path.*=\).*/\1 ""/g' \
		-e 's/\(\s*\).*\(terraform_backend_config_file_name.*\)/\1#\2/g' \
		-e 's/\(force_destroy.*=\).*/\1 true/g' main.tf

destroy: destroyprep
	$(CMD) apply -target module.terraform_state_backend -auto-approve
	$(CMD) init -force-copy
	$(CMD) destroy -parallelism=20

# NEED TO TEST
clean: applyprep
	@rm -f backend.tf
	@terraform destroy
