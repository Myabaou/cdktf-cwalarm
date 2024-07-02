# (ex)
# cdktfの場合: make diff
# terraformの場合: make _TF=true "state list"

_AWSPROFILE=aws-sample
_TF ?= false
_EXEC ?= docker
CURRENT_DIR = $(shell pwd)

ifeq (,$(filter $(_EXEC),docker finch local))
$(error Invalid EXEC variable. It should be either 'docker' or 'finch' or 'local')
endif

.PHONY: ensure-aws-auth costview install

install:
	npm install @cdktf/provider-aws
	npm install --save-dev @types/node
	npm install --save-dev @types/papaparse
	npm install papaparse

build:
	${_EXEC} compose build

up:
	${_EXEC} compose up -d --build



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
	${_EXEC} run -it --rm -v $(CURRENT_DIR):/app -v ~/.aws:/root/.aws -e AWS_PROFILE=$(_AWSPROFILE) -w /app cdktf-docker:latest cdktf $@
endef


%:
	@make ensure-aws-auth

	@if [ "$(_TF)" = "true" ]; then \
		echo "[CMD]: $(TERRAFORM_CMD)"; \
		$(TERRAFORM_CMD); \
	elif [ "$(_EXEC)" = "docker" ] || [ "$(_EXEC)" = "finch" ]; then \
        echo "[CMD]: $(DOCKER_EXEC)"; \
        $(DOCKER_EXEC); \
	else \
		echo "[CMD]: $(CDKTF_CMD)"; \
		$(CDKTF_CMD); \
	fi;

