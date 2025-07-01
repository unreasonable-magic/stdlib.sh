PREFIX ?= /usr/local
BINDIR := $(PREFIX)/bin

.PHONY: test
test:
	bundle
	@for test in $$(find test -name "*.sh"); do \
		echo "$$test"; \
		bash "$$test"; \
	done
.PHONY: manpages
manpages:
	find lib -name "*.adoc" | xargs
	@for adoc in $$(find lib -name "*.adoc"); do \
		echo "$$adoc"; \
		stdlib file/dirname "$$adoc" | sed "s/lib\///g"  | xargs -I DIR mkdir -p "share/man/DIR"; \
		asciidoctor -b manpage "$$adoc" -D share/man/ -v; \
	done
