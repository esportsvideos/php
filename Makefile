IMAGE_NAME=ghcr.io/esportsvideos/php
HADOLINT_VERSION=v2.14.0-alpine
TRIVY_VERSION=0.71.0
CST_VERSION=v1.22.1

HADOLINT = docker run --rm -i hadolint/hadolint:$(HADOLINT_VERSION)
TRIVY = docker run --rm -e GITHUB_TOKEN -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:$(TRIVY_VERSION)
TRIVY_OPTS = image --scanners vuln --severity HIGH,CRITICAL --ignore-unfixed
TRIVY_SCAN = $(TRIVY) $(TRIVY_OPTS) --exit-code 1
TRIVY_REPORT = $(TRIVY) $(TRIVY_OPTS) --format table
CST_BIN = .bin/container-structure-test
CST_URL = https://github.com/GoogleContainerTools/container-structure-test/releases/download/$(CST_VERSION)/container-structure-test-linux-amd64
# Overridable so CI can point the tests at the freshly-built remote tags.
TEST_PROD_IMG = $(IMAGE_NAME):local
TEST_DEV_IMG = $(IMAGE_NAME):local-dev

##
###--------------#
###    Docker    #
###--------------#
##

build: build-prod build-dev ## Build all images

build-prod: ## Build prod image
	docker build --target php_prod -t $(IMAGE_NAME):local .

build-dev: ## Build dev image
	docker build --target php_dev -t $(IMAGE_NAME):local-dev .

.PHONY: build build-prod build-dev

##
###-----------------#
###    Q&A tools    #
###-----------------#
##

lint: # Lint the Dockerfile with Hadolint
	$(HADOLINT) < Dockerfile

scan: scan-prod scan-dev ## Scan all locally-built images for vulnerabilities

scan-prod: build-prod ## Scan the prod locally-built images for vulnerabilities
	$(TRIVY_SCAN) $(IMAGE_NAME):local

scan-dev: build-dev ## Scan the dev locally-built images for vulnerabilities
	$(TRIVY_SCAN) $(IMAGE_NAME):local-dev

# Report-only scan (no gate) of an arbitrary image — used by CI for the job
# summary. Output is the bare table, so the recipe is silenced with @.
scan-report: ## Report-only Trivy scan of IMG (no gate). Usage: make scan-report IMG=...
	@$(TRIVY_REPORT) $(IMG)

.PHONY: lint scan scan-prod scan-dev scan-report

##
###-------------#
###    Tests    #
###-------------#
##

$(CST_BIN): ## Download the pinned container-structure-test binary (cached in .bin/).
	mkdir -p .bin
	curl -fsSL $(CST_URL) -o $(CST_BIN)
	chmod +x $(CST_BIN)

test: test-prod test-dev ## Structure-test all images

test-prod: $(CST_BIN) ## Structure-test the prod image
	$(CST_BIN) test --image $(TEST_PROD_IMG) --config container-structure-test.yaml

test-dev: $(CST_BIN) ## Structure-test the dev image
	$(CST_BIN) test --image $(TEST_DEV_IMG) --config container-structure-test.dev.yaml

.PHONY: test test-prod test-dev

##
###--------------------#
###    Help & Others   #
###--------------------#
##

.DEFAULT_GOAL := help

help: ## Display help messages from Makefile
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-20s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

.PHONY: help
