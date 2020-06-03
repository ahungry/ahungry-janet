#include <janet.h>

#include <arpa/inet.h>  /* IP address conversion stuff */
#include <ctype.h>
#include <errno.h>
#include <netdb.h>      /* gethostbyname */
#include <netinet/in.h> /* INET constants and stuff */
#include <string.h>
#include <sys/socket.h> /* socket specific definitions */
#include <sys/types.h>
#include <unistd.h>

#define MAXBUF 1024 * 1024

struct world
{
  unsigned char udp_listen_received[MAXBUF];
  int udp_listen_received_len;
};

struct world world;

void
die (const char *s)
{
  perror (s);
  exit (1);
}

// How to prevent socket from failing on getaddrinfo resolution?
// https://stackoverflow.com/questions/2597608/c-socket-connection-timeout
int
get_socket_fd (struct addrinfo** return_res, char *hostname, int port)
{
  char portname[10];
  snprintf (portname, sizeof (portname), "%d", port);

  // printf ("About to send to: %s:%s (%d)\n", hostname, portname, port);

  struct addrinfo hints;
  memset (&hints, 0, sizeof (hints));

  hints.ai_family = AF_UNSPEC;
  hints.ai_socktype = SOCK_DGRAM;
  hints.ai_protocol = 0;
  hints.ai_flags = AI_ADDRCONFIG;

  struct addrinfo* res = 0;
  int err = getaddrinfo (hostname, portname, &hints, &res);

  if (err != 0) die("getaddrinfo");

  int fd = socket (res->ai_family, res->ai_socktype, res->ai_protocol);

  if (fd == -1) die("socket");

  // Return the res by setting in place
  *return_res = res;

  return fd;
}

// Fire and forget some udp (we don't get anything back)
void
send_udp (int fd, struct addrinfo* res, char *s)
{
  int slen = strlen (s);
  char *buf = NULL;
  buf = malloc (slen);
  memcpy (buf, s, slen);

  // printf ("About to send: %s at %d bytes\n", buf, slen);

  if (sendto (fd, buf, slen, 0,
              res->ai_addr, res->ai_addrlen) == -1)
    {
      die("sendto");
    }

  free (buf);
}

void
receive_udp (int sd)
{
  unsigned int len;
  struct sockaddr_in remote;

  len = sizeof (remote);

  char bufin[MAXBUF];
  int n; // Rec bytes

  n = recvfrom (sd, bufin, MAXBUF, 0, (struct sockaddr *) &remote, &len);

  if (n < 0)
    {
      perror ("Error receiving data.");
    }
  else
    {
      memcpy (world.udp_listen_received, bufin, n);
      world.udp_listen_received_len = n;
      world.udp_listen_received[n + 1] = '\0';
      // printf ("We received some bytes: %s of len: %d\n", bufin, n);
    }
}

// Listen for inbound - how could we do something useful with it though...
int
udp_listen (int listen_port)
{
  int ld;
  struct sockaddr_in skaddr;
  unsigned int length;

  if ((ld = socket( PF_INET, SOCK_DGRAM, 0 )) < 0) {
    printf("Problem creating socket\n");
    exit(1);
  }

  skaddr.sin_family = AF_INET;
  skaddr.sin_addr.s_addr = htonl(INADDR_ANY);
  skaddr.sin_port = htons(listen_port); // 0 for the kernel to choose random

  if (bind(ld, (struct sockaddr *) &skaddr, sizeof(skaddr))<0) {
    printf("Problem binding\n");
    exit(0);
  }

  /* find out what port we were assigned and print it out */

  length = sizeof( skaddr );
  if (getsockname(ld, (struct sockaddr *) &skaddr, &length)<0) {
    printf("Error getsockname\n");
    exit(1);
  }

  return ld;
}

/**
 * Wrapper to handle making a socket, sending a string, and closing a socket, all in one.
 */
static Janet
send_string (int32_t argc, const Janet *argv)
{
  janet_fixarity (argc, 3);
  const uint8_t *host = janet_getstring (argv, 0);
  int port = janet_getinteger (argv, 1);
  const uint8_t *s = janet_getstring (argv, 2);

  struct addrinfo *res = 0;
  int fd = get_socket_fd (&res, (char*) host, port);
  send_udp (fd, res, (char*) s);
  close (fd);
  free (res);

  return janet_wrap_boolean (1);
}

/**
 * Wrapper to handle making a socket, sending a string, and closing a socket, all in one.
 */
static Janet
j_listen (int32_t argc, const Janet *argv)
{
  janet_fixarity (argc, 1);

  int port = janet_getinteger (argv, 0);
  int fd = udp_listen (port);

  receive_udp (fd);
  close (fd);

  const uint8_t *s = janet_string (world.udp_listen_received,
                                   world.udp_listen_received_len);

  return janet_wrap_string (s);
}

static const JanetReg
cfuns[] = {
  {"send-string", send_string, "(udp/send-string host port string)\n\nSend string to host:port over UDP."},
  {"listen", j_listen, "(udp/listen port)\n\nListen for incoming UDP and close after receiving some data."},
  {NULL, NULL, NULL}
};

JANET_MODULE_ENTRY(JanetTable *env) {
  janet_cfuns (env, "udp", cfuns);
}
