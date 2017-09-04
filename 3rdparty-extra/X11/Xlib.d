/* 	Xlib binding for D language
	Copyright 2007 TEISSIER Sylvere sligor(at)free.fr
	version 0.1 2007/08/29
	This binding is an alpha release and need to be more tested

	This file is free software, please read COPYING file for more informations
*/

/* This file is binding from:
 $XdotOrg: lib/X11/include/X11/Xlib.h,v 1.6 2005-11-08 06:33:25 jkj Exp $
 $Xorg: Xlib.h,v 1.6 2001/02/09 02:03:38 xorgcvs Exp $
*/

module std.c.linux.X11.Xlib;
version(USE_XCB):
public import std.c.linux.X11.X;

const int XlibSpecificationRelease=6;
version = X_HAVE_UTF8_STRING;

alias XPointer = void*;
alias Status = int;
enum Bool:int{False,True}; //xlib boolean is int type, D bool is only byte
enum QueueMode{QueuedAlready,QueuedAfterReading,QueuedAfterFlush};

/+
TODO Nested struc or union verify
+/

int		ConnectionNumber(Display *dpy) 	{return dpy.fd;}
Window	RootWindow(Display *dpy,int scr) 	{return ScreenOfDisplay(dpy,scr).root;}
int		DefaultScreen(Display *dpy) 		{return dpy.default_screen;}
Window	DefaultRootWindow(Display *dpy) 	{return ScreenOfDisplay(dpy,DefaultScreen(dpy)).root;}
Visual*	DefaultVisual(Display *dpy,int scr) {return ScreenOfDisplay(dpy,scr).root_visual;}
GC		DefaultGC(Display *dpy,int scr) 	{return ScreenOfDisplay(dpy,scr).default_gc;}
uint	BlackPixel(Display *dpy,int scr) 	{return cast(uint) ScreenOfDisplay(dpy,scr).black_pixel;}
uint	WhitePixel(Display *dpy,int scr) 	{return cast(uint) ScreenOfDisplay(dpy,scr).white_pixel;}
ulong	AllPlanes()							{return 0xFFFFFFFF;}
int		QLength(Display *dpy) 				{return dpy.qlen;}
int		DisplayWidth(Display *dpy,int scr) 	{return ScreenOfDisplay(dpy,scr).width;}
int		DisplayHeight(Display *dpy,int scr) {return ScreenOfDisplay(dpy,scr).height;}
int		DisplayWidthMM(Display *dpy,int scr){return ScreenOfDisplay(dpy,scr).mwidth;}
int		DisplayHeightMM(Display *dpy,int scr){return ScreenOfDisplay(dpy,scr).mheight;}
int		DisplayPlanes(Display *dpy,int scr) {return ScreenOfDisplay(dpy,scr).root_depth;}
int		DisplayCells(Display *dpy,int scr) 	{return DefaultVisual(dpy,scr).map_entries;}
int		ScreenCount(Display *dpy) 			{return dpy.nscreens;}
char*	ServerVendor(Display *dpy) 			{return dpy.vendor;}
int		ProtocolVersion(Display *dpy) 		{return dpy.proto_major_version;}
int		ProtocolRevision(Display *dpy) 		{return dpy.proto_minor_version;}
int		VendorRelease(Display *dpy) 			{return dpy.release;}
char*	DisplayString(Display *dpy) 			{return dpy.display_name;}
int		DefaultDepth(Display *dpy,int scr) 	{return ScreenOfDisplay(dpy,scr).root_depth;}
Colormap DefaultColormap(Display *dpy,int scr){return ScreenOfDisplay(dpy,scr).cmap;}
int		BitmapUnit(Display *dpy) 			{return dpy.bitmap_unit;}
int		BitmapBitOrder(Display *dpy) 		{return dpy.bitmap_bit_order;}
int		BitmapPad(Display *dpy) 			{return dpy.bitmap_pad;}
int		ImageByteOrder(Display *dpy) 		{return dpy.byte_order;}
uint	NextRequest(Display *dpy)			{return cast(uint) dpy.request + 1;}

uint	LastKnownRequestProcessed(Display *dpy)	{return cast(uint) dpy.last_request_read;}

/* macros for screen oriented applications (toolkit) */
Screen*	ScreenOfDisplay(Display *dpy,int scr)	{return &dpy.screens[scr];}
Screen*	DefaultScreenOfDisplay(Display *dpy) {return ScreenOfDisplay(dpy,DefaultScreen(dpy));}
Display* DisplayOfScreen(Screen s)			{return s.display;}
Window	RootWindowOfScreen(Screen s)		{return s.root;}
uint 	BlackPixelOfScreen(Screen s)		{return cast(uint) s.black_pixel;}
uint 	WhitePixelOfScreen(Screen s)		{return cast(uint) s.white_pixel;}
Colormap DefaultColormapOfScreen(Screen s)	{return s.cmap;}
int 	DefaultDepthOfScreen(Screen s)		{return s.root_depth;}
GC		DefaultGCOfScreen(Screen s)		{return s.default_gc;}
Visual*	DefaultVisualOfScreen(Screen s)	{return s.root_visual;}
int		WidthOfScreen(Screen s)			{return s.width;}
int		HeightOfScreen(Screen s)		{return s.height;}
int		WidthMMOfScreen(Screen s)		{return s.mwidth;}
int		HeightMMOfScreen(Screen s)		{return s.mheight;}
int		PlanesOfScreen(Screen s)		{return s.root_depth;}
int 	CellsOfScreen(Screen s)			{return DefaultVisualOfScreen(s).map_entries;}
int		MinCmapsOfScreen(Screen s)		{return s.min_maps;}
int		MaxCmapsOfScreen(Screen s)		{return s.max_maps;}
Bool	DoesSaveUnders(Screen s)		{return s.save_unders;}
int 	DoesBackingStore(Screen s)		{return s.backing_store;}
int		EventMaskOfScreen(Screen s)		{return cast(int) s.root_input_mask;}



/*
 * Extensions need a way to hang private data on some structures.
 */
struct XExtData
{
	int number;		/* number returned by XRegisterExtension */
	XExtData *next;		/* next item on list of data for structure */
	int function(XExtData *extension) free_private;	/* called to free private storage */
	XPointer private_data;	/* data private to this extension. */
};

/*
 * This file contains structures used by the extension mechanism.
 */
struct XExtCodes
{						/* public to extension, cannot be changed */
	int extension;		/* extension number */
	int major_opcode;	/* major op-code assigned by server */
	int first_event;	/* first event number for the extension */
	int first_error;	/* first error number for the extension */
};

/*
 * Data structure for retrieving info about pixmap formats.
 */

struct XPixmapFormatValues
{
    int depth;
    int bits_per_pixel;
    int scanline_pad;
};

struct XGCValues
{
	GraphicFunction function_;		/* logical operation*/
	ulong plane_mask;				/* plane mask */
	ulong foreground;				/* foreground pixel */
	ulong background;				/* background pixel */
	int line_width;					/* line width */
	LineStyle line_style;	 		/* LineSolid, LineOnOffDash, LineDoubleDash */
	CapStyle cap_style;	  			/* CapNotLast, CapButt, CapRound, CapProjecting */
	LineStyle join_style;	 		/* JoinMiter, JoinRound, JoinBevel */
	FillStyle fill_style;	 		/* FillSolid, FillTiled,FillStippled, FillOpaeueStippled */
	FillRule fill_rule;		  		/* EvenOddRule, WindingRule */
	ArcMode arc_mode;				/* ArcChord, ArcPieSlice */
	Pixmap tile;					/* tile pixmap for tiling operations */
	Pixmap stipple;				/* stipple 1 plane pixmap for stipping */
	int ts_x_origin;				/* offset for tile or stipple operations */
	int ts_y_origin;
	Font font;	        			/* default text font for text operations */
	SubwindowMode subwindow_mode;   /* ClipByChildren, IncludeInferiors */
	Bool graphics_exposures;		/* Boolean, should exposures be generated */
	int clip_x_origin;				/* origin for clipping */
	int clip_y_origin;
	Pixmap clip_mask;				/* bitmap clipping; other calls for rects */
	int dash_offset;				/* patterned/dashed line information */
	byte dashes;
};

alias GC = void*;

/*
 * Visual structure; contains information about colormapping possible.
 */
struct Visual
{
	XExtData *ext_data;	/* hook for extension to hang data */
	VisualID visualid;	/* visual id of this visual */
	int class_;			/* class of screen (monochrome, etc.) */
	ulong red_mask, green_mask, blue_mask;	/* mask values */
	int bits_per_rgb;	/* log base 2 of distinct color values */
	int map_entries;	/* color map entries */
} ;

/*
 * Depth structure; contains information for each possible depth.
 */
struct Depth
{
	int depth;		/* this depth (Z) of the depth */
	int nvisuals;		/* number of Visual types at this depth */
	Visual *visuals;	/* list of visuals possible at this depth */
};

alias Display XDisplay;

struct Screen{
	XExtData *ext_data;		/* hook for extension to hang data */
	XDisplay *display;		/* back pointer to display structure */
	Window root;			/* Root window id. */
	int width, height;		/* width and height of screen */
	int mwidth, mheight;	/* width and height of  in millimeters */
	int ndepths;			/* number of depths possible */
	Depth *depths;			/* list of allowable depths on the screen */
	int root_depth;			/* bits per pixel */
	Visual *root_visual;	/* root visual */
	GC default_gc;			/* GC for the root root visual */
	Colormap cmap;			/* default color map */
	ulong white_pixel;
	ulong black_pixel;		/* White and Black pixel values */
	int max_maps, min_maps;	/* max and min color maps */
	int backing_store;		/* Never, WhenMapped, Always */
	Bool save_unders;
	long root_input_mask;	/* initial root input mask */
};

/*
 * Format structure; describes ZFormat data the screen will understand.
 */
struct ScreenFormat
{
	XExtData *ext_data;	/* hook for extension to hang data */
	int depth;			/* depth of this image format */
	int bits_per_pixel;	/* bits/pixel at this depth */
	int scanline_pad;	/* scanline must padded to this multiple */
};

/*
 * Data structure for setting window attributes.
 */
struct  XSetWindowAttributes
{
    Pixmap background_pixmap;	/* background or None or ParentRelative */
    ulong background_pixel;		/* background pixel */
    Pixmap border_pixmap;		/* border of the window */
    ulong border_pixel;			/* border pixel value */
    BitGravity bit_gravity;		/* one of bit gravity values */
    BitGravity win_gravity;		/* one of the window gravity values */
    BackingStoreHint backing_store;		/* NotUseful, WhenMapped, Always */
    ulong backing_planes;		/* planes to be preseved if possible */
    ulong backing_pixel;			/* value to use in restoring planes */
    Bool save_under;			/* should bits under be saved? (popups) */
    long event_mask;			/* set of events that should be saved */
    long do_not_propagate_mask;/* set of events that should not propagate */
    Bool override_redirect;		/* Boolean value for override-redirect */
    Colormap colormap;			/* color map to be associated with window */
    Cursor cursor;				/* cursor to be displayed (or None) */
};

struct XWindowAttributes
{
    int x, y;					/* location of window */
    int width, height;			/* width and height of window */
    int border_width;			/* border width of window */
    int depth;          		/* depth of window */
    Visual *visual;				/* the associated visual structure */
    Window root;        		/* root of screen containing window */
    WindowClass class_;			/* InputOutput, InputOnly*/
    BitGravity bit_gravity;		/* one of bit gravity values */
    BitGravity win_gravity;		/* one of the window gravity values */
    BackingStoreHint backing_store;	/* NotUseful, WhenMapped, Always */
    ulong backing_planes;		/* planes to be preserved if possible */
    ulong backing_pixel;	/* value to be used when restoring planes */
    Bool save_under;			/* Boolean, should bits under be saved? */
    Colormap colormap;			/* color map to be associated with window */
    Bool map_installed;		/* Boolean, is color map currently installed*/
    MapState map_state;		/* IsUnmapped, IsUnviewable, IsViewable */
    EventMask all_event_masks;	/* set of events all people have interest in*/
    EventMask your_event_mask;	/* my event mask */
    EventMask do_not_propagate_mask; /* set of events that should not propagate */
    Bool override_redirect;		/* Boolean value for override-redirect */
    Screen *screen;				/* back pointer to correct screen */
};

/*
 * Data structure for host setting; getting routines.
 *
 */

struct XHostAddress
{
	ProtocolFamlily family;	/* for example FamilyInternet */
	int length;					/* length of address, in bytes */
	void *address;				/* pointer to where to find the bytes */
};

/*
 * Data structure for ServerFamilyInterpreted addresses in host routines
 */
struct XServerInterpretedAddress
{
	int typelength;		/* length of type string, in bytes */
	int valuelength;	/* length of value string, in bytes */
	void *type;			/* pointer to where to find the type string */
	void *value;		/* pointer to where to find the address */
};

/*
 * Data structure for "image" data, used by image manipulation routines.
 */
struct XImage
{
    int width, height;			/* size of image */
    int xoffset;				/* number of pixels offset in X direction */
    ImageFormat format;		/* XYBitmap, XYPixmap, ZPixmap */
    void *data;					/* pointer to image data */
    ByteOrder byte_order;		/* data byte order, LSBFirst, MSBFirst */
    int bitmap_unit;			/* quant. of scanline 8, 16, 32 */
    int bitmap_bit_order;		/* LSBFirst, MSBFirst */
    int bitmap_pad;			/* 8, 16, 32 either XY or ZPixmap */
    int depth;					/* depth of image */
    int bytes_per_line;			/* accelarator to next line */
    int bits_per_pixel;			/* bits per pixel (ZPixmap) */
    ulong red_mask;	/* bits in z arrangment */
    ulong green_mask;
    ulong blue_mask;
    XPointer obdata;			/* hook for the object routines to hang on */
    struct f {				/* image manipulation routines */
		XImage* function(
			XDisplay* 			/* display */,
			Visual*				/* visual */,
			uint				/* depth */,
			int					/* format */,
			int					/* offset */,
			byte*				/* data */,
			uint				/* width */,
			uint				/* height */,
			int					/* bitmap_pad */,
			int					/* bytes_per_line */) create_image;
		int  function(XImage *)destroy_image;
		ulong function(XImage *, int, int)get_pixel;
		int  function(XImage *, int, int, ulong)put_pixel;
		XImage function(XImage *, int, int, uint, uint)sub_image;
		int function(XImage *, long)add_pixel;
	};
};

/*
 * Data structure for XReconfigureWindow
 */
struct XWindowChanges{
    int x, y;
    int width, height;
    int border_width;
    Window sibling;
    WindowStackingMethod stack_mode;
};

/*
 * Data structure used by color operations
 */
struct XColor
{
	ulong pixel;
	ushort red, green, blue;
	StoreColor flags;  /* do_red, do_green, do_blue */
	byte pad;
};

/*
 * Data structures for graphics operations.  On most machines, these are
 * congruent with the wire protocol structures, so reformatting the data
 * can be avoided on these architectures.
 */
struct XSegment
{
    short x1, y1, x2, y2;
};

struct XPoint
{
    short x, y;
};

struct XRectangle
{
    short x, y;
    ushort width, height;
};

struct XArc
{
    short x, y;
    ushort width, height;
    short angle1, angle2;
};


/* Data structure for XChangeKeyboardControl */

struct XKeyboardControl
{
	int key_click_percent;
	int bell_percent;
	int bell_pitch;
	int bell_duration;
	int led;
	LedMode led_mode;
	int key;
	AutoRepeatMode auto_repeat_mode;   /* On, Off, Default */
};

/* Data structure for XGetKeyboardControl */

struct XKeyboardState
{
	int key_click_percent;
	int bell_percent;
	uint bell_pitch, bell_duration;
	ulong led_mask;
	int global_auto_repeat;
	byte auto_repeats[32];
};

struct XTimeCoord
{
	Time time;
	short x, y;
};

/* Data structure for X{Set,Get}ModifierMapping */

struct XModifierKeymap
{
 	int max_keypermod;	/* The server's max # of keys per modifier */
 	KeyCode *modifiermap;	/* An 8 by max_keypermod array of modifiers */
};


/+ todo Verify Here+/
/*
 * Display datatype maintaining display specific data.
 * The contents of this structure are implementation dependent.
 * A Display should be treated as opaque by application code.
 */

struct _XPrivate{}		/* Forward declare before use for C++ */
struct _XrmHashBucketRec{}

struct Display
{
	XExtData *ext_data;	/* hook for extension to hang data */
	_XPrivate *private1;
	int fd;			/* Network socket. */
	int private2;
	int proto_major_version;/* major version of server's X protocol */
	int proto_minor_version;/* minor version of servers X protocol */
	char *vendor;		/* vendor of the server hardware */
    XID private3;
	XID private4;
	XID private5;
	int private6;
	XID function(Display*)resource_alloc;/* allocator function */
	ByteOrder byte_order;		/* screen byte order, LSBFirst, MSBFirst */
	int bitmap_unit;	/* padding and data requirements */
	int bitmap_pad;		/* padding requirements on bitmaps */
	ByteOrder bitmap_bit_order;	/* LeastSignificant or MostSignificant */
	int nformats;		/* number of pixmap formats in list */
	ScreenFormat *pixmap_format;	/* pixmap format list */
	int private8;
	int release;		/* release of the server */
	_XPrivate *private9;
	_XPrivate *private10;
	int qlen;		/* Length of input event queue */
	ulong last_request_read; /* seq number of last event read */
	ulong request;	/* sequence number of last request. */
	XPointer private11;
	XPointer private12;
	XPointer private13;
	XPointer private14;
	uint max_request_size; /* maximum number 32 bit words in request*/
	_XrmHashBucketRec *db;
	int function  (Display*)private15;
	char *display_name;	/* "host:display" string used on this connect*/
	int default_screen;	/* default screen for operations */
	int nscreens;		/* number of screens on this server*/
	Screen *screens;	/* pointer to list of screens */
	ulong motion_buffer;	/* size of motion buffer */
	ulong private16;
	int min_keycode;	/* minimum defined keycode */
	int max_keycode;	/* maximum defined keycode */
	XPointer private17;
	XPointer private18;
	int private19;
	byte *xdefaults;	/* contents of defaults from server */
	/* there is more to this structure, but it is private to Xlib */
}

alias _XPrivDisplay = Display *;
struct XrmHashBucketRec{};


/*
 * Definitions of specific events.
 */
struct XKeyEvent
{
	int type;			/* of event */
	ulong serial;		/* # of last request processed by server */
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window window;	        /* "event" window it is reported relative to */
	Window root;	        /* root window that the event occurred on */
	Window subwindow;	/* child window */
	Time time;		/* milliseconds */
	int x, y;		/* pointer x, y coordinates in event window */
	int x_root, y_root;	/* coordinates relative to root */
	KeyOrButtonMask state;	/* key or button mask */
	uint keycode;	/* detail */
	Bool same_screen;	/* same screen flag */
};
alias XKeyPressedEvent = XKeyEvent;
alias XKeyReleasedEvent = XKeyEvent;

struct XButtonEvent
{
	int type;		/* of event */
	ulong serial;	/* # of last request processed by server */
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window window;	        /* "event" window it is reported relative to */
	Window root;	        /* root window that the event occurred on */
	Window subwindow;	/* child window */
	Time time;		/* milliseconds */
	int x, y;		/* pointer x, y coordinates in event window */
	int x_root, y_root;	/* coordinates relative to root */
	KeyOrButtonMask state;	/* key or button mask */
	uint button;	/* detail */
	Bool same_screen;	/* same screen flag */
};
alias XButtonPressedEvent = XButtonEvent;
alias XButtonReleasedEvent = XButtonEvent;

struct XMotionEvent{
	int type;		/* of event */
	ulong serial;	/* # of last request processed by server */
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window window;	        /* "event" window reported relative to */
	Window root;	        /* root window that the event occurred on */
	Window subwindow;	/* child window */
	Time time;		/* milliseconds */
	int x, y;		/* pointer x, y coordinates in event window */
	int x_root, y_root;	/* coordinates relative to root */
	KeyOrButtonMask state;	/* key or button mask */
	byte is_hint;		/* detail */
	Bool same_screen;	/* same screen flag */
};
alias XPointerMovedEvent = XMotionEvent;

struct XCrossingEvent{
	int type;		/* of event */
	ulong serial;	/* # of last request processed by server */
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window window;	        /* "event" window reported relative to */
	Window root;	        /* root window that the event occurred on */
	Window subwindow;	/* child window */
	Time time;		/* milliseconds */
	int x, y;		/* pointer x, y coordinates in event window */
	int x_root, y_root;	/* coordinates relative to root */
	NotifyModes mode;		/* NotifyNormal, NotifyGrab, NotifyUngrab */
	NotifyDetail detail;
	/*
	 * NotifyAncestor, NotifyVirtual, NotifyInferior,
	 * NotifyNonlinear,NotifyNonlinearVirtual
	 */
	Bool same_screen;	/* same screen flag */
	Bool focus;		/* Boolean focus */
	KeyOrButtonMask state;	/* key or button mask */
};
alias XEnterWindowEvent = XCrossingEvent ;
alias XLeaveWindowEvent = XCrossingEvent ;

struct XFocusChangeEvent{
	int type;		/* FocusIn or FocusOut */
	ulong serial;	/* # of last request processed by server */
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window window;		/* window of event */
	NotifyModes mode;		/* NotifyNormal, NotifyWhileGrabbed,
				   NotifyGrab, NotifyUngrab */
	NotifyDetail detail;
	/*
	 * NotifyAncestor, NotifyVirtual, NotifyInferior,
	 * NotifyNonlinear,NotifyNonlinearVirtual, NotifyPointer,
	 * NotifyPointerRoot, NotifyDetailNone
	 */
};
alias XFocusInEvent = XFocusChangeEvent;
alias XFocusOutEvent = XFocusChangeEvent;

/* generated on EnterWindow and FocusIn  when KeyMapState selected */
struct XKeymapEvent
{
	int type;
	ulong serial;	/* # of last request processed by server */
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window window;
	byte key_vector[32];
};

struct XExposeEvent
{
	int type;
	ulong serial;	/* # of last request processed by server */
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window window;
	int x, y;
	int width, height;
	int count;		/* if non-zero, at least this many more */
};

struct XGraphicsExposeEvent{
	int type;
	ulong serial;	/* # of last request processed by server */
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Drawable drawable;
	int x, y;
	int width, height;
	int count;		/* if non-zero, at least this many more */
	int major_code;		/* core is CopyArea or CopyPlane */
	int minor_code;		/* not defined in the core */
};

struct XNoExposeEvent{
	int type;
	ulong serial;	/* # of last request processed by server */
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Drawable drawable;
	int major_code;		/* core is CopyArea or CopyPlane */
	int minor_code;		/* not defined in the core */
};

struct XVisibilityEvent{
	int type;
	ulong serial;	/* # of last request processed by server */
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window window;
	VisibilityNotify state;		/* Visibility state */
};

struct XCreateWindowEvent{
	int type;
	ulong serial;	/* # of last request processed by server */
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window parent;		/* parent of the window */
	Window window;		/* window id of window created */
	int x, y;		/* window location */
	int width, height;	/* size of window */
	int border_width;	/* border width */
	Bool override_redirect;	/* creation should be overridden */
};

struct XDestroyWindowEvent
{
	int type;
	ulong serial;		/* # of last request processed by server */
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window event;
	Window window;
};

struct XUnmapEvent
{
	int type;
	ulong serial;		/* # of last request processed by server */
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window event;
	Window window;
	Bool from_configure;
};

struct XMapEvent
{
	int type;
	ulong serial;		/* # of last request processed by server */
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window event;
	Window window;
	Bool override_redirect;	/* Boolean, is override set... */
};

struct XMapRequestEvent
{
	int type;
	ulong serial;	/* # of last request processed by server */
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window parent;
	Window window;
};

struct XReparentEvent
{
	int type;
	ulong serial;	/* # of last request processed by server */
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window event;
	Window window;
	Window parent;
	int x, y;
	Bool override_redirect;
};

struct XConfigureEvent
{
	int type;
	ulong serial;	/* # of last request processed by server */
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window event;
	Window window;
	int x, y;
	int width, height;
	int border_width;
	Window above;
	Bool override_redirect;
};

struct XGravityEvent
{
	int type;
	ulong serial;	/* # of last request processed by server */
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window event;
	Window window;
	int x, y;
};

struct XResizeRequestEvent
{
	int type;
	ulong serial;	/* # of last request processed by server */
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window window;
	int width, height;
};

struct  XConfigureRequestEvent
{
	int type;
	ulong serial;	/* # of last request processed by server */
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window parent;
	Window window;
	int x, y;
	int width, height;
	int border_width;
	Window above;
	WindowStackingMethod detail;		/* Above, Below, TopIf, BottomIf, Opposite */
	uint value_mask;
};

struct XCirculateEvent
{
	int type;
	ulong serial;	/* # of last request processed by server */
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window event;
	Window window;
	CirculationRequest place;		/* PlaceOnTop, PlaceOnBottom */
};

struct XCirculateRequestEvent
{
	int type;
	ulong serial;	/* # of last request processed by server */
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window parent;
	Window window;
	CirculationRequest place;		/* PlaceOnTop, PlaceOnBottom */
};

struct XPropertyEvent
{
	int type;
	ulong serial;	/* # of last request processed by server */
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window window;
	Atom atom;
	Time time;
	PropertyNotification state;		/* NewValue, Deleted */
};

struct XSelectionClearEvent
{
	int type;
	ulong serial;	/* # of last request processed by server */
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window window;
	Atom selection;
	Time time;
};

struct XSelectionRequestEvent
{
	int type;
	ulong serial;	/* # of last request processed by server */
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window owner;
	Window requestor;
	Atom selection;
	Atom target;
	Atom property;
	Time time;
};

struct XSelectionEvent
{
	int type;
	ulong serial;	/* # of last request processed by server */
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window requestor;
	Atom selection;
	Atom target;
	Atom property;		/* ATOM or None */
	Time time;
} ;

struct XColormapEvent
{
	int type;
	ulong serial;	/* # of last request processed by server */
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window window;
	Colormap colormap;	/* COLORMAP or None */
	Bool new_;		/* C++ */
	ColorMapNotification state;		/* ColormapInstalled, ColormapUninstalled */
};

struct XClientMessageEvent
{
	int type;
	ulong serial;	/* # of last request processed by server */
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window window;
	Atom message_type;
	int format;
	union data{
		byte b[20];
		short s[10];
		long l[5];
		};
};

struct XMappingEvent
{
	int type;
	ulong serial;	/* # of last request processed by server */
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window window;		/* unused */
	MappingType request;		/* one of MappingModifier, MappingKeyboard,
				   MappingPointer */
	int first_keycode;	/* first keycode */
	int count;		/* defines range of change w. first_keycode*/
};

struct XErrorEvent
{
	int type;
	Display *display;	/* Display the event was read from */
	XID resourceid;		/* resource id */
	ulong serial;	/* serial number of failed request */
	uint error_code;	/* error code of failed request */
	ubyte request_code;	/* Major op-code of failed request */
	ubyte minor_code;	/* Minor op-code of failed request */
};

struct XAnyEvent
{
	int type;
	ubyte serial;	/* # of last request processed by server */
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;/* Display the event was read from */
	Window window;	/* window on which event was requested in event mask */
};

/*
 * this union is defined so Xlib can always use the same sized
 * event structure internally, to avoid memory fragmentation.
 */
union XEvent{
    int type;		/* must not be changed; first element */
	XAnyEvent xany;
	XKeyEvent xkey;
	XButtonEvent xbutton;
	XMotionEvent xmotion;
	XCrossingEvent xcrossing;
	XFocusChangeEvent xfocus;
	XExposeEvent xexpose;
	XGraphicsExposeEvent xgraphicsexpose;
	XNoExposeEvent xnoexpose;
	XVisibilityEvent xvisibility;
	XCreateWindowEvent xcreatewindow;
	XDestroyWindowEvent xdestroywindow;
	XUnmapEvent xunmap;
	XMapEvent xmap;
	XMapRequestEvent xmaprequest;
	XReparentEvent xreparent;
	XConfigureEvent xconfigure;
	XGravityEvent xgravity;
	XResizeRequestEvent xresizerequest;
	XConfigureRequestEvent xconfigurerequest;
	XCirculateEvent xcirculate;
	XCirculateRequestEvent xcirculaterequest;
	XPropertyEvent xproperty;
	XSelectionClearEvent xselectionclear;
	XSelectionRequestEvent xselectionrequest;
	XSelectionEvent xselection;
	XColormapEvent xcolormap;
	XClientMessageEvent xclient;
	XMappingEvent xmapping;
	XErrorEvent xerror;
	XKeymapEvent xkeymap;
	long pad[24];
};


int XAllocID(Display* dpy) {return cast(int) dpy.resource_alloc(dpy);}


/*
 * per character font metric information.
 */
struct XCharStruct
{
    short	lbearing;	/* origin to left edge of raster */
    short	rbearing;	/* origin to right edge of raster */
    short	width;		/* advance to next char's origin */
    short	ascent;		/* baseline to top edge of raster */
    short	descent;	/* baseline to bottom edge of raster */
    short 	attributes;	/* per char flags (not predefined) */
};

/*
 * To allow arbitrary information with fonts, there are additional properties
 * returned.
 */
struct XFontProp
{
    Atom name;
    ulong card32;
};

struct XFontStruct{
    XExtData	*ext_data;			/* hook for extension to hang data */
    Font        fid;            	/* Font id for this font */
    FontDrawDirection	direction;	/* hint about direction the font is painted */
    uint		min_char_or_byte2;	/* first character */
    uint		max_char_or_byte2;	/* last character */
    uint		min_byte1;			/* first row that exists */
    uint		max_byte1;			/* last row that exists */
    Bool		all_chars_exist;	/* flag if all characters have non-zero size*/
    uint		default_char;		/* char to print for undefined character */
    int         n_properties;   	/* how many properties there are */
    XFontProp	*properties;		/* pointer to array of additional properties*/
    XCharStruct	min_bounds;		/* minimum bounds over all existing char*/
    XCharStruct	max_bounds;		/* maximum bounds over all existing char*/
    XCharStruct	*per_char;			/* first_char to last_char information */
    int			ascent;				/* log. extent above baseline for spacing */
    int			descent;			/* log. descent below baseline for spacing */
};

/*
 * PolyText routines take these as arguments.
 */
struct XTextItem{
    char 	*chars;			/* pointer to string */
    int 	nchars;			/* number of characters */
    int 	delta;			/* delta between strings */
    Font 	font;			/* font to print it in, None don't change */
};

struct XChar2b
{		/* normal 16 bit characters are two bytes */
align(1):
    ubyte byte1;
    ubyte byte2;
};


struct XTextItem16
{
    XChar2b *chars;			/* two byte characters */
    int 	nchars;			/* number of characters */
    int 	delta;			/* delta between strings */
    Font 	font;			/* font to print it in, None don't change */
}


union XEDataObject
{
	Display 	*display;
	GC 			gc;
	Visual 		*visual;
	Screen 		*screen;
	ScreenFormat *pixmap_format;
	XFontStruct *font;
} ;

struct XFontSetExtents{
    XRectangle	max_ink_extent;
    XRectangle	max_logical_extent;
};

/* unused:
typedef void (*XOMProc)();
 */

struct _XOM{}
struct _XOC{}
alias XOM = _XOM *;
alias XOC = _XOC *;
alias XFontSet = _XOC *;
struct XmbTextItem{
    byte		*chars;
    int			nchars;
    int			delta;
    XFontSet	font_set;
};

struct XwcTextItem{
    wchar        	*chars;
    int             nchars;
    int             delta;
    XFontSet        font_set;
} ;


char[] XNRequiredCharSet ="requiredCharSet".dup;
char[] XNQueryOrientation ="queryOrientation".dup;
char[] XNBaseFontName ="baseFontName".dup;
char[] XNOMAutomatic ="omAutomatic".dup;
char[] XNMissingCharSet ="missingCharSet".dup;
char[] XNDefaultString ="defaultString".dup;
char[] XNOrientation ="orientation".dup;
char[] XNDirectionalDependentDrawing ="directionalDependentDrawing".dup;
char[] XNContextualDrawing ="contextualDrawing".dup;
char[] XNFontInfo ="fontInfo".dup;


struct XOMCharSetList
{
    int charset_count;
    byte **charset_list;
};

enum XOrientation
{
    XOMOrientation_LTR_TTB,
    XOMOrientation_RTL_TTB,
    XOMOrientation_TTB_LTR,
    XOMOrientation_TTB_RTL,
    XOMOrientation_Context
};

struct XOMOrientation{
    int num_orientation;
    XOrientation *orientation;	/* Input Text description */
};

struct XOMFontInfo{
    int num_font;
    XFontStruct **font_struct_list;
    byte **font_name_list;
} ;

struct _XIM{}
struct _XIC{}
alias XIM = _XIM *;
alias XIC = _XIC *;


alias XIMProc = void function(
    XIM,
    XPointer,
    XPointer
) ;

alias XICProc = Bool function(
    XIC,
    XPointer,
    XPointer
);

alias XIDProc =  void function(
    Display*,
    XPointer,
    XPointer
);

enum  XIMStyle:ulong
{
	XIMPreeditArea			=0x0001L,
	XIMPreeditCallbacks		=0x0002L,
	XIMPreeditPosition		=0x0004L,
	XIMPreeditNothing		=0x0008L,
	XIMPreeditNone			=0x0010L,
	XIMStatusArea			=0x0100L,
	XIMStatusCallbacks		=0x0200L,
	XIMStatusNothing		=0x0400L,
	XIMStatusNone			=0x0800L
}

struct XIMStyles{
    ushort count_styles;
    XIMStyle *supported_styles;
};

const char[] XNVaNestedList ="XNVaNestedList";
const char[] XNQueryInputStyle ="queryInputStyle";
const char[] XNClientWindow ="clientWindow";
const char[] XNInputStyle ="inputStyle";
const char[] XNFocusWindow ="focusWindow";
const char[] XNResourceName ="resourceName";
const char[] XNResourceClass ="resourceClass";
const char[] XNGeometryCallback ="geometryCallback";
const char[] XNDestroyCallback ="destroyCallback";
const char[] XNFilterEvents ="filterEvents";
const char[] XNPreeditStartCallback ="preeditStartCallback";
const char[] XNPreeditDoneCallback ="preeditDoneCallback";
const char[] XNPreeditDrawCallback ="preeditDrawCallback";
const char[] XNPreeditCaretCallback ="preeditCaretCallback";
const char[] XNPreeditStateNotifyCallback ="preeditStateNotifyCallback";
const char[] XNPreeditAttributes ="preeditAttributes";
const char[] XNStatusStartCallback ="statusStartCallback";
const char[] XNStatusDoneCallback ="statusDoneCallback";
const char[] XNStatusDrawCallback ="statusDrawCallback";
const char[] XNStatusAttributes ="statusAttributes";
const char[] XNArea ="area";
const char[] XNAreaNeeded ="areaNeeded";
const char[] XNSpotLocation ="spotLocation";
const char[] XNColormap ="colorMap";
const char[] XNStdColormap ="stdColorMap";
const char[] XNForeground ="foreground";
const char[] XNBackground ="background";
const char[] XNBackgroundPixmap ="backgroundPixmap";
const char[] XNFontSet ="fontSet";
const char[] XNLineSpace ="lineSpace";
const char[] XNCursor ="cursor";

const char[] XNQueryIMValuesList ="queryIMValuesList";
const char[] XNQueryICValuesList ="queryICValuesList";
const char[] XNVisiblePosition ="visiblePosition";
const char[] XNR6PreeditCallback ="r6PreeditCallback";
const char[] XNStringConversionCallback ="stringConversionCallback";
const char[] XNStringConversion ="stringConversion";
const char[] XNResetState ="resetState";
const char[] XNHotKey ="hotKey";
const char[] XNHotKeyState ="hotKeyState";
const char[] XNPreeditState ="preeditState";
const char[] XNSeparatorofNestedList ="separatorofNestedList";

const int XBufferOverflow=		-1;
const int XLookupNone=		1;
const int XLookupChars=		2;
const int XLookupKeySym=		3;
const int XLookupBoth	=	4;


alias XVaNestedList = void *;

struct XIMCallback{
    XPointer client_data;
    XIMProc callback;
};

struct XICCallback{
    XPointer client_data;
    XICProc callback;
};

enum XIMFeedback:ulong
{
	XIMReverse			=1,
	XIMUnderline		=1<<1,
	XIMHighlight		=1<<2,
	XIMPrimary	 		=1<<5,
	XIMSecondary		=1<<6,
	XIMTertiary	 		=1<<7,
	XIMVisibleToForward =1<<8,
	XIMVisibleToBackword=1<<9,
	XIMVisibleToCenter 	=1<<10
}

struct XIMText {
    ushort length;
    XIMFeedback *feedback;
    Bool encoding_is_wchar;
    union string
    {
		byte *multi_byte;
		wchar *wide_char;
    };
};

enum XIMPreeditState:ulong
{
	XIMPreeditUnKnown	=0L,
	XIMPreeditEnable	=1L,
	XIMPreeditDisable	=1L<<1
}

struct	XIMPreeditStateNotifyCallbackStruct
{
    XIMPreeditState state;
}

enum XIMResetState:ulong
{
	XIMInitialState		=1L,
	XIMPreserveState	=1L<<1
}

enum XIMStringConversionFeedback:ulong
{
	XIMStringConversionLeftEdge		=0x00000001,
	XIMStringConversionRightEdge	=0x00000002,
	XIMStringConversionTopEdge		=0x00000004,
	XIMStringConversionBottomEdge	=0x00000008,
	XIMStringConversionConcealed	=0x00000010,
	XIMStringConversionWrapped		=0x00000020
}

struct XIMStringConversionText {
    uint length;
    XIMStringConversionFeedback *feedback;
    Bool encoding_is_wchar;
    union string
    {
		byte *mbs;
		wchar *wcs;
    };
};

alias XIMStringConversionPosition = ushort	;

enum XIMStringConversionType:ushort
{
	XIMStringConversionBuffer	=0x0001,
	XIMStringConversionLine		=0x0002,
	XIMStringConversionWord		=0x0003,
	XIMStringConversionChar		=0x0004
}

enum XIMStringConversionOperation:ushort
{
	XIMStringConversionSubstitution	=0x0001,
	XIMStringConversionRetrieval	=0x0002
}

enum XIMCaretDirection:int{
    XIMForwardChar, XIMBackwardChar,
    XIMForwardWord, XIMBackwardWord,
    XIMCaretUp, XIMCaretDown,
    XIMNextLine, XIMPreviousLine,
    XIMLineStart, XIMLineEnd,
    XIMAbsolutePosition,
    XIMDontChange
};

struct XIMStringConversionCallbackStruct {
    XIMStringConversionPosition position;
    XIMCaretDirection direction;
    XIMStringConversionOperation operation;
    ushort factor;
    XIMStringConversionText *text;
};

struct XIMPreeditDrawCallbackStruct {
    int caret;		/* Cursor offset within pre-edit string */
    int chg_first;	/* Starting change position */
    int chg_length;	/* Length of the change in character count */
    XIMText *text;
} ;

enum XIMCaretStyle{
    XIMIsInvisible,	/* Disable caret feedback */
    XIMIsPrimary,	/* UI defined caret feedback */
    XIMIsSecondary	/* UI defined caret feedback */
};

struct XIMPreeditCaretCallbackStruct {
    int position;		 /* Caret offset within pre-edit string */
    XIMCaretDirection direction; /* Caret moves direction */
    XIMCaretStyle style;	 /* Feedback of the caret */
};

enum XIMStatusDataType{
    XIMTextType,
    XIMBitmapType
};

struct XIMStatusDrawCallbackStruct {
    XIMStatusDataType type;
    union data{
	XIMText *text;
	Pixmap  bitmap;
    } ;
};

struct XIMHotKeyTrigger {
    KeySym	 keysym;
    int		 modifier;
    int		 modifier_mask;
} ;

struct XIMHotKeyTriggers {
    int			 num_hot_key;
    XIMHotKeyTrigger	*key;
};

enum XIMHotKeyState:ulong
{
	XIMHotKeyStateON	=0x0001L,
	XIMHotKeyStateOFF	=0x0002L
}

struct XIMValuesList{
    ushort count_values;
    byte **supported_values;
};

/* FUNCTION PROTOTYPES*/
extern (C)
{

extern int _Xdebug;

extern XFontStruct *XLoadQueryFont(
    Display*		/* display */,
    byte*		/* name */
);

extern XFontStruct *XQueryFont(
    Display*		/* display */,
    XID				/* font_ID */
);


extern XTimeCoord *XGetMotionEvents(
    Display*		/* display */,
    Window		/* w */,
    Time		/* start */,
    Time		/* stop */,
    int*		/* nevents_return */
);

extern XModifierKeymap *XDeleteModifiermapEntry(
    XModifierKeymap*	/* modmap */,
    KeyCode		/* keycode_entry */,
    int			/* modifier */
);

extern XModifierKeymap	*XGetModifierMapping(
    Display*		/* display */
);

extern XModifierKeymap	*XInsertModifiermapEntry(
    XModifierKeymap*	/* modmap */,
    KeyCode		/* keycode_entry */,
    int			/* modifier */
);

extern XModifierKeymap *XNewModifiermap(
    int			/* max_keys_per_mod */
);

extern XImage *XCreateImage(
    Display*		/* display */,
    Visual*		/* visual */,
    uint	/* depth */,
    int			/* format */,
    int			/* offset */,
    byte*		/* data */,
    uint	/* width */,
    uint	/* height */,
    int			/* bitmap_pad */,
    int			/* bytes_per_line */
);
extern Status XInitImage(
    XImage*		/* image */
);
extern XImage *XGetImage(
    Display*		/* display */,
    Drawable		/* d */,
    int			/* x */,
    int			/* y */,
    uint	/* width */,
    uint	/* height */,
    ulong	/* plane_mask */,
    ImageFormat	/* format */
);
extern XImage *XGetSubImage(
    Display*		/* display */,
    Drawable		/* d */,
    int			/* x */,
    int			/* y */,
    uint	/* width */,
    uint	/* height */,
    ulong	/* plane_mask */,
    int			/* format */,
    XImage*		/* dest_image */,
    int			/* dest_x */,
    int			/* dest_y */
);

/*
 * X function declarations.
 */
extern Display *XOpenDisplay(
    char*	/* display_name */
);

	/*
struct XVisualInfo {
	Visual *visual;
	VisualID visualid;
	int screen;
	uint depth;
	int c_class;
	uint red_mask;
	uint green_mask;
	uint blue_mask;
	int colormap_size;
	int bits_per_rgb;
};
	 * */

extern void XrmInitialize();

extern byte *XFetchBytes(
    Display*		/* display */,
    int*		/* nbytes_return */
);
extern byte *XFetchBuffer(
    Display*		/* display */,
    int*		/* nbytes_return */,
    int			/* buffer */
);
extern byte *XGetAtomName(
    Display*		/* display */,
    Atom		/* atom */
);
extern Status XGetAtomNames(
    Display*		/* dpy */,
    Atom*		/* atoms */,
    int			/* count */,
    byte**		/* names_return */
);
extern byte *XGetDefault(
    Display*		/* display */,
    byte*	/* program */,
    byte*	/* option */
);
extern char *XDisplayName(
    char*	/* string */
);
extern char *XKeysymToString(
    KeySym		/* keysym */
);


extern int function(Display*/* display */,Bool		/* onoff */)XSynchronize(
    Display*		/* display */
);
extern int function(
    Display*		/* display */,
    int function(
	     Display*	/* display */
            )		/* procedure */
)XSetAfterFunction(
    Display*		/* display */
);


extern Atom XInternAtom(
    Display*		/* display */,
    byte*	/* atom_name */,
    Bool		/* only_if_exists */
);

extern Status XInternAtoms(
    Display*		/* dpy */,
    byte**		/* names */,
    int			/* count */,
    Bool		/* onlyIfExists */,
    Atom*		/* atoms_return */
);
extern Colormap XCopyColormapAndFree(
    Display*		/* display */,
    Colormap		/* colormap */
);
extern Colormap XCreateColormap(
    Display*		/* display */,
    Window		/* w */,
    Visual*		/* visual */,
    int			/* alloc */
);
extern Cursor XCreatePixmapCursor(
    Display*		/* display */,
    Pixmap		/* source */,
    Pixmap		/* mask */,
    XColor*		/* foreground_color */,
    XColor*		/* background_color */,
    uint	/* x */,
    uint	/* y */
);
extern Cursor XCreateGlyphCursor(
    Display*		/* display */,
    Font		/* source_font */,
    Font		/* mask_font */,
    uint	/* source_char */,
    uint	/* mask_char */,
    XColor*	/* foreground_color */,
    XColor*	/* background_color */
);
extern Cursor XCreateFontCursor(
    Display*		/* display */,
    uint	/* shape */
);
extern Font XLoadFont(
    Display*		/* display */,
    byte*	/* name */
);
extern GC XCreateGC(
    Display*		/* display */,
    Drawable		/* d */,
    ulong			/* valuemask */,
    XGCValues*		/* values */
);
extern GContext XGContextFromGC(
    GC			/* gc */
);
extern void XFlushGC(
    Display*		/* display */,
    GC			/* gc */
);
extern Pixmap XCreatePixmap(
    Display*		/* display */,
    Drawable		/* d */,
    uint		/* width */,
    uint		/* height */,
    uint		/* depth */
);
extern Pixmap XCreateBitmapFromData(
    Display*	/* display */,
    Drawable	/* d */,
    byte*		/* data */,
    uint		/* width */,
    uint		/* height */
);
extern Pixmap XCreatePixmapFromBitmapData(
    Display*	/* display */,
    Drawable	/* d */,
    byte*		/* data */,
    uint		/* width */,
    uint		/* height */,
    ulong		/* fg */,
    ulong		/* bg */,
    uint		/* depth */
);
extern Window XCreateSimpleWindow(
    Display*	/* display */,
    Window		/* parent */,
    int			/* x */,
    int			/* y */,
    uint		/* width */,
    uint		/* height */,
    uint		/* border_width */,
    ulong		/* border */,
    ulong		/* background */
);
extern Window XGetSelectionOwner(
    Display*	/* display */,
    Atom		/* selection */
);
extern Window XCreateWindow(
    Display*	/* display */,
    Window		/* parent */,
    int			/* x */,
    int			/* y */,
    uint		/* width */,
    uint		/* height */,
    uint		/* border_width */,
    int			/* depth */,
    WindowClass		/* class */,
    Visual*		/* visual */,
    WindowAttribute		/* valuemask */,
    XSetWindowAttributes*	/* attributes */
);
extern Colormap *XListInstalledColormaps(
    Display*	/* display */,
    Window		/* w */,
    int*		/* num_return */
);
extern byte **XListFonts(
    Display*	/* display */,
    byte*		/* pattern */,
    int			/* maxnames */,
    int*		/* actual_count_return */
);
extern byte **XListFontsWithInfo(
    Display*	/* display */,
    byte*	    /* pattern */,
    int			/* maxnames */,
    int*		/* count_return */,
    XFontStruct**	/* info_return */
);
extern byte **XGetFontPath(
    Display*		/* display */,
    int*		/* npaths_return */
);
extern byte **XListExtensions(
    Display*	/* display */,
    int*		/* nextensions_return */
);
extern Atom *XListProperties(
    Display*	/* display */,
    Window		/* w */,
    int*		/* num_prop_return */
);
extern XHostAddress *XListHosts(
    Display*		/* display */,
    int*		/* nhosts_return */,
    Bool*		/* state_return */
);
extern KeySym XKeycodeToKeysym(
    Display*	/* display */,
    KeyCode		/* keycode */,
    int			/* index */
);
extern KeySym XLookupKeysym(
    XKeyEvent*	/* key_event */,
    int			/* index */
);
extern KeySym *XGetKeyboardMapping(
    Display*		/* display */,
    KeyCode		/* first_keycode */,
    int			/* keycode_count */,
    int*		/* keysyms_per_keycode_return */
);
extern KeySym XStringToKeysym(
    char*	/* string */
);
extern long XMaxRequestSize(
    Display*		/* display */
);
extern long XExtendedMaxRequestSize(
    Display*		/* display */
);
extern char *XResourceManagerString(
    Display*		/* display */
);
extern char *XScreenResourceString(
	Screen*		/* screen */
);
extern ulong XDisplayMotionBufferSize(
    Display*		/* display */
);
extern VisualID XVisualIDFromVisual(
    Visual*		/* visual */
);

/* multithread routines */

extern Status XInitThreads();

extern void XLockDisplay(
    Display*		/* display */
);

extern void XUnlockDisplay(
    Display*		/* display */
);

/* routines for dealing with extensions */

extern XExtCodes *XInitExtension(
    Display*		/* display */,
    byte*			/* name */
);

extern XExtCodes *XAddExtension(
    Display*		/* display */
);
extern XExtData *XFindOnExtensionList(
    XExtData**		/* structure */,
    int				/* number */
);
extern XExtData **XEHeadOfExtensionList(
    XEDataObject	/* object */
);

/* these are routines for which there are also macros */
extern Window XRootWindow(
    Display*		/* display */,
    int				/* screen_number */
);
extern Window XDefaultRootWindow(
    Display*		/* display */
);
extern Window XRootWindowOfScreen(
    Screen*			/* screen */
);
extern Visual *XDefaultVisual(
    Display*		/* display */,
    int				/* screen_number */
);
extern Visual *XDefaultVisualOfScreen(
    Screen*			/* screen */
);
extern GC XDefaultGC(
    Display*		/* display */,
    int				/* screen_number */
);
extern GC XDefaultGCOfScreen(
    Screen*			/* screen */
);
extern ulong XBlackPixel(
    Display*		/* display */,
    int				/* screen_number */
);
extern ulong XWhitePixel(
    Display*		/* display */,
    int				/* screen_number */
);
extern ulong XAllPlanes();
extern ulong XBlackPixelOfScreen(
    Screen*			/* screen */
);
extern ulong XWhitePixelOfScreen(
    Screen*		/* screen */
);
extern ulong XNextRequest(
    Display*		/* display */
);
extern ulong XLastKnownRequestProcessed(
    Display*		/* display */
);
extern char *XServerVendor(
    Display*		/* display */
);
extern char *XDisplayString(
    Display*		/* display */
);
extern Colormap XDefaultColormap(
    Display*		/* display */,
    int			/* screen_number */
);
extern Colormap XDefaultColormapOfScreen(
    Screen*		/* screen */
);
extern Display *XDisplayOfScreen(
    Screen*		/* screen */
);
extern Screen *XScreenOfDisplay(
    Display*		/* display */,
    int			/* screen_number */
);
extern Screen *XDefaultScreenOfDisplay(
    Display*		/* display */
);
extern long XEventMaskOfScreen(
    Screen*		/* screen */
);

extern int XScreenNumberOfScreen(
    Screen*		/* screen */
);

alias XErrorHandler = int function (	    /* WARNING, this type not in Xlib spec */
    Display*		/* display */,
    XErrorEvent*	/* error_event */
);

extern XErrorHandler XSetErrorHandler (
    XErrorHandler	/* handler */
);


alias XIOErrorHandler = int function (    /* WARNING, this type not in Xlib spec */
    Display*		/* display */
);

extern XIOErrorHandler XSetIOErrorHandler (
    XIOErrorHandler	/* handler */
);


extern XPixmapFormatValues *XListPixmapFormats(
    Display*		/* display */,
    int*		/* count_return */
);
extern int *XListDepths(
    Display*		/* display */,
    int			/* screen_number */,
    int*		/* count_return */
);

/* ICCCM routines for things that don't require special include files; */
/* other declarations are given in Xutil.h                             */
extern Status XReconfigureWMWindow(
    Display*		/* display */,
    Window			/* w */,
    int				/* screen_number */,
    ConfigureWindowStruct	/* mask */,
    XWindowChanges*	/* changes */
);

extern Status XGetWMProtocols(
    Display*	/* display */,
    Window		/* w */,
    Atom**		/* protocols_return */,
    int*		/* count_return */
);
extern Status XSetWMProtocols(
    Display*	/* display */,
    Window		/* w */,
    Atom*		/* protocols */,
    int			/* count */
);
extern Status XIconifyWindow(
    Display*		/* display */,
    Window		/* w */,
    int			/* screen_number */
);
extern Status XWithdrawWindow(
    Display*		/* display */,
    Window		/* w */,
    int			/* screen_number */
);
extern Status XGetCommand(
    Display*		/* display */,
    Window		/* w */,
    byte***		/* argv_return */,
    int*		/* argc_return */
);
extern Status XGetWMColormapWindows(
    Display*		/* display */,
    Window		/* w */,
    Window**		/* windows_return */,
    int*		/* count_return */
);
extern Status XSetWMColormapWindows(
    Display*		/* display */,
    Window		/* w */,
    Window*		/* colormap_windows */,
    int			/* count */
);
extern void XFreeStringList(
    char**		/* list */
);
extern int XSetTransientForHint(
    Display*		/* display */,
    Window		/* w */,
    Window		/* prop_window */
);

/* The following are given in alphabetical order */

extern int XActivateScreenSaver(
    Display*		/* display */
);

extern int XAddHost(
    Display*		/* display */,
    XHostAddress*	/* host */
);

extern int XAddHosts(
    Display*		/* display */,
    XHostAddress*	/* hosts */,
    int			/* num_hosts */
);

extern int XAddToExtensionList(
    XExtData**	/* structure */,
    XExtData*		/* ext_data */
);

extern int XAddToSaveSet(
    Display*		/* display */,
    Window		/* w */
);

extern Status XAllocColor(
    Display*		/* display */,
    Colormap		/* colormap */,
    XColor*		/* screen_in_out */
);

extern Status XAllocColorCells(
    Display*		/* display */,
    Colormap		/* colormap */,
    Bool	        /* contig */,
    ulong*	/* plane_masks_return */,
    uint	/* nplanes */,
    ulong*	/* pixels_return */,
    uint 	/* npixels */
);

extern Status XAllocColorPlanes(
    Display*		/* display */,
    Colormap		/* colormap */,
    Bool		/* contig */,
    ulong*	/* pixels_return */,
    int			/* ncolors */,
    int			/* nreds */,
    int			/* ngreens */,
    int			/* nblues */,
    ulong*	/* rmask_return */,
    ulong*	/* gmask_return */,
    ulong*	/* bmask_return */
);

	const AllocNone = 0;

extern Status XAllocNamedColor(
    Display*		/* display */,
    Colormap		/* colormap */,
    byte*	/* color_name */,
    XColor*		/* screen_def_return */,
    XColor*		/* exact_def_return */
);

extern int XAllowEvents(
    Display*	/* display */,
    int			/* event_mode */,
    Time		/* time */
);

extern int XAutoRepeatOff(
    Display*	/* display */
);

extern int XAutoRepeatOff(
    Display*	/* display */
);

extern int XAutoRepeatOn(
    Display*	/* display */
);

extern int XBell(
    Display*	/* display */,
    int			/* percent */
);

extern int XBitmapBitOrder(
    Display*	/* display */
);

extern int XBitmapPad(
    Display*	/* display */
);

extern int XBitmapUnit(
    Display*	/* display */
);

extern int XCellsOfScreen(
    Screen*		/* screen */
);

extern int XChangeActivePointerGrab(
    Display*	/* display */,
    EventMask	/* event_mask */,
    Cursor		/* cursor */,
    Time		/* time */
);

extern int XChangeGC(
    Display*	/* display */,
    GC			/* gc */,
    GCMask		/* valuemask */,
    XGCValues*	/* values */
);

extern int XChangeKeyboardControl(
    Display*			/* display */,
    KBMask				/* value_mask */,
    XKeyboardControl*	/* values */
);

extern int XChangeKeyboardMapping(
    Display*	/* display */,
    int			/* first_keycode */,
    int			/* keysyms_per_keycode */,
    KeySym*	/* keysyms */,
    int			/* num_codes */
);

extern int XChangePointerControl(
    Display*	/* display */,
    Bool		/* do_accel */,
    Bool		/* do_threshold */,
    int			/* accel_numerator */,
    int			/* accel_denominator */,
    int			/* threshold */
);

extern int XChangeProperty(
    Display*	/* display */,
    Window		/* w */,
    Atom		/* property */,
    Atom		/* type */,
    int			/* format */,
    PropertyMode/* mode */,
    ubyte*		/* data */,
    int			/* nelements */
);

extern int XChangeSaveSet(
    Display*		/* display */,
    Window			/* w */,
    ChangeMode		/* change_mode */
);

extern int XChangeWindowAttributes(
    Display*		/* display */,
    Window			/* w */,
    WindowAttribute			/* valuemask */,
    XSetWindowAttributes* /* attributes */
);

extern Bool XCheckIfEvent(
    Display*		/* display */,
    XEvent*		/* event_return */,
    Bool function(
	       Display*			/* display */,
               XEvent*			/* event */,
               XPointer			/* arg */
             )		/* predicate */,
    XPointer		/* arg */
);

extern Bool XCheckMaskEvent(
    Display*		/* display */,
    EventMask		/* event_mask */,
    XEvent*			/* event_return */
);

extern Bool XCheckTypedEvent(
    Display*		/* display */,
    EventType		/* event_type */,
    XEvent*			/* event_return */
);

extern Bool XCheckTypedWindowEvent(
    Display*	/* display */,
    Window		/* w */,
    EventType	/* event_type */,
    XEvent*		/* event_return */
);

extern Bool XCheckWindowEvent(
    Display*	/* display */,
    Window		/* w */,
    EventMask	/* event_mask */,
    XEvent*		/* event_return */
);

extern int XCirculateSubwindows(
    Display*			/* display */,
    Window				/* w */,
    CircularDirection	/* direction */
);

extern int XCirculateSubwindowsDown(
    Display*	/* display */,
    Window		/* w */
);

extern int XCirculateSubwindowsUp(
    Display*	/* display */,
    Window		/* w */
);

extern int XClearArea(
    Display*	/* display */,
    Window		/* w */,
    int			/* x */,
    int			/* y */,
    uint		/* width */,
    uint		/* height */,
    Bool		/* exposures */
);

extern int XClearWindow(
    Display*	/* display */,
    Window		/* w */
);

extern int XCloseDisplay(
    Display*	/* display */
);

extern int XConfigureWindow(
    Display*	/* display */,
    Window		/* w */,
    uint		/* value_mask */,
    XWindowChanges*	/* values */
);

extern int XConnectionNumber(
    Display*		/* display */
);

extern int XConvertSelection(
    Display*		/* display */,
    Atom		/* selection */,
    Atom 		/* target */,
    Atom		/* property */,
    Window		/* requestor */,
    Time		/* time */
);

extern int XCopyArea(
    Display*	/* display */,
    Drawable	/* src */,
    Drawable	/* dest */,
    GC			/* gc */,
    int			/* src_x */,
    int			/* src_y */,
    uint		/* width */,
    uint		/* height */,
    int			/* dest_x */,
    int			/* dest_y */
);

extern int XCopyGC(
    Display*	/* display */,
    GC			/* src */,
    GCMask		/* valuemask */,
    GC			/* dest */
);

extern int XCopyPlane(
    Display*		/* display */,
    Drawable		/* src */,
    Drawable		/* dest */,
    GC				/* gc */,
    int				/* src_x */,
    int				/* src_y */,
    uint			/* width */,
    uint			/* height */,
    int				/* dest_x */,
    int				/* dest_y */,
    ulong			/* plane */
);

extern int XDefaultDepth(
    Display*	/* display */,
    int			/* screen_number */
);

extern int XDefaultDepthOfScreen(
    Screen*		/* screen */
);

extern int XDefaultScreen(
    Display*	/* display */
);

extern int XDefineCursor(
    Display*	/* display */,
    Window		/* w */,
    Cursor		/* cursor */
);

extern int XDeleteProperty(
    Display*		/* display */,
    Window		/* w */,
    Atom		/* property */
);

extern int XDestroyWindow(
    Display*	/* display */,
    Window		/* w */
);

extern int XDestroySubwindows(
    Display*	/* display */,
    Window		/* w */
);

extern int XDoesBackingStore(
    Screen*		/* screen */
);

extern Bool XDoesSaveUnders(
    Screen*		/* screen */
);

extern int XDisableAccessControl(
    Display*	/* display */
);


extern int XDisplayCells(
    Display*	/* display */,
    int			/* screen_number */
);

extern int XDisplayHeight(
    Display*	/* display */,
    int			/* screen_number */
);

extern int XDisplayHeightMM(
    Display*	/* display */,
    int			/* screen_number */
);

extern int XDisplayKeycodes(
    Display*	/* display */,
    int*		/* min_keycodes_return */,
    int*		/* max_keycodes_return */
);

extern int XDisplayPlanes(
    Display*	/* display */,
    int			/* screen_number */
);

extern int XDisplayWidth(
    Display*	/* display */,
    int			/* screen_number */
);

extern int XDisplayWidthMM(
    Display*	/* display */,
    int			/* screen_number */
);

extern int XDrawArc(
    Display*	/* display */,
    Drawable	/* d */,
    GC			/* gc */,
    int			/* x */,
    int			/* y */,
    uint		/* width */,
    uint		/* height */,
    int			/* angle1 */,
    int			/* angle2 */
);

extern int XDrawArcs(
    Display*	/* display */,
    Drawable	/* d */,
    GC			/* gc */,
    XArc*		/* arcs */,
    int			/* narcs */
);

extern int XDrawImageString(
    Display*	/* display */,
    Drawable	/* d */,
    GC			/* gc */,
    int			/* x */,
    int			/* y */,
    char*		/* string */,
    int			/* length */
);

extern int XDrawImageString16(
    Display*	/* display */,
    Drawable	/* d */,
    GC			/* gc */,
    int			/* x */,
    int			/* y */,
    XChar2b*	/* string */,
    int			/* length */
);

extern int XDrawLine(
    Display*	/* display */,
    Drawable	/* d */,
    GC			/* gc */,
    int			/* x1 */,
    int			/* y1 */,
    int			/* x2 */,
    int			/* y2 */
);

extern int XDrawLines(
    Display*		/* display */,
    Drawable		/* d */,
    GC				/* gc */,
    XPoint*			/* points */,
    int				/* npoints */,
    CoordinateMode	/* mode */
);

extern int XDrawPoint(
    Display*	/* display */,
    Drawable	/* d */,
    GC			/* gc */,
    int			/* x */,
    int			/* y */
);

extern int XDrawPoints(
    Display*		/* display */,
    Drawable		/* d */,
    GC				/* gc */,
    XPoint*			/* points */,
    int				/* npoints */,
    CoordinateMode	/* mode */
);

extern int XDrawRectangle(
    Display*		/* display */,
    Drawable		/* d */,
    GC				/* gc */,
    int				/* x */,
    int				/* y */,
    uint			/* width */,
    uint			/* height */
);

extern int XDrawRectangles(
    Display*		/* display */,
    Drawable		/* d */,
    GC				/* gc */,
    XRectangle*		/* rectangles */,
    int				/* nrectangles */
);

extern int XDrawSegments(
    Display*		/* display */,
    Drawable		/* d */,
    GC				/* gc */,
    XSegment*		/* segments */,
    int				/* nsegments */
);

extern int XDrawString(
    Display*		/* display */,
    Drawable		/* d */,
    GC				/* gc */,
    int				/* x */,
    int				/* y */,
    char*	/* string */,
    int			/* length */
);

extern int XDrawString16(
    Display*	/* display */,
    Drawable	/* d */,
    GC			/* gc */,
    int			/* x */,
    int			/* y */,
    XChar2b*	/* string */,
    int			/* length */
);

extern int XDrawText(
    Display*	/* display */,
    Drawable	/* d */,
    GC			/* gc */,
    int			/* x */,
    int			/* y */,
    XTextItem*	/* items */,
    int			/* nitems */
);

extern int XDrawText16(
    Display*	/* display */,
    Drawable	/* d */,
    GC			/* gc */,
    int			/* x */,
    int			/* y */,
    XTextItem16*/* items */,
    int			/* nitems */
);

extern int XEnableAccessControl(
    Display*	/* display */
);

extern int XEventsQueued(
    Display*	/* display */,
    QueueMode	/* mode */
);

extern Status XFetchName(
    Display*	/* display */,
    Window		/* w */,
    byte**		/* window_name_return */
);

extern int XFillArc(
    Display*	/* display */,
    Drawable	/* d */,
    GC			/* gc */,
    int			/* x */,
    int			/* y */,
    uint		/* width */,
    uint		/* height */,
    int			/* angle1 */,
    int			/* angle2 */
);

extern int XFillArcs(
    Display*	/* display */,
    Drawable	/* d */,
    GC			/* gc */,
    XArc*		/* arcs */,
    int			/* narcs */
);

extern int XFillPolygon(
    Display*	/* display */,
    Drawable	/* d */,
    GC			/* gc */,
    XPoint*		/* points */,
    int			/* npoints */,
    int			/* shape */,
    CoordinateMode	/* mode */
);

extern int XFillRectangle(
    Display*	/* display */,
    Drawable	/* d */,
    GC			/* gc */,
    int			/* x */,
    int			/* y */,
    uint		/* width */,
    uint		/* height */
);

extern int XFillRectangles(
    Display*	/* display */,
    Drawable	/* d */,
    GC			/* gc */,
    XRectangle*	/* rectangles */,
    int			/* nrectangles */
);

extern int XFlush(
    Display*	/* display */
);

extern int XForceScreenSaver(
    Display*			/* display */,
    ScreenSaverMode		/* mode */
);

extern int XFree(
    void*		/* data */
);

extern int XFreeColormap(
    Display*	/* display */,
    Colormap	/* colormap */
);

extern int XFreeColors(
    Display*	/* display */,
    Colormap	/* colormap */,
    ulong*		/* pixels */,
    int			/* npixels */,
    ulong		/* planes */
);

extern int XFreeCursor(
    Display*	/* display */,
    Cursor		/* cursor */
);

extern int XFreeExtensionList(
    byte**		/* list */
);

extern int XFreeFont(
    Display*	/* display */,
    XFontStruct*/* font_struct */
);

extern int XFreeFontInfo(
    byte**		/* names */,
    XFontStruct*/* free_info */,
    int			/* actual_count */
);

extern int XFreeFontNames(
    byte**		/* list */
);

extern int XFreeFontPath(
    byte**		/* list */
);

extern int XFreeGC(
    Display*	/* display */,
    GC			/* gc */
);

extern int XFreeModifiermap(
    XModifierKeymap*	/* modmap */
);

extern int XFreePixmap(
    Display*	/* display */,
    Pixmap		/* pixmap */
);

extern int XGeometry(
    Display*	/* display */,
    int			/* screen */,
    byte*		/* position */,
    byte*		/* default_position */,
    uint		/* bwidth */,
    uint		/* fwidth */,
    uint		/* fheight */,
    int			/* xadder */,
    int			/* yadder */,
    int*		/* x_return */,
    int*		/* y_return */,
    int*		/* width_return */,
    int*		/* height_return */
);

extern int XGetErrorDatabaseText(
    Display*	/* display */,
    char*		/* name */,
    char*		/* message */,
    char*		/* default_string */,
    byte*		/* buffer_return */,
    int			/* length */
);

extern int XGetErrorText(
    Display*	/* display */,
    XErrorCode	/* code */,
    byte*		/* buffer_return */,
    int			/* length */
);

extern Bool XGetFontProperty(
    XFontStruct*/* font_struct */,
    Atom		/* atom */,
    ulong*		/* value_return */
);

extern Status XGetGCValues(
    Display*		/* display */,
    GC				/* gc */,
    GCMask			/* valuemask */,
    XGCValues*		/* values_return */
);

extern Status XGetGeometry(
    Display*		/* display */,
    Drawable		/* d */,
    Window*			/* root_return */,
    int*			/* x_return */,
    int*			/* y_return */,
    uint*			/* width_return */,
    uint*			/* height_return */,
    uint*			/* border_width_return */,
    uint*			/* depth_return */
);

extern Status XGetIconName(
    Display*	/* display */,
    Window		/* w */,
    byte**		/* icon_name_return */
);

extern int XGetInputFocus(
    Display*		/* display */,
    Window*		/* focus_return */,
    int*		/* revert_to_return */
);

extern int XGetKeyboardControl(
    Display*		/* display */,
    XKeyboardState*	/* values_return */
);

extern int XGetPointerControl(
    Display*	/* display */,
    int*		/* accel_numerator_return */,
    int*		/* accel_denominator_return */,
    int*		/* threshold_return */
);

extern int XGetPointerMapping(
    Display*		/* display */,
    ubyte*			/* map_return */,
    int				/* nmap */
);

extern int XGetScreenSaver(
    Display*	/* display */,
    int*		/* timeout_return */,
    int*		/* interval_return */,
    int*		/* prefer_blanking_return */,
    int*		/* allow_exposures_return */
);

extern Status XGetTransientForHint(
    Display*	/* display */,
    Window		/* w */,
    Window*		/* prop_window_return */
);

extern int XGetWindowProperty(
    Display*	/* display */,
    Window		/* w */,
    Atom		/* property */,
    long		/* long_offset */,
    long		/* long_length */,
    Bool		/* delete */,
    Atom		/* req_type */,
    Atom*		/* actual_type_return */,
    int*		/* actual_format_return */,
    ulong*		/* nitems_return */,
    ulong*		/* bytes_after_return */,
    ubyte**		/* prop_return */
);

extern Status XGetWindowAttributes(
    Display*	/* display */,
    Window		/* w */,
    XWindowAttributes*	/* window_attributes_return */
);

extern int XGrabButton(
    Display*		/* display */,
    uint			/* button */,
    uint			/* modifiers */,
    Window			/* grab_window */,
    Bool			/* owner_events */,
    EventMask		/* event_mask */,
    GrabMode		/* pointer_mode */,
    GrabMode		/* keyboard_mode */,
    Window			/* confine_to */,
    Cursor			/* cursor */
);

extern int XGrabKey(
    Display*	/* display */,
    int			/* keycode */,
    KeyMask		/* modifiers */,
    Window		/* grab_window */,
    Bool		/* owner_events */,
    GrabMode	/* pointer_mode */,
    GrabMode	/* keyboard_mode */
);

extern int XGrabKeyboard(
    Display*	/* display */,
    Window		/* grab_window */,
    Bool		/* owner_events */,
    GrabMode	/* pointer_mode */,
    GrabMode	/* keyboard_mode */,
    Time		/* time */
);

extern int XGrabPointer(
    Display*	/* display */,
    Window		/* grab_window */,
    Bool		/* owner_events */,
    EventMask	/* event_mask */,
    GrabMode	/* pointer_mode */,
    GrabMode	/* keyboard_mode */,
    Window		/* confine_to */,
    Cursor		/* cursor */,
    Time		/* time */
);

extern int XGrabServer(
    Display*	/* display */
);

extern int XHeightMMOfScreen(
    Screen*		/* screen */
);

extern int XHeightOfScreen(
    Screen*		/* screen */
);

extern int XIfEvent(
    Display*	/* display */,
    XEvent*		/* event_return */,
    Bool function(
	       Display*			/* display */,
               XEvent*			/* event */,
               XPointer			/* arg */
             )		/* predicate */,
    XPointer		/* arg */
);

extern int XImageByteOrder(
    Display*	/* display */
);

extern int XInstallColormap(
    Display*	/* display */,
    Colormap	/* colormap */
);

extern KeyCode XKeysymToKeycode(
    Display*	/* display */,
    KeySym		/* keysym */
);

extern int XKillClient(
    Display*	/* display */,
    XID			/* resource */
);

extern Status XLookupColor(
    Display*	/* display */,
    Colormap	/* colormap */,
    byte*		/* color_name */,
    XColor*		/* exact_def_return */,
    XColor*		/* screen_def_return */
);

extern int XLowerWindow(
    Display*	/* display */,
    Window		/* w */
);

extern int XMapRaised(
    Display*	/* display */,
    Window		/* w */
);

extern int XMapSubwindows(
    Display*	/* display */,
    Window		/* w */
);

extern int XMapWindow(
    Display*	/* display */,
    Window		/* w */
);

extern int XMaskEvent(
    Display*	/* display */,
    EventMask	/* event_mask */,
    XEvent*		/* event_return */
);

extern int XMaxCmapsOfScreen(
    Screen*		/* screen */
);

extern int XMinCmapsOfScreen(
    Screen*		/* screen */
);

extern int XMoveResizeWindow(
    Display*	/* display */,
    Window		/* w */,
    int			/* x */,
    int			/* y */,
    uint		/* width */,
    uint		/* height */
);

extern int XMoveWindow(
    Display*	/* display */,
    Window		/* w */,
    int			/* x */,
    int			/* y */
);

extern int XNextEvent(
    Display*	/* display */,
    XEvent*		/* event_return */
);

extern int XNoOp(
    Display*	/* display */
);

extern Status XParseColor(
    Display*	/* display */,
    Colormap	/* colormap */,
    ubyte*		/* spec */,
    XColor*		/* exact_def_return */
);

extern int XParseGeometry(
    char*		/* parsestring */,
    int*		/* x_return */,
    int*		/* y_return */,
    uint*		/* width_return */,
    uint*		/* height_return */
);

extern int XPeekEvent(
    Display*	/* display */,
    XEvent*		/* event_return */
);

extern int XPeekIfEvent(
    Display*	/* display */,
    XEvent*		/* event_return */,
    Bool function (
	       Display*		/* display */,
               XEvent*	/* event */,
               XPointer	/* arg */
             )	/* predicate */,
    XPointer	/* arg */
);

extern int XPending(
    Display*	/* display */
);

extern int XPlanesOfScreen(
    Screen*		/* screen */
);

extern int XProtocolRevision(
    Display*	/* display */
);

extern int XProtocolVersion(
    Display*	/* display */
);


extern int XPutBackEvent(
    Display*	/* display */,
    XEvent*		/* event */
);

extern int XPutImage(
    Display*	/* display */,
    Drawable	/* d */,
    GC			/* gc */,
    XImage*	/* image */,
    int			/* src_x */,
    int			/* src_y */,
    int			/* dest_x */,
    int			/* dest_y */,
    uint		/* width */,
    uint		/* height */
);

extern int XQLength(
    Display*	/* display */
);

extern Status XQueryBestCursor(
    Display*	/* display */,
    Drawable	/* d */,
    uint		/* width */,
    uint		/* height */,
    uint*		/* width_return */,
    uint*		/* height_return */
);

extern Status XQueryBestSize(
    Display*	/* display */,
    int			/* class */,
    Drawable	/* which_screen */,
    uint		/* width */,
    uint		/* height */,
    uint*		/* width_return */,
    uint*		/* height_return */
);

extern Status XQueryBestStipple(
    Display*	/* display */,
    Drawable	/* which_screen */,
    uint		/* width */,
    uint		/* height */,
    uint*		/* width_return */,
    uint*		/* height_return */
);

extern Status XQueryBestTile(
    Display*	/* display */,
    Drawable	/* which_screen */,
    uint		/* width */,
    uint		/* height */,
    uint*		/* width_return */,
    uint*		/* height_return */
);

extern int XQueryColor(
    Display*	/* display */,
    Colormap	/* colormap */,
    XColor*		/* def_in_out */
);

extern int XQueryColors(
    Display*	/* display */,
    Colormap	/* colormap */,
    XColor*		/* defs_in_out */,
    int			/* ncolors */
);

extern Bool XQueryExtension(
    Display*	/* display */,
    byte*		/* name */,
    int*		/* major_opcode_return */,
    int*		/* first_event_return */,
    int*		/* first_error_return */
);

extern int XQueryKeymap(
    Display*	/* display */,
    byte [32]	/* keys_return */
);

extern Bool XQueryPointer(
    Display*	/* display */,
    Window		/* w */,
    Window*		/* root_return */,
    Window*		/* child_return */,
    int*		/* root_x_return */,
    int*		/* root_y_return */,
    int*		/* win_x_return */,
    int*		/* win_y_return */,
    uint*       /* mask_return */
);

extern int XQueryTextExtents(
    Display*	/* display */,
    XID			/* font_ID */,
    char*		/* string */,
    int			/* nchars */,
    FontDrawDirection*	/* direction_return */,
    int*		/* font_ascent_return */,
    int*		/* font_descent_return */,
    XCharStruct*/* overall_return */
);

extern int XQueryTextExtents16(
    Display*	/* display */,
    XID			/* font_ID */,
    XChar2b*	/* string */,
    int			/* nchars */,
    FontDrawDirection*	/* direction_return */,
    int*		/* font_ascent_return */,
    int*		/* font_descent_return */,
    XCharStruct*/* overall_return */
);

extern Status XQueryTree(
    Display*	/* display */,
    Window		/* w */,
    Window*		/* root_return */,
    Window*		/* parent_return */,
    Window**	/* children_return */,
    uint*		/* nchildren_return */
);

extern int XRaiseWindow(
    Display*	/* display */,
    Window		/* w */
);

extern int XReadBitmapFile(
    Display*	/* display */,
    Drawable 	/* d */,
    ubyte*		/* filename */,
    uint*		/* width_return */,
    uint*		/* height_return */,
    Pixmap*	/* bitmap_return */,
    int*		/* x_hot_return */,
    int*		/* y_hot_return */
);

extern int XReadBitmapFileData(
    byte*		/* filename */,
    uint*		/* width_return */,
    uint*		/* height_return */,
    ubyte**		/* data_return */,
    int*		/* x_hot_return */,
    int*		/* y_hot_return */
);

extern int XRebindKeysym(
    Display*	/* display */,
    KeySym		/* keysym */,
    KeySym*	/* list */,
    int			/* mod_count */,
    char*		/* string */,
    int			/* bytes_string */
);

extern int XRecolorCursor(
    Display*	/* display */,
    Cursor		/* cursor */,
    XColor*		/* foreground_color */,
    XColor*		/* background_color */
);

extern int XRefreshKeyboardMapping(
    XMappingEvent*	/* event_map */
);

extern int XRemoveFromSaveSet(
    Display*	/* display */,
    Window		/* w */
);

extern int XRemoveHost(
    Display*		/* display */,
    XHostAddress*	/* host */
);

extern int XRemoveHosts(
    Display*		/* display */,
    XHostAddress*	/* hosts */,
    int			/* num_hosts */
);

extern int XReparentWindow(
    Display*	/* display */,
    Window		/* w */,
    Window		/* parent */,
    int			/* x */,
    int			/* y */
);

extern int XResetScreenSaver(
    Display*	/* display */
);

extern int XResizeWindow(
    Display*	/* display */,
    Window		/* w */,
    uint		/* width */,
    uint		/* height */
);

extern int XRestackWindows(
    Display*	/* display */,
    Window*		/* windows */,
    int			/* nwindows */
);

extern int XRotateBuffers(
    Display*	/* display */,
    int			/* rotate */
);

extern int XRotateWindowProperties(
    Display*	/* display */,
    Window		/* w */,
    Atom*		/* properties */,
    int			/* num_prop */,
    int			/* npositions */
);

extern int XScreenCount(
    Display*	/* display */
);

extern int XSelectInput(
    Display*	/* display */,
    Window		/* w */,
    EventMask	/* event_mask */
);

extern Status XSendEvent(
    Display*	/* display */,
    Window		/* w */,
    Bool		/* propagate */,
    EventMask	/* event_mask */,
    XEvent*		/* event_send */
);

extern int XSetAccessControl(
    Display*	/* display */,
    HostAccess	/* mode */
);

extern int XSetArcMode(
    Display*	/* display */,
    GC			/* gc */,
    ArcMode		/* arc_mode */
);

extern int XSetBackground(
    Display*	/* display */,
    GC			/* gc */,
    ulong		/* background */
);

extern int XSetClipMask(
    Display*	/* display */,
    GC			/* gc */,
    Pixmap		/* pixmap */
);

extern int XSetClipOrigin(
    Display*	/* display */,
    GC			/* gc */,
    int			/* clip_x_origin */,
    int			/* clip_y_origin */
);

extern int XSetClipRectangles(
    Display*	/* display */,
    GC			/* gc */,
    int			/* clip_x_origin */,
    int			/* clip_y_origin */,
    XRectangle*	/* rectangles */,
    int			/* n */,
    int			/* ordering */
);

extern int XSetCloseDownMode(
    Display*	/* display */,
    int			/* close_mode */
);

extern int XSetCommand(
    Display*	/* display */,
    Window		/* w */,
    byte**		/* argv */,
    int			/* argc */
);

extern int XSetDashes(
    Display*	/* display */,
    GC			/* gc */,
    int			/* dash_offset */,
    byte*		/* dash_list */,
    int			/* n */
);

extern int XSetFillRule(
    Display*	/* display */,
    GC			/* gc */,
    FillRule	/* fill_rule */
);

extern int XSetFillStyle(
    Display*	/* display */,
    GC			/* gc */,
    FillStyle	/* fill_style */
);

extern int XSetFont(
    Display*	/* display */,
    GC			/* gc */,
    Font		/* font */
);

extern int XSetFontPath(
    Display*	/* display */,
    byte**		/* directories */,
    int			/* ndirs */
);

extern int XSetForeground(
    Display*	/* display */,
    GC			/* gc */,
    ulong		/* foreground */
);

extern int XSetFunction(
    Display*	/* display */,
    GC			/* gc */,
    int			/* function */
);

extern int XSetGraphicsExposures(
    Display*	/* display */,
    GC			/* gc */,
    Bool		/* graphics_exposures */
);

extern int XSetIconName(
    Display*	/* display */,
    Window		/* w */,
    byte*		/* icon_name */
);

extern int XSetInputFocus(
    Display*	/* display */,
    Window		/* focus */,
    int			/* revert_to */,
    Time		/* time */
);

extern int XSetLineAttributes(
    Display*	/* display */,
    GC			/* gc */,
    uint		/* line_width */,
    LineStyle	/* line_style */,
    CapStyle	/* cap_style */,
    JoinStyle	/* join_style */
);

extern int XSetModifierMapping(
    Display*		/* display */,
    XModifierKeymap*/* modmap */
);

extern int XSetPlaneMask(
    Display*	/* display */,
    GC			/* gc */,
    ulong		/* plane_mask */
);

extern int XSetPointerMapping(
    Display*	/* display */,
    ubyte*		/* map */,
    int			/* nmap */
);

extern int XSetScreenSaver(
    Display*	/* display */,
    int			/* timeout */,
    int			/* interval */,
    int			/* prefer_blanking */,
    int			/* allow_exposures */
);

extern int XSetSelectionOwner(
    Display*	/* display */,
    Atom	    /* selection */,
    Window		/* owner */,
    Time		/* time */
);

extern int XSetState(
    Display*		/* display */,
    GC			/* gc */,
    ulong	/* foreground */,
    ulong	/* background */,
    GraphicFunction			/* function */,
    ulong	/* plane_mask */
);

extern int XSetStipple(
    Display*		/* display */,
    GC			/* gc */,
    Pixmap		/* stipple */
);

extern int XSetSubwindowMode(
    Display*		/* display */,
    GC			/* gc */,
    int			/* subwindow_mode */
);

extern int XSetTSOrigin(
    Display*		/* display */,
    GC			/* gc */,
    int			/* ts_x_origin */,
    int			/* ts_y_origin */
);

extern int XSetTile(
    Display*		/* display */,
    GC			/* gc */,
    Pixmap		/* tile */
);

extern int XSetWindowBackground(
    Display*		/* display */,
    Window		/* w */,
    ulong	/* background_pixel */
);

extern int XSetWindowBackgroundPixmap(
    Display*		/* display */,
    Window		/* w */,
    Pixmap		/* background_pixmap */
);

extern int XSetWindowBorder(
    Display*		/* display */,
    Window		/* w */,
    ulong	/* border_pixel */
);

extern int XSetWindowBorderPixmap(
    Display*		/* display */,
    Window		/* w */,
    Pixmap		/* border_pixmap */
);

extern int XSetWindowBorderWidth(
    Display*		/* display */,
    Window		/* w */,
    uint	/* width */
);

extern int XSetWindowColormap(
    Display*		/* display */,
    Window		/* w */,
    Colormap		/* colormap */
);

extern int XStoreBuffer(
    Display*		/* display */,
    byte*	/* bytes */,
    int			/* nbytes */,
    int			/* buffer */
);

extern int XStoreBytes(
    Display*		/* display */,
    byte*	/* bytes */,
    int			/* nbytes */
);

extern int XStoreColor(
    Display*		/* display */,
    Colormap		/* colormap */,
    XColor*		/* color */
);

extern int XStoreColors(
    Display*		/* display */,
    Colormap		/* colormap */,
    XColor*		/* color */,
    int			/* ncolors */
);

extern int XStoreName(
    Display*		/* display */,
    Window		/* w */,
    char*	/* window_name */
);

extern int XStoreNamedColor(
    Display*		/* display */,
    Colormap		/* colormap */,
    char*			/* color */,
    ulong			/* pixel */,
    StoreColor		/* flags */
);

extern int XSync(
    Display*		/* display */,
    Bool			/* discard */
);

extern int XTextExtents(
    XFontStruct*	/* font_struct */,
    char*	/* string */,
    int			/* nchars */,
    int*		/* direction_return */,
    int*		/* font_ascent_return */,
    int*		/* font_descent_return */,
    XCharStruct*	/* overall_return */
);

extern int XTextExtents16(
    XFontStruct*	/* font_struct */,
    XChar2b*	/* string */,
    int			/* nchars */,
    FontDrawDirection*		/* direction_return */,
    int*		/* font_ascent_return */,
    int*		/* font_descent_return */,
    XCharStruct*	/* overall_return */
);

extern int XTextWidth(
    XFontStruct*	/* font_struct */,
    char*	/* string */,
    int			/* count */
);

extern int XTextWidth16(
    XFontStruct*	/* font_struct */,
    XChar2b*	/* string */,
    int			/* count */
);

extern Bool XTranslateCoordinates(
    Display*		/* display */,
    Window		/* src_w */,
    Window		/* dest_w */,
    int			/* src_x */,
    int			/* src_y */,
    int*		/* dest_x_return */,
    int*		/* dest_y_return */,
    Window*		/* child_return */
);

extern int XUndefineCursor(
    Display*		/* display */,
    Window		/* w */
);

extern int XUngrabButton(
    Display*	/* display */,
    uint		/* button */,
    KeyMask		/* modifiers */,
    Window		/* grab_window */
);

extern int XUngrabKey(
    Display*	/* display */,
    int			/* keycode */,
    KeyMask		/* modifiers */,
    Window		/* grab_window */
);

extern int XUngrabKeyboard(
    Display*	/* display */,
    Time		/* time */
);

extern int XUngrabPointer(
    Display*	/* display */,
    Time		/* time */
);

extern int XUngrabServer(
    Display*	/* display */
);

extern int XUninstallColormap(
    Display*	/* display */,
    Colormap	/* colormap */
);

extern int XUnloadFont(
    Display*	/* display */,
    Font		/* font */
);

extern int XUnmapSubwindows(
    Display*	/* display */,
    Window		/* w */
);

extern int XUnmapWindow(
    Display*	/* display */,
    Window		/* w */
);

extern int XVendorRelease(
    Display*	/* display */
);

extern int XWarpPointer(
    Display*	/* display */,
    Window		/* src_w */,
    Window		/* dest_w */,
    int			/* src_x */,
    int			/* src_y */,
    uint		/* src_width */,
    uint		/* src_height */,
    int			/* dest_x */,
    int			/* dest_y */
);

extern int XWidthMMOfScreen(
    Screen*		/* screen */
);

extern int XWidthOfScreen(
    Screen*		/* screen */
);

extern int XWindowEvent(
    Display*	/* display */,
    Window		/* w */,
    EventMask	/* event_mask */,
    XEvent*		/* event_return */
);

extern int XWriteBitmapFile(
    Display*		/* display */,
    byte*	/* filename */,
    Pixmap		/* bitmap */,
    uint	/* width */,
    uint	/* height */,
    int			/* x_hot */,
    int			/* y_hot */
);

extern Bool XSupportsLocale ();

extern byte *XSetLocaleModifiers(
    byte*		/* modifier_list */
);

extern XOM XOpenOM(
    Display*			/* display */,
    XrmHashBucketRec*	/* rdb */,
    byte*		/* res_name */,
    byte*		/* res_class */
);

extern Status XCloseOM(
    XOM			/* om */
);

/+todo
extern byte *XSetOMValues(
    XOM			/* om */,
    ...
) _X_SENTINEL(0);

extern byte *XGetOMValues(
    XOM			/* om */,
    ...
) _X_SENTINEL(0);
+/

extern Display *XDisplayOfOM(
    XOM			/* om */
);

extern byte *XLocaleOfOM(
    XOM			/* om */
);

/+todo
extern XOC XCreateOC(
    XOM			/* om */,
    ...
) _X_SENTINEL(0);
+/

extern void XDestroyOC(
    XOC			/* oc */
);

extern XOM XOMOfOC(
    XOC			/* oc */
);

/+todo
extern byte *XSetOCValues(
    XOC			/* oc */,
    ...
) _X_SENTINEL(0);


extern byte *XGetOCValues(
    XOC			/* oc */,
    ...
) _X_SENTINEL(0);
+/

extern XFontSet XCreateFontSet(
    Display*		/* display */,
    byte*	/* base_font_name_list */,
    byte***		/* missing_charset_list */,
    int*		/* missing_charset_count */,
    char**		/* def_string */
);

extern void XFreeFontSet(
    Display*		/* display */,
    XFontSet		/* font_set */
);

extern int XFontsOfFontSet(
    XFontSet		/* font_set */,
    XFontStruct***	/* font_struct_list */,
    byte***		/* font_name_list */
);

extern byte *XBaseFontNameListOfFontSet(
    XFontSet		/* font_set */
);

extern byte *XLocaleOfFontSet(
    XFontSet		/* font_set */
);

extern Bool XContextDependentDrawing(
    XFontSet		/* font_set */
);

extern Bool XDirectionalDependentDrawing(
    XFontSet		/* font_set */
);

extern Bool XContextualDrawing(
    XFontSet		/* font_set */
);

extern XFontSetExtents *XExtentsOfFontSet(
    XFontSet		/* font_set */
);

extern int XmbTextEscapement(
    XFontSet		/* font_set */,
    byte*	/* text */,
    int			/* bytes_text */
);

extern int XwcTextEscapement(
    XFontSet		/* font_set */,
    wchar*	/* text */,
    int			/* num_wchars */
);

extern int Xutf8TextEscapement(
    XFontSet		/* font_set */,
    char*	/* text */,
    int			/* bytes_text */
);

extern int XmbTextExtents(
    XFontSet		/* font_set */,
    byte*	/* text */,
    int			/* bytes_text */,
    XRectangle*		/* overall_ink_return */,
    XRectangle*		/* overall_logical_return */
);

extern int XwcTextExtents(
    XFontSet		/* font_set */,
    wchar*	/* text */,
    int			/* num_wchars */,
    XRectangle*		/* overall_ink_return */,
    XRectangle*		/* overall_logical_return */
);

extern int Xutf8TextExtents(
    XFontSet		/* font_set */,
    char*	/* text */,
    int			/* bytes_text */,
    XRectangle*		/* overall_ink_return */,
    XRectangle*		/* overall_logical_return */
);

extern Status XmbTextPerCharExtents(
    XFontSet		/* font_set */,
    byte*	/* text */,
    int			/* bytes_text */,
    XRectangle*		/* ink_extents_buffer */,
    XRectangle*		/* logical_extents_buffer */,
    int			/* buffer_size */,
    int*		/* num_chars */,
    XRectangle*		/* overall_ink_return */,
    XRectangle*		/* overall_logical_return */
);

extern Status XwcTextPerCharExtents(
    XFontSet		/* font_set */,
    wchar*	/* text */,
    int			/* num_wchars */,
    XRectangle*		/* ink_extents_buffer */,
    XRectangle*		/* logical_extents_buffer */,
    int			/* buffer_size */,
    int*		/* num_chars */,
    XRectangle*		/* overall_ink_return */,
    XRectangle*		/* overall_logical_return */
);

extern Status Xutf8TextPerCharExtents(
    XFontSet		/* font_set */,
    char*	/* text */,
    int			/* bytes_text */,
    XRectangle*		/* ink_extents_buffer */,
    XRectangle*		/* logical_extents_buffer */,
    int			/* buffer_size */,
    int*		/* num_chars */,
    XRectangle*		/* overall_ink_return */,
    XRectangle*		/* overall_logical_return */
);

extern void XmbDrawText(
    Display*		/* display */,
    Drawable		/* d */,
    GC			/* gc */,
    int			/* x */,
    int			/* y */,
    XmbTextItem*	/* text_items */,
    int			/* nitems */
);

extern void XwcDrawText(
    Display*		/* display */,
    Drawable		/* d */,
    GC			/* gc */,
    int			/* x */,
    int			/* y */,
    XwcTextItem*	/* text_items */,
    int			/* nitems */
);

extern void Xutf8DrawText(
    Display*		/* display */,
    Drawable		/* d */,
    GC			/* gc */,
    int			/* x */,
    int			/* y */,
    XmbTextItem*	/* text_items */,
    int			/* nitems */
);

extern void XmbDrawString(
    Display*		/* display */,
    Drawable		/* d */,
    XFontSet		/* font_set */,
    GC			/* gc */,
    int			/* x */,
    int			/* y */,
    char*	/* text */,
    int			/* bytes_text */
);

extern void XwcDrawString(
    Display*		/* display */,
    Drawable		/* d */,
    XFontSet		/* font_set */,
    GC			/* gc */,
    int			/* x */,
    int			/* y */,
    wchar*	/* text */,
    int			/* num_wchars */
);

extern void Xutf8DrawString(
    Display*		/* display */,
    Drawable		/* d */,
    XFontSet		/* font_set */,
    GC			/* gc */,
    int			/* x */,
    int			/* y */,
    char*	/* text */,
    int			/* bytes_text */
);

extern void XmbDrawImageString(
    Display*		/* display */,
    Drawable		/* d */,
    XFontSet		/* font_set */,
    GC			/* gc */,
    int			/* x */,
    int			/* y */,
    char*	/* text */,
    int			/* bytes_text */
);

extern void XwcDrawImageString(
    Display*		/* display */,
    Drawable		/* d */,
    XFontSet		/* font_set */,
    GC			/* gc */,
    int			/* x */,
    int			/* y */,
    wchar*	/* text */,
    int			/* num_wchars */
);

extern void Xutf8DrawImageString(
    Display*		/* display */,
    Drawable		/* d */,
    XFontSet		/* font_set */,
    GC			/* gc */,
    int			/* x */,
    int			/* y */,
    char*	/* text */,
    int			/* bytes_text */
);

extern XIM XOpenIM(
    Display*			/* dpy */,
    XrmHashBucketRec*	/* rdb */,
    byte*			/* res_name */,
    byte*			/* res_class */
);

extern Status XCloseIM(
    XIM /* im */
);

/+todo
extern byte *XGetIMValues(
    XIM /* im */, ...
) _X_SENTINEL(0);

extern byte *XSetIMValues(
    XIM /* im */, ...
) _X_SENTINEL(0);

+/
extern Display *XDisplayOfIM(
    XIM /* im */
);

extern byte *XLocaleOfIM(
    XIM /* im*/
);

/+todo
extern XIC XCreateIC(
    XIM /* im */, ...
) _X_SENTINEL(0);
+/

extern void XDestroyIC(
    XIC /* ic */
);

extern void XSetICFocus(
    XIC /* ic */
);

extern void XUnsetICFocus(
    XIC /* ic */
);

extern wchar *XwcResetIC(
    XIC /* ic */
);

extern byte *XmbResetIC(
    XIC /* ic */
);

extern byte *Xutf8ResetIC(
    XIC /* ic */
);

/+todo
extern byte *XSetICValues(
    XIC /* ic */, ...
) _X_SENTINEL(0);

extern byte *XGetICValues(
    XIC /* ic */, ...
) _X_SENTINEL(0);
+/
extern XIM XIMOfIC(
    XIC /* ic */
);

extern Bool XFilterEvent(
    XEvent*	/* event */,
    Window	/* window */
);

extern int XmbLookupString(
    XIC			/* ic */,
    XKeyPressedEvent*	/* event */,
    char*		/* buffer_return */,
    int			/* bytes_buffer */,
    KeySym*		/* keysym_return */,
    Status*		/* status_return */
);

extern int XwcLookupString(
    XIC			/* ic */,
    XKeyPressedEvent*	/* event */,
    wchar*		/* buffer_return */,
    int			/* wchars_buffer */,
    KeySym*		/* keysym_return */,
    Status*		/* status_return */
);

extern int Xutf8LookupString(
    XIC			/* ic */,
    XKeyPressedEvent*	/* event */,
    char*		/* buffer_return */,
    int			/* bytes_buffer */,
    KeySym*		/* keysym_return */,
    Status*		/* status_return */
);

/+todo
extern XVaNestedList XVaCreateNestedList(
    int /*unused*/, ...
) _X_SENTINEL(0);
+/
/* internal connections for IMs */

extern Bool XRegisterIMInstantiateCallback(
    Display*			/* dpy */,
    XrmHashBucketRec*	/* rdb */,
    byte*			/* res_name */,
    byte*			/* res_class */,
    XIDProc			/* callback */,
    XPointer			/* client_data */
);

extern Bool XUnregisterIMInstantiateCallback(
    Display*			/* dpy */,
    XrmHashBucketRec*	/* rdb */,
    byte*			/* res_name */,
    byte*			/* res_class */,
    XIDProc			/* callback */,
    XPointer			/* client_data */
);

alias XConnectionWatchProc = void function(
    Display*			/* dpy */,
    XPointer			/* client_data */,
    int				/* fd */,
    Bool			/* opening */,	 /* open or close flag */
    XPointer*			/* watch_data */ /* open sets, close uses */
);


extern Status XInternalConnectionNumbers(
    Display*			/* dpy */,
    int**			/* fd_return */,
    int*			/* count_return */
);

extern void XProcessInternalConnection(
    Display*			/* dpy */,
    int				/* fd */
);

extern Status XAddConnectionWatch(
    Display*			/* dpy */,
    XConnectionWatchProc	/* callback */,
    XPointer			/* client_data */
);

extern void XRemoveConnectionWatch(
    Display*			/* dpy */,
    XConnectionWatchProc	/* callback */,
    XPointer			/* client_data */
);

extern void XSetAuthorization(
    byte *			/* name */,
    int				/* namelen */,
    byte *			/* data */,
    int				/* datalen */
);

extern int _Xmbtowc(
    wchar *			/* wstr */,
    byte *			/* str */,
    int				/* len */
);

extern int _Xwctomb(
    byte *			/* str */,
    wchar			/* wc */
);


}
