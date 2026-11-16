#!/bin/sh
# Upstream Open Adventure at the commit package/openadventure.lock names,
# into <dir> (made or refreshed), with its dungeon tables (dungeon.c,
# dungeon.h) made by upstream's make_dungeon.py from adventure.yaml.
#   fetch-upstream.sh <dir>
# Needs git, python3 and PyYAML. MIT, Copyright (c) 2026 AmiCradle Team.
set -eu
HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$HERE/openadventure.lock"
OA=$1
if [ "$(git -C "$OA" rev-parse HEAD 2>/dev/null)" != "$OA_COMMIT" ]; then
    rm -rf "$OA"; mkdir -p "$OA"
    git -C "$OA" init -q
    git -C "$OA" fetch -q --depth 1 "$OA_URL" "$OA_COMMIT"
    git -C "$OA" checkout -q FETCH_HEAD
fi
git -C "$OA" checkout -q -- . && git -C "$OA" clean -qfdx
(cd "$OA" && python3 make_dungeon.py)
test -s "$OA/dungeon.c" && test -s "$OA/dungeon.h"
