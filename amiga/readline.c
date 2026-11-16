/* readline() and add_history() for the Amiga port of Open Adventure, in
 * place of editline: the Amiga console (CON:) edits the line and keeps its
 * history, so a line is read whole with fgets.
 *
 * As editline: the prompt is written only when the input is a console (a
 * script or a file piped in gets none: misc.c then echoes the prompt and
 * the line itself), the newline is taken off, the line is in memory the
 * caller frees, and the end of the input (Ctrl-\ in a console, the window's
 * close gadget) gives NULL. A line of any length is read whole.
 * Copyright (c) 2026 AmiCradle Team. BSD-2-Clause, like Open Adventure. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <editline/readline.h>

char *readline(const char *prompt)
{
	size_t size = 128, len = 0;
	char *line;

	if (prompt != NULL && isatty(0)) {
		fputs(prompt, stdout);
	}
	fflush(stdout);
	if ((line = malloc(size)) == NULL) {
		return NULL;
	}
	for (;;) {
		if (fgets(line + len, (int)(size - len), stdin) == NULL) {
			if (len == 0) { /* the end of the input */
				free(line);
				return NULL;
			}
			break; /* a last line with no newline */
		}
		len += strlen(line + len);
		if (len > 0 && line[len - 1] == '\n') {
			line[--len] = '\0';
			break;
		}
		if (len + 1 == size) { /* longer than the buffer: grow it */
			char *more = realloc(line, size * 2);
			if (more == NULL) {
				break;
			}
			line = more;
			size *= 2;
		}
	}
	return line;
}

int add_history(const char *line)
{
	(void)line;
	return 0;
}
