#include <janet.h>
#include <string.h>

int
main (int argc, char *argv[])
{
  int i;
  JanetArray *args;
  JanetTable *env;

  janet_init ();

  /* Create args tuple */
  args = janet_array (argc);

  for (i = 1; i < argc; i++)
    {
      janet_array_push (args, janet_cstringv (argv[i]));
    }

  env = janet_core_env (NULL);

  janet_table_put(env, janet_ckeywordv("executable"), janet_cstringv(argv[0]));
  janet_table_put(env, janet_ckeywordv("args"), janet_wrap_array (args));

  const char *embed = "(import app :as app) (app/main 1)";

  janet_dostring (env, embed, "main", NULL);
  janet_deinit();

  return 0;
}
