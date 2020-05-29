#include <janet.h>

static Janet
version_wrapped (int32_t argc, Janet *argv)
{
  JanetString s = janet_string ((uint8_t*)"20200528", 8);

  return janet_wrap_string (s);
}

static const JanetReg
meta_cfuns[] = {
  {"version", version_wrapped, ""},
  {NULL,NULL,NULL}
};

/* extern const unsigned char *meta_lib_embed; */
/* extern size_t meta_lib_embed_size; */

JANET_MODULE_ENTRY (JanetTable *env) {
  janet_cfuns (env, "meta", meta_cfuns);
  /* janet_dobytes(env, */
  /*               meta_lib_embed, */
  /*               meta_lib_embed_size, */
  /*               "meta_lib.janet", */
  /*               NULL); */
}
