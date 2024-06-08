# (ex)
# cdktfの場合: make diff
# terraformの場合: make _TF=true "state list"

_AWSPROFILE=aws-sample
_TF ?= false


.PHONY: ensure-aws-auth costview install

install:
	npm install @cdktf/provider-aws
	npm install --save-dev @types/node
	npm install --save-dev @types/papaparse
	npm install papaparse

build:
	docker compose build

up:
	docker compose up -d --build



# AWS SSO 認証していない場合再認証
ensure-aws-auth:
	@{ \
	set +e ;\
	IDENTITY=$$(aws sts get-caller-identity --profile $(_AWSPROFILE) 2>&1) ;\
	if echo $$IDENTITY | grep -q 'The SSO session associated with this profile has expired or is otherwise invalid' ; then \
		aws sso login --profile $(_AWSPROFILE) ;\
	else \
		echo "[INFO]: AWS SSO $(_AWSPROFILE) Authentication successful!" ;\
	fi \
	}


# 	aws-vault exec $(_AWSPROFILE) -- terraform -chdir="cdktf.out/stacks/${_environment}" $@
define TERRAFORM_CMD
	aws-vault exec $(_AWSPROFILE) -- terraform -chdir="cdktf.out/stacks/cloudwatch_alarm" $(subst $() ,$() ,$@)
endef

define CDKTF_CMD
	aws-vault exec $(_AWSPROFILE) -- cdktf $@
endef

# Docker Exec
define DOCKER_EXEC
	docker compose run -e AWS_PROFILE=$(_AWSPROFILE) cdk-tf cdktf $@
endef


%:
	@make ensure-aws-auth 
	@if [ "$(_TF)" = "true" ]; then \
		echo "[CMD]: $(TERRAFORM_CMD)"; \
		$(TERRAFORM_CMD); \
	elif [ "$(_DK)" = "true" ]; then \
		echo "[CMD]: $(DOCKER_EXEC)"; \
		$(DOCKER_EXEC); \
	else \
		echo "[CMD]: $(CDKTF_CMD)"; \
		$(CDKTF_CMD); \
	fi;

