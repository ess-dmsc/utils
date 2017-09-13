INSTALL = /usr/bin/install

prefix = /usr/local
bindir = $(prefix)/bin

SCRIPTS = \
	clangformatdiff.sh \
	make_conan_package.sh \
	upload_conan_package.sh

.PHONY: install
install: $(SCRIPTS)
	install -d $(bindir)
	install $(SCRIPTS) $(bindir)
