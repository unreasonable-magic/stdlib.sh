PREFIX ?= /usr/local
BINDIR := $(PREFIX)/bin

.PHONY: test
test:
	@for test in $$(find test -name "*.sh"); do \
		echo "$$test"; \
		bash "$$test"; \
	done

.PHONY: manpages
manpages:
	rm -rf tmp/man; \
	bundle exec asciidoctor -b manpage  -D tmp/man/ -v "docs/*.adoc"; \

.PHONY: docs
docs:
	bundle exec asciidoctor --attribute relfilesuffix=.html -b html -D tmp/html/ -v "docs/*.adoc"; \
	open tmp/html/stdlib.html;

.PHONY: install
install:
	cp tmp/man/* /opt/homebrew/share/man/man1/;
