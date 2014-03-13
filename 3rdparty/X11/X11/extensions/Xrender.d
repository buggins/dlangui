/*
 *
 * Copyright © 2000 SuSE, Inc.
 *
 * Permission to use, copy, modify, distribute, and sell this software and its
 * documentation for any purpose is hereby granted without fee, provided that
 * the above copyright notice appear in all copies and that both that
 * copyright notice and this permission notice appear in supporting
 * documentation, and that the name of SuSE not be used in advertising or
 * publicity pertaining to distribution of the software without specific,
 * written prior permission.  SuSE makes no representations about the
 * suitability of this software for any purpose.  It is provided "as is"
 * without express or implied warranty.
 *
 * SuSE DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING ALL
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT SHALL SuSE
 * BE LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION
 * OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
 * CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 * Author: Keith Packard, SuSE, Inc.
 * Author of this D binding: Adam Cigánek <adam.ciganek@gmail.com>
 */
module X11.extensions.Xrender;

pragma(lib, "Xrender");

import X11.Xlib;
// import X11.Xosdefs;
import X11.Xutil;

import X11.extensions.render;

struct XRenderDirectFormat {
  short red;
  short redMask;
  short green;
  short greenMask;
  short blue;
  short blueMask;
  short alpha;
  short alphaMask;
}

struct XRenderPictFormat {
  PictFormat           id;
  int                  type;
  int                  depth;
  XRenderDirectFormat  direct;
  Colormap             colormap;
}

enum {
  PictFormatID        = 1 << 0,
  PictFormatType      = 1 << 1,
  PictFormatDepth     = 1 << 2,
  PictFormatRed       = 1 << 3,
  PictFormatRedMask   = 1 << 4,
  PictFormatGreen     = 1 << 5,
  PictFormatGreenMask = 1 << 6,
  PictFormatBlue      = 1 << 7,
  PictFormatBlueMask  = 1 << 8,
  PictFormatAlpha     = 1 << 9,
  PictFormatAlphaMask = 1 << 10,
  PictFormatColormap  = 1 << 11}

struct XRenderPictureAttributes {
  int     repeat;
  Picture alpha_map;
  int     alpha_x_origin;
  int     alpha_y_origin;
  int     clip_x_origin;
  int     clip_y_origin;
  Pixmap  clip_mask;
  Bool    graphics_exposures;
  int     subwindow_mode;
  int     poly_edge;
  int     poly_mode;
  Atom    dither;
  Bool    component_alpha;
}

struct XRenderColor {
  ushort red;
  ushort green;
  ushort blue;
  ushort alpha;
}

struct XGlyphInfo {
  ushort width;
  ushort height;
  short  x;
  short  y;
  short  xOff;
  short  yOff;
}

struct XGlyphElt8 {
  GlyphSet    glyphset;
  const char* chars;
  int         nchars;
  int         xOff;
  int         yOff;
}

struct XGlyphElt16 {
  GlyphSet      glyphset;
  const ushort* chars;
  int           nchars;
  int           xOff;
  int           yOff;
}

struct XGlyphElt32 {
  GlyphSet    glyphset;
  const uint* chars;
  int         nchars;
  int         xOff;
  int         yOff;
}

alias double XDouble;

struct XPointDouble {
  XDouble x, y;
}

XFixed XDoubleToFixed(XDouble f) { return cast(XFixed) (f * 65536); }
XDouble XFixedToDouble(XFixed f) { return cast(XDouble) (f / 65536); }

alias int XFixed;

struct XPointFixed {
  XFixed x, y;
}

struct XLineFixed {
  XPointFixed  p1, p2;
}

struct XTriangle {
  XPointFixed  p1, p2, p3;
}

struct XCircle {
  XFixed x;
  XFixed y;
  XFixed radius;
}

struct XTrapezoid {
  XFixed     top, bottom;
  XLineFixed left, right;
}

struct XTransform {
  XFixed matrix[3][3];
}

struct XFilters {
  int    nfilter;
  char** filter;
  int    nalias;
  short* _alias; // [D-binding]: This was called alias, but that is a keyword in D.
}

struct XIndexValue {
  uint   pixel;
  ushort red, green, blue, alpha;
}

struct XAnimCursor {
  Cursor cursor;
  uint   delay;
}

struct XSpanFix {
  XFixed left, right, y;
}

struct XTrap {
  XSpanFix top, bottom;
}

struct XLinearGradient {
  XPointFixed p1;
  XPointFixed p2;
}

struct XRadialGradient {
  XCircle inner;
  XCircle outer;
}

struct XConicalGradient {
  XPointFixed center;
  XFixed      angle; // in degrees
}

extern(C) Bool XRenderQueryExtension(
  Display* dpy,
  int*     event_basep,
  int*     error_basep);

extern(C) Status XRenderQueryVersion(
  Display* dpy,
  int*     major_versionp,
  int*     minor_versionp);

extern(C) Status XRenderQueryFormats(
  Display* dpy);

extern(C) int XRenderQuerySubpixelOrder(
  Display* dpy,
  int      screen);

extern(C) Bool XRenderSetSubpixelOrder(
  Display* dpy,
  int      screen,
  int      subpixel);

extern(C) XRenderPictFormat* XRenderFindVisualFormat(
  Display*      dpy,
  const Visual* visual);

extern(C) XRenderPictFormat* XRenderFindFormat(
  Display*                 dpy,
  uint                     mask,
  const XRenderPictFormat* templ,
  int                      count);

enum {
  PictStandardARGB32 = 0,
  PictStandardRGB24  = 1,
  PictStandardA8     = 2,
  PictStandardA4     = 3,
  PictStandardA1     = 4,
  PictStandardNUM    = 5}

extern(C) XRenderPictFormat* XRenderFindStandardFormat(
  Display* dpy,
  int      format);

extern(C) XIndexValue* XRenderQueryPictIndexValues(
  Display*                 dpy,
  const XRenderPictFormat* format,
  int*                     num);

extern(C) Picture XRenderCreatePicture(
  Display*                        dpy,
  Drawable                        drawable,
  const XRenderPictFormat*        format,
  uint                            valuemask,
  const XRenderPictureAttributes* attributes);

extern(C) void XRenderChangePicture(
  Display* dpy,
  Picture  picture,
  uint     valuemask,
  const    XRenderPictureAttributes  *attributes);

extern(C) void XRenderSetPictureClipRectangles(
  Display*          dpy,
  Picture           picture,
  int               xOrigin,
  int               yOrigin,
  const XRectangle* rects,
  int               n);

extern(C) void XRenderSetPictureClipRegion(
  Display* dpy,
  Picture  picture,
  Region   r);

extern(C) void XRenderSetPictureTransform(
  Display*    dpy,
  Picture     picture,
  XTransform* transform);

extern(C) void XRenderFreePicture(Display* dpy,
        Picture                   picture);

extern(C) void XRenderComposite(Display* dpy,
      int      op,
      Picture   src,
      Picture   mask,
      Picture   dst,
      int      src_x,
      int      src_y,
      int      mask_x,
      int      mask_y,
      int      dst_x,
      int      dst_y,
      uint  width,
      uint  height);

extern(C) GlyphSet XRenderCreateGlyphSet(Display* dpy, const XRenderPictFormat *format);

extern(C) GlyphSet XRenderReferenceGlyphSet(Display* dpy, GlyphSet existing);

extern(C) void XRenderFreeGlyphSet(Display* dpy, GlyphSet glyphset);

extern(C) void XRenderAddGlyphs(Display* dpy,
      GlyphSet    glyphset,
      const Glyph    *gids,
      const XGlyphInfo  *glyphs,
      int      nglyphs,
      const char    *images,
      int      nbyte_images);

extern(C) void XRenderFreeGlyphs(Display* dpy,
       GlyphSet      glyphset,
       const Glyph    *gids,
       int        nglyphs);

extern(C) void XRenderCompositeString8(Display* dpy,
       int          op,
       Picture        src,
       Picture        dst,
       const XRenderPictFormat  *maskFormat,
       GlyphSet        glyphset,
       int          xSrc,
       int          ySrc,
       int          xDst,
       int          yDst,
       const char        *string,
       int          nchar);

extern(C) void XRenderCompositeString16(Display* dpy,
        int          op,
        Picture        src,
        Picture        dst,
        const XRenderPictFormat *maskFormat,
        GlyphSet        glyphset,
        int          xSrc,
        int          ySrc,
        int          xDst,
        int          yDst,
        const ushort    *string,
        int          nchar);

extern(C) void XRenderCompositeString32(Display* dpy,
        int          op,
        Picture        src,
        Picture        dst,
        const XRenderPictFormat *maskFormat,
        GlyphSet        glyphset,
        int          xSrc,
        int          ySrc,
        int          xDst,
        int          yDst,
        const uint      *string,
        int          nchar);

extern(C) void XRenderCompositeText8(Display* dpy,
           int          op,
           Picture          src,
           Picture          dst,
           const XRenderPictFormat    *maskFormat,
           int          xSrc,
           int          ySrc,
           int          xDst,
           int          yDst,
           const XGlyphElt8      *elts,
           int          nelt);

extern(C) void XRenderCompositeText16(Display* dpy,
      int          op,
      Picture          src,
      Picture          dst,
      const XRenderPictFormat   *maskFormat,
      int          xSrc,
      int          ySrc,
      int          xDst,
      int          yDst,
      const XGlyphElt16      *elts,
      int          nelt);

extern(C) void XRenderCompositeText32(Display* dpy,
      int          op,
      Picture          src,
      Picture          dst,
      const XRenderPictFormat   *maskFormat,
      int          xSrc,
      int          ySrc,
      int          xDst,
      int          yDst,
      const XGlyphElt32      *elts,
      int          nelt);

extern(C) void XRenderFillRectangle(Display* dpy,
          int        op,
          Picture        dst,
          const XRenderColor  *color,
          int        x,
          int        y,
          uint      width,
          uint      height);

extern(C) void XRenderFillRectangles(Display* dpy,
           int        op,
           Picture        dst,
           const XRenderColor *color,
           const XRectangle   *rectangles,
           int        n_rects);

extern(C) void XRenderCompositeTrapezoids(Display* dpy,
          int      op,
          Picture    src,
          Picture    dst,
          const XRenderPictFormat  *maskFormat,
          int      xSrc,
          int      ySrc,
          const XTrapezoid  *traps,
          int      ntrap);

extern(C) void XRenderCompositeTriangles(Display* dpy,
         int      op,
         Picture    src,
         Picture    dst,
          const XRenderPictFormat  *maskFormat,
         int      xSrc,
         int      ySrc,
         const XTriangle  *triangles,
         int      ntriangle);

extern(C) void XRenderCompositeTriStrip(Display* dpy,
        int      op,
        Picture    src,
        Picture    dst,
          const XRenderPictFormat  *maskFormat,
        int      xSrc,
        int      ySrc,
        const XPointFixed  *points,
        int      npoint);

extern(C) void XRenderCompositeTriFan(Display* dpy,
      int      op,
      Picture      src,
      Picture      dst,
      const XRenderPictFormat  *maskFormat,
      int      xSrc,
      int      ySrc,
      const XPointFixed  *points,
      int      npoint);

extern(C) void XRenderCompositeDoublePoly(Display* dpy,
          int          op,
          Picture        src,
          Picture        dst,
          const XRenderPictFormat  *maskFormat,
          int          xSrc,
          int          ySrc,
          int          xDst,
          int          yDst,
          const XPointDouble    *fpoints,
          int          npoints,
          int          winding);

extern(C) Status XRenderParseColor(Display* dpy,
      char    *spec,
      XRenderColor  *def);

extern(C) Cursor XRenderCreateCursor(Display* dpy,
         Picture      source,
         uint   x,
         uint   y);

extern(C) XFilters * XRenderQueryFilters(Display* dpy, Drawable drawable);

extern(C) void XRenderSetPictureFilter(Display* dpy,
       Picture    picture,
       const char *filter,
       XFixed      *params,
       int      nparams);

extern(C) Cursor XRenderCreateAnimCursor(Display* dpy,
       int    ncursor,
       XAnimCursor  *cursors);


extern(C) void XRenderAddTraps(Display* dpy,
     Picture      picture,
     int        xOff,
     int        yOff,
     const XTrap      *traps,
     int        ntrap);

extern(C) Picture XRenderCreateSolidFill(Display* dpy,
                                const XRenderColor *color);

extern(C) Picture XRenderCreateLinearGradient(Display* dpy,
                                     const XLinearGradient *gradient,
                                     const XFixed *stops,
                                     const XRenderColor *colors,
                                     int nstops);

extern(C) Picture XRenderCreateRadialGradient(Display* dpy,
                                     const XRadialGradient *gradient,
                                     const XFixed *stops,
                                     const XRenderColor *colors,
                                     int nstops);

extern(C) Picture XRenderCreateConicalGradient(Display* dpy,
                                      const XConicalGradient *gradient,
                                      const XFixed *stops,
                                      const XRenderColor *colors,
                                      int nstops);
