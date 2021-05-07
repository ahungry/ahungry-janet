// Copyright (C) 2020 Matthew Carter <m@ahungry.com>

#include "puny-server.h"

int server_sock;
// char * callback (int (*f)(char *request));//  { return fn (y); }
char * (*callback)(char *request);

static volatile int keep_running = 1;

void
set_server_sock (int sock)
{
  server_sock = sock;
}

void
set_callback (char * (*cb)(char *request))
{
  callback = cb;
}

void
sigint_handler (__attribute__((unused))int dummy)
{
  keep_running = 0;
  fprintf (stderr, "Shutting down, freeing socket.\n");

  if (server_sock)
    {
#ifdef _WIN32
  closesocket (server_sock);
  WSACleanup ();
  exit (EXIT_SUCCESS);
#else
  close (server_sock);
  exit (EXIT_SUCCESS);
#endif
    }
}

/**
 * Send out the successful HTTP header
 *
 * @param int csock The client socket to write to
 * @return void
 */
void http_send_header_success (int csock)
{
  (void) send (csock, "HTTP/1.1 200 OK\n", 16, 0);
  (void) send (csock, "Content-Type: text/html\n", 24, 0);
  (void) send (csock, "Content-Length: 7\n", 18, 0);
  (void) send (csock, "Connection: close\n\n", 19, 0);
}

/* ------------------------------------------------------------ */
/* How to clean up after dead child processes                   */
/* ------------------------------------------------------------ */
// void wait_for_zombie(int s)
#ifdef _WIN32
void wait_for_zombie () {}
#else
void wait_for_zombie()
{
  while(waitpid(-1, NULL, WNOHANG) > 0) ;
}
#endif


/**
 * Read some string from the destination socket, stopping when data
 * ends.  Will populate buf with the contents of it.
 */
char *
read_tcp (int sock)
{
  char *buf = NULL;
  int i = 0;
  int n = 0;
  int offset = 0;
  // int read_bytes = sizeof (buf) - 1;
  int read_bytes = CLIENT_CHUNK;
  char tmp[CLIENT_CHUNK];
  int set_timer = 0;

  // TODO: Add parsing for content-length on input body
  // Read until we see double newlines
  int has_seen_req_terminator = 0;
  int req_terminator_pos = 0;
  int final_content_length = 0;

  // Keep polling for client input until we have useful buf input
  while (! has_seen_req_terminator)
    {
      while ((n = recv (sock, tmp, read_bytes, 0)) > 0)
        {
          tmp[n] = 0;
          int mem = ++i * read_bytes * sizeof (char);
          buf = realloc (buf, mem);
          memcpy (buf + offset, tmp, strlen (tmp));
          offset += n;

          has_seen_req_terminator = NULL != strstr (buf, "\r\n\r\n");

          // Before we end, confirm we didn't find a Content-Length - if we did,
          // we need to read at least that many more bytes.
          char *content_length1 = strstr (buf, "content-length: ");
          char *content_length2 = strstr (buf, "Content-Length: ");
          char *content_length = NULL == content_length1 ? content_length2 : content_length1;

          if (NULL != content_length)
            {
              fprintf (stderr, "Saw some content_length");
              fflush (stderr);

              int nl_offset = 0;

              // Find where the next \r is
              for (int i = 0; i < (int) strlen (content_length); i++)
                {
                  if ('\r' == content_length[i])
                    {
                      nl_offset = i;
                      break;
                    }
                }

              int textlen = 16; // content-length: string
              char *clen_string = malloc (sizeof (char) * nl_offset);
              memcpy (clen_string, content_length + textlen, nl_offset - textlen);
              final_content_length = atoi (clen_string);

              fprintf (stderr,
                       "The nl_offset was: %d, fcl: %d - clen: %s\n",
                       nl_offset, final_content_length, clen_string);
              fflush (stderr);
            }

          if (set_timer == 0)
            {
              // https://stackoverflow.com/questions/2876024/linux-is-there-a-read-or-recv-from-socket-with-timeout
#ifdef _WIN32
              // WINDOWS
              // DWORD timeout = timeout_in_seconds * 1000;
              DWORD timeout = 10;
              setsockopt (sock, SOL_SOCKET, SO_RCVTIMEO, (const char*)&timeout, sizeof timeout);

              // FIXME: This will only read max CLIENT_CHUNK from users.
              // We can break here so its fast on windows, until we figure out select
              // based polling so we don't wait forever for the client option.
              // https://docs.microsoft.com/en-us/windows/win32/winsock/receiving-and-sending-data-on-the-server
              break;
#else
              // LINUX
              struct timeval tv;
              tv.tv_sec = 0;
              // We need a way to dynamically set this after first received byte in read() call
              tv.tv_usec = 1; // 500,000 would be half a second, as this is micro seconds
              setsockopt (sock, SOL_SOCKET, SO_RCVTIMEO, (const char*)&tv, sizeof tv);
#endif
              set_timer = 1;
            }
        }
    }

  if (final_content_length)
    {
      char *ending = strstr (buf, "\r\n\r\n");

      // Pointer subtraction to find the index pos, neat.
      int header_length = (ending - buf) + 4;

      while ((int) strlen (buf) < header_length + final_content_length)
        {
          while ((n = recv (sock, tmp, read_bytes, 0)) > 0)
            {
              tmp[n] = 0;
              int mem = ++i * read_bytes * sizeof (char);
              buf = realloc (buf, mem);
              memcpy (buf + offset, tmp, strlen (tmp));
              offset += n;
            }
        }
    }

  buf[offset] = 0;

  return buf;
}

char *
get_version (__attribute__((unused))char *request)
{
  return "HTTP/1.1 200 OK\n"
    "Content-Type: text/html\n"
    "Content-Length: 7\n"
    "Connection: close\n\n"
    "\"0.0.1\"";
}

/* ------------------------------------------------------------ */
/* Core of implementation of a child process                    */
/* ------------------------------------------------------------ */
void http_send_client_response(int csock)
{
  char *buf = read_tcp (csock);

  // fprintf (stderr, "Read from the client socket:\n%s\n", buf);

  if (NULL == callback)
    {
      callback = get_version;
    }

  char *response = callback (buf);
  (void) send (csock, response, strlen (response), 0);

  /* http_send_header_success (csock); */
  /* (void) send (csock, "\"0.0.1\"", 7, 0); */

  // Politely hang up the call (if we do not send the length).
  // If we don't use this, error rate increases.
  shutdown (csock, SHUT_RDWR);
}

// ptr is the csock waiting to be serviced
void *
thread_fn (void *ptr)
{
  intptr_t csock = (intptr_t) ptr;

  http_send_client_response (csock);
  close(csock);

  return NULL;
}

/* ------------------------------------------------------------ */
/* Core of implementation of the parent process                 */
/* ------------------------------------------------------------ */
void take_connections_forever(int ssock)
{
  // https://stackoverflow.com/questions/2876024/linux-is-there-a-read-or-recv-from-socket-with-timeout
#ifdef _WIN32
  // FIXME: For some reason, this doesn't assist with not-pausing on win...
  // WINDOWS
  // DWORD timeout = timeout_in_seconds * 1000;
  DWORD timeout = 500;
  setsockopt (ssock, SOL_SOCKET, SO_RCVTIMEO, (const char*)&timeout, sizeof timeout);
#else
  // LINUX
  struct timeval tv;
  tv.tv_sec = 0;
  // We need a way to dynamically set this after first received byte in read() call
  tv.tv_usec = 500000; // 500,000 would be half a second, as this is micro seconds
  setsockopt (ssock, SOL_SOCKET, SO_RCVTIMEO, (const char*)&tv, sizeof tv);
#endif

  while (keep_running)
    {
      struct sockaddr addr;
      socklen_t addr_size = sizeof(addr);
      int csock;
      pthread_t pth;

      /* Block until we take one connection to the server socket */
      csock = accept(ssock, &addr, &addr_size);

      if (csock < 0) continue;

      if (csock == -1) {
        perror("accept");
      } else {
        pthread_create(&pth, NULL, thread_fn, (void*)(intptr_t)csock);
      }
    }
}

#ifdef _WIN32

WSADATA wsaData;

int
make_sock (char *port)
{
  int iResult;

  // Initialize Winsock
  iResult = WSAStartup (MAKEWORD (2,2), &wsaData);

  if (iResult != 0)
    {
      fprintf (stderr, "WSAStartup failed: %d\n", iResult);
      return 1;
    }

  struct addrinfo *result = NULL, *ptr = NULL, hints;

  ZeroMemory (&hints, sizeof (hints));

  hints.ai_family = AF_INET;
  hints.ai_socktype = SOCK_STREAM;
  hints.ai_protocol = IPPROTO_TCP;
  hints.ai_flags = AI_PASSIVE;

  iResult = getaddrinfo (NULL, port, &hints, &result);
  if (iResult != 0)
    {
      fprintf (stderr, "getaddrinfo failed: %d\n", iResult);
      WSACleanup ();

      return 1;
    }

  SOCKET ListenSocket = INVALID_SOCKET;
  ListenSocket = socket (result->ai_family, result->ai_socktype,
                         result->ai_protocol);

  if (ListenSocket == INVALID_SOCKET) {
    fprintf (stderr, "Error at socket(): %ld\n", WSAGetLastError ());
    freeaddrinfo (result);
    WSACleanup ();

    return 1;
  }

  // https://linux.die.net/man/3/setsockopt
  int enable = 1;
  setsockopt (ListenSocket, SOL_SOCKET, SO_REUSEADDR, &enable, sizeof (int));

  // Setup the TCP listening socket
  iResult = bind (ListenSocket, result->ai_addr, (int) result->ai_addrlen);

  if (iResult == SOCKET_ERROR)
    {
      fprintf (stderr, "bind failed with error: %d\n", WSAGetLastError ());
      freeaddrinfo (result);
      closesocket (ListenSocket);
      WSACleanup ();

      return 1;
    }

  freeaddrinfo (result);

  if (listen (ListenSocket, SOMAXCONN) == SOCKET_ERROR)
    {
      fprintf (stderr, "Listen failed with error: %ld\n", WSAGetLastError ());
      closesocket (ListenSocket);
      WSACleanup ();

      return 1;
    }

  /* SOCKET ClientSocket; */

  /* ClientSocket = INVALID_SOCKET; */

  /* // TODO: Fix this lame attempt */
  /* // https://docs.microsoft.com/en-us/windows/win32/winsock/accepting-a-connection */
  /* // Accept a client socket */
  /* ClientSocket = accept (ListenSocket, NULL, NULL); */
  /* if (ClientSocket == INVALID_SOCKET) */
  /*   { */
  /*     printf ("accept failed: %d\n", WSAGetLastError()); */
  /*     closesocket (ListenSocket); */
  /*     WSACleanup (); */

  /*     return 1; */
  /*   } */

  return ListenSocket;
}
#else
int
make_sock (char *port)
{
  struct addrinfo hints, *res;
  struct sigaction sa;
  int sock;
  char portno[10];

  // strcpy (portno, argc > 1 ? argv[1] : PORT_STR);
  strcpy (portno, port); //

  /* Look up the address to bind to */
  memset(&hints, 0, sizeof(struct addrinfo));
  hints.ai_family = AF_UNSPEC;
  hints.ai_socktype = SOCK_STREAM;
  hints.ai_flags = AI_PASSIVE;

  if (getaddrinfo (NULL, portno, &hints, &res) != 0 ) {
    perror("getaddrinfo");
    exit(EXIT_FAILURE);
  }

  /* Make a socket */
  if ( (sock = socket(res->ai_family, res->ai_socktype, res->ai_protocol)) == -1 ) {
    perror("socket");
    exit(EXIT_FAILURE);
  }

  /* Arrange to clean up child processes (the workers) */
  sa.sa_handler = wait_for_zombie;
  sigemptyset(&sa.sa_mask);
  sa.sa_flags = SA_RESTART;
  if ( sigaction(SIGCHLD, &sa, NULL) == -1 ) {
    perror("sigaction");
    exit(EXIT_FAILURE);
  }

  // https://linux.die.net/man/3/setsockopt
  int enable = 1;
  setsockopt (sock, SOL_SOCKET, SO_REUSEADDR, &enable, sizeof (int));

  /* Associate the socket with its address */
  if ( bind(sock, res->ai_addr, res->ai_addrlen) != 0 ) {
    perror("bind");
    exit(EXIT_FAILURE);
  }

  freeaddrinfo(res);

  /* State that we've opened a server socket and are listening for connections */
  if ( listen(sock, MAX_ENQUEUED) != 0 ) {
    perror("listen");
    exit(EXIT_FAILURE);
  }

  return sock;

  /* /\* Serve the listening socket until killed *\/ */
  /* take_connections_forever(sock); */
  /* return EXIT_SUCCESS; */
}
#endif
