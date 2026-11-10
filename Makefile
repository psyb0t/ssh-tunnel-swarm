SCRIPTS := logger.sh validators.sh rules.sh splitters.sh main.sh
MERGED_SCRIPT := build/ssh-tunnel-swarm

# Lint and tests run in pinned images, so the host needs only Docker, Make and Bash.
SHELLCHECK_IMAGE ?= koalaman/shellcheck:v0.11.0@sha256:61862eba1fcf09a484ebcc6feea46f1782532571a34ed51fedf90dd25f925a8d
BASH_IMAGE       ?= bash:5.2.37@sha256:2cf7ddaf5f6369c16a0359e3bd48e54ada211a2e4e90d87532ad2958d642bdd5
JEKYLL_IMAGE     ?= ghcr.io/actions/jekyll-build-pages:v1.0.13@sha256:6791ebfd912185ed59bfb5fb102664fa872496b79f87ff8b9cfba292a7345041
SHELL_SOURCES    := $(shell git ls-files '*.sh')
DOCS_SITE        ?= .testing/docs-site

.PHONY: all help build clean run lint test docs

all: build

help: ## Show every target
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-8s\033[0m %s\n", $$1, $$2}'

build: ## Merge the sources into build/ssh-tunnel-swarm
	@mkdir -p build
	@echo '#!/bin/bash' > $(MERGED_SCRIPT)
	@cat $(SCRIPTS) | grep -v '^source' | sed '/^#!/,$$!d' | sed '/^\s*#/d' | sed '/^\s*$$/d' >> $(MERGED_SCRIPT)
	@chmod +x $(MERGED_SCRIPT)

clean: ## Remove build/
	@rm -rf build

run: ## Run main.sh from the source tree
	@bash main.sh

lint: ## Run shellcheck on every tracked shell script
	docker run --rm -v "$(CURDIR):/mnt:ro" -w /mnt $(SHELLCHECK_IMAGE) \
		--external-sources --source-path=SCRIPTDIR $(SHELL_SOURCES)

# Runs as the calling user: one test expects chmod u-r to block reads, which
# it does not for root.
test: ## Run the unit tests in the bash image
	docker run --rm \
		--user "$$(id -u):$$(id -g)" \
		-v "$(CURDIR):/src:ro" \
		-w /src \
		$(BASH_IMAGE) bash ./test.sh

# Builds docs/ with the image GitHub Pages uses, so the local result matches.
docs: ## Build the documentation site into .testing/docs-site
	@mkdir -p "$(DOCS_SITE)"
	docker run --rm \
		--user "$$(id -u):$$(id -g)" \
		-e HOME=/tmp \
		-e GITHUB_WORKSPACE=/work \
		-e GITHUB_REPOSITORY=psyb0t/ssh-tunnel-swarm \
		-e INPUT_SOURCE=docs \
		-e INPUT_DESTINATION="$(DOCS_SITE)" \
		-e INPUT_VERBOSE=false \
		-v "$(CURDIR):/work" \
		$(JEKYLL_IMAGE)
