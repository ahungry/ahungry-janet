#include <janet.h>

#include <openssl/evp.h>
#include <openssl/hmac.h>
#include <string.h>

static Janet
hmac_sha256_wrapped (int32_t argc, Janet *argv)
{
  janet_fixarity (argc, 2);

  const char *in_key = janet_getcstring (argv, 0);
  const char *in_val = janet_getcstring (argv, 1);

  const unsigned char *key = (const unsigned char *)strdup (in_key);
  const unsigned char *val = (const unsigned char *)strdup (in_val);
  int keylen = strlen (in_key);
  int vallen = strlen (in_val);
  unsigned char *result = NULL;
  unsigned int resultlen = -1;

  result = HMAC(EVP_sha256(), key, keylen, val, vallen, result, &resultlen);

  char *out = malloc (sizeof(char) * resultlen);

  for (unsigned int i = 0; i < resultlen; i++)
    {
      sprintf (out, "%c", result[i]);
    }

  return janet_wrap_string (out);
}

static Janet
hmac_sha256_hex_wrapped (int32_t argc, Janet *argv)
{
  janet_fixarity (argc, 2);

  const char *in_key = janet_getcstring (argv, 0);
  const char *in_val = janet_getcstring (argv, 1);

  const unsigned char *key = (const unsigned char *)strdup (in_key);
  const unsigned char *val = (const unsigned char *)strdup (in_val);
  int keylen = strlen (in_key);
  int vallen = strlen (in_val);
  unsigned char *result = NULL;
  unsigned int resultlen = -1;

  fprintf (stderr, "Received key: %s", in_key);
  fprintf (stderr, "Received val: %s", in_val);

  result = HMAC(EVP_sha256(), key, keylen, val, vallen, result, &resultlen);

  fprintf (stderr, "\nResultlen was: %d\n", resultlen);

  char *out = malloc (sizeof (char *) * resultlen * 3);
  char *out2 = out;

  for (unsigned int i = 0; i < resultlen; i++)
    {
      out2 += sprintf (out2, "%02x", result[i]);
      // printf ("%02x", result[i]);
    }
  out2 += sprintf (out2, "\0");

  fprintf (stderr, "Out length is: %d", (int) strlen (out));

  const uint8_t *janet_out = janet_string ((uint8_t *) out, strlen (out));

  return janet_wrap_string (janet_out);
}

static const JanetReg
com_ahungry_crypt_jwt_cfuns[] = {
  {"hmac-sha256", hmac_sha256_wrapped, "Generate an HS256 in binary output format."},
  {"hmac-sha256-hex", hmac_sha256_hex_wrapped, "Generate an HS256 in hex output format."},
  {NULL,NULL,NULL}
};

/* extern const unsigned char *iup_lib_embed; */
/* extern size_t iup_lib_embed_size; */

JANET_MODULE_ENTRY (JanetTable *env) {
  janet_cfuns (env, "com_ahungry_crypt_jwt", com_ahungry_crypt_jwt_cfuns);
  /* janet_dobytes(env, */
  /*               iup_lib_embed, */
  /*               iup_lib_embed_size, */
  /*               "iup_lib.janet", */
  /*               NULL); */
}
