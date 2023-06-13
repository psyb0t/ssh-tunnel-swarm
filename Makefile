SCRIPTS := logger.sh validators.sh rules.sh splitters.sh main.sh
MERGED_SCRIPT := build/ssh-tunnel-swarm

.PHONY: all clean build test

all: build

build:
	@mkdir -p build
	@echo '#!/bin/bash' > $(MERGED_SCRIPT)  # Add shebang
	@cat $(SCRIPTS) | grep -v '^source' >> $(MERGED_SCRIPT)  # Append script contents
	@chmod +x $(MERGED_SCRIPT)

clean:
	@rm -rf build

test:
	@./test.sh
