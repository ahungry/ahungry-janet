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

  char *embed = malloc (200 + strlen (request));

  sprintf (embed, "(import %s :as h) (h/main \n```%s\n```)",
           handler,
           request);

  // Without locking the gc, mingw/Windows seems to segfault after dostring
  // but before the return value is accessible, even with gcroot calls.
  Janet ret;
  int h = janet_gclock ();

  janet_dostring (env, embed, "main", &ret);

  const unsigned char *result;

  if (janet_checktype (ret, JANET_STRING))
    {
      result = janet_unwrap_string (ret);
    }
  else
    {
      fprintf (stderr, "janet_universal_cb must return a string.");
      result = (uint8_t *) "HTTP/1.1 500 Internal Server Error\n"
        "Content-Type: text/html\n"
        "Content-Length: 25\n"
        "Connection: close\n\n"
        "500 Internal Server Error";
    }

  janet_gcunlock (h);

  free (embed);
  janet_deinit ();

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
