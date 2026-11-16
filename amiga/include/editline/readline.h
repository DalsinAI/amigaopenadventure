/* The two calls Open Adventure takes from editline, for the Amiga port:
 * the Amiga console (CON:) edits the line and keeps its history itself,
 * so amiga/readline.c reads a whole line with fgets.
 * Copyright (c) 2026 AmiCradle Team. BSD-2-Clause, like Open Adventure. */
#ifndef AMIGA_EDITLINE_READLINE_H
#define AMIGA_EDITLINE_READLINE_H

/* The prompt (when the input is a console), then a line of input without
 * its newline, in memory the caller frees; NULL at the end of the input. */
char *readline(const char *prompt);
/* The console keeps the history: nothing to do. */
int add_history(const char *line);

#endif
