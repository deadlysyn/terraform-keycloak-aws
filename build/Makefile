BUILD_CMD := ./scripts/do.sh -b -e $(ENV)
DEPLOY_CMD := ./scripts/do.sh -d -e $(ENV)

help:
	@echo 'Build and Deploy Keycloak'
	@echo ''
	@echo 'Requirements:'
	@echo '  aws, docker, terraform'
	@echo ''
	@echo 'Usage:'
	@echo '  make <target> ENV=<environment_name>'
	@echo ''
	@echo 'Targets:'
	@echo '  make all            build and deploy'
	@echo '  make build          build keycloak container'
	@echo '  make deploy         deploy keycloak container'

deps:
	@echo 'Checking dependencies...'
	@which aws
	@which docker
	@which terraform

all: build deploy

build:
	$(BUILD_CMD)

deploy:
	$(DEPLOY_CMD)
