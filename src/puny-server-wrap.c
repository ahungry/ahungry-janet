// Copyright (C) 2020 Matthew Carter <m@ahungry.com>

#include <janet.h>
#include "puny-server.h"

const char * handler;

char *
janet_universal_cb (char *request)
{
  JanetTable *env;
  janet_init ();
  env = janet_core_env (NULL);

  JanetArray *args;

  const uint8_t *s = janet_string ((unsigned char *) request, strlen (request));

  args = janet_array (1);
  janet_array_push (args, janet_wrap_string (s));

  char *embed = malloc (200 + strlen (request));

  sprintf (embed, "(import %s :as h) (h/main \n```%s\n```)",
           handler,
           request);

  Janet *out = malloc (1);
  janet_dostring (env, embed, "main", out);
  janet_deinit ();

  const char *result = janet_getcstring (out, 0);

  free (out);
  free (embed);

  return (char *) result;
}

static Janet
puny_server_start_wrap (int32_t argc, Janet *argv)
{
  janet_fixarity (argc, 2);

  const char *my_handler = janet_getcstring (argv, 0);
  const char *port = janet_getcstring (argv, 1);

  handler = my_handler;

  int sock = make_sock (port);

  set_server_sock (sock);
  set_callback (janet_universal_cb);

  fprintf (stderr, "Listening on %s\n", port);

  /* Serve the listening socket until killed */
  take_connections_forever (sock);

  return janet_wrap_nil ();
}

static const JanetReg
puny_server_cfuns[] = {
  {"start", puny_server_start_wrap, "Start the server"},
  {NULL,NULL,NULL}
};

JANET_MODULE_ENTRY (JanetTable *env) {
  janet_cfuns (env, "puny-server", puny_server_cfuns);
}
