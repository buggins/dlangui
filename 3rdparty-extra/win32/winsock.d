/***********************************************************************\
*                               winsock.d                               *
*                                                                       *
*                       Windows API header module                       *
*                                                                       *
*                 Translated from MinGW Windows headers                 *
*                           by Stewart Gordon                           *
\***********************************************************************/
module win32.winsock;
version(Windows):

/*
  Definitions for winsock 1.1

  Portions Copyright (c) 1980, 1983, 1988, 1993
  The Regents of the University of California.  All rights reserved.

  Portions Copyright (c) 1993 by Digital Equipment Corporation.
 */

/*	DRK: This module should not be included if -version=Win32_Winsock2 has
 *	been set.  If it has, assert.  I think it's better that way than letting
 *	the user believe that it's worked.
 *
 *	SG: It has now been changed so that winsock2 is the default, and
 *	-version=Win32_Winsock1 must be set to use winsock.
 */
version(Win32_Winsock1) {}
else {
    pragma(msg, "Cannot use win32.winsock without "
			~ "Win32_Winsock1 defined.");
    static assert(false);
}

import win32.windef;

alias char u_char;
alias ushort u_short;
alias uint u_int, u_long, SOCKET;

const size_t FD_SETSIZE = 64;

// shutdown() how types
enum : int {
	SD_RECEIVE,
	SD_SEND,
	SD_BOTH
}

struct FD_SET {
	u_int              fd_count;
	SOCKET[FD_SETSIZE] fd_array;

	static void opCall(SOCKET fd, FD_SET* set) {
		if (set.fd_count < FD_SETSIZE) set.fd_array[set.fd_count++] = fd;
	}
}
alias FD_SET* PFD_SET, LPFD_SET;

extern(Pascal) int __WSAFDIsSet(SOCKET, FD_SET*);
alias __WSAFDIsSet FD_ISSET;

void FD_CLR(SOCKET fd, FD_SET* set) {
	for (u_int i = 0; i < set.fd_count; i++) {
		if (set.fd_array[i] == fd) {
			while (i < set.fd_count - 1) {
				set.fd_array[i] = set.fd_array[i+1];
				i++;
			}
			set.fd_count--;
			break;
		}
	}
}

/+void FD_SET(SOCKET fd, FD_SET* set) {
	if (set.fd_count < FD_SETSIZE) set.fd_array[set.fd_count++] = fd;
}+/

void FD_ZERO(FD_SET* set) {
	set.fd_count = 0;
}


struct TIMEVAL {
	int tv_sec;
	int tv_usec;

	int opCmp(TIMEVAL tv) {
		if (tv_sec < tv.tv_sec)   return -1;
		if (tv_sec > tv.tv_sec)   return  1;
		if (tv_usec < tv.tv_usec) return -1;
		if (tv_usec > tv.tv_usec) return  1;
		return 0;
	}
}
alias TIMEVAL* PTIMEVAL, LPTIMEVAL;

bool timerisset(TIMEVAL tvp) {
	return tvp.tv_sec || tvp.tv_usec;
}

void timerclear(ref TIMEVAL tvp) {
	tvp.tv_sec = tvp.tv_usec = 0;
}

struct HOSTENT {
	char*  h_name;
	char** h_aliases;
	short  h_addrtype;
	short  h_length;
	char** h_addr_list;

	char* h_addr() { return h_addr_list[0]; }
	char* h_addr(char* h) { return h_addr_list[0] = h; }
}
alias HOSTENT* PHOSTENT, LPHOSTENT;

struct LINGER {
	u_short l_onoff;
	u_short l_linger;
}
alias LINGER* PLINGER, LPLINGER;

// TOTHINKABOUT: do we need these, or are they just for internal use?
/+
#define IOCPARM_MASK	0x7f
#define IOC_VOID	0x20000000
#define IOC_OUT	0x40000000
#define IOC_IN	0x80000000
#define IOC_INOUT	(IOC_IN|IOC_OUT)

#define _IO(x,y)	(IOC_VOID|((x)<<8)|(y))
#define _IOR(x,y,t)	(IOC_OUT|(((int)sizeof(t)&IOCPARM_MASK)<<16)|((x)<<8)|(y))
#define _IOW(x,y,t)	(IOC_IN|(((int)sizeof(t)&IOCPARM_MASK)<<16)|((x)<<8)|(y))

#define FIONBIO	_IOW('f', 126, u_long)
#define FIONREAD	_IOR('f', 127, u_long)
#define FIOASYNC	_IOW('f', 125, u_long)
#define SIOCSHIWAT	_IOW('s',  0, u_long)
#define SIOCGHIWAT	_IOR('s',  1, u_long)
#define SIOCSLOWAT	_IOW('s',  2, u_long)
#define SIOCGLOWAT	_IOR('s',  3, u_long)
#define SIOCATMARK	_IOR('s',  7, u_long)
+/

enum : DWORD {
	FIONBIO    = 0x8004667E,
	FIONREAD   = 0x4004667F,
	FIOASYNC   = 0x8004667D,
	SIOCSHIWAT = 0x80047300,
	SIOCGHIWAT = 0x40047301,
	SIOCSLOWAT = 0x80047302,
	SIOCGLOWAT = 0x40047303,
	SIOCATMARK = 0x40047307
}

struct netent {
	char*  n_name;
	char** n_aliases;
	short  n_addrtype;
	u_long n_net;
}

struct SERVENT {
	char*  s_name;
	char** s_aliases;
	short  s_port;
	char*  s_proto;
}
alias SERVENT* PSERVENT, LPSERVENT;

struct PROTOENT {
	char*  p_name;
	char** p_aliases;
	short  p_proto;
}
alias PROTOENT* PPROTOENT, LPPROTOENT;

enum : int {
	IPPROTO_IP   =   0,
	IPPROTO_ICMP =   1,
	IPPROTO_IGMP =   2,
	IPPROTO_GGP  =   3,
	IPPROTO_TCP  =   6,
	IPPROTO_PUP  =  12,
	IPPROTO_UDP  =  17,
	IPPROTO_IDP  =  22,
	IPPROTO_ND   =  77,
	IPPROTO_RAW  = 255,
	IPPROTO_MAX  = 256
}

// These are not documented on the MSDN site
enum {
	IPPORT_ECHO        =    7,
	IPPORT_DISCARD     =    9,
	IPPORT_SYSTAT      =   11,
	IPPORT_DAYTIME     =   13,
	IPPORT_NETSTAT     =   15,
	IPPORT_FTP         =   21,
	IPPORT_TELNET      =   23,
	IPPORT_SMTP        =   25,
	IPPORT_TIMESERVER  =   37,
	IPPORT_NAMESERVER  =   42,
	IPPORT_WHOIS       =   43,
	IPPORT_MTP         =   57,
	IPPORT_TFTP        =   69,
	IPPORT_RJE         =   77,
	IPPORT_FINGER      =   79,
	IPPORT_TTYLINK     =   87,
	IPPORT_SUPDUP      =   95,
	IPPORT_EXECSERVER  =  512,
	IPPORT_LOGINSERVER =  513,
	IPPORT_CMDSERVER   =  514,
	IPPORT_EFSSERVER   =  520,
	IPPORT_BIFFUDP     =  512,
	IPPORT_WHOSERVER   =  513,
	IPPORT_ROUTESERVER =  520,
	IPPORT_RESERVED    = 1024
}

// These are not documented on the MSDN site
enum {
	IMPLINK_IP        = 155,
	IMPLINK_LOWEXPER  = 156,
	IMPLINK_HIGHEXPER = 158
}

struct IN_ADDR {
	union {
		struct { u_char s_net, s_host, s_lh, s_impno; }
		struct { u_short s_w1, s_imp; }
		u_long s_addr;
	}
}
alias IN_ADDR* PIN_ADDR, LPIN_ADDR;

// IN_CLASSx are not used anywhere or documented on MSDN.
bool IN_CLASSA(int i) {
	return (i & 0x80000000) == 0;
}

const IN_CLASSA_NET    = 0xff000000;
const IN_CLASSA_NSHIFT =  24;
const IN_CLASSA_HOST   = 0x00ffffff;
const IN_CLASSA_MAX    = 128;

bool IN_CLASSB(int i) {
	return (i & 0xC0000000) == 0x80000000;
}

const IN_CLASSB_NET    = 0xffff0000;
const IN_CLASSB_NSHIFT = 16;
const IN_CLASSB_HOST   = 0x0000ffff;
const IN_CLASSB_MAX    = 65536;

bool IN_CLASSC(int i) {
	return (i & 0xE0000000) == 0xC0000000;
}

const IN_CLASSC_NET    = 0xffffff00;
const IN_CLASSC_NSHIFT = 8;
const IN_CLASSC_HOST   = 0x000000ff;

const u_long
	INADDR_ANY       = 0,
	INADDR_LOOPBACK  = 0x7F000001,
	INADDR_BROADCAST = 0xFFFFFFFF,
	INADDR_NONE      = 0xFFFFFFFF;

struct SOCKADDR_IN {
	short   sin_family;
	u_short sin_port;
	IN_ADDR sin_addr;
	char[8] sin_zero;
}
alias SOCKADDR_IN* PSOCKADDR_IN, LPSOCKADDR_IN;

const size_t
	WSADESCRIPTION_LEN = 256,
	WSASYS_STATUS_LEN  = 128;

struct WSADATA {
	WORD   wVersion;
	WORD   wHighVersion;
	char[WSADESCRIPTION_LEN+1] szDescription;
	char[WSASYS_STATUS_LEN+1]  szSystemStatus;
	ushort iMaxSockets;
	ushort iMaxUdpDg;
	char*  lpVendorInfo;
}
alias WSADATA* LPWSADATA;

// This is not documented on the MSDN site
const IP_OPTIONS = 1;

const int
	SO_DEBUG       =   1,
	SO_ACCEPTCONN  =   2,
	SO_REUSEADDR   =   4,
	SO_KEEPALIVE   =   8,
	SO_DONTROUTE   =  16,
	SO_BROADCAST   =  32,
	SO_USELOOPBACK =  64,
	SO_LINGER      = 128,
	SO_OOBINLINE   = 256,
	SO_DONTLINGER  = ~SO_LINGER;

enum : int {
	SO_SNDBUF = 0x1001,
	SO_RCVBUF,
	SO_SNDLOWAT,
	SO_RCVLOWAT,
	SO_SNDTIMEO,
	SO_RCVTIMEO,
	SO_ERROR,
	SO_TYPE // = 0x1008
}

/*
 * Note that the next 5 IP defines are specific to WinSock 1.1 (wsock32.dll).
 * They will cause errors or unexpected results if used with the
 * (gs)etsockopts exported from the WinSock 2 lib, ws2_32.dll. Refer ws2tcpip.h.
 */
enum : int {
	IP_MULTICAST_IF = 2,
	IP_MULTICAST_TTL,
	IP_MULTICAST_LOOP,
	IP_ADD_MEMBERSHIP,
	IP_DROP_MEMBERSHIP
}

// These are not documented on the MSDN site
const IP_DEFAULT_MULTICAST_TTL  =  1;
const IP_DEFAULT_MULTICAST_LOOP =  1;
const IP_MAX_MEMBERSHIPS        = 20;

struct ip_mreq {
	IN_ADDR imr_multiaddr;
	IN_ADDR imr_interface;
}

const SOCKET INVALID_SOCKET = uint.max;
const int SOCKET_ERROR = -1;

enum : int {
	SOCK_STREAM = 1,
	SOCK_DGRAM,
	SOCK_RAW,
	SOCK_RDM,
	SOCK_SEQPACKET
}

const int TCP_NODELAY = 1;

enum : int {
	AF_UNSPEC,
	AF_UNIX,
	AF_INET,
	AF_IMPLINK,
	AF_PUP,
	AF_CHAOS,
	AF_IPX,  // =  6
	AF_NS       =  6,
	AF_ISO,
	AF_OSI      = AF_ISO,
	AF_ECMA,
	AF_DATAKIT,
	AF_CCITT,
	AF_SNA,
	AF_DECnet,
	AF_DLI,
	AF_LAT,
	AF_HYLINK,
	AF_APPLETALK,
	AF_NETBIOS,
	AF_VOICEVIEW,
	AF_FIREFOX,
	AF_UNKNOWN1,
	AF_BAN,
	AF_ATM,
	AF_INET6,
	AF_MAX  // = 24
}

struct SOCKADDR {
	u_short  sa_family;
	char[14] sa_data;
}
alias SOCKADDR* PSOCKADDR, LPSOCKADDR;

struct sockproto {
	u_short sp_family;
	u_short sp_protocol;
}

enum : int {
	PF_UNSPEC    = AF_UNSPEC,
	PF_UNIX      = AF_UNIX,
	PF_INET      = AF_INET,
	PF_IMPLINK   = AF_IMPLINK,
	PF_PUP       = AF_PUP,
	PF_CHAOS     = AF_CHAOS,
	PF_NS        = AF_NS,
	PF_IPX       = AF_IPX,
	PF_ISO       = AF_ISO,
	PF_OSI       = AF_OSI,
	PF_ECMA      = AF_ECMA,
	PF_DATAKIT   = AF_DATAKIT,
	PF_CCITT     = AF_CCITT,
	PF_SNA       = AF_SNA,
	PF_DECnet    = AF_DECnet,
	PF_DLI       = AF_DLI,
	PF_LAT       = AF_LAT,
	PF_HYLINK    = AF_HYLINK,
	PF_APPLETALK = AF_APPLETALK,
	PF_VOICEVIEW = AF_VOICEVIEW,
	PF_FIREFOX   = AF_FIREFOX,
	PF_UNKNOWN1  = AF_UNKNOWN1,
	PF_BAN       = AF_BAN,
	PF_ATM       = AF_ATM,
	PF_INET6     = AF_INET6,
	PF_MAX       = AF_MAX
}

const int SOL_SOCKET = 0xFFFF;

const int SOMAXCONN = 5;

const int
	MSG_OOB       = 1,
	MSG_PEEK      = 2,
	MSG_DONTROUTE = 4,
	MSG_MAXIOVLEN = 16,
	MSG_PARTIAL   = 0x8000;

const size_t MAXGETHOSTSTRUCT = 1024;

const int
	FD_READ    =  1,
	FD_WRITE   =  2,
	FD_OOB     =  4,
	FD_ACCEPT  =  8,
	FD_CONNECT = 16,
	FD_CLOSE   = 32;

enum : int {
	WSABASEERR         = 10000,
	WSAEINTR           = 10004,
	WSAEBADF           = 10009,
	WSAEACCES          = 10013,
	WSAEFAULT          = 10014,
	WSAEINVAL          = 10022,
	WSAEMFILE          = 10024,
	WSAEWOULDBLOCK     = 10035,
	WSAEINPROGRESS     = 10036,
	WSAEALREADY        = 10037,
	WSAENOTSOCK        = 10038,
	WSAEDESTADDRREQ    = 10039,
	WSAEMSGSIZE        = 10040,
	WSAEPROTOTYPE      = 10041,
	WSAENOPROTOOPT     = 10042,
	WSAEPROTONOSUPPORT = 10043,
	WSAESOCKTNOSUPPORT = 10044,
	WSAEOPNOTSUPP      = 10045,
	WSAEPFNOSUPPORT    = 10046,
	WSAEAFNOSUPPORT    = 10047,
	WSAEADDRINUSE      = 10048,
	WSAEADDRNOTAVAIL   = 10049,
	WSAENETDOWN        = 10050,
	WSAENETUNREACH     = 10051,
	WSAENETRESET       = 10052,
	WSAECONNABORTED    = 10053,
	WSAECONNRESET      = 10054,
	WSAENOBUFS         = 10055,
	WSAEISCONN         = 10056,
	WSAENOTCONN        = 10057,
	WSAESHUTDOWN       = 10058,
	WSAETOOMANYREFS    = 10059,
	WSAETIMEDOUT       = 10060,
	WSAECONNREFUSED    = 10061,
	WSAELOOP           = 10062,
	WSAENAMETOOLONG    = 10063,
	WSAEHOSTDOWN       = 10064,
	WSAEHOSTUNREACH    = 10065,
	WSAENOTEMPTY       = 10066,
	WSAEPROCLIM        = 10067,
	WSAEUSERS          = 10068,
	WSAEDQUOT          = 10069,
	WSAESTALE          = 10070,
	WSAEREMOTE         = 10071,
	WSAEDISCON         = 10101,
	WSASYSNOTREADY     = 10091,
	WSAVERNOTSUPPORTED = 10092,
	WSANOTINITIALISED  = 10093,
	WSAHOST_NOT_FOUND  = 11001,
	WSATRY_AGAIN       = 11002,
	WSANO_RECOVERY     = 11003,
	WSANO_DATA         = 11004,
	WSANO_ADDRESS      = WSANO_DATA
}

alias WSAGetLastError h_errno;

enum : int {
	HOST_NOT_FOUND = WSAHOST_NOT_FOUND,
	TRY_AGAIN      = WSATRY_AGAIN,
	NO_RECOVERY    = WSANO_RECOVERY,
	NO_DATA        = WSANO_DATA,
	NO_ADDRESS     = WSANO_ADDRESS
}

extern (Pascal) {
	SOCKET accept(SOCKET, SOCKADDR*, int*);
	int bind(SOCKET, const(SOCKADDR)*, int);
	int closesocket(SOCKET);
	int connect(SOCKET, const(SOCKADDR)*, int);
	int ioctlsocket(SOCKET, int, u_long*);
	int getpeername(SOCKET, SOCKADDR*, int*);
	int getsockname(SOCKET, SOCKADDR*, int*);
	int getsockopt(SOCKET, int, int, char*, int*);
	uint inet_addr(const(char)*);
	int listen(SOCKET, int);
	int recv(SOCKET, char*, int, int);
	int recvfrom(SOCKET, char*, int, int, SOCKADDR*, int*);
	int send(SOCKET, const(char)*, int, int);
	int sendto(SOCKET, const(char)*, int, int, const(SOCKADDR)*, int);
	int setsockopt(SOCKET, int, int, const(char)*, int);
	int shutdown(SOCKET, int);
	SOCKET socket(int, int, int);
	int WSAStartup(WORD, LPWSADATA);
	int WSACleanup();
	void WSASetLastError(int);
	int WSAGetLastError();
	BOOL WSAIsBlocking();
	int WSAUnhookBlockingHook();
	FARPROC WSASetBlockingHook(FARPROC);
	int WSACancelBlockingCall();
	HANDLE WSAAsyncGetServByName(HWND, u_int, const(char)*, const(char)*, char*, int);
	HANDLE WSAAsyncGetServByPort(HWND, u_int, int, const(char)*, char*, int);
	HANDLE WSAAsyncGetProtoByName(HWND, u_int, const(char)*, char*, int);
	HANDLE WSAAsyncGetProtoByNumber(HWND, u_int, int, char*, int);
	HANDLE WSAAsyncGetHostByName(HWND, u_int, const(char)*, char*, int);
	HANDLE WSAAsyncGetHostByAddr(HWND, u_int, const(char)*, int, int, char*, int);
	int WSACancelAsyncRequest(HANDLE);
	int WSAAsyncSelect(SOCKET, HWND, u_int, int);
	u_long htonl(u_long);
	u_long ntohl(u_long);
	u_short htons(u_short);
	u_short ntohs(u_short);
	int select(int nfds, FD_SET*, FD_SET*, FD_SET*, const(TIMEVAL)*);
	int gethostname(char*, int);
}

extern (Windows) {
	char* inet_ntoa(IN_ADDR);
	HOSTENT* gethostbyaddr(const(char)*, int, int);
	HOSTENT* gethostbyname(const(char)*);
	SERVENT* getservbyport(int, const(char)*);
	SERVENT* getservbyname(const(char)*, const(char)*);
	PROTOENT* getprotobynumber(int);
	PROTOENT* getprotobyname(const(char)*);
}

alias MAKELONG WSAMAKEASYNCREPLY, WSAMAKESELECTREPLY;
alias LOWORD WSAGETASYNCBUFLEN, WSAGETSELECTEVENT;
alias HIWORD WSAGETASYNCERROR, WSAGETSELECTERROR;


/*
 * Recent MSDN docs indicate that the MS-specific extensions exported from
 * mswsock.dll (AcceptEx, TransmitFile. WSARecEx and GetAcceptExSockaddrs) are
 * declared in mswsock.h. These extensions are not supported on W9x or WinCE.
 * However, code using WinSock 1.1 API may expect the declarations and
 * associated defines to be in this header. Thus we include mswsock.h here.
 *
 * When linking against the WinSock 1.1 lib, wsock32.dll, the mswsock functions
 * are automatically routed to mswsock.dll (on platforms with support).
 * The WinSock 2 lib, ws2_32.dll, does not contain any references to
 * the mswsock extensions.
 */

import win32.mswsock;
