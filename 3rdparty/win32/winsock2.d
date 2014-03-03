/***********************************************************************\
*                              winsock2.d                               *
*                                                                       *
*                       Windows API header module                       *
*                                                                       *
*                 Translated from MinGW Windows headers                 *
*                             by Daniel Keep                            *
\***********************************************************************/
module win32.winsock2;
pragma(lib, "Ws2_32");

/*
  Definitions for winsock 2

  Contributed by the WINE project.

  Portions Copyright (c) 1980, 1983, 1988, 1993
  The Regents of the University of California.  All rights reserved.

  Portions Copyright (c) 1993 by Digital Equipment Corporation.
 */

/*	DRK: This module should not be included if -version=Win32_Winsock2 has
 *	not been set.  If it has, assert.  I think it's better this way than
 *	letting the user believe that it's worked.
 *
 *	SG: It has now been changed so that winsock2 is the default, and
 *	-version=Win32_Winsock1 must be set to use winsock.
 */
version(Win32_Winsock1) {
	pragma(msg, "Cannot use win32.winsock2 with Win32_Winsock1 defined.");
	static assert(false);
}

import win32.winbase;
import win32.windef;
import win32.basetyps;

alias char u_char;
alias ushort u_short;
alias uint u_int, u_long, SOCKET;

const size_t FD_SETSIZE = 64;

/* shutdown() how types */
enum : int {
	SD_RECEIVE,
	SD_SEND,
	SD_BOTH
}

/* Good grief this is stupid... is it a struct?  A preprocessor macro?  A
   struct tag?  Who the hell knows!? */
struct FD_SET {
	u_int               fd_count;
	SOCKET[FD_SETSIZE]  fd_array;

	/* this differs from the define in winsock.h and in cygwin sys/types.h */
	static void opCall(SOCKET fd, FD_SET set) {
		u_int i;
		for (i = 0; i < set.fd_count; i++)
			if (set.fd_array[i] == fd)
				break;
		if (i == set.fd_count)
			if (set.fd_count < FD_SETSIZE) {
				set.fd_array[i] = fd;
				set.fd_count++;
			}
	}
}
alias FD_SET* PFD_SET, LPFD_SET;

// Keep this alias, since fd_set isn't a tag name in the original header.
alias FD_SET fd_set;

extern(Windows) int __WSAFDIsSet(SOCKET, FD_SET*);
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

bool timerisset(TIMEVAL* tvp) {
	return tvp.tv_sec || tvp.tv_usec;
}

/+
/* DRK: These have been commented out because it was felt that using
 * omCmp on the TIMEVAL struct was cleaner.  Still, perhaps these should
 * be enabled under a version tag for compatibility's sake?
 * If it is decided that it's just ugly and unwanted, then feel free to
 * delete this section :)
 */
int timercmp(TIMEVAL* tvp, TIMEVAL* uvp) {
	return tvp.tv_sec != uvp.tv_sec ?
	    (tvp.tv_sec < uvp.tv_sec ? -1 :
            (tvp.tv_sec > uvp.tv_sec ? 1 : 0)) :
	    (tvp.tv_usec < uvp.tv_usec ? -1 :
	        (tvp.tv_usec > uvp.tv_usec ? 1 : 0));
}

int timercmp(TIMEVAL* tvp, TIMEVAL* uvp, int function(long,long) cmp) {
	return tvp.tv_sec != uvp.tv_sec ?
	    cmp(tvp.tv_sec, uvp.tv_sec) :
	    cmp(tvp.tv_usec, uvp.tv_usec);
}+/

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

enum : DWORD {
	IOCPARAM_MASK = 0x7f,
	IOC_VOID      = 0x20000000,
	IOC_OUT       = 0x40000000,
	IOC_IN        = 0x80000000,
	IOC_INOUT     = IOC_IN|IOC_OUT
}

// NOTE: This isn't even used anywhere...
template _IO(char x, ubyte y) {
	const DWORD _IO = IOC_VOID | (cast(ubyte)x<<8) | y;
}

template _IOR(char x, ubyte y, t) {
	const DWORD _IOR = IOC_OUT | ((t.sizeof & IOCPARAM_MASK)<<16)
		| (cast(ubyte)x<<8) | y;
}

template _IOW(char x, ubyte y, t) {
	const DWORD _IOW = IOC_IN | ((t.sizeof & IOCPARAM_MASK)<<16)
		| (cast(ubyte)x<<8) | y;
}

enum : DWORD {
	FIONBIO    = _IOW!('f', 126, u_long),
	FIONREAD   = _IOR!('f', 127, u_long),
	FIOASYNC   = _IOW!('f', 125, u_long),
	SIOCSHIWAT = _IOW!('s',   0, u_long),
	SIOCGHIWAT = _IOR!('s',   1, u_long),
	SIOCSLOWAT = _IOW!('s',   2, u_long),
	SIOCGLOWAT = _IOR!('s',   3, u_long),
	SIOCATMARK = _IOR!('s',   7, u_long)
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
	IPPROTO_MAX  = 256,

	// IPv6 options
	IPPROTO_HOPOPTS  =  0, // IPv6 Hop-by-Hop options
	IPPROTO_IPV6     = 41, // IPv6 header
	IPPROTO_ROUTING  = 43, // IPv6 Routing header
	IPPROTO_FRAGMENT = 44, // IPv6 fragmentation header
	IPPROTO_ESP      = 50, // encapsulating security payload
	IPPROTO_AH       = 51, // authentication header
	IPPROTO_ICMPV6   = 58, // ICMPv6
	IPPROTO_NONE     = 59, // IPv6 no next header
	IPPROTO_DSTOPTS  = 60  // IPv6 Destination options
}

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

enum {
	IMPLINK_IP         =  155,
	IMPLINK_LOWEXPER   =  156,
	IMPLINK_HIGHEXPER  =  158
}

struct IN_ADDR {
	union {
		struct { u_char  s_b1, s_b2, s_b3, s_b4; }
		struct { u_char  s_net, s_host, s_lh, s_impno; }
		struct { u_short s_w1, s_w2; }
		struct { u_short s_w_, s_imp; } // Can I get rid of s_w_ using alignment tricks?
		u_long S_addr;
		u_long s_addr;
	}
}
alias IN_ADDR* PIN_ADDR, LPIN_ADDR;

// IN_CLASSx are not used anywhere or documented on MSDN.
bool IN_CLASSA(int i) { return (i & 0x80000000) == 0; }

const IN_CLASSA_NET    = 0xff000000;
const IN_CLASSA_NSHIFT =         24;
const IN_CLASSA_HOST   = 0x00ffffff;
const IN_CLASSA_MAX    =        128;

bool IN_CLASSB(int i) { return (i & 0xc0000000) == 0x80000000; }

const IN_CLASSB_NET    = 0xffff0000;
const IN_CLASSB_NSHIFT =         16;
const IN_CLASSB_HOST   = 0x0000ffff;
const IN_CLASSB_MAX    =      65536;

bool IN_CLASSC(int i) { return (i & 0xe0000000) == 0xc0000000; }

const IN_CLASSC_NET    = 0xffffff00;
const IN_CLASSC_NSHIFT =          8;
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
	SO_OPTIONS     =   1,
	SO_DEBUG       =   1,
	SO_ACCEPTCONN  =   2,
	SO_REUSEADDR   =   4,
	SO_KEEPALIVE   =   8,
	SO_DONTROUTE   =  16,
	SO_BROADCAST   =  32,
	SO_USELOOPBACK =  64,
	SO_LINGER      = 128,
	SO_OOBINLINE   = 256,
	SO_DONTLINGER  = ~SO_LINGER,
	SO_EXCLUSIVEADDRUSE= ~SO_REUSEADDR;

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

const SOCKET INVALID_SOCKET = cast(SOCKET)(~0);
const int SOCKET_ERROR = -1;

enum : int {
	SOCK_STREAM = 1,
	SOCK_DGRAM,
	SOCK_RAW,
	SOCK_RDM,
	SOCK_SEQPACKET
}

const int TCP_NODELAY = 0x0001;

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
	// AF_CLUSTER, AF_12844 nad AF_NETDES are not documented on MSDN
	AF_CLUSTER,
	AF_12844,
	AF_IRDA, // = 26
	AF_NETDES   = 28,
	AF_MAX   // = 29
}

struct SOCKADDR {
	u_short  sa_family;
	char[14] sa_data;
}
alias SOCKADDR* PSOCKADDR, LPSOCKADDR;

/* Portable IPv6/IPv4 version of sockaddr.
   Uses padding to force 8 byte alignment
   and maximum size of 128 bytes */
struct SOCKADDR_STORAGE {
    short     ss_family;
    char[6]   __ss_pad1;   // pad to 8
    long      __ss_align;  // force alignment
    char[112] __ss_pad2;   // pad to 128
}
alias SOCKADDR_STORAGE* PSOCKADDR_STORAGE;

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

// Not documented on MSDN
enum {
	FD_READ_BIT,
	FD_WRITE_BIT,
	FD_OOB_BIT,
	FD_ACCEPT_BIT,
	FD_CONNECT_BIT,
	FD_CLOSE_BIT,
	FD_QOS_BIT,
	FD_GROUP_QOS_BIT,
	FD_ROUTING_INTERFACE_CHANGE_BIT,
	FD_ADDRESS_LIST_CHANGE_BIT,
	FD_MAX_EVENTS // = 10
}

const int
	FD_READ                     = 1 << FD_READ_BIT,
	FD_WRITE                    = 1 << FD_WRITE_BIT,
	FD_OOB                      = 1 << FD_OOB_BIT,
	FD_ACCEPT                   = 1 << FD_ACCEPT_BIT,
	FD_CONNECT                  = 1 << FD_CONNECT_BIT,
	FD_CLOSE                    = 1 << FD_CLOSE_BIT,
	FD_QOS                      = 1 << FD_QOS_BIT,
	FD_GROUP_QOS                = 1 << FD_GROUP_QOS_BIT,
	FD_ROUTING_INTERFACE_CHANGE = 1 << FD_ROUTING_INTERFACE_CHANGE_BIT,
	FD_ADDRESS_LIST_CHANGE      = 1 << FD_ADDRESS_LIST_CHANGE_BIT,
	FD_ALL_EVENTS               = (1 << FD_MAX_EVENTS) - 1;

enum : int {
	WSABASEERR         = 10000,
	WSAEINTR           = WSABASEERR + 4,
	WSAEBADF           = WSABASEERR + 9,
	WSAEACCES          = WSABASEERR + 13,
	WSAEFAULT          = WSABASEERR + 14,
	WSAEINVAL          = WSABASEERR + 22,
	WSAEMFILE          = WSABASEERR + 24,
	WSAEWOULDBLOCK     = WSABASEERR + 35,
	WSAEINPROGRESS     = WSABASEERR + 36, // deprecated on WinSock2
	WSAEALREADY        = WSABASEERR + 37,
	WSAENOTSOCK        = WSABASEERR + 38,
	WSAEDESTADDRREQ    = WSABASEERR + 39,
	WSAEMSGSIZE        = WSABASEERR + 40,
	WSAEPROTOTYPE      = WSABASEERR + 41,
	WSAENOPROTOOPT     = WSABASEERR + 42,
	WSAEPROTONOSUPPORT = WSABASEERR + 43,
	WSAESOCKTNOSUPPORT = WSABASEERR + 44,
	WSAEOPNOTSUPP      = WSABASEERR + 45,
	WSAEPFNOSUPPORT    = WSABASEERR + 46,
	WSAEAFNOSUPPORT    = WSABASEERR + 47,
	WSAEADDRINUSE      = WSABASEERR + 48,
	WSAEADDRNOTAVAIL   = WSABASEERR + 49,
	WSAENETDOWN        = WSABASEERR + 50,
	WSAENETUNREACH     = WSABASEERR + 51,
	WSAENETRESET       = WSABASEERR + 52,
	WSAECONNABORTED    = WSABASEERR + 53,
	WSAECONNRESET      = WSABASEERR + 54,
	WSAENOBUFS         = WSABASEERR + 55,
	WSAEISCONN         = WSABASEERR + 56,
	WSAENOTCONN        = WSABASEERR + 57,
	WSAESHUTDOWN       = WSABASEERR + 58,
	WSAETOOMANYREFS    = WSABASEERR + 59,
	WSAETIMEDOUT       = WSABASEERR + 60,
	WSAECONNREFUSED    = WSABASEERR + 61,
	WSAELOOP           = WSABASEERR + 62,
	WSAENAMETOOLONG    = WSABASEERR + 63,
	WSAEHOSTDOWN       = WSABASEERR + 64,
	WSAEHOSTUNREACH    = WSABASEERR + 65,
	WSAENOTEMPTY       = WSABASEERR + 66,
	WSAEPROCLIM        = WSABASEERR + 67,
	WSAEUSERS          = WSABASEERR + 68,
	WSAEDQUOT          = WSABASEERR + 69,
	WSAESTALE          = WSABASEERR + 70,
	WSAEREMOTE         = WSABASEERR + 71,
	WSAEDISCON         = WSABASEERR + 101,
	WSASYSNOTREADY     = WSABASEERR + 91,
	WSAVERNOTSUPPORTED = WSABASEERR + 92,
	WSANOTINITIALISED  = WSABASEERR + 93,
	WSAHOST_NOT_FOUND  = WSABASEERR + 1001,
	WSATRY_AGAIN       = WSABASEERR + 1002,
	WSANO_RECOVERY     = WSABASEERR + 1003,
	WSANO_DATA         = WSABASEERR + 1004,
	WSANO_ADDRESS      = WSANO_DATA,

	// WinSock2 specific error codes
	WSAENOMORE             = WSABASEERR + 102,
	WSAECANCELLED          = WSABASEERR + 103,
	WSAEINVALIDPROCTABLE   = WSABASEERR + 104,
	WSAEINVALIDPROVIDER    = WSABASEERR + 105,
	WSAEPROVIDERFAILEDINIT = WSABASEERR + 106,
	WSASYSCALLFAILURE      = WSABASEERR + 107,
	WSASERVICE_NOT_FOUND   = WSABASEERR + 108,
	WSATYPE_NOT_FOUND      = WSABASEERR + 109,
	WSA_E_NO_MORE          = WSABASEERR + 110,
	WSA_E_CANCELLED        = WSABASEERR + 111,
	WSAEREFUSED            = WSABASEERR + 112,

	// WS QualityofService errors
	WSA_QOS_RECEIVERS          = WSABASEERR + 1005,
	WSA_QOS_SENDERS            = WSABASEERR + 1006,
	WSA_QOS_NO_SENDERS         = WSABASEERR + 1007,
	WSA_QOS_NO_RECEIVERS       = WSABASEERR + 1008,
	WSA_QOS_REQUEST_CONFIRMED  = WSABASEERR + 1009,
	WSA_QOS_ADMISSION_FAILURE  = WSABASEERR + 1010,
	WSA_QOS_POLICY_FAILURE     = WSABASEERR + 1011,
	WSA_QOS_BAD_STYLE          = WSABASEERR + 1012,
	WSA_QOS_BAD_OBJECT         = WSABASEERR + 1013,
	WSA_QOS_TRAFFIC_CTRL_ERROR = WSABASEERR + 1014,
	WSA_QOS_GENERIC_ERROR      = WSABASEERR + 1015,
	WSA_QOS_ESERVICETYPE       = WSABASEERR + 1016,
	WSA_QOS_EFLOWSPEC          = WSABASEERR + 1017,
	WSA_QOS_EPROVSPECBUF       = WSABASEERR + 1018,
	WSA_QOS_EFILTERSTYLE       = WSABASEERR + 1019,
	WSA_QOS_EFILTERTYPE        = WSABASEERR + 1020,
	WSA_QOS_EFILTERCOUNT       = WSABASEERR + 1021,
	WSA_QOS_EOBJLENGTH         = WSABASEERR + 1022,
	WSA_QOS_EFLOWCOUNT         = WSABASEERR + 1023,
	WSA_QOS_EUNKOWNPSOBJ       = WSABASEERR + 1024,
	WSA_QOS_EPOLICYOBJ         = WSABASEERR + 1025,
	WSA_QOS_EFLOWDESC          = WSABASEERR + 1026,
	WSA_QOS_EPSFLOWSPEC        = WSABASEERR + 1027,
	WSA_QOS_EPSFILTERSPEC      = WSABASEERR + 1028,
	WSA_QOS_ESDMODEOBJ         = WSABASEERR + 1029,
	WSA_QOS_ESHAPERATEOBJ      = WSABASEERR + 1030,
	WSA_QOS_RESERVED_PETYPE    = WSABASEERR + 1031
}

alias WSAGetLastError h_errno;

enum : int {
	HOST_NOT_FOUND = WSAHOST_NOT_FOUND,
	TRY_AGAIN      = WSATRY_AGAIN,
	NO_RECOVERY    = WSANO_RECOVERY,
	NO_DATA        = WSANO_DATA,
	NO_ADDRESS     = WSANO_ADDRESS
}

extern (Windows) {
	SOCKET accept(SOCKET, SOCKADDR*, int*);
	int bind(SOCKET, const(SOCKADDR)*, int);
	int closesocket(SOCKET);
	int connect(SOCKET, const(SOCKADDR)*, int);
	int ioctlsocket(SOCKET, int, u_long*);
	int getpeername(SOCKET, SOCKADDR*, int*);
	int getsockname(SOCKET, SOCKADDR*, int*);
	int getsockopt(SOCKET, int, int, void*, int*);
	uint inet_addr(const(char)*);
	int listen(SOCKET, int);
	int recv(SOCKET, ubyte*, int, int);
	int recvfrom(SOCKET, ubyte*, int, int, SOCKADDR*, int*);
	int send(SOCKET, const(ubyte)*, int, int);
	int sendto(SOCKET, const(ubyte)*, int, int, const(SOCKADDR)*, int);
	int setsockopt(SOCKET, int, int, const(void)*, int);
	int shutdown(SOCKET, int);
	SOCKET socket(int, int, int);

	alias typeof(&accept) LPFN_ACCEPT;
	alias typeof(&bind) LPFN_BIND;
	alias typeof(&closesocket) LPFN_CLOSESOCKET;
	alias typeof(&connect) LPFN_CONNECT;
	alias typeof(&ioctlsocket) LPFN_IOCTLSOCKET;
	alias typeof(&getpeername) LPFN_GETPEERNAME;
	alias typeof(&getsockname) LPFN_GETSOCKNAME;
	alias typeof(&getsockopt) LPFN_GETSOCKOPT;
	alias typeof(&inet_addr) LPFN_INET_ADDR;
	alias typeof(&listen) LPFN_LISTEN;
	alias typeof(&recv) LPFN_RECV;
	alias typeof(&recvfrom) LPFN_RECVFROM;
	alias typeof(&send) LPFN_SEND;
	alias typeof(&sendto) LPFN_SENDTO;
	alias typeof(&setsockopt) LPFN_SETSOCKOPT;
	alias typeof(&shutdown) LPFN_SHUTDOWN;
	alias typeof(&socket) LPFN_SOCKET;
}

extern(Windows) {
	char* inet_ntoa(IN_ADDR);
	HOSTENT* gethostbyaddr(const(char)*, int, int);
	HOSTENT* gethostbyname(const(char)*);
	SERVENT* getservbyport(int, const(char)*);
	SERVENT* getservbyname(const(char)*, const(char)*);
	PROTOENT* getprotobynumber(int);
	PROTOENT* getprotobyname(const(char)*);

	/* NOTE: DK: in the original headers, these were declared with
	   PASCAL linkage.  Since this is at odds with the definition
	   of the functions themselves, and also since MinGW seems to
	   treat the two interchangably, I have moved them here. */
	alias typeof(&inet_ntoa) LPFN_INET_NTOA;
	alias typeof(&gethostbyaddr) LPFN_GETHOSTBYADDR;
	alias typeof(&gethostbyname) LPFN_GETHOSTBYNAME;
	alias typeof(&getservbyport) LPFN_GETSERVBYPORT;
	alias typeof(&getservbyname) LPFN_GETSERVBYNAME;
	alias typeof(&getprotobynumber) LPFN_GETPROTOBYNUMBER;
	alias typeof(&getprotobyname) LPFN_GETPROTOBYNAME;
}

extern(Windows) {
	int WSAStartup(WORD, LPWSADATA);
	int WSACleanup();
	void WSASetLastError(int);
	int WSAGetLastError();

	alias typeof(&WSAStartup) LPFN_WSASTARTUP;
	alias typeof(&WSACleanup) LPFN_WSACLEANUP;
	alias typeof(&WSASetLastError) LPFN_WSASETLASTERROR;
	alias typeof(&WSAGetLastError) LPFN_WSAGETLASTERROR;
}

/*
 * Pseudo-blocking functions are deprecated in WinSock2
 * spec. Use threads instead.
 */
deprecated extern(Windows) {
	BOOL WSAIsBlocking();
	int WSAUnhookBlockingHook();
	FARPROC WSASetBlockingHook(FARPROC);
	int WSACancelBlockingCall();

	alias typeof(&WSAIsBlocking) LPFN_WSAISBLOCKING;
	alias typeof(&WSAUnhookBlockingHook) LPFN_WSAUNHOOKBLOCKINGHOOK;
	alias typeof(&WSASetBlockingHook) LPFN_WSASETBLOCKINGHOOK;
	alias typeof(&WSACancelBlockingCall) LPFN_WSACANCELBLOCKINGCALL;
}

extern(Windows) {
	HANDLE WSAAsyncGetServByName(HWND, u_int, const(char)*, const(char)*, char*, int);
	HANDLE WSAAsyncGetServByPort(HWND, u_int, int, const(char)*, char*, int);
	HANDLE WSAAsyncGetProtoByName(HWND, u_int, const(char)*, char*, int);
	HANDLE WSAAsyncGetProtoByNumber(HWND, u_int, int, char*, int);
	HANDLE WSAAsyncGetHostByName(HWND, u_int, const(char)*, char*, int);
	HANDLE WSAAsyncGetHostByAddr(HWND, u_int, const(char)*, int, int, char*, int);
	int WSACancelAsyncRequest(HANDLE);
	int WSAAsyncSelect(SOCKET, HWND, u_int, long);

	alias typeof(&WSAAsyncGetServByName) LPFN_WSAAsyncGetServByName;
	alias typeof(&WSAAsyncGetServByPort) LPFN_WSAASYNCGETSERVBYPORT;
	alias typeof(&WSAAsyncGetProtoByName) LPFN_WSAASYNCGETPROTOBYNAME;
	alias typeof(&WSAAsyncGetProtoByNumber) LPFN_WSAASYNCGETPROTOBYNUMBER;
	alias typeof(&WSAAsyncGetHostByName) LPFN_WSAASYNCGETHOSTBYNAME;
	alias typeof(&WSAAsyncGetHostByAddr) LPFN_WSAASYNCGETHOSTBYADDR;
	alias typeof(&WSACancelAsyncRequest) LPFN_WSACANCELASYNCREQUEST;
	alias typeof(&WSAAsyncSelect) LPFN_WSAASYNCSELECT;
}

extern(Windows) {
	u_long htonl(u_long);
	u_long ntohl(u_long);
	u_short htons(u_short);
	u_short ntohs(u_short);
	int select(int nfds, fd_set*, fd_set*, fd_set*, const(TIMEVAL)*);

	alias typeof(&htonl) LPFN_HTONL;
	alias typeof(&ntohl) LPFN_NTOHL;
	alias typeof(&htons) LPFN_HTONS;
	alias typeof(&ntohs) LPFN_NTOHS;
	alias typeof(&select) LPFN_SELECT;

	int gethostname(char*, int);
	alias typeof(&gethostname) LPFN_GETHOSTNAME;
}

alias MAKELONG WSAMAKEASYNCREPLY, WSAMAKESELECTREPLY;
alias LOWORD WSAGETASYNCBUFLEN, WSAGETSELECTEVENT;
alias HIWORD WSAGETASYNCERROR, WSAGETSELECTERROR;


alias INADDR_ANY ADDR_ANY;

bool IN_CLASSD(int i) { return (i & 0xf0000000) == 0xe0000000; }

const IN_CLASSD_NET    = 0xf0000000;
const IN_CLASSD_NSHIFT =         28;
const IN_CLASSD_HOST   = 0x0fffffff;

alias IN_CLASSD IN_MULTICAST;

const FROM_PROTOCOL_INFO = -1;

enum : int {
	SO_GROUP_ID = 0x2001,
	SO_GROUP_PRIORITY,
	SO_MAX_MSG_SIZE,
	SO_PROTOCOL_INFOA,
	SO_PROTOCOL_INFOW
}
// NOTE: These are logically part of the previous enum, but you can't
// have version statements in an enum body...
version(Unicode)
	const int SO_PROTOCOL_INFO = SO_PROTOCOL_INFOW;
else
	const int SO_PROTOCOL_INFO = SO_PROTOCOL_INFOA;

const PVD_CONFIG = 0x3001;

const MSG_INTERRUPT = 0x10;
//const MSG_MAXIOVLEN = 16; // Already declared above

mixin DECLARE_HANDLE!("WSAEVENT");
alias WSAEVENT* LPWSAEVENT;
alias OVERLAPPED WSAOVERLAPPED;
alias OVERLAPPED* LPWSAOVERLAPPED;

private import win32.winerror;
private import win32.winbase;

enum {
	WSA_IO_PENDING        = ERROR_IO_PENDING,
	WSA_IO_INCOMPLETE     = ERROR_IO_INCOMPLETE,
	WSA_INVALID_HANDLE    = ERROR_INVALID_HANDLE,
	WSA_INVALID_PARAMETER = ERROR_INVALID_PARAMETER,
	WSA_NOT_ENOUGH_MEMORY = ERROR_NOT_ENOUGH_MEMORY,
	WSA_OPERATION_ABORTED = ERROR_OPERATION_ABORTED
}

const WSA_INVALID_EVENT = cast(WSAEVENT)HANDLE.init;
const WSA_MAXIMUM_WAIT_EVENTS = MAXIMUM_WAIT_OBJECTS;
const WSA_WAIT_FAILED = cast(DWORD)-1;
const WSA_WAIT_EVENT_0 = WAIT_OBJECT_0;
const WSA_WAIT_IO_COMPLETION = WAIT_IO_COMPLETION;
const WSA_WAIT_TIMEOUT = WAIT_TIMEOUT;
const WSA_INFINITE = INFINITE;

struct WSABUF {
	uint  len;
	char* buf;
}

alias WSABUF* LPWSABUF;

enum GUARANTEE {
	BestEffortService,
	ControlledLoadService,
	PredictiveService,
	GuaranteedDelayService,
	GuaranteedService
}

/* TODO: FLOWSPEC and related definitions belong in qos.h */

/*
   Windows Sockets 2 Application Programming Interface,
   revision 2.2.2 (1997) uses the type uint32 for SERVICETYPE
   and the elements of _flowspec, but the type uint32 is not defined
   or used anywhere else in the w32api. For now, just use
   unsigned int, which is 32 bits on _WIN32 and _WIN64.
*/

alias uint SERVICETYPE;

struct FLOWSPEC {
	uint        TokenRate;
	uint        TokenBucketSize;
	uint        PeakBandwidth;
	uint        Latency;
	uint        DelayVariation;
	SERVICETYPE ServiceType;
	uint        MaxSduSize;
	uint        MinimumPolicedSize;
}

alias FLOWSPEC* PFLOWSPEC, LPFLOWSPEC;

struct QOS
{
	FLOWSPEC SendingFlowspec;
	FLOWSPEC ReceivingFlowspec;
	WSABUF   ProviderSpecific;
}

alias QOS* LPQOS;

enum {
	CF_ACCEPT,
	CF_REJECT,
	CF_DEFER
}

// REM: Already defined above
/*enum {
	SD_RECEIVE,
	SD_SEND,
	SD_BOTH
}*/

alias uint GROUP;

enum {
	SG_UNCONSTRAINED_GROUP = 0x01,
	SG_CONSTRAINED_GROUP
}

struct WSANETWORKEVENTS {
	int lNetworkEvents;
	int[FD_MAX_EVENTS] iErrorCode;
}

alias WSANETWORKEVENTS* LPWSANETWORKEVENTS;

const MAX_PROTOCOL_CHAIN = 7;

const BASE_PROTOCOL    = 1;
const LAYERED_PROTOCOL = 0;

enum WSAESETSERVICEOP
{
	RNRSERVICE_REGISTER = 0,
	RNRSERVICE_DEREGISTER,
	RNRSERVICE_DELETE
}

alias WSAESETSERVICEOP* PWSAESETSERVICEOP, LPWSAESETSERVICEOP;

struct AFPROTOCOLS {
	INT iAddressFamily;
	INT iProtocol;
}

alias AFPROTOCOLS* PAFPROTOCOLS, LPAFPROTOCOLS;

enum WSAECOMPARATOR
{
	COMP_EQUAL = 0,
	COMP_NOTLESS
}

alias WSAECOMPARATOR* PWSAECOMPARATOR, LPWSAECOMPARATOR;

struct WSAVERSION
{
	DWORD          dwVersion;
	WSAECOMPARATOR ecHow;
}

alias WSAVERSION* PWSAVERSION, LPWSAVERSION;

// Import for SOCKET_ADDRESS, CSADDR_INFO
// import win32.nspapi;
//#ifndef __CSADDR_T_DEFINED /* also in nspapi.h */
//#define __CSADDR_T_DEFINED

struct SOCKET_ADDRESS {
	LPSOCKADDR lpSockaddr;
	INT        iSockaddrLength;
}

alias SOCKET_ADDRESS* PSOCKET_ADDRESS, LPSOCKET_ADDRESS;

struct CSADDR_INFO {
	SOCKET_ADDRESS LocalAddr;
	SOCKET_ADDRESS RemoteAddr;
	INT            iSocketType;
	INT            iProtocol;
}

alias CSADDR_INFO* PCSADDR_INFO, LPCSADDR_INFO;

//#endif

struct SOCKET_ADDRESS_LIST {
    INT               iAddressCount;
    SOCKET_ADDRESS[1] _Address;
    SOCKET_ADDRESS* Address() { return _Address.ptr; }
}

alias SOCKET_ADDRESS_LIST* LPSOCKET_ADDRESS_LIST;

// TODO: Import wtypes/nspapi?
//#ifndef __BLOB_T_DEFINED /* also in wtypes.h and nspapi.h */
//#define __BLOB_T_DEFINED
struct BLOB {
	ULONG cbSize;
	BYTE* pBlobData;
}

alias BLOB* PBLOB, LPBLOB;
//#endif

struct WSAQUERYSETA
{
	DWORD         dwSize;
	LPSTR         lpszServiceInstanceName;
	LPGUID        lpServiceClassId;
	LPWSAVERSION  lpVersion;
	LPSTR         lpszComment;
	DWORD         dwNameSpace;
	LPGUID        lpNSProviderId;
	LPSTR         lpszContext;
	DWORD         dwNumberOfProtocols;
	LPAFPROTOCOLS lpafpProtocols;
	LPSTR         lpszQueryString;
	DWORD         dwNumberOfCsAddrs;
	LPCSADDR_INFO lpcsaBuffer;
	DWORD         dwOutputFlags;
	LPBLOB        lpBlob;
}

alias WSAQUERYSETA* PWSAQUERYSETA, LPWSAQUERYSETA;

struct WSAQUERYSETW
{
	DWORD         dwSize;
	LPWSTR        lpszServiceInstanceName;
	LPGUID        lpServiceClassId;
	LPWSAVERSION  lpVersion;
	LPWSTR        lpszComment;
	DWORD         dwNameSpace;
	LPGUID        lpNSProviderId;
	LPWSTR        lpszContext;
	DWORD         dwNumberOfProtocols;
	LPAFPROTOCOLS lpafpProtocols;
	LPWSTR        lpszQueryString;
	DWORD         dwNumberOfCsAddrs;
	LPCSADDR_INFO lpcsaBuffer;
	DWORD         dwOutputFlags;
	LPBLOB        lpBlob;
}


alias WSAQUERYSETW* PWSAQUERYSETW, LPWSAQUERYSETW;

version(Unicode) {
	alias WSAQUERYSETW WSAQUERYSET;
	alias PWSAQUERYSETW PWSAQUERYSET;
	alias LPWSAQUERYSETW LPWSAQUERYSET;
} else {
	alias WSAQUERYSETA WSAQUERYSET;
	alias PWSAQUERYSETA PWSAQUERYSET;
	alias LPWSAQUERYSETA LPWSAQUERYSET;
}

const int
	LUP_DEEP                = 0x0001,
	LUP_CONTAINERS          = 0x0002,
	LUP_NOCONTAINERS        = 0x0004,
	LUP_NEAREST             = 0x0008,
	LUP_RETURN_NAME         = 0x0010,
	LUP_RETURN_TYPE         = 0x0020,
	LUP_RETURN_VERSION      = 0x0040,
	LUP_RETURN_COMMENT      = 0x0080,
	LUP_RETURN_ADDR         = 0x0100,
	LUP_RETURN_BLOB         = 0x0200,
	LUP_RETURN_ALIASES      = 0x0400,
	LUP_RETURN_QUERY_STRING = 0x0800,
	LUP_RETURN_ALL          = 0x0FF0,
	LUP_RES_SERVICE         = 0x8000,
	LUP_FLUSHCACHE          = 0x1000,
	LUP_FLUSHPREVIOUS       = 0x2000;

struct WSANSCLASSINFOA
{
	LPSTR  lpszName;
	DWORD  dwNameSpace;
	DWORD  dwValueType;
	DWORD  dwValueSize;
	LPVOID lpValue;
}

alias WSANSCLASSINFOA* PWSANSCLASSINFOA, LPWSANSCLASSINFOA;

struct WSANSCLASSINFOW
{
	LPWSTR lpszName;
	DWORD  dwNameSpace;
	DWORD  dwValueType;
	DWORD  dwValueSize;
	LPVOID lpValue;
}

alias WSANSCLASSINFOW* PWSANSCLASSINFOW, LPWSANSCLASSINFOW;

version(Unicode) {
	alias WSANSCLASSINFOW WSANSCLASSINFO;
	alias PWSANSCLASSINFOW PWSANSCLASSINFO;
	alias LPWSANSCLASSINFOW LPWSANSCLASSINFO;
} else {
	alias WSANSCLASSINFOA WSANSCLASSINFO;
	alias PWSANSCLASSINFOA PWSANSCLASSINFO;
	alias LPWSANSCLASSINFOA LPWSANSCLASSINFO;
}

struct WSASERVICECLASSINFOA
{
	LPGUID            lpServiceClassId;
	LPSTR             lpszServiceClassName;
	DWORD             dwCount;
	LPWSANSCLASSINFOA lpClassInfos;
}

alias WSASERVICECLASSINFOA* PWSASERVICECLASSINFOA, LPWSASERVICECLASSINFOA;

struct WSASERVICECLASSINFOW
{
	LPGUID            lpServiceClassId;
	LPWSTR            lpszServiceClassName;
	DWORD             dwCount;
	LPWSANSCLASSINFOW lpClassInfos;
}

alias WSASERVICECLASSINFOW* PWSASERVICECLASSINFOW, LPWSASERVICECLASSINFOW;

version(Unicode) {
	alias WSASERVICECLASSINFOW WSASERVICECLASSINFO;
	alias PWSASERVICECLASSINFOW PWSASERVICECLASSINFO;
	alias LPWSASERVICECLASSINFOW LPWSASERVICECLASSINFO;
} else {
	alias WSASERVICECLASSINFOA WSASERVICECLASSINFO;
	alias PWSASERVICECLASSINFOA PWSASERVICECLASSINFO;
	alias LPWSASERVICECLASSINFOA LPWSASERVICECLASSINFO;
}

struct WSANAMESPACE_INFOA {
	GUID  NSProviderId;
	DWORD dwNameSpace;
	BOOL  fActive;
	DWORD dwVersion;
	LPSTR lpszIdentifier;
}

alias WSANAMESPACE_INFOA* PWSANAMESPACE_INFOA, LPWSANAMESPACE_INFOA;

struct WSANAMESPACE_INFOW {
	GUID   NSProviderId;
	DWORD  dwNameSpace;
	BOOL   fActive;
	DWORD  dwVersion;
	LPWSTR lpszIdentifier;
}

alias WSANAMESPACE_INFOW* PWSANAMESPACE_INFOW, LPWSANAMESPACE_INFOW;

version(Unicode) {
	alias WSANAMESPACE_INFOW WSANAMESPACE_INFO;
	alias PWSANAMESPACE_INFOW PWSANAMESPACE_INFO;
	alias LPWSANAMESPACE_INFOW LPWSANAMESPACE_INFO;
} else {
	alias WSANAMESPACE_INFOA WSANAMESPACE_INFO;
	alias PWSANAMESPACE_INFOA PWSANAMESPACE_INFO;
	alias LPWSANAMESPACE_INFOA LPWSANAMESPACE_INFO;
}

struct WSAPROTOCOLCHAIN {
	int                       ChainLen;
	DWORD[MAX_PROTOCOL_CHAIN] ChainEntries;
}

alias WSAPROTOCOLCHAIN* LPWSAPROTOCOLCHAIN;

const WSAPROTOCOL_LEN = 255;

struct WSAPROTOCOL_INFOA {
	DWORD dwServiceFlags1;
	DWORD dwServiceFlags2;
	DWORD dwServiceFlags3;
	DWORD dwServiceFlags4;
	DWORD dwProviderFlags;
	GUID ProviderId;
	DWORD dwCatalogEntryId;
	WSAPROTOCOLCHAIN ProtocolChain;
	int iVersion;
	int iAddressFamily;
	int iMaxSockAddr;
	int iMinSockAddr;
	int iSocketType;
	int iProtocol;
	int iProtocolMaxOffset;
	int iNetworkByteOrder;
	int iSecurityScheme;
	DWORD dwMessageSize;
	DWORD dwProviderReserved;
	CHAR[WSAPROTOCOL_LEN+1] szProtocol;
}

alias WSAPROTOCOL_INFOA* LPWSAPROTOCOL_INFOA;

struct WSAPROTOCOL_INFOW {
	DWORD dwServiceFlags1;
	DWORD dwServiceFlags2;
	DWORD dwServiceFlags3;
	DWORD dwServiceFlags4;
	DWORD dwProviderFlags;
	GUID ProviderId;
	DWORD dwCatalogEntryId;
	WSAPROTOCOLCHAIN ProtocolChain;
	int iVersion;
	int iAddressFamily;
	int iMaxSockAddr;
	int iMinSockAddr;
	int iSocketType;
	int iProtocol;
	int iProtocolMaxOffset;
	int iNetworkByteOrder;
	int iSecurityScheme;
	DWORD dwMessageSize;
	DWORD dwProviderReserved;
	WCHAR[WSAPROTOCOL_LEN+1] szProtocol;
}

alias WSAPROTOCOL_INFOW* LPWSAPROTOCOL_INFOW;

// TODO: Below fptr was defined as "CALLBACK" for linkage; is this right?
extern(C) {
	alias int function(LPWSABUF, LPWSABUF, LPQOS, LPQOS, LPWSABUF, LPWSABUF, GROUP *, DWORD) LPCONDITIONPROC;
}

extern(Windows) {
	alias void function(DWORD, DWORD, LPWSAOVERLAPPED, DWORD) LPWSAOVERLAPPED_COMPLETION_ROUTINE;
}

version(Unicode) {
	alias WSAPROTOCOL_INFOW WSAPROTOCOL_INFO;
	alias LPWSAPROTOCOL_INFOW LPWSAPROTOCOL_INFO;
} else {
	alias WSAPROTOCOL_INFOA WSAPROTOCOL_INFO;
	alias LPWSAPROTOCOL_INFOA LPWSAPROTOCOL_INFO;
}

/* Needed for XP & .NET Server function WSANSPIoctl.  */
enum WSACOMPLETIONTYPE {
    NSP_NOTIFY_IMMEDIATELY = 0,
    NSP_NOTIFY_HWND,
    NSP_NOTIFY_EVENT,
    NSP_NOTIFY_PORT,
    NSP_NOTIFY_APC
}

alias WSACOMPLETIONTYPE* PWSACOMPLETIONTYPE, LPWSACOMPLETIONTYPE;

struct WSACOMPLETION {
    WSACOMPLETIONTYPE Type;
    union WSACOMPLETION_PARAMETERS {
        struct WSACOMPLETION_WINDOWMESSAGE {
            HWND hWnd;
            UINT uMsg;
            WPARAM context;
        }
		WSACOMPLETION_WINDOWMESSAGE WindowMessage;
        struct WSACOMPLETION_EVENT {
            LPWSAOVERLAPPED lpOverlapped;
        }
		WSACOMPLETION_EVENT Event;
        struct WSACOMPLETION_APC {
            LPWSAOVERLAPPED lpOverlapped;
            LPWSAOVERLAPPED_COMPLETION_ROUTINE lpfnCompletionProc;
        }
		WSACOMPLETION_APC Apc;
        struct WSACOMPLETION_PORT {
            LPWSAOVERLAPPED lpOverlapped;
            HANDLE hPort;
            ULONG_PTR Key;
        }
		WSACOMPLETION_PORT Port;
    }
	WSACOMPLETION_PARAMETERS Parameters;
}

alias WSACOMPLETION* PWSACOMPLETION, LPWSACOMPLETION;

const int
	PFL_MULTIPLE_PROTO_ENTRIES  = 0x00000001,
	PFL_RECOMMENDED_PROTO_ENTRY = 0x00000002,
	PFL_HIDDEN                  = 0x00000004,
	PFL_MATCHES_PROTOCOL_ZERO   = 0x00000008;

const int
	XP1_CONNECTIONLESS           = 0x00000001,
	XP1_GUARANTEED_DELIVERY      = 0x00000002,
	XP1_GUARANTEED_ORDER         = 0x00000004,
	XP1_MESSAGE_ORIENTED         = 0x00000008,
	XP1_PSEUDO_STREAM            = 0x00000010,
	XP1_GRACEFUL_CLOSE           = 0x00000020,
	XP1_EXPEDITED_DATA           = 0x00000040,
	XP1_CONNECT_DATA             = 0x00000080,
	XP1_DISCONNECT_DATA          = 0x00000100,
	XP1_SUPPORT_BROADCAST        = 0x00000200,
	XP1_SUPPORT_MULTIPOINT       = 0x00000400,
	XP1_MULTIPOINT_CONTROL_PLANE = 0x00000800,
	XP1_MULTIPOINT_DATA_PLANE    = 0x00001000,
	XP1_QOS_SUPPORTED            = 0x00002000,
	XP1_INTERRUPT                = 0x00004000,
	XP1_UNI_SEND                 = 0x00008000,
	XP1_UNI_RECV                 = 0x00010000,
	XP1_IFS_HANDLES              = 0x00020000,
	XP1_PARTIAL_MESSAGE          = 0x00040000;

enum : int {
	BIGENDIAN    = 0x0000,
	LITTLEENDIAN = 0x0001
}

const SECURITY_PROTOCOL_NONE = 0x0000;

const JL_SENDER_ONLY = 0x01;
const JL_RECEIVER_ONLY = 0x02;
const JL_BOTH = 0x04;

const WSA_FLAG_OVERLAPPED = 0x01;
const WSA_FLAG_MULTIPOINT_C_ROOT = 0x02;
const WSA_FLAG_MULTIPOINT_C_LEAF = 0x04;
const WSA_FLAG_MULTIPOINT_D_ROOT = 0x08;
const WSA_FLAG_MULTIPOINT_D_LEAF = 0x10;

const int IOC_UNIX = 0x00000000;
const int IOC_WS2 = 0x08000000;
const int IOC_PROTOCOL = 0x10000000;
const int IOC_VENDOR = 0x18000000;

template _WSAIO(int x, int y) { const int _WSAIO = IOC_VOID | x | y; }
template _WSAIOR(int x, int y) { const int _WSAIOR = IOC_OUT | x | y; }
template _WSAIOW(int x, int y) { const int _WSAIOW = IOC_IN | x | y; }
template _WSAIORW(int x, int y) { const int _WSAIORW = IOC_INOUT | x | y; }

const int SIO_ASSOCIATE_HANDLE               = _WSAIOW!(IOC_WS2,1);
const int SIO_ENABLE_CIRCULAR_QUEUEING       = _WSAIO!(IOC_WS2,2);
const int SIO_FIND_ROUTE                     = _WSAIOR!(IOC_WS2,3);
const int SIO_FLUSH                          = _WSAIO!(IOC_WS2,4);
const int SIO_GET_BROADCAST_ADDRESS          = _WSAIOR!(IOC_WS2,5);
const int SIO_GET_EXTENSION_FUNCTION_POINTER = _WSAIORW!(IOC_WS2,6);
const int SIO_GET_QOS                        = _WSAIORW!(IOC_WS2,7);
const int SIO_GET_GROUP_QOS                  = _WSAIORW!(IOC_WS2,8);
const int SIO_MULTIPOINT_LOOPBACK            = _WSAIOW!(IOC_WS2,9);
const int SIO_MULTICAST_SCOPE                = _WSAIOW!(IOC_WS2,10);
const int SIO_SET_QOS                        = _WSAIOW!(IOC_WS2,11);
const int SIO_SET_GROUP_QOS                  = _WSAIOW!(IOC_WS2,12);
const int SIO_TRANSLATE_HANDLE               = _WSAIORW!(IOC_WS2,13);
const int SIO_ROUTING_INTERFACE_QUERY        = _WSAIORW!(IOC_WS2,20);
const int SIO_ROUTING_INTERFACE_CHANGE       = _WSAIOW!(IOC_WS2,21);
const int SIO_ADDRESS_LIST_QUERY             = _WSAIOR!(IOC_WS2,22);
const int SIO_ADDRESS_LIST_CHANGE            = _WSAIO!(IOC_WS2,23);
const int SIO_QUERY_TARGET_PNP_HANDLE        = _WSAIOR!(IOC_WS2,24);
const int SIO_NSP_NOTIFY_CHANGE              = _WSAIOW!(IOC_WS2,25);

const int TH_NETDEV = 1;
const int TH_TAPI   = 2;


extern(Windows) {
	SOCKET WSAAccept(SOCKET, SOCKADDR*, LPINT, LPCONDITIONPROC, DWORD);
	INT WSAAddressToStringA(LPSOCKADDR, DWORD, LPWSAPROTOCOL_INFOA, LPSTR, LPDWORD);
	INT WSAAddressToStringW(LPSOCKADDR, DWORD, LPWSAPROTOCOL_INFOW, LPWSTR, LPDWORD);
	BOOL WSACloseEvent(WSAEVENT);
	int WSAConnect(SOCKET, const(SOCKADDR)*, int, LPWSABUF, LPWSABUF, LPQOS, LPQOS);
	WSAEVENT WSACreateEvent();
	int WSADuplicateSocketA(SOCKET, DWORD, LPWSAPROTOCOL_INFOA);
	int WSADuplicateSocketW(SOCKET, DWORD, LPWSAPROTOCOL_INFOW);
	INT WSAEnumNameSpaceProvidersA(LPDWORD, LPWSANAMESPACE_INFOA);
	INT WSAEnumNameSpaceProvidersW(LPDWORD, LPWSANAMESPACE_INFOW);
	int WSAEnumNetworkEvents(SOCKET, WSAEVENT, LPWSANETWORKEVENTS);
	int WSAEnumProtocolsA(LPINT, LPWSAPROTOCOL_INFOA, LPDWORD);
	int WSAEnumProtocolsW(LPINT, LPWSAPROTOCOL_INFOW, LPDWORD);
	int WSAEventSelect(SOCKET, WSAEVENT, int);
	BOOL WSAGetOverlappedResult(SOCKET, LPWSAOVERLAPPED, LPDWORD, BOOL, LPDWORD);
	BOOL WSAGetQOSByName(SOCKET, LPWSABUF, LPQOS);
	INT WSAGetServiceClassInfoA(LPGUID, LPGUID, LPDWORD, LPWSASERVICECLASSINFOA);
	INT WSAGetServiceClassInfoW(LPGUID, LPGUID, LPDWORD, LPWSASERVICECLASSINFOW);
	INT WSAGetServiceClassNameByClassIdA(LPGUID, LPSTR, LPDWORD);
	INT WSAGetServiceClassNameByClassIdW(LPGUID, LPWSTR, LPDWORD);
	int WSAHtonl(SOCKET, uint, uint*);
	int WSAHtons(SOCKET, ushort, ushort*);
	INT WSAInstallServiceClassA(LPWSASERVICECLASSINFOA);
	INT WSAInstallServiceClassW(LPWSASERVICECLASSINFOW);
	int WSAIoctl(SOCKET, DWORD, LPVOID, DWORD, LPVOID, DWORD, LPDWORD, LPWSAOVERLAPPED, LPWSAOVERLAPPED_COMPLETION_ROUTINE);
	SOCKET WSAJoinLeaf(SOCKET, const(SOCKADDR)*, int, LPWSABUF, LPWSABUF, LPQOS, LPQOS, DWORD);
	INT WSALookupServiceBeginA(LPWSAQUERYSETA, DWORD, LPHANDLE);
	INT WSALookupServiceBeginW(LPWSAQUERYSETW lpqsRestrictions, DWORD, LPHANDLE);
	INT WSALookupServiceNextA(HANDLE, DWORD, LPDWORD, LPWSAQUERYSETA);
	INT WSALookupServiceNextW(HANDLE, DWORD, LPDWORD, LPWSAQUERYSETW);
	INT WSALookupServiceEnd(HANDLE);
	int WSANSPIoctl(HANDLE,DWORD,LPVOID,DWORD,LPVOID,DWORD,LPDWORD,LPWSACOMPLETION); /* XP or .NET Server */
	int WSANtohl(SOCKET, uint, uint*);
	int WSANtohs(SOCKET, ushort, ushort*);
	int WSARecv(SOCKET, LPWSABUF, DWORD, LPDWORD, LPDWORD, LPWSAOVERLAPPED, LPWSAOVERLAPPED_COMPLETION_ROUTINE);
	int WSARecvDisconnect(SOCKET, LPWSABUF);
	int WSARecvFrom(SOCKET, LPWSABUF, DWORD, LPDWORD, LPDWORD, SOCKADDR*, LPINT, LPWSAOVERLAPPED, LPWSAOVERLAPPED_COMPLETION_ROUTINE);
	INT WSARemoveServiceClass(LPGUID);
	BOOL WSAResetEvent(WSAEVENT);
	int WSASend(SOCKET, LPWSABUF, DWORD, LPDWORD, DWORD, LPWSAOVERLAPPED, LPWSAOVERLAPPED_COMPLETION_ROUTINE);
	int WSASendDisconnect(SOCKET, LPWSABUF);
	int WSASendTo(SOCKET, LPWSABUF, DWORD, LPDWORD, DWORD, const(SOCKADDR)*, int, LPWSAOVERLAPPED, LPWSAOVERLAPPED_COMPLETION_ROUTINE);
	BOOL WSASetEvent(WSAEVENT);
	INT WSASetServiceA(LPWSAQUERYSETA, WSAESETSERVICEOP, DWORD); // NB: was declared with "WSAAPI" linkage
	INT WSASetServiceW(LPWSAQUERYSETW, WSAESETSERVICEOP, DWORD);
	SOCKET WSASocketA(int, int, int, LPWSAPROTOCOL_INFOA, GROUP, DWORD);
	SOCKET WSASocketW(int, int, int, LPWSAPROTOCOL_INFOW, GROUP, DWORD);
	INT WSAStringToAddressA(LPSTR, INT, LPWSAPROTOCOL_INFOA, LPSOCKADDR, LPINT);
	INT WSAStringToAddressW(LPWSTR, INT, LPWSAPROTOCOL_INFOW, LPSOCKADDR, LPINT);
	DWORD WSAWaitForMultipleEvents(DWORD, const(WSAEVENT)*, BOOL, DWORD, BOOL);

	alias typeof(&WSAAccept) LPFN_WSAACCEPT;
	alias typeof(&WSAAddressToStringA) LPFN_WSAADDRESSTOSTRINGA;
	alias typeof(&WSAAddressToStringW) LPFN_WSAADDRESSTOSTRINGW;
	alias typeof(&WSACloseEvent) LPFN_WSACLOSEEVENT;
	alias typeof(&WSAConnect) LPFN_WSACONNECT;
	alias typeof(&WSACreateEvent) LPFN_WSACREATEEVENT;
	alias typeof(&WSADuplicateSocketA) LPFN_WSADUPLICATESOCKETA;
	alias typeof(&WSADuplicateSocketW) LPFN_WSADUPLICATESOCKETW;
	alias typeof(&WSAEnumNameSpaceProvidersA) LPFN_WSAENUMNAMESPACEPROVIDERSA;
	alias typeof(&WSAEnumNameSpaceProvidersW) LPFN_WSAENUMNAMESPACEPROVIDERSW;
	alias typeof(&WSAEnumNetworkEvents) LPFN_WSAENUMNETWORKEVENTS;
	alias typeof(&WSAEnumProtocolsA) LPFN_WSAENUMPROTOCOLSA;
	alias typeof(&WSAEnumProtocolsW) LPFN_WSAENUMPROTOCOLSW;
	alias typeof(&WSAEventSelect) LPFN_WSAEVENTSELECT;
	alias typeof(&WSAGetOverlappedResult) LPFN_WSAGETOVERLAPPEDRESULT;
	alias typeof(&WSAGetQOSByName) LPFN_WSAGETQOSBYNAME;
	alias typeof(&WSAGetServiceClassInfoA) LPFN_WSAGETSERVICECLASSINFOA;
	alias typeof(&WSAGetServiceClassInfoW) LPFN_WSAGETSERVICECLASSINFOW;
	alias typeof(&WSAGetServiceClassNameByClassIdA) LPFN_WSAGETSERVICECLASSNAMEBYCLASSIDA;
	alias typeof(&WSAGetServiceClassNameByClassIdW) LPFN_WSAGETSERVICECLASSNAMEBYCLASSIDW;
	alias typeof(&WSAHtonl) LPFN_WSAHTONL;
	alias typeof(&WSAHtons) LPFN_WSAHTONS;
	alias typeof(&WSAInstallServiceClassA) LPFN_WSAINSTALLSERVICECLASSA;
	alias typeof(&WSAInstallServiceClassW) LPFN_WSAINSTALLSERVICECLASSW;
	alias typeof(&WSAIoctl) LPFN_WSAIOCTL;
	alias typeof(&WSAJoinLeaf) LPFN_WSAJOINLEAF;
	alias typeof(&WSALookupServiceBeginA) LPFN_WSALOOKUPSERVICEBEGINA;
	alias typeof(&WSALookupServiceBeginW) LPFN_WSALOOKUPSERVICEBEGINW;
	alias typeof(&WSALookupServiceNextA) LPFN_WSALOOKUPSERVICENEXTA;
	alias typeof(&WSALookupServiceNextW) LPFN_WSALOOKUPSERVICENEXTW;
	alias typeof(&WSALookupServiceEnd) LPFN_WSALOOKUPSERVICEEND;
	alias typeof(&WSANSPIoctl) LPFN_WSANSPIoctl;
	alias typeof(&WSANtohl) LPFN_WSANTOHL;
	alias typeof(&WSANtohs) LPFN_WSANTOHS;
	alias typeof(&WSARecv) LPFN_WSARECV;
	alias typeof(&WSARecvDisconnect) LPFN_WSARECVDISCONNECT;
	alias typeof(&WSARecvFrom) LPFN_WSARECVFROM;
	alias typeof(&WSARemoveServiceClass) LPFN_WSAREMOVESERVICECLASS;
	alias typeof(&WSAResetEvent) LPFN_WSARESETEVENT;
	alias typeof(&WSASend) LPFN_WSASEND;
	alias typeof(&WSASendDisconnect) LPFN_WSASENDDISCONNECT;
	alias typeof(&WSASendTo) LPFN_WSASENDTO;
	alias typeof(&WSASetEvent) LPFN_WSASETEVENT;
	alias typeof(&WSASetServiceA) LPFN_WSASETSERVICEA;
	alias typeof(&WSASetServiceW) LPFN_WSASETSERVICEW;
	alias typeof(&WSASocketA) LPFN_WSASOCKETA;
	alias typeof(&WSASocketW) LPFN_WSASOCKETW;
	alias typeof(&WSAStringToAddressA) LPFN_WSASTRINGTOADDRESSA;
	alias typeof(&WSAStringToAddressW) LPFN_WSASTRINGTOADDRESSW;
	alias typeof(&WSAWaitForMultipleEvents) LPFN_WSAWAITFORMULTIPLEEVENTS;
}

version(Unicode) {
	alias LPFN_WSAADDRESSTOSTRINGW LPFN_WSAADDRESSTOSTRING;
	alias LPFN_WSADUPLICATESOCKETW LPFN_WSADUPLICATESOCKET;
	alias LPFN_WSAENUMNAMESPACEPROVIDERSW LPFN_WSAENUMNAMESPACEPROVIDERS;
	alias LPFN_WSAENUMPROTOCOLSW LPFN_WSAENUMPROTOCOLS;
	alias LPFN_WSAGETSERVICECLASSINFOW LPFN_WSAGETSERVICECLASSINFO;
	alias LPFN_WSAGETSERVICECLASSNAMEBYCLASSIDW LPFN_WSAGETSERVICECLASSNAMEBYCLASSID;
	alias LPFN_WSAINSTALLSERVICECLASSW LPFN_WSAINSTALLSERVICECLASS;
	alias LPFN_WSALOOKUPSERVICEBEGINW LPFN_WSALOOKUPSERVICEBEGIN;
	alias LPFN_WSALOOKUPSERVICENEXTW LPFN_WSALOOKUPSERVICENEXT;
	alias LPFN_WSASETSERVICEW LPFN_WSASETSERVICE;
	alias LPFN_WSASOCKETW LPFN_WSASOCKET;
	alias LPFN_WSASTRINGTOADDRESSW LPFN_WSASTRINGTOADDRESS;
	alias WSAAddressToStringW WSAAddressToString;
	alias WSADuplicateSocketW WSADuplicateSocket;
	alias WSAEnumNameSpaceProvidersW WSAEnumNameSpaceProviders;
	alias WSAEnumProtocolsW WSAEnumProtocols;
	alias WSAGetServiceClassInfoW WSAGetServiceClassInfo;
	alias WSAGetServiceClassNameByClassIdW WSAGetServiceClassNameByClassId;
	alias WSASetServiceW WSASetService;
	alias WSASocketW WSASocket;
	alias WSAStringToAddressW WSAStringToAddress;
	alias WSALookupServiceBeginW WSALookupServiceBegin;
	alias WSALookupServiceNextW WSALookupServiceNext;
	alias WSAInstallServiceClassW WSAInstallServiceClass;
} else {
	alias LPFN_WSAADDRESSTOSTRINGA LPFN_WSAADDRESSTOSTRING;
	alias LPFN_WSADUPLICATESOCKETW LPFN_WSADUPLICATESOCKET;
	alias LPFN_WSAENUMNAMESPACEPROVIDERSA LPFN_WSAENUMNAMESPACEPROVIDERS;
	alias LPFN_WSAENUMPROTOCOLSA LPFN_WSAENUMPROTOCOLS;
	alias LPFN_WSAGETSERVICECLASSINFOA LPFN_WSAGETSERVICECLASSINFO;
	alias LPFN_WSAGETSERVICECLASSNAMEBYCLASSIDA LPFN_WSAGETSERVICECLASSNAMEBYCLASSID;
	alias LPFN_WSAINSTALLSERVICECLASSA LPFN_WSAINSTALLSERVICECLASS;
	alias LPFN_WSALOOKUPSERVICEBEGINA LPFN_WSALOOKUPSERVICEBEGIN;
	alias LPFN_WSALOOKUPSERVICENEXTA LPFN_WSALOOKUPSERVICENEXT;
	alias LPFN_WSASETSERVICEA LPFN_WSASETSERVICE;
	alias LPFN_WSASOCKETA LPFN_WSASOCKET;
	alias LPFN_WSASTRINGTOADDRESSA LPFN_WSASTRINGTOADDRESS;
	alias WSAAddressToStringA WSAAddressToString;
	alias WSADuplicateSocketA WSADuplicateSocket;
	alias WSAEnumNameSpaceProvidersA WSAEnumNameSpaceProviders;
	alias WSAEnumProtocolsA WSAEnumProtocols;
	alias WSAGetServiceClassInfoA WSAGetServiceClassInfo;
	alias WSAGetServiceClassNameByClassIdA WSAGetServiceClassNameByClassId;
	alias WSAInstallServiceClassA WSAInstallServiceClass;
	alias WSALookupServiceBeginA WSALookupServiceBegin;
	alias WSALookupServiceNextA WSALookupServiceNext;
	alias WSASocketA WSASocket;
	alias WSAStringToAddressA WSAStringToAddress;
	alias WSASetServiceA WSASetService;
}
