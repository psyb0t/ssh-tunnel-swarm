UID := $(shell id -u)
GID := $(shell id -g)
SCRIPTS := logger.sh validators.sh rules.sh splitters.sh main.sh
MERGED_SCRIPT := build/ssh-tunnel-swarm

# Lint and tests run in pinned images, so the host needs only Docker, Make and Bash.
SHELLCHECK_IMAGE ?= koalaman/shellcheck:v0.11.0@sha256:61862eba1fcf09a484ebcc6feea46f1782532571a34ed51fedf90dd25f925a8d
BASH_IMAGE       ?= bash:5.2.37@sha256:2cf7ddaf5f6369c16a0359e3bd48e54ada211a2e4e90d87532ad2958d642bdd5
SHELL_SOURCES    := $(shell git ls-files '*.sh')

.PHONY: all help build clean run lint test docs docs-build docs-lock

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

# The documentation site runs in a pinned Node container with install scripts
# disabled and a seven-day dependency age gate. The build itself has no network.
DOCS_NODE_IMAGE := node:24.21.0-bookworm-slim@sha256:d6aa754f16b3197301076f047b5def2f02ea1dbbc2ca920407d46d7ec7f87b20
DOCS_CACHE := .testing/docs-cache
DOCS_RUN := docker run --rm --init --cap-drop ALL --security-opt no-new-privileges:true \
	--user $(UID):$(GID) -e HOME=/tmp -e COREPACK_HOME=/cache/corepack \
	-v "$(CURDIR)/$(DOCS_CACHE):/cache" \
	-v "$(CURDIR)/docs:/work/docs:ro" -v "$(CURDIR)/website:/work/website" -w /work/website

docs: docs-build ## Build the documentation site into website/build and check its links

docs-build: | $(DOCS_CACHE)
	$(DOCS_RUN) $(DOCS_NODE_IMAGE) corepack pnpm install --frozen-lockfile --ignore-scripts --store-dir /cache/pnpm
	$(DOCS_RUN) --network none $(DOCS_NODE_IMAGE) corepack pnpm run build

docs-lock: | $(DOCS_CACHE) ## Refresh website/pnpm-lock.yaml from website/package.json
	$(DOCS_RUN) $(DOCS_NODE_IMAGE) corepack pnpm install --lockfile-only --ignore-scripts --store-dir /cache/pnpm

$(DOCS_CACHE):
	mkdir -p "$@"
