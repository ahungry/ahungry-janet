#include <janet.h>

static Janet
version_wrapped (int32_t argc, Janet *argv)
{
  JanetString s = janet_string ((uint8_t*)"20200528", 8);

  return janet_wrap_string (s);
}

static const JanetReg
iup_cfuns[] = {
  {"version", version_wrapped, ""},
  {NULL,NULL,NULL}
};

/* extern const unsigned char *iup_lib_embed; */
/* extern size_t iup_lib_embed_size; */

JANET_MODULE_ENTRY (JanetTable *env) {
  janet_cfuns (env, "iup", iup_cfuns);
  /* janet_dobytes(env, */
  /*               iup_lib_embed, */
  /*               iup_lib_embed_size, */
  /*               "iup_lib.janet", */
  /*               NULL); */
}
