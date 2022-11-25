# This Makefile contains the main targets for all supported language runtimes

run-mysql:
	nix run nixpkgs#wasmedge -- --enable-all --dir .:. php/build-output/php/php-7.4.32/bin/php mysql.php

run-hello:
	nix run nixpkgs#wasmedge -- --enable-all --dir .:. php/build-output/php/php-7.4.32/bin/php hello.php

.PHONY: php/php-*
php/php-*:
	make -C php $(subst php/php-,php-,$@)

.PHONY: clean
clean:
	make -C php clean
