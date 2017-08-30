// Manually created
module std.c.linux.X11.xcb.image;
version(USE_XCB):

import std.c.linux.X11.xcb.xcb;
import std.c.linux.X11.xcb.shm;
import std.c.linux.X11.xcb.xproto;
import std.c.stdlib;
import std.conv;

struct xcb_image_t
{
	ushort           width;
	ushort           height;
	xcb_image_format_t format;
	ubyte            scanline_pad;
	ubyte            depth;
	ubyte            bpp;
	ubyte          unit;
	uint           plane_mask;
	xcb_image_order_t  byte_order;
	xcb_image_order_t  bit_order;
	uint           stride;
	uint           size;
	void *             base;
	ubyte *          data;
}

xcb_format_t *
find_format_by_depth (xcb_setup_t *setup, ubyte depth)
{
  xcb_format_t *fmt = xcb_setup_pixmap_formats(setup);
  xcb_format_t *fmtend = fmt + xcb_setup_pixmap_formats_length(setup);
  for(; fmt != fmtend; ++fmt)
      if(fmt.depth == depth)
	  return fmt;
  return null;
}


xcb_image_format_t
effective_format(xcb_image_format_t format, ubyte bpp)
{
    if (format == XCB_IMAGE_FORMAT_Z_PIXMAP && bpp != 1)
	    return format;
    return XCB_IMAGE_FORMAT_XY_PIXMAP;
}


int
format_valid (ubyte depth, ubyte bpp, ubyte unit,
	      xcb_image_format_t format, ubyte xpad)
{
  xcb_image_format_t  ef = effective_format(format, bpp);
  if (depth > bpp)
      return 0;
  switch(ef) {
  case XCB_IMAGE_FORMAT_XY_PIXMAP:
      switch(unit) {
      case 8:
      case 16:
      case 32:
	  break;
      default:
	  return 0;
      }
      if (xpad < bpp)
	  return 0;
      switch (xpad) {
      case 8:
      case 16:
      case 32:
	  break;
      default:
	  return 0;
      }
      break;
  case XCB_IMAGE_FORMAT_Z_PIXMAP:
      switch (bpp) {
      case 4:
	  if (unit != 8)
	      return 0;
	  break;
      case 8:
      case 16:
      case 24:
      case 32:
	  if (unit != bpp)
	      return 0;
	  break;
      default:
	  return 0;
      }
      break;
  default:
      return 0;
  }
  return 1;
}


int
image_format_valid (xcb_image_t *image) {
    return format_valid(image.depth,
			image.bpp,
			image.unit,
			image.format,
			image.scanline_pad);
}

uint xcb_roundup(uint  	base,
		uint	pad
)
{
    uint b = base + pad - 1;
    /* faster if pad is a power of two */
    if (((pad - 1) & pad) == 0)
       return b & -pad;
    return b - b % pad;
}

void
xcb_image_annotate (xcb_image_t *image)
{
  xcb_image_format_t  ef = effective_format(image.format, image.bpp);
  switch (ef) {
  case XCB_IMAGE_FORMAT_XY_PIXMAP:
      image.stride = xcb_roundup(image.width, image.scanline_pad) >> 3;
      image.size = image.height * image.stride * image.depth;
      break;
  case XCB_IMAGE_FORMAT_Z_PIXMAP:
      image.stride = xcb_roundup(cast(uint)image.width *
				  cast(uint)image.bpp,
				  image.scanline_pad) >> 3;
      image.size = image.height * image.stride;
      break;
  default:
      assert(0);
  }
}

xcb_image_t *
xcb_image_create_native (xcb_connection_t *  c,
			 ushort            width,
			 ushort            height,
			 xcb_image_format_t  format,
			 ubyte             depth,
			 void *              base,
			 uint            bytes,
			 ubyte *           data)
{
  xcb_setup_t *  setup = xcb_get_setup(c);
  xcb_format_t *       fmt;
  xcb_image_format_t   ef = format;

  if (ef == XCB_IMAGE_FORMAT_Z_PIXMAP && depth == 1)
      ef = XCB_IMAGE_FORMAT_XY_PIXMAP;
  switch (ef) {
  case XCB_IMAGE_FORMAT_XY_BITMAP:
      if (depth != 1)
	  return null;
      /* fall through */
        goto case;
  case XCB_IMAGE_FORMAT_XY_PIXMAP:
      if (depth > 1) {
	  fmt = find_format_by_depth(setup, depth);
	  if (!fmt)
	      return null;
      }
      return xcb_image_create(width, height, format,
			      setup.bitmap_format_scanline_pad,
			      depth, depth, setup.bitmap_format_scanline_unit,
			      setup.image_byte_order,
			      setup.bitmap_format_bit_order,
			      base, bytes, data);
  case XCB_IMAGE_FORMAT_Z_PIXMAP:
      fmt = find_format_by_depth(setup, depth);
      if (!fmt)
	  		return null;
      return xcb_image_create(width, height, format,
			      fmt.scanline_pad,
			      fmt.depth, fmt.bits_per_pixel, 0,
			      setup.image_byte_order,
			      XCB_IMAGE_ORDER_MSB_FIRST,
			      base, bytes, data);
  default:
      assert(0);
  }
  assert(0);
}

uint xcb_mask(uint n)
{
    return n == 32 ? ~0 : (1 << n) - 1;
}

xcb_image_t *
xcb_image_create (ushort           width,
		  ushort           height,
		  xcb_image_format_t format,
		  ubyte            xpad,
		  ubyte            depth,
		  ubyte            bpp,
		  ubyte            unit,
		  xcb_image_order_t  byte_order,
		  xcb_image_order_t  bit_order,
		  void *             base,
		  uint           bytes,
		  ubyte *          data)
{
  xcb_image_t *  image;

  if (unit == 0) {
      switch (format) {
	      case XCB_IMAGE_FORMAT_XY_BITMAP:
	      case XCB_IMAGE_FORMAT_XY_PIXMAP:
			  unit = 32;
			  break;
	      case XCB_IMAGE_FORMAT_Z_PIXMAP:
			  if (bpp == 1) {
			      unit = 32;
			      break;
			  }
			  if (bpp < 8) {
			      unit = 8;
			      break;
			  }
			  unit = bpp;
			  break;
		default:
			break;

      }
  }
  if (!format_valid(depth, bpp, unit, format, xpad))
      return null;
  import std.c.stdlib;
  image = cast(xcb_image_t*)malloc(xcb_image_t.sizeof);
  if (image is null)
      return null;
  image.width = width;
  image.height = height;
  image.format = format;
  image.scanline_pad = xpad;
  image.depth = depth;
  image.bpp = bpp;
  image.unit = unit;
  image.plane_mask = xcb_mask(depth);
  image.byte_order = byte_order;
  image.bit_order = bit_order;
  xcb_image_annotate(image);

  /*
   * Ways this function can be called:
   *   * with data: we fail if bytes isn't
   *     large enough, else leave well enough alone.
   *   * with base and !data: if bytes is zero, we
   *     default; otherwise we fail if bytes isn't
   *     large enough, else fill in data
   *   * with !base and !data: we malloc storage
   *     for the data, save that address as the base,
   *     and fail if malloc does.
   *
   * When successful, we establish the invariant that data
   * points at sufficient storage that may have been
   * supplied, and base is set iff it should be
   * auto-freed when the image is destroyed.
   *
   * Except as a special case when base = 0 && data == 0 &&
   * bytes == ~0 we just return the image structure and let
   * the caller deal with getting the allocation right.
   */
  if (!base && !data && bytes == ~0) {
      image.base = null;
      image.data = null;
      return image;
  }
  if (!base && data && bytes == 0)
      bytes = image.size;
  image.base = base;
  image.data = data;
  if (!image.data) {
      if (image.base) {
  	  	  image.data = cast(ubyte*)image.base;
      } else {
		  bytes = image.size;
		  image.base = malloc(bytes);
		  image.data = cast(ubyte*)image.base;
      }
  }
  if (!image.data || bytes < image.size) {
      free(image);
      return null;
  }
  return image;
}


void
xcb_image_destroy (xcb_image_t *image)
{
  if (image.base)
      free (image.base);
  free (image);
}

ubyte
xcb_aux_get_depth(xcb_connection_t *c,
                   xcb_screen_t     *screen)
{
  xcb_drawable_t            drawable;
  xcb_get_geometry_reply_t *geom;
  ubyte                       depth;

  drawable = screen.root;
  geom = xcb_get_geometry_reply (c, xcb_get_geometry(c, drawable), null);

  if (!geom) {
	  //Log.e("GetGeometry(root) failed");
    	exit (0);
  }

  depth = geom.depth;
  free (geom);

  return depth;
}

extern (C) int xcb_image_shm_get(xcb_connection_t * conn,
	       xcb_drawable_t          draw,
	       xcb_image_t *           image,
	       xcb_shm_segment_info_t  shminfo,
	       ushort                 x,
	       ushort                 y,
	       uint                plane_mask);
const XCB_ALL_PLANES = ~0;

extern (C) xcb_image_t *
xcb_image_shm_put (xcb_connection_t *      conn,
		   xcb_drawable_t          draw,
		   xcb_gcontext_t          gc,
		   xcb_image_t *           image,
		   xcb_shm_segment_info_t  shminfo,
		   short                 src_x,
		   short                 src_y,
		   short                 dest_x,
		   short                 dest_y,
		   ushort                src_width,
		   ushort                src_height,
		   ubyte                 send_event);

/**
 * @struct xcb_shm_segment_info_t
 * A structure that stores the informations needed by the MIT Shm
 * Extension.
 */
struct xcb_shm_segment_info_t
{
  xcb_shm_seg_t shmseg;
  uint    shmid;
  ubyte   *shmaddr;
}

alias int key_t;
extern (C) int shmget(key_t key, size_t size, int shmflg);
extern (C) int getpagesize();
extern (C) ubyte *shmat(int shmid, ubyte *shmaddr, int shmflg);
extern (C) int shmctl(int shmid, int cmd, void *buf);
const IPC_CREAT = octal!1000;
const IPC_PRIVATE = (cast(key_t) 0);
const IPC_RMID = 0;
