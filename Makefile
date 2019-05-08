INSTALL = /usr/bin/install

prefix = /usr/local
bindir = $(prefix)/bin

SCRIPTS = \
	clangformatdiff.sh \
	filter-make-output \
	make_conan_package.sh \
	upload_conan_package.sh

VERSIONING_SCRIPTS = \
	versioning/create-major-release

.PHONY: install versioning
install: $(SCRIPTS)
	install -d $(bindir)
	install $(SCRIPTS) $(bindir)

versioning: $(VERSIONING_SCRIPTS)
	install -d $(bindir)
	install $(VERSIONING_SCRIPTS) $(bindir)
