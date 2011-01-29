SHELL=/bin/bash

all: dist

dist:
	@rm supertab.vba 2> /dev/null || true
	@vim -c 'r! git ls-files doc plugin' \
		-c '$$,$$d _' -c '%MkVimball supertab.vba .' -c 'q!'

clean:
	@rm -R build 2> /dev/null || true
