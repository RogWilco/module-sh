
.PHONY: default test

default: test

test:
	@for file in ./src/*.test.sh; do \
		bash "$$file"; \
	done
