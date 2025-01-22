.PHONY: default install format lint test

default: test

INSTALL_DIR ?= $(HOME)/Scripts

install:
	@if [ -n "$(to)" ]; then \
		target_dir="$(to)"; \
	else \
		read -p "Enter install target [$(INSTALL_DIR)]: " input; \
		target_dir=$${input:-$(INSTALL_DIR)}; \
	fi; \
	mkdir -p "$$target_dir"; \
	cp ./src/module.sh "$$target_dir/module"; \
	echo "Successfully installed to: $$target_dir"

format:
	@find ./src -type f -name "*.sh" -exec shfmt -d {} \;

lint:
	@find ./src -type f -name "*.sh" -exec shellcheck {} \;

test:
	@find ./src -type f -name "*.test.sh" -exec bash {} \;
