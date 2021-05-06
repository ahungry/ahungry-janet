#include <janet.h>
#include <stdio.h>
#include <errno.h>
#include <unistd.h>     /* defines STDIN_FILENO, system calls,etc */

#ifdef _WIN32
#include <conio.h>
#else
#include <termios.h>
#endif

// Keep all the state of app in here.

#ifndef _WIN32
struct world_atom
{
  struct termios orig_termios;
};

typedef struct world_atom world_atom;

world_atom world;
#endif

void
disable_raw_mode ()
{
#ifndef _WIN32
  if (-1 == tcsetattr (STDIN_FILENO, TCSAFLUSH, &world.orig_termios))
    fprintf (stderr, "tcsetattr");
#endif
}

void
enable_raw_mode ()
{
#ifndef _WIN32
  if (-1 == tcgetattr (STDIN_FILENO, &world.orig_termios)) fprintf (stderr, "tcgetattr");
  atexit (disable_raw_mode);

  struct termios raw = world.orig_termios;
  raw.c_iflag &= ~(BRKINT | ICRNL | INPCK | ISTRIP | IXON);
  raw.c_cflag |= (CS8);
  raw.c_lflag &= ~(ECHO | ICANON | IEXTEN);
  raw.c_cc[VMIN] = 0;
  raw.c_cc[VTIME] = 1; // Every 10th of second redraw / skip the read (stop block).

  if (-1 == tcsetattr (STDIN_FILENO, TCSAFLUSH, &raw)) fprintf (stderr, "tcsetattr");
#endif
}

static Janet
wait_for_key_wrapped (int32_t argc, Janet *argv)
{
  int nread;
  char c;

#ifdef _WIN32
  // while ( !_kbhit() );
  c = _getch ();
#else
  enable_raw_mode ();

  while ((nread = read (STDIN_FILENO, &c, 1)) != 1)
    {
      if (nread == -1 && errno != EAGAIN) fprintf (stderr, "read");
    }

  disable_raw_mode ();
#endif

  return janet_wrap_number (c);
}

static Janet
read_key_wrapped (int32_t argc, Janet *argv)
{
  int nread;
  char c;

#ifdef _WIN32
  c = fgetc (stdin);
  fflush (stdin); // Without this, the trailing newline will be in the next call to it.
#else
  while ((nread = read (STDIN_FILENO, &c, 1)) != 1)
    {
      if (nread == -1 && errno != EAGAIN) fprintf (stderr, "read");
    }
#endif

  return janet_wrap_number (c);
}

static const JanetReg
com_ahungry_io_cfuns[] = {
  {"wait-for-key", wait_for_key_wrapped, "Get a single character as an int in raw term mode (no pressing Enter)."},
  {"read-key", read_key_wrapped, "Get a single character as an int (requires pressing Enter)."},
  {NULL,NULL,NULL}
};

JANET_MODULE_ENTRY (JanetTable *env) {
  janet_cfuns (env, "com_ahungry_io", com_ahungry_io_cfuns);
}
