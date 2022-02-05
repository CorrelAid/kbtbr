# Main ideas from: github.com/yihui/knitr
# Adapted by: MK

# Main variables
PKG_NAME := $(shell sed -n "s/Package: *\([^ ]*\)/\1/p" DESCRIPTION)
PKG_VERS := $(shell sed -n "s/Version: *\([^ ]*\)/\1/p" DESCRIPTION)
PKG_SRC := $(shell basename `pwd`)

# For releases: GIT informations
GIT_BRANCH := $(shell git branch --show-current)
GIT_LAST_COMMIT := $(shell git log -1 --pretty=%s)
LATEST_TAG := $(shell git tag -l --sort -version:refname | head -n1)

.PHONY: test docs deps build build-cran install check format clean release


# Update Code (docs, format) --------------------------------------------------

docs:
	@Rscript -e "devtools::document()"
format:
	@Rscript -e "styler::style_pkg(style = styler::tidyverse_style, indent_by = 2)"

# Build / Check / Test --------------------------------------------------------

test:
	@Rscript -e "devtools::test()"

build:
	R CMD build --no-manual ./

build-cran:
	R CMD build ./

install: build
	R CMD INSTALL $(PKG_NAME)_$(PKG_VERS).tar.gz

check: build-cran
	R CMD check $(PKG_NAME)_$(PKG_VERS).tar.gz --as-cran

# GitHub Interaction ----------------------------------------------------------

release:
ifneq ($(GIT_BRANCH), main)
	$(error Releases only possible from 'main', but branch is $(GIT_BRANCH))
else ifeq ($(PKG_VERS), $(LATEST_TAG))
	$(error Current version is identical to latest known release.)
else ifeq ($(shell printf '%s\n' $(PKG_VERS) $(LATEST_TAG)), $(PKG_VERS))
	$(error Current version is below latest known release.)
else
	git tag $(PKG_VERS) \
		&& git push origin $(PKG_VERS) \
		&& gh release create $(PKG_VERS) -t $(GIT_LAST_COMMIT)
	@echo "Created release '$(PKG_VERS) - $(GIT_LAST_COMMIT)'"
endif

# Other utilities -------------------------------------------------------------

renv_deps:
	@Rscript -e "renv::install()"

clean:
	@rm -rf \
		$(PKG_NAME).Rcheck \
		$(PKG_NAME)_$(PKG_VERS).tar.gz
