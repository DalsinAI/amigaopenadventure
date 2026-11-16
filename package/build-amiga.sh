#!/bin/sh
# The release archive and the GFOpenUp part, for Cradle's stove_build
# (target package):
#  1. upstream Open Adventure, fetched at the commit
#     package/openadventure.lock names (it is never kept in this
#     repository), with its dungeon tables made from adventure.yaml;
#  2. the host test: upstream's own regression games, played through
#     amiga/readline.c (tests/host/test_regress.sh);
#  3. the game built by amiga/Makefile.amigaos;
#  4. the drawer, its icon and the Installer script beside it packed as
#     NAME-VERSION-68040.lha (tools/pack_dist.py), with its .sha256 and a
#     short .readme;
#  5. OUT/Parts/OpenAdventure, a GFOpenUp part: its Part file and the
#     drawer's files for SYS:Games/OpenAdventure, installed with
#       GFOpenUpTool INSTALL Parts/OpenAdventure
# Nothing is published from here.
# MIT, Copyright (c) 2026 AmiCradle Team.
set -eu

HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$HERE/.." && pwd)
. "$HERE/package.env"
. "$HERE/openadventure.lock"
OUT=${OUT:-"$ROOT/build-amiga-package"}
mkdir -p "$OUT"
OUT=$(CDPATH= cd -- "$OUT" && pwd)
STOVE=${STOVE:-"$HOME/AmiCradle/stoves/os32-gcc16-open6"}
# outside the checkout: Cradle cleans it (git clean -ffdx) before every job
WORK=${WORK:-"$HOME/.cache/amigaopenadventure"}
cd "$ROOT"
t0=$(date +%s)

# 1. upstream at the locked commit
OA="$WORK/open-adventure"
sh "$HERE/fetch-upstream.sh" "$OA"

# 2. the host test, when the machine has a C compiler
if command -v cc >/dev/null 2>&1; then
    OA="$OA" sh tests/host/test_regress.sh
fi

# 3. the game (a stove's compiler is in its prefix/, or STOVE is the prefix)
if [ -x "$STOVE/prefix/bin/m68k-amigaos-gcc" ]; then PREFIX="$STOVE/prefix"; else PREFIX="$STOVE"; fi
make -f amiga/Makefile.amigaos OA="$OA" STOVE="$STOVE" PREFIX="$PREFIX" -j4 $TARGET > "$OUT/build-output.txt" 2>&1 || { tail -n 60 "$OUT/build-output.txt"; exit 1; }

# 4. the archive
python3 "$ROOT/tools/pack_dist.py" --dist "$DIST" --name "$NAME" --out "$OUT"

# 5. the GFOpenUp part
sh "$ROOT/package/write-part.sh" "$DIST/$NAME" "$OUT/Parts/$NAME" "$NAME" "$PORT_VERSION" \
    "Open Adventure: Colossal Cave, the first text adventure, in a console window"
echo "part: $(grep -c '^copy' "$OUT/Parts/$NAME/Part") files, $(du -sk "$OUT/Parts/$NAME" | cut -f1) KB"
ls -l "$DIST/$NAME/$NAME"
echo "total: $(( $(date +%s) - t0 )) s"
