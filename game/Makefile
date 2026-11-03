.PHONY: help run format check build

.DEFAULT_GOAL := help

help:
	@echo "Available targets:"
	@echo "  run     - Start the game"
	@echo "  format  - Format all gdscript files"
	@echo "  check   - Check formatting of all gdscript files"
	@echo "  build   - Export Linux and Windows builds"

NIX := nix --extra-experimental-features 'nix-command flakes'

run:
	$(NIX) run .#run

format:
	$(NIX) run .#format

check:
	$(NIX) run .#check

build:
	$(NIX) run .#build
