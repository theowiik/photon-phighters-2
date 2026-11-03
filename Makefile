.PHONY: help run format check build

.DEFAULT_GOAL := help

help:
	@echo "Available targets:"
	@echo "  run     - Start the game"
	@echo "  format  - Format all files"
	@echo "  check   - Check formatting, linting and naming"
	@echo "  build   - Export Linux and Windows builds"

NIX_SHELL := nix-shell -p python3Packages.mdformat ruff python3 nixfmt-rfc-style --run

format:
	$(NIX_SHELL) "mdformat . --wrap 88"
	$(NIX_SHELL) "ruff format ."
	$(NIX_SHELL) "ruff check --select I --fix ."
	$(NIX_SHELL) "nixfmt ."
	$(MAKE) -C game format

check:
	$(NIX_SHELL) "mdformat . --wrap 88 --check"
	$(NIX_SHELL) "ruff format --check ."
	$(NIX_SHELL) "ruff check --select I ."
	$(NIX_SHELL) "nixfmt . --check"
	$(NIX_SHELL) "python3 check_naming.py"
	$(MAKE) -C game check

run:
	$(MAKE) -C game run

build:
	$(MAKE) -C game build
