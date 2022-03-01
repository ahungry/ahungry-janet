// gcc -Wall -I./amalg ./amalg/janet.c ./src/janet-os-fail.c -o test.bin -lm
#include <janet.h>
#include <string.h>

char *
janet_stuff ()
{
  JanetTable *env;

  janet_init ();
  env = janet_core_env (NULL);

  Janet ret;
  int h = janet_gclock ();

  // This will fail
  // janet_dostring (env, "(do (os/shell \"whoami\") \"bob\")", "fake", &ret);

  // This will succeed
  janet_dostring (env, "(do \"bob\")", "fake", &ret);

  const unsigned char *result;

  if (janet_checktype (ret, JANET_STRING))
    {
      result = janet_unwrap_string (ret);
    }
  else
    {
      fprintf (stderr, "The string was not returned, woops.");
      result = (uint8_t *) "FAILURE";
    }

  janet_gcunlock (h);
  janet_deinit ();

  return (char *) result;
}

int
main (int argc, char *argv[])
{
  char *res = janet_stuff ();

  fprintf (stdout, res);

  return 0;
}
