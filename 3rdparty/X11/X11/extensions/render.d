/*
 * $XFree86: xc/include/extensions/render.h,v 1.10 2002/11/06 22:47:49 keithp Exp $
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
 * Author:  Keith Packard, SuSE, Inc.
 * Author of this D binding: Adam Cigánek <adam.ciganek@gmail.com>
 */
module X11.extensions.render;

import X11.X;

alias XID Glyph;
alias XID GlyphSet;
alias XID Picture;
alias XID PictFormat;

const RENDER_NAME  = "RENDER";
const RENDER_MAJOR = 0;
const RENDER_MINOR = 11;

enum {
  X_RenderQueryVersion             = 0,
  X_RenderQueryPictFormats         = 1,
  X_RenderQueryPictIndexValues     = 2,  // 0.7
  X_RenderQueryDithers             = 3,
  X_RenderCreatePicture            = 4,
  X_RenderChangePicture            = 5,
  X_RenderSetPictureClipRectangles = 6,
  X_RenderFreePicture              = 7,
  X_RenderComposite                = 8,
  X_RenderScale                    = 9,
  X_RenderTrapezoids               = 10,
  X_RenderTriangles                = 11,
  X_RenderTriStrip                 = 12,
  X_RenderTriFan                   = 13,
  X_RenderColorTrapezoids          = 14,
  X_RenderColorTriangles           = 15,
// X_RenderTransform                = 16,
  X_RenderCreateGlyphSet           = 17,
  X_RenderReferenceGlyphSet        = 18,
  X_RenderFreeGlyphSet             = 19,
  X_RenderAddGlyphs                = 20,
  X_RenderAddGlyphsFromPicture     = 21,
  X_RenderFreeGlyphs               = 22,
  X_RenderCompositeGlyphs8         = 23,
  X_RenderCompositeGlyphs16        = 24,
  X_RenderCompositeGlyphs32        = 25,
  X_RenderFillRectangles           = 26,
  // 0.5
  X_RenderCreateCursor             = 27,
  // 0.6
  X_RenderSetPictureTransform      = 28,
  X_RenderQueryFilters             = 29,
  X_RenderSetPictureFilter         = 30,
  // 0.8
  X_RenderCreateAnimCursor         = 31,
  // 0.9
  X_RenderAddTraps                 = 32,
  // 0.10
  X_RenderCreateSolidFill          = 33,
  X_RenderCreateLinearGradient     = 34,
  X_RenderCreateRadialGradient     = 35,
  X_RenderCreateConicalGradient    = 36,
  RenderNumberRequests             = X_RenderCreateConicalGradient + 1
}

enum {
  BadPictFormat                    = 0,
  BadPicture                       = 1,
  BadPictOp                        = 2,
  BadGlyphSet                      = 3,
  BadGlyph                         = 4,
  RenderNumberErrors               = BadGlyph + 1
}

enum {
  PictTypeIndexed                  = 0,
  PictTypeDirect                   = 1
}

enum {
  PictOpMinimum                    = 0,
  PictOpClear                      = 0,
  PictOpSrc                        = 1,
  PictOpDst                        = 2,
  PictOpOver                       = 3,
  PictOpOverReverse                = 4,
  PictOpIn                         = 5,
  PictOpInReverse                  = 6,
  PictOpOut                        = 7,
  PictOpOutReverse                 = 8,
  PictOpAtop                       = 9,
  PictOpAtopReverse                = 10,
  PictOpXor                        = 11,
  PictOpAdd                        = 12,
  PictOpSaturate                   = 13,
  PictOpMaximum                    = 13,

  /*
   * Operators only available in version 0.2
   */
  PictOpDisjointMinimum            = 0x10,
  PictOpDisjointClear              = 0x10,
  PictOpDisjointSrc                = 0x11,
  PictOpDisjointDst                = 0x12,
  PictOpDisjointOver               = 0x13,
  PictOpDisjointOverReverse        = 0x14,
  PictOpDisjointIn                 = 0x15,
  PictOpDisjointInReverse          = 0x16,
  PictOpDisjointOut                = 0x17,
  PictOpDisjointOutReverse         = 0x18,
  PictOpDisjointAtop               = 0x19,
  PictOpDisjointAtopReverse        = 0x1a,
  PictOpDisjointXor                = 0x1b,
  PictOpDisjointMaximum            = 0x1b,

  PictOpConjointMinimum            = 0x20,
  PictOpConjointClear              = 0x20,
  PictOpConjointSrc                = 0x21,
  PictOpConjointDst                = 0x22,
  PictOpConjointOver               = 0x23,
  PictOpConjointOverReverse        = 0x24,
  PictOpConjointIn                 = 0x25,
  PictOpConjointInReverse          = 0x26,
  PictOpConjointOut                = 0x27,
  PictOpConjointOutReverse         = 0x28,
  PictOpConjointAtop               = 0x29,
  PictOpConjointAtopReverse        = 0x2a,
  PictOpConjointXor                = 0x2b,
  PictOpConjointMaximum            = 0x2b,

  /*
   * Operators only available in version 0.11
   */
  PictOpBlendMinimum               = 0x30,
  PictOpMultiply                   = 0x30,
  PictOpScreen                     = 0x31,
  PictOpOverlay                    = 0x32,
  PictOpDarken                     = 0x33,
  PictOpLighten                    = 0x34,
  PictOpColorDodge                 = 0x35,
  PictOpColorBurn                  = 0x36,
  PictOpHardLight                  = 0x37,
  PictOpSoftLight                  = 0x38,
  PictOpDifference                 = 0x39,
  PictOpExclusion                  = 0x3a,
  PictOpHSLHue                     = 0x3b,
  PictOpHSLSaturation              = 0x3c,
  PictOpHSLColor                   = 0x3d,
  PictOpHSLLuminosity              = 0x3e,
  PictOpBlendMaximum               = 0x3e
}

enum {
  PolyEdgeSharp                    = 0,
  PolyEdgeSmooth                   = 1
}

enum {
  PolyModePrecise                  = 0,
  PolyModeImprecise                = 1
}

enum {
  CPRepeat                         = 1 << 0,
  CPAlphaMap                       = 1 << 1,
  CPAlphaXOrigin                   = 1 << 2,
  CPAlphaYOrigin                   = 1 << 3,
  CPClipXOrigin                    = 1 << 4,
  CPClipYOrigin                    = 1 << 5,
  CPClipMask                       = 1 << 6,
  CPGraphicsExposure               = 1 << 7,
  CPSubwindowMode                  = 1 << 8,
  CPPolyEdge                       = 1 << 9,
  CPPolyMode                       = 1 << 10,
  CPDither                         = 1 << 11,
  CPComponentAlpha                 = 1 << 12,
  CPLastBit                        = 12
}

enum {
  /* Filters included in 0.6 */
  FilterNearest                    = "nearest",
  FilterBilinear                   = "bilinear",
  /* Filters included in 0.10 */
  FilterConvolution                = "convolution",

  FilterFast                       = "fast",
  FilterGood                       = "good",
  FilterBest                       = "best"
}

enum FilterAliasNone               = -1;

enum {
  /* Subpixel orders included in 0.6 */
  SubPixelUnknown                  = 0,
  SubPixelHorizontalRGB            = 1,
  SubPixelHorizontalBGR            = 2,
  SubPixelVerticalRGB              = 3,
  SubPixelVerticalBGR              = 4,
  SubPixelNone                     = 5
}

enum {
  /* Extended repeat attributes included in 0.10 */
  RepeatNone                       = 0,
  RepeatNormal                     = 1,
  RepeatPad                        = 2,
  RepeatReflect                    = 3
}

