#!/usr/bin/env bash
set -Eeuxo pipefail

# Reset file permissions to match umask.
# Currently recommending umask 0002.

user="$(id -u)"
group="$(id -g)"

# SC2035: Use ./*glob* or -- *glob* so names with dashes won't become options.
chown -R "${user}:${group}" -- *

find . -type d -print0 | \
    xargs -0 -I {} chmod u=rwx,g=rwx,o=rx {}
find . -type f -print0 | \
    xargs -0 -I {} chmod u=rw,g=rw,o=r {}
find . -name "*.sh" -type f -print0 | \
    xargs -0 -I {} chmod u=rwx,g=rwx,o=rx {}

unset -v user group
