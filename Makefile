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
	asciidoctor -b manpage "lib/**/*.adoc" -D share/man/ -v;

.PHONY: install
install:
	cp share/man/* /opt/homebrew/share/man/man1/;
