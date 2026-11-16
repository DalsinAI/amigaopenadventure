Open Adventure for GFOS
=======================

A port of Open Adventure, Eric S. Raymond's forward port of Colossal Cave
Adventure 2.5 (Will Crowther and Don Woods, 1976-1995, the 430-point
version), from https://gitlab.com/esr/open-adventure at commit
e6160529e70a8c7a06b9a5f190d69aa35c4c62f5 (version 1.22), for GFOS:
AmigaOS 3.2 with GFOpenUp, on a 68040 or 68060.

Somewhere nearby is Colossal Cave, where others have found fortunes in
treasure and gold, though it is rumored that some who enter are never
seen again. Type in plain English: GO NORTH (or N), TAKE LAMP, INVENTORY.

Status: built in Cradle's os32-gcc16-open6 stove; upstream's regression
games pass through the port's console code on the build machine; not yet
run in a lab.


What you need
-------------

- AmigaOS 3.2 (GFOS) on a 68040 or 68060. The FPU is used when there is
  one; the game needs none (an LC040 is fine).
- About 300 KB of disk and 200 KB of memory. No libraries: the whole cave
  is in the program.


How to play
-----------

Run Install-OpenAdventure (or copy the OpenAdventure drawer where you want
it), then double-click OpenAdventure: it opens its own window. Or, from a
Shell, in that Shell's window:

    OpenAdventure [-o] [-r savefile] [-l logfile]

-o plays the game as it was in 1995 (2.5), -r resumes a saved game, -l
writes what you type to a log. The window's own line editing works: the
cursor keys, and up and down for earlier commands.

SAVE and RESUME ask for a file name. Started from Workbench the game plays
in the drawer's User drawer, so a bare name (say "cave") lands there;
Install-OpenAdventure keeps the User drawer when it updates the game. From
a Shell a bare name is in the Shell's current drawer. QUIT ends the game;
so does the window's close gadget. The window stays until you close it, so
the last score can be read.

The full guide is the drawer's Guide (upstream's advent.adoc); the
history of the game is in ReadMe-OpenAdventure.


Building
--------

    sh package/fetch-upstream.sh $HOME/.cache/amigaopenadventure/open-adventure
    make -f amiga/Makefile.amigaos -j4 OA=$HOME/.cache/amigaopenadventure/open-adventure STOVE=/path/to/os32-gcc16-open6

or, in Cradle, stove_build with the os32-gcc16-open6 stove and target
package (package/build-amiga.sh), which also runs the host test, packs
OpenAdventure-VERSION-68040.lha and makes the GFOpenUp part
Parts/OpenAdventure (GFOpenUpTool INSTALL Parts/OpenAdventure puts the
game in SYS:Games/OpenAdventure).

Upstream is fetched at the locked commit (package/openadventure.lock), not
kept in this repository. Its dungeon tables (dungeon.c, dungeon.h) are
made from adventure.yaml by upstream's make_dungeon.py: the build machine
needs python3 and PyYAML.


What was changed
----------------

Nothing in upstream's code. The port adds:

- amiga/include/editline/readline.h and amiga/readline.c: readline() and
  add_history(), which upstream takes from editline, read a whole line
  with fgets. The Amiga console edits the line and keeps the history
  itself. As editline, the prompt is written only to a console, so the
  game's script and log modes are as upstream's.
- amiga/amiga_start.c: the stack, the $VER string, and a Workbench start
  (its own window, stdin and stdout on it, the User drawer). Upstream's
  main() is built as advent_main.
- tests/host/test_regress.sh: upstream built on the host with the port's
  readline instead of editline; all of upstream's regression games and
  save-file checks (115) must give upstream's own expected output.
- amiga/: the Makefile, the GlowIcons (our own art), the Installer script
  and its spec. package/: the fetch, the archive and the GFOpenUp part.

The AmiCradle Team.
