#!/bin/sh
# Host test of the port's readline (amiga/readline.c, in place of editline):
# upstream Open Adventure built on this machine with it, then upstream's
# whole regression suite (tests/*.log played, each output compared with its
# .chk, the save-file and option checks) must pass, as it does with
# editline. The game's own code is upstream's, unchanged.
#   sh tests/host/test_regress.sh        (fetches upstream at the lock)
#   OA=/path/to/open-adventure sh tests/host/test_regress.sh
# MIT, Copyright (c) 2026 AmiCradle Team.
set -eu
HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$HERE/../.." && pwd)
. "$ROOT/package/openadventure.lock"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
if [ -n "${OA:-}" ]; then
    cp -R "$OA" "$T/oa"
else
    sh "$ROOT/package/fetch-upstream.sh" "$T/oa"
fi
CC=${CC:-cc}
F="-std=c99 -D_DEFAULT_SOURCE -DVERSION=\"$OA_VERSION\" -O2 -I$ROOT/amiga/include -I$T/oa"
cd "$T/oa"
# the objects beside the sources, as upstream's Makefile has them: the
# badmagic test resumes from ../main.o, a file that is no saved game
for f in main init actions score misc saveresume dungeon cheat; do
    $CC $F -c -o "$f.o" "$f.c"
done
$CC $F -c -o readline.o "$ROOT/amiga/readline.c"
C="init.o actions.o score.o misc.o saveresume.o dungeon.o readline.o"
$CC -o advent main.o $C
$CC -o cheat cheat.o $C
cd tests
# tapview reads the TAP; keep it plain so the result can be counted here
make --quiet tap > "$T/tap.txt" 2>&1 || true
plan=$(sed -n 's/^1\.\.//p' "$T/tap.txt" | head -1)
ok=$(grep -c '^ok ' "$T/tap.txt" || true)
bad=$(grep -c '^not ok' "$T/tap.txt" || true)
grep '^not ok' "$T/tap.txt" || true
echo "open-adventure regression through amiga/readline.c: $ok of ${plan:-?} ok, $bad not ok"
[ -n "$plan" ] && [ "$bad" -eq 0 ] && [ "$ok" -eq "$plan" ]
