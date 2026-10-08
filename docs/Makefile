# Minimal makefile for nson Sphinx + Doxygen documentation.
# Usage:
#   make html       # generate HTML docs into _build/html
#   make clean      # remove all build output

SPHINXOPTS    ?=
SPHINXBUILD   ?= sphinx-build
DOXYGEN       ?= doxygen
SOURCEDIR     = .
BUILDDIR      = _build

.PHONY: help doxygen html clean

help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS)
	@echo "  doxygen     regenerate Doxygen XML (dependency of html)"

doxygen:
	@mkdir -p "$(BUILDDIR)/doxygen"
	@$(DOXYGEN) Doxyfile

html: doxygen
	@$(SPHINXBUILD) -M html "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS)

clean:
	rm -rf "$(BUILDDIR)"

# Give the makefile itself an explicit empty rule, so the catch-all below is never
# used to "remake" it (which would invoke sphinx-build with a builder named Makefile).
Makefile: ;

# Catch-all: forward any other target to sphinx-build after regenerating Doxygen XML.
%: doxygen
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS)
