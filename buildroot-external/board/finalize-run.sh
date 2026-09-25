#!/bin/sh
# Give /run and /var/run the same tmpfs-backed runtime directory in both images.
set -eu

target_dir=$1
run="$target_dir/run"
var_run="$target_dir/var/run"

# Buildroot's SysV skeleton starts with /var/run -> ../run. Break that link
# before replacing /run, otherwise the two paths would point at each other.
if [ -L "$var_run" ]; then
	if [ "$(readlink "$var_run")" != ../run ]; then
		echo "Unexpected /var/run link: $(readlink "$var_run")" >&2
		exit 1
	fi
	rm "$var_run"
fi
mkdir -p "$var_run"

if [ -L "$run" ]; then
	if [ "$(readlink "$run")" = var/run ]; then
		exit 0
	fi
	echo "Unexpected /run link: $(readlink "$run")" >&2
	exit 1
fi

if [ -d "$run" ]; then
	# Preserve entries installed by Buildroot packages (including /run/lock).
	cp -a "$run/." "$var_run/"
	rm -r "$run"
elif [ -e "$run" ]; then
	echo "Cannot replace /run: not a directory" >&2
	exit 1
fi
ln -s var/run "$run"
