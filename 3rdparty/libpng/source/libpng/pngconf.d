module libpng.pngconf;
/* pngconf.h - machine configurable file for libpng
 *
 * libpng version 1.5.14 - January 24, 2013
 *
 * Copyright (c) 1998-2013 Glenn Randers-Pehrson
 * (Version 0.96 Copyright (c) 1996, 1997 Andreas Dilger)
 * (Version 0.88 Copyright (c) 1995, 1996 Guy Eric Schalnat, Group 42, Inc.)
 *
 * This code is released under the libpng license.
 * For conditions of distribution and use, see the disclaimer
 * and license in png.h
 *
 */

/* Any machine specific code is near the front of this file, so if you
 * are configuring libpng for a machine, you may want to read the section
 * starting here down to where it starts to typedef png_color, png_text,
 * and png_info.
 */


/* For png_FILE_p - this provides the standard definition of a
 * FILE
 */
import core.stdc.stdio : FILE;

public:

/* Some typedefs to get us started.  These should be safe on most of the
 * common platforms.  The typedefs should be at least as large as the
 * numbers suggest (a png_uint_32 must be at least 32 bits long), but they
 * don't have to be exactly that size.  Some compilers dislike passing
 * unsigned shorts as function parameters, so you may be better off using
 * unsigned int for png_uint_16.
 */

alias uint png_uint_32;
alias int png_int_32;
alias ushort png_uint_16;
alias short png_int_16;
alias ubyte png_byte;

alias size_t png_size_t;
//#define png_sizeof(x) (sizeof (x))

/* Typedef for floating-point numbers that are converted
 * to fixed-point with a multiple of 100,000, e.g., gamma
 */
alias png_int_32 png_fixed_point;

/* Add typedefs for pointers */
alias void                      * png_voidp;
alias const(void)               * png_const_voidp;
alias png_byte                  * png_bytep;
alias const(png_byte)           * png_const_bytep;
alias png_uint_32               * png_uint_32p;
alias const(png_uint_32)        * png_const_uint_32p;
alias png_int_32                * png_int_32p;
alias const(png_int_32)         * png_const_int_32p;
alias png_uint_16               * png_uint_16p;
alias const(png_uint_16)        * png_const_uint_16p;
alias png_int_16                * png_int_16p;
alias const(png_int_16)         * png_const_int_16p;
alias char                      * png_charp;
alias const(char)               * png_const_charp;
alias png_fixed_point           * png_fixed_point_p;
alias const(png_fixed_point)    * png_const_fixed_point_p;
alias png_size_t                * png_size_tp;
alias const(png_size_t)      * png_const_size_tp;

alias FILE            * png_FILE_p;

alias double           * png_doublep;
alias const(double)    * png_const_doublep;

/* Pointers to pointers; i.e. arrays */
alias png_byte        * * png_bytepp;
alias png_uint_32     * * png_uint_32pp;
alias png_int_32      * * png_int_32pp;
alias png_uint_16     * * png_uint_16pp;
alias png_int_16      * * png_int_16pp;
alias const(char)     * * png_const_charpp;
alias char            * * png_charpp;
alias png_fixed_point * * png_fixed_point_pp;
alias double          * * png_doublepp;

/* Pointers to pointers to pointers; i.e., pointer to array */
alias char            * * * png_charppp;

/* png_alloc_size_t is guaranteed to be no smaller than png_size_t,
 * and no smaller than png_uint_32.  Casts from png_size_t or png_uint_32
 * to png_alloc_size_t are not necessary; in fact, it is recommended
 * not to use them at all so that the compiler can complain when something
 * turns out to be problematic.
 * Casts in the other direction (from png_alloc_size_t to png_size_t or
 * png_uint_32) should be explicitly applied; however, we do not expect
 * to encounter practical situations that require such conversions.
 */
alias png_size_t    png_alloc_size_t;
