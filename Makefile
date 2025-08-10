.PHONY: test install clean help

help: ## Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

test: ## Run tests
	@tests/run.sh

install: ## Install the theme for the current user
	@echo "Installing purity-enhanced theme..."
	@mkdir -p ~/.config/zsh/themes
	@cp purity-enhanced.zsh ~/.config/zsh/themes/
	@echo "Theme installed to ~/.config/zsh/themes/"
	@echo "Add 'source ~/.config/zsh/themes/purity-enhanced.zsh' to your .zshrc"

clean: ## Clean up test artifacts
	@rm -rf vendor/ async.zsh
	@echo "Cleaned up test artifacts"