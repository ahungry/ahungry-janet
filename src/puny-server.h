// Copyright (C) 2020 Matthew Carter <m@ahungry.com>
#ifndef PUNY_SERVER_H
#define PUNY_SERVER_H

// #include "config.h"
#define PORT_STR "12003"
#define CLIENT_CHUNK 1024

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <signal.h>

#ifdef _WIN32
// For windows
#include <winsock2.h>
#include <windows.h>
#include <ws2tcpip.h>
#include <iphlpapi.h>

// Taken from posix/wait.h
#define WNOHANG          0x00000001

// Taken from unistd.h
#define SHUT_RDWR 0x02

#else
// For good systems
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/wait.h>
#include <netdb.h>
#include <unistd.h>
#endif

#include <signal.h>
#include <pthread.h>
#include <stdint.h>

#define MAX_ENQUEUED 20
#define BUF_LEN 512
#define MAX_HTML_FILE_SIZE 8192

void sigint_handler (int dummy);
void wait_for_zombie ();

void http_send_header_success (int csock);
void http_send_client_response (int csock);

void * thread_fn (void *ptr);

void take_connections_forever (int ssock);
int make_sock ();

void set_server_sock (int sock);
void set_callback (char * (*callback)(char *request));

#endif
