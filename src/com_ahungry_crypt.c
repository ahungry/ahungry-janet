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

  // For some reason, it is necessary to add one to resultlen and put NUL in buffer for out.
  char *out = malloc (sizeof(char) * (resultlen + 1));
  char *out2 = out;

  for (unsigned int i = 0; i < resultlen; i++)
    {
      out2 += sprintf (out2, "%c", result[i]);
    }

  resultlen++;
  out[resultlen] = '\0';

  /* const uint8_t *janet_out = janet_string ((uint8_t *) out, resultlen); */
  /* free (out); */
  /* return janet_wrap_string (janet_out); */

  JanetBuffer *out_buf = janet_buffer (sizeof (const uint8_t) * resultlen);
  janet_buffer_push_bytes (out_buf, (const uint8_t *) out, resultlen);

  free (out);

  return janet_wrap_buffer (out_buf);
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

static Janet
base64_encode_wrapped (int32_t argc, Janet *argv)
{
  janet_fixarity (argc, 1);

  JanetBuffer *buf = janet_getbuffer (argv, 0);
  char * data = malloc (sizeof (uint8_t) * buf->count);
  memcpy (data, buf->data, buf->count);
  int datalen = buf->count;

  // base64 uses 4 bytes to encode every 3 bytes of input
  int block_size = datalen / 3 * 4;
  if (datalen % 3 != 0) block_size += 4;
  char encoded[block_size];
  int len = EVP_EncodeBlock ((unsigned char *) encoded, (unsigned char *) data, datalen);

  const uint8_t *janet_out = janet_string ((uint8_t *) encoded, len);

  return janet_wrap_string (janet_out);
}

static Janet
base64_decode_wrapped (int32_t argc, Janet *argv)
{
  janet_fixarity (argc, 1);

  const char * data = janet_getcstring (argv, 0);
  int datalen = strlen (data);
  // base64 uses 4 bytes to encode every 3 bytes of input
  int block_size = datalen / 4 * 3;
  if (datalen % 4 != 0) block_size += 3;
  char decoded[block_size];
  EVP_DecodeBlock ((unsigned char *) decoded, (unsigned char *) data, strlen (data));

  JanetBuffer *out_buf = janet_buffer (sizeof (const uint8_t) * block_size);
  janet_buffer_push_bytes (out_buf, (const uint8_t *) decoded, block_size);

  // free (decoded);

  return janet_wrap_buffer (out_buf);
}

static const JanetReg
com_ahungry_crypt_cfuns[] = {
  {"hmac-sha256", hmac_sha256_wrapped, "Generate an HS256 in binary output format."},
  {"hmac-sha256-hex", hmac_sha256_hex_wrapped, "Generate an HS256 in hex output format."},
  {"sha256", sha256_wrapped, "Generate a SHA256 in hex output format."},
  {"base64-encode", base64_encode_wrapped, "Encode string as base64."},
  {"base64-decode", base64_decode_wrapped, "Decode base64 as string."},
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
