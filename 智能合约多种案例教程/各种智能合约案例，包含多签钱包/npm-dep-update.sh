#!/usr/bin/env sh

echo "Installing npm-check-updates…"
npm -g i npm-check-updates

for dir in */ ; do
	cd "$dir"
	if [ -f package.json ] ; then
		echo "\n\n==========================="
		echo "== Updating dependencies of $dir"
		echo "==========================="
		ncu -u && npm install
	fi
	cd ..
done

echo "Done."