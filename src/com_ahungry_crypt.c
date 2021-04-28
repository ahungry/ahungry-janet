#include <janet.h>

#include <openssl/evp.h>
#include <openssl/hmac.h>
#include <string.h>

static Janet
sha256_wrapped (int32_t argc, Janet *argv)
{
  janet_fixarity (argc, 1);

  const char *in_val = janet_getcstring (argv, 0);
  const unsigned char *val = (const unsigned char *)strdup (in_val);
  int vallen = strlen (in_val);

  EVP_MD_CTX *ctx = EVP_MD_CTX_new();

  if (NULL == ctx) janet_panic ("SHA256 ctx failure!");
  if (!EVP_DigestInit_ex (ctx, EVP_sha256(), NULL)) janet_panic ("SHA256 init failure!");
  if (!EVP_DigestUpdate (ctx, val, vallen)) janet_panic ("SHA256 digest update failure!");

  unsigned char hash[EVP_MAX_MD_SIZE];
  unsigned int hashlen = 0;

  if (!EVP_DigestFinal_ex (ctx, hash, &hashlen)) janet_panic ("SHA256 digest final failure!");

  int outlen = hashlen * 2;
  char *out = malloc (sizeof (char) * outlen);
  char *out2 = out;

  for (unsigned int i = 0; i < hashlen; i++)
    {
      out2 += sprintf (out2, "%02x", hash[i]);
    }

  EVP_MD_CTX_free (ctx);

  out[outlen] = '\0';

  const uint8_t *janet_out = janet_string ((uint8_t *) out, outlen);

  free (out);

  return janet_wrap_string (janet_out);
}

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
  char *out2 = out;

  for (unsigned int i = 0; i < resultlen; i++)
    {
      out2 += sprintf (out2, "%c", result[i]);
    }

  out[resultlen] = '\0';

  const uint8_t *janet_out = janet_string ((uint8_t *) out, resultlen);

  free (out);

  return janet_wrap_string (janet_out);
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

  result = HMAC(EVP_sha256(), key, keylen, val, vallen, result, &resultlen);

  int outlen = resultlen * 2; // We use 2 char output for hex
  char *out = malloc (sizeof (char *) * outlen);
  char *out2 = out;

  for (unsigned int i = 0; i < resultlen; i++)
    {
      out2 += sprintf (out2, "%02x", result[i]);
    }

  out[outlen] = '\0';

  const uint8_t *janet_out = janet_string ((uint8_t *) out, outlen);

  free (out);

  return janet_wrap_string (janet_out);
}

static const JanetReg
com_ahungry_crypt_cfuns[] = {
  {"hmac-sha256", hmac_sha256_wrapped, "Generate an HS256 in binary output format."},
  {"hmac-sha256-hex", hmac_sha256_hex_wrapped, "Generate an HS256 in hex output format."},
  {"sha256", sha256_wrapped, "Generate a SHA256 in hex output format."},
  {NULL,NULL,NULL}
};

/* extern const unsigned char *iup_lib_embed; */
/* extern size_t iup_lib_embed_size; */

JANET_MODULE_ENTRY (JanetTable *env) {
  janet_cfuns (env, "com_ahungry_crypt", com_ahungry_crypt_cfuns);
  /* janet_dobytes(env, */
  /*               iup_lib_embed, */
  /*               iup_lib_embed_size, */
  /*               "iup_lib.janet", */
  /*               NULL); */
}
