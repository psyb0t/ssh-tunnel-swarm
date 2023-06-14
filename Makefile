SCRIPTS := logger.sh validators.sh rules.sh splitters.sh main.sh
MERGED_SCRIPT := build/ssh-tunnel-swarm

.PHONY: all clean build test

all: build

build:
	@mkdir -p build
	@echo '#!/bin/bash' > $(MERGED_SCRIPT)
	@cat $(SCRIPTS) | grep -v '^source' | sed '/^#!/,$$!d' | sed '/^\s*#/d' | sed '/^\s*$$/d' >> $(MERGED_SCRIPT)
	@chmod +x $(MERGED_SCRIPT)

clean:
	@rm -rf build

test:
	@./test.sh
