#include <janet.h>
#include <stdio.h>
#include <errno.h>
#include <unistd.h>     /* defines STDIN_FILENO, system calls,etc */
#include <termios.h>

// Keep all the state of app in here.

struct world_atom
{
  struct termios orig_termios;
};

typedef struct world_atom world_atom;

world_atom world;

void
disable_raw_mode ()
{
  if (-1 == tcsetattr (STDIN_FILENO, TCSAFLUSH, &world.orig_termios))
    fprintf (stderr, "tcsetattr");
}

void
enable_raw_mode ()
{
  if (-1 == tcgetattr (STDIN_FILENO, &world.orig_termios)) fprintf (stderr, "tcgetattr");
  atexit (disable_raw_mode);

  struct termios raw = world.orig_termios;
  raw.c_iflag &= ~(BRKINT | ICRNL | INPCK | ISTRIP | IXON);
  raw.c_cflag |= (CS8);
  raw.c_lflag &= ~(ECHO | ICANON | IEXTEN);
  raw.c_cc[VMIN] = 0;
  raw.c_cc[VTIME] = 1; // Every 10th of second redraw / skip the read (stop block).

  if (-1 == tcsetattr (STDIN_FILENO, TCSAFLUSH, &raw)) fprintf (stderr, "tcsetattr");
}

static Janet
wait_for_key_wrapped (int32_t argc, Janet *argv)
{
  enable_raw_mode ();
  int nread;
  char c;

  while ((nread = read (STDIN_FILENO, &c, 1)) != 1)
    {
      if (nread == -1 && errno != EAGAIN) fprintf (stderr, "read");
    }

  disable_raw_mode ();

  return janet_wrap_number (c);
}

static Janet
read_key_wrapped (int32_t argc, Janet *argv)
{
  int nread;
  char c;

  while ((nread = read (STDIN_FILENO, &c, 1)) != 1)
    {
      if (nread == -1 && errno != EAGAIN) fprintf (stderr, "read");
    }

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
