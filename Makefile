PREFIX ?= /usr/local
BINDIR := $(PREFIX)/bin

.PHONY: test
test:
	bash test/string/capitalize.sh
	bash test/string/titleize.sh
	bash test/string/contains.sh
	bash test/string/lowercase.sh
	bash test/string/uppercase.sh
	bash test/string/trim.sh
.PHONY: manpages
manpages:
	asciidoctor -b manpage lib/url/parse.adoc -D share/man/
