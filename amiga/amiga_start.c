/* The Amiga port's start for Open Adventure: the stack, the version string
 * and a Workbench start.
 *
 * Open Adventure reads its commands from the standard input and writes to
 * the standard output. Started from a Shell it uses that Shell's window.
 * Started from Workbench a program has no window, so this opens one (CON:,
 * which edits the line and keeps its history), makes it the program's
 * console and opens stdin, stdout and stderr on it ("*"), then plays in the
 * drawer's User drawer, so a SAVE with a bare name lands there. The window
 * waits to be closed when the game ends, so the last score can be read.
 *
 * Upstream's main() is built as advent_main (amiga/Makefile.amigaos).
 * Copyright (c) 2026 AmiCradle Team. BSD-2-Clause, like Open Adventure. */
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>

#include <dos/dos.h>
#include <dos/dosextens.h>
#include <proto/dos.h>
#include <proto/exec.h>

int advent_main(int argc, char *argv[]);

/* A Shell gives 4 KB of stack; libnix's startup sets this much up. */
unsigned long __stack = 64 * 1024;
static const char version[] __attribute__((used)) =
    "$VER: OpenAdventure 1.22 (16.11.2026)";

#define WB_WINDOW "CON:0/20/640/400/Open Adventure/CLOSE/WAIT"

static BPTR wb_console, wb_user, wb_olddir;
static int wb_moved;

static void wb_end(void)
{
	if (wb_moved) {
		CurrentDir(wb_olddir);
	}
	if (wb_user) {
		UnLock(wb_user);
	}
	/* stdin, stdout and stderr ("*") close after this, with libnix's
	 * stdio; the window goes when the last of them is closed. */
	if (wb_console) {
		Close(wb_console);
	}
}

static int wb_start(void)
{
	struct Process *me = (struct Process *)FindTask(NULL);

	wb_console = Open((CONST_STRPTR)WB_WINDOW, MODE_NEWFILE);
	if (!wb_console) {
		return 0;
	}
	atexit(wb_end);
	/* the window's handler is the console "*" names */
	me->pr_ConsoleTask = (APTR)((struct FileHandle *)BADDR(wb_console))->fh_Type;
	if (!freopen("*", "r", stdin) || !freopen("*", "w", stdout) ||
	    !freopen("*", "w", stderr)) {
		return 0;
	}
	mkdir("PROGDIR:User", 0755);
	if ((wb_user = Lock((CONST_STRPTR)"PROGDIR:User", SHARED_LOCK)) != 0) {
		wb_olddir = CurrentDir(wb_user);
		wb_moved = 1;
	}
	return 1;
}

int main(int argc, char *argv[])
{
	static char name[] = "OpenAdventure";
	static char *wb_argv[] = { name, NULL };

	if (argc == 0) { /* Workbench: argv is the WBStartup message */
		if (!wb_start()) {
			return RETURN_FAIL;
		}
		return advent_main(1, wb_argv);
	}
	return advent_main(argc, argv);
}
