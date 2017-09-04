/*
 * This file generated automatically from render.xml by c-client.xsl using XSLT.
 * Edit at your peril.
 */

/**
 * @defgroup XCB_Render_API XCB Render API
 * @brief Render XCB Protocol Implementation.
 * @{
 **/


module std.c.linux.X11.xcb.render;
version(USE_XCB):

import std.c.linux.X11.xcb.xcb;
import std.c.linux.X11.xcb.xproto;

const int XCB_RENDER_MAJOR_VERSION =0;
const int XCB_RENDER_MINOR_VERSION =10;

extern(C) extern xcb_extension_t xcb_render_id;

enum :int{
    XCB_RENDER_PICT_TYPE_INDEXED,
    XCB_RENDER_PICT_TYPE_DIRECT
};

enum :int{
    XCB_RENDER_PICT_OP_CLEAR,
    XCB_RENDER_PICT_OP_SRC,
    XCB_RENDER_PICT_OP_DST,
    XCB_RENDER_PICT_OP_OVER,
    XCB_RENDER_PICT_OP_OVER_REVERSE,
    XCB_RENDER_PICT_OP_IN,
    XCB_RENDER_PICT_OP_IN_REVERSE,
    XCB_RENDER_PICT_OP_OUT,
    XCB_RENDER_PICT_OP_OUT_REVERSE,
    XCB_RENDER_PICT_OP_ATOP,
    XCB_RENDER_PICT_OP_ATOP_REVERSE,
    XCB_RENDER_PICT_OP_XOR,
    XCB_RENDER_PICT_OP_ADD,
    XCB_RENDER_PICT_OP_SATURATE,
    XCB_RENDER_PICT_OP_DISJOINT_CLEAR = 0x10,
    XCB_RENDER_PICT_OP_DISJOINT_SRC,
    XCB_RENDER_PICT_OP_DISJOINT_DST,
    XCB_RENDER_PICT_OP_DISJOINT_OVER,
    XCB_RENDER_PICT_OP_DISJOINT_OVER_REVERSE,
    XCB_RENDER_PICT_OP_DISJOINT_IN,
    XCB_RENDER_PICT_OP_DISJOINT_IN_REVERSE,
    XCB_RENDER_PICT_OP_DISJOINT_OUT,
    XCB_RENDER_PICT_OP_DISJOINT_OUT_REVERSE,
    XCB_RENDER_PICT_OP_DISJOINT_ATOP,
    XCB_RENDER_PICT_OP_DISJOINT_ATOP_REVERSE,
    XCB_RENDER_PICT_OP_DISJOINT_XOR,
    XCB_RENDER_PICT_OP_CONJOINT_CLEAR = 0x20,
    XCB_RENDER_PICT_OP_CONJOINT_SRC,
    XCB_RENDER_PICT_OP_CONJOINT_DST,
    XCB_RENDER_PICT_OP_CONJOINT_OVER,
    XCB_RENDER_PICT_OP_CONJOINT_OVER_REVERSE,
    XCB_RENDER_PICT_OP_CONJOINT_IN,
    XCB_RENDER_PICT_OP_CONJOINT_IN_REVERSE,
    XCB_RENDER_PICT_OP_CONJOINT_OUT,
    XCB_RENDER_PICT_OP_CONJOINT_OUT_REVERSE,
    XCB_RENDER_PICT_OP_CONJOINT_ATOP,
    XCB_RENDER_PICT_OP_CONJOINT_ATOP_REVERSE,
    XCB_RENDER_PICT_OP_CONJOINT_XOR
};

enum :int{
    XCB_RENDER_POLY_EDGE_SHARP,
    XCB_RENDER_POLY_EDGE_SMOOTH
};

enum :int{
    XCB_RENDER_POLY_MODE_PRECISE,
    XCB_RENDER_POLY_MODE_IMPRECISE
};

enum :int{
    XCB_RENDER_CP_REPEAT = (1 << 0),
    XCB_RENDER_CP_ALPHA_MAP = (1 << 1),
    XCB_RENDER_CP_ALPHA_X_ORIGIN = (1 << 2),
    XCB_RENDER_CP_ALPHA_Y_ORIGIN = (1 << 3),
    XCB_RENDER_CP_CLIP_X_ORIGIN = (1 << 4),
    XCB_RENDER_CP_CLIP_Y_ORIGIN = (1 << 5),
    XCB_RENDER_CP_CLIP_MASK = (1 << 6),
    XCB_RENDER_CP_GRAPHICS_EXPOSURE = (1 << 7),
    XCB_RENDER_CP_SUBWINDOW_MODE = (1 << 8),
    XCB_RENDER_CP_POLY_EDGE = (1 << 9),
    XCB_RENDER_CP_POLY_MODE = (1 << 10),
    XCB_RENDER_CP_DITHER = (1 << 11),
    XCB_RENDER_CP_COMPONENT_ALPHA = (1 << 12)
};

enum :int{
    XCB_RENDER_SUB_PIXEL_UNKNOWN,
    XCB_RENDER_SUB_PIXEL_HORIZONTAL_RGB,
    XCB_RENDER_SUB_PIXEL_HORIZONTAL_BGR,
    XCB_RENDER_SUB_PIXEL_VERTICAL_RGB,
    XCB_RENDER_SUB_PIXEL_VERTICAL_BGR,
    XCB_RENDER_SUB_PIXEL_NONE
};

enum :int{
    XCB_RENDER_REPEAT_NONE,
    XCB_RENDER_REPEAT_NORMAL,
    XCB_RENDER_REPEAT_PAD,
    XCB_RENDER_REPEAT_REFLECT
};

alias uint xcb_render_glyph_t;

/**
 * @brief xcb_render_glyph_iterator_t
 **/
struct xcb_render_glyph_iterator_t {
    xcb_render_glyph_t *data; /**<  */
    int                 rem; /**<  */
    int                 index; /**<  */
} ;

alias uint xcb_render_glyphset_t;

/**
 * @brief xcb_render_glyphset_iterator_t
 **/
struct xcb_render_glyphset_iterator_t {
    xcb_render_glyphset_t *data; /**<  */
    int                    rem; /**<  */
    int                    index; /**<  */
} ;

alias uint xcb_render_picture_t;

/**
 * @brief xcb_render_picture_iterator_t
 **/
struct xcb_render_picture_iterator_t {
    xcb_render_picture_t *data; /**<  */
    int                   rem; /**<  */
    int                   index; /**<  */
} ;

alias uint xcb_render_pictformat_t;

/**
 * @brief xcb_render_pictformat_iterator_t
 **/
struct xcb_render_pictformat_iterator_t {
    xcb_render_pictformat_t *data; /**<  */
    int                      rem; /**<  */
    int                      index; /**<  */
} ;

alias int xcb_render_fixed_t;

/**
 * @brief xcb_render_fixed_iterator_t
 **/
struct xcb_render_fixed_iterator_t {
    xcb_render_fixed_t *data; /**<  */
    int                 rem; /**<  */
    int                 index; /**<  */
} ;

/** Opcode for xcb_render_pict_format. */
const uint XCB_RENDER_PICT_FORMAT = 0;

/**
 * @brief xcb_render_pict_format_error_t
 **/
struct xcb_render_pict_format_error_t {
    ubyte  response_type; /**<  */
    ubyte  error_code; /**<  */
    ushort sequence; /**<  */
} ;

/** Opcode for xcb_render_picture. */
const uint XCB_RENDER_PICTURE = 1;

/**
 * @brief xcb_render_picture_error_t
 **/
struct xcb_render_picture_error_t {
    ubyte  response_type; /**<  */
    ubyte  error_code; /**<  */
    ushort sequence; /**<  */
} ;

/** Opcode for xcb_render_pict_op. */
const uint XCB_RENDER_PICT_OP = 2;

/**
 * @brief xcb_render_pict_op_error_t
 **/
struct xcb_render_pict_op_error_t {
    ubyte  response_type; /**<  */
    ubyte  error_code; /**<  */
    ushort sequence; /**<  */
} ;

/** Opcode for xcb_render_glyph_set. */
const uint XCB_RENDER_GLYPH_SET = 3;

/**
 * @brief xcb_render_glyph_set_error_t
 **/
struct xcb_render_glyph_set_error_t {
    ubyte  response_type; /**<  */
    ubyte  error_code; /**<  */
    ushort sequence; /**<  */
} ;

/** Opcode for xcb_render_glyph. */
const uint XCB_RENDER_GLYPH = 4;

/**
 * @brief xcb_render_glyph_error_t
 **/
struct xcb_render_glyph_error_t {
    ubyte  response_type; /**<  */
    ubyte  error_code; /**<  */
    ushort sequence; /**<  */
} ;

/**
 * @brief xcb_render_directformat_t
 **/
struct xcb_render_directformat_t {
    ushort red_shift; /**<  */
    ushort red_mask; /**<  */
    ushort green_shift; /**<  */
    ushort green_mask; /**<  */
    ushort blue_shift; /**<  */
    ushort blue_mask; /**<  */
    ushort alpha_shift; /**<  */
    ushort alpha_mask; /**<  */
} ;

/**
 * @brief xcb_render_directformat_iterator_t
 **/
struct xcb_render_directformat_iterator_t {
    xcb_render_directformat_t *data; /**<  */
    int                        rem; /**<  */
    int                        index; /**<  */
} ;

/**
 * @brief xcb_render_pictforminfo_t
 **/
struct xcb_render_pictforminfo_t {
    xcb_render_pictformat_t   id; /**<  */
    ubyte                     type; /**<  */
    ubyte                     depth; /**<  */
    ubyte                     pad0[2]; /**<  */
    xcb_render_directformat_t direct; /**<  */
    xcb_colormap_t            colormap; /**<  */
} ;

/**
 * @brief xcb_render_pictforminfo_iterator_t
 **/
struct xcb_render_pictforminfo_iterator_t {
    xcb_render_pictforminfo_t *data; /**<  */
    int                        rem; /**<  */
    int                        index; /**<  */
} ;

/**
 * @brief xcb_render_pictvisual_t
 **/
struct xcb_render_pictvisual_t {
    xcb_visualid_t          visual; /**<  */
    xcb_render_pictformat_t format; /**<  */
} ;

/**
 * @brief xcb_render_pictvisual_iterator_t
 **/
struct xcb_render_pictvisual_iterator_t {
    xcb_render_pictvisual_t *data; /**<  */
    int                      rem; /**<  */
    int                      index; /**<  */
} ;

/**
 * @brief xcb_render_pictdepth_t
 **/
struct xcb_render_pictdepth_t {
    ubyte  depth; /**<  */
    ubyte  pad0; /**<  */
    ushort num_visuals; /**<  */
    ubyte  pad1[4]; /**<  */
} ;

/**
 * @brief xcb_render_pictdepth_iterator_t
 **/
struct xcb_render_pictdepth_iterator_t {
    xcb_render_pictdepth_t *data; /**<  */
    int                     rem; /**<  */
    int                     index; /**<  */
} ;

/**
 * @brief xcb_render_pictscreen_t
 **/
struct xcb_render_pictscreen_t {
    uint                    num_depths; /**<  */
    xcb_render_pictformat_t fallback; /**<  */
} ;

/**
 * @brief xcb_render_pictscreen_iterator_t
 **/
struct xcb_render_pictscreen_iterator_t {
    xcb_render_pictscreen_t *data; /**<  */
    int                      rem; /**<  */
    int                      index; /**<  */
} ;

/**
 * @brief xcb_render_indexvalue_t
 **/
struct xcb_render_indexvalue_t {
    uint   pixel; /**<  */
    ushort red; /**<  */
    ushort green; /**<  */
    ushort blue; /**<  */
    ushort alpha; /**<  */
} ;

/**
 * @brief xcb_render_indexvalue_iterator_t
 **/
struct xcb_render_indexvalue_iterator_t {
    xcb_render_indexvalue_t *data; /**<  */
    int                      rem; /**<  */
    int                      index; /**<  */
} ;

/**
 * @brief xcb_render_color_t
 **/
struct xcb_render_color_t {
    ushort red; /**<  */
    ushort green; /**<  */
    ushort blue; /**<  */
    ushort alpha; /**<  */
} ;

/**
 * @brief xcb_render_color_iterator_t
 **/
struct xcb_render_color_iterator_t {
    xcb_render_color_t *data; /**<  */
    int                 rem; /**<  */
    int                 index; /**<  */
} ;

/**
 * @brief xcb_render_pointfix_t
 **/
struct xcb_render_pointfix_t {
    xcb_render_fixed_t x; /**<  */
    xcb_render_fixed_t y; /**<  */
} ;

/**
 * @brief xcb_render_pointfix_iterator_t
 **/
struct xcb_render_pointfix_iterator_t {
    xcb_render_pointfix_t *data; /**<  */
    int                    rem; /**<  */
    int                    index; /**<  */
} ;

/**
 * @brief xcb_render_linefix_t
 **/
struct xcb_render_linefix_t {
    xcb_render_pointfix_t p1; /**<  */
    xcb_render_pointfix_t p2; /**<  */
} ;

/**
 * @brief xcb_render_linefix_iterator_t
 **/
struct xcb_render_linefix_iterator_t {
    xcb_render_linefix_t *data; /**<  */
    int                   rem; /**<  */
    int                   index; /**<  */
} ;

/**
 * @brief xcb_render_triangle_t
 **/
struct xcb_render_triangle_t {
    xcb_render_pointfix_t p1; /**<  */
    xcb_render_pointfix_t p2; /**<  */
    xcb_render_pointfix_t p3; /**<  */
} ;

/**
 * @brief xcb_render_triangle_iterator_t
 **/
struct xcb_render_triangle_iterator_t {
    xcb_render_triangle_t *data; /**<  */
    int                    rem; /**<  */
    int                    index; /**<  */
} ;

/**
 * @brief xcb_render_trapezoid_t
 **/
struct xcb_render_trapezoid_t {
    xcb_render_fixed_t   top; /**<  */
    xcb_render_fixed_t   bottom; /**<  */
    xcb_render_linefix_t left; /**<  */
    xcb_render_linefix_t right; /**<  */
} ;

/**
 * @brief xcb_render_trapezoid_iterator_t
 **/
struct xcb_render_trapezoid_iterator_t {
    xcb_render_trapezoid_t *data; /**<  */
    int                     rem; /**<  */
    int                     index; /**<  */
} ;

/**
 * @brief xcb_render_glyphinfo_t
 **/
struct xcb_render_glyphinfo_t {
    ushort width; /**<  */
    ushort height; /**<  */
    short  x; /**<  */
    short  y; /**<  */
    short  x_off; /**<  */
    short  y_off; /**<  */
} ;

/**
 * @brief xcb_render_glyphinfo_iterator_t
 **/
struct xcb_render_glyphinfo_iterator_t {
    xcb_render_glyphinfo_t *data; /**<  */
    int                     rem; /**<  */
    int                     index; /**<  */
} ;

/**
 * @brief xcb_render_query_version_cookie_t
 **/
struct xcb_render_query_version_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_render_query_version. */
const uint XCB_RENDER_QUERY_VERSION = 0;

/**
 * @brief xcb_render_query_version_request_t
 **/
struct xcb_render_query_version_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
    uint   client_major_version; /**<  */
    uint   client_minor_version; /**<  */
} ;

/**
 * @brief xcb_render_query_version_reply_t
 **/
struct xcb_render_query_version_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    uint   major_version; /**<  */
    uint   minor_version; /**<  */
    ubyte  pad1[16]; /**<  */
} ;

/**
 * @brief xcb_render_query_pict_formats_cookie_t
 **/
struct xcb_render_query_pict_formats_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_render_query_pict_formats. */
const uint XCB_RENDER_QUERY_PICT_FORMATS = 1;

/**
 * @brief xcb_render_query_pict_formats_request_t
 **/
struct xcb_render_query_pict_formats_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
} ;

/**
 * @brief xcb_render_query_pict_formats_reply_t
 **/
struct xcb_render_query_pict_formats_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    uint   num_formats; /**<  */
    uint   num_screens; /**<  */
    uint   num_depths; /**<  */
    uint   num_visuals; /**<  */
    uint   num_subpixel; /**<  */
    ubyte  pad1[4]; /**<  */
} ;

/**
 * @brief xcb_render_query_pict_index_values_cookie_t
 **/
struct xcb_render_query_pict_index_values_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_render_query_pict_index_values. */
const uint XCB_RENDER_QUERY_PICT_INDEX_VALUES = 2;

/**
 * @brief xcb_render_query_pict_index_values_request_t
 **/
struct xcb_render_query_pict_index_values_request_t {
    ubyte                   major_opcode; /**<  */
    ubyte                   minor_opcode; /**<  */
    ushort                  length; /**<  */
    xcb_render_pictformat_t format; /**<  */
} ;

/**
 * @brief xcb_render_query_pict_index_values_reply_t
 **/
struct xcb_render_query_pict_index_values_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    uint   num_values; /**<  */
    ubyte  pad1[20]; /**<  */
} ;

/** Opcode for xcb_render_create_picture. */
const uint XCB_RENDER_CREATE_PICTURE = 4;

/**
 * @brief xcb_render_create_picture_request_t
 **/
struct xcb_render_create_picture_request_t {
    ubyte                   major_opcode; /**<  */
    ubyte                   minor_opcode; /**<  */
    ushort                  length; /**<  */
    xcb_render_picture_t    pid; /**<  */
    xcb_drawable_t          drawable; /**<  */
    xcb_render_pictformat_t format; /**<  */
    uint                    value_mask; /**<  */
} ;

/** Opcode for xcb_render_change_picture. */
const uint XCB_RENDER_CHANGE_PICTURE = 5;

/**
 * @brief xcb_render_change_picture_request_t
 **/
struct xcb_render_change_picture_request_t {
    ubyte                major_opcode; /**<  */
    ubyte                minor_opcode; /**<  */
    ushort               length; /**<  */
    xcb_render_picture_t picture; /**<  */
    uint                 value_mask; /**<  */
} ;

/** Opcode for xcb_render_set_picture_clip_rectangles. */
const uint XCB_RENDER_SET_PICTURE_CLIP_RECTANGLES = 6;

/**
 * @brief xcb_render_set_picture_clip_rectangles_request_t
 **/
struct xcb_render_set_picture_clip_rectangles_request_t {
    ubyte                major_opcode; /**<  */
    ubyte                minor_opcode; /**<  */
    ushort               length; /**<  */
    xcb_render_picture_t picture; /**<  */
    short                clip_x_origin; /**<  */
    short                clip_y_origin; /**<  */
} ;

/** Opcode for xcb_render_free_picture. */
const uint XCB_RENDER_FREE_PICTURE = 7;

/**
 * @brief xcb_render_free_picture_request_t
 **/
struct xcb_render_free_picture_request_t {
    ubyte                major_opcode; /**<  */
    ubyte                minor_opcode; /**<  */
    ushort               length; /**<  */
    xcb_render_picture_t picture; /**<  */
} ;

/** Opcode for xcb_render_composite. */
const uint XCB_RENDER_COMPOSITE = 8;

/**
 * @brief xcb_render_composite_request_t
 **/
struct xcb_render_composite_request_t {
    ubyte                major_opcode; /**<  */
    ubyte                minor_opcode; /**<  */
    ushort               length; /**<  */
    ubyte                op; /**<  */
    ubyte                pad0[3]; /**<  */
    xcb_render_picture_t src; /**<  */
    xcb_render_picture_t mask; /**<  */
    xcb_render_picture_t dst; /**<  */
    short                src_x; /**<  */
    short                src_y; /**<  */
    short                mask_x; /**<  */
    short                mask_y; /**<  */
    short                dst_x; /**<  */
    short                dst_y; /**<  */
    ushort               width; /**<  */
    ushort               height; /**<  */
} ;

/** Opcode for xcb_render_trapezoids. */
const uint XCB_RENDER_TRAPEZOIDS = 10;

/**
 * @brief xcb_render_trapezoids_request_t
 **/
struct xcb_render_trapezoids_request_t {
    ubyte                   major_opcode; /**<  */
    ubyte                   minor_opcode; /**<  */
    ushort                  length; /**<  */
    ubyte                   op; /**<  */
    ubyte                   pad0[3]; /**<  */
    xcb_render_picture_t    src; /**<  */
    xcb_render_picture_t    dst; /**<  */
    xcb_render_pictformat_t mask_format; /**<  */
    short                   src_x; /**<  */
    short                   src_y; /**<  */
} ;

/** Opcode for xcb_render_triangles. */
const uint XCB_RENDER_TRIANGLES = 11;

/**
 * @brief xcb_render_triangles_request_t
 **/
struct xcb_render_triangles_request_t {
    ubyte                   major_opcode; /**<  */
    ubyte                   minor_opcode; /**<  */
    ushort                  length; /**<  */
    ubyte                   op; /**<  */
    ubyte                   pad0[3]; /**<  */
    xcb_render_picture_t    src; /**<  */
    xcb_render_picture_t    dst; /**<  */
    xcb_render_pictformat_t mask_format; /**<  */
    short                   src_x; /**<  */
    short                   src_y; /**<  */
} ;

/** Opcode for xcb_render_tri_strip. */
const uint XCB_RENDER_TRI_STRIP = 12;

/**
 * @brief xcb_render_tri_strip_request_t
 **/
struct xcb_render_tri_strip_request_t {
    ubyte                   major_opcode; /**<  */
    ubyte                   minor_opcode; /**<  */
    ushort                  length; /**<  */
    ubyte                   op; /**<  */
    ubyte                   pad0[3]; /**<  */
    xcb_render_picture_t    src; /**<  */
    xcb_render_picture_t    dst; /**<  */
    xcb_render_pictformat_t mask_format; /**<  */
    short                   src_x; /**<  */
    short                   src_y; /**<  */
} ;

/** Opcode for xcb_render_tri_fan. */
const uint XCB_RENDER_TRI_FAN = 13;

/**
 * @brief xcb_render_tri_fan_request_t
 **/
struct xcb_render_tri_fan_request_t {
    ubyte                   major_opcode; /**<  */
    ubyte                   minor_opcode; /**<  */
    ushort                  length; /**<  */
    ubyte                   op; /**<  */
    ubyte                   pad0[3]; /**<  */
    xcb_render_picture_t    src; /**<  */
    xcb_render_picture_t    dst; /**<  */
    xcb_render_pictformat_t mask_format; /**<  */
    short                   src_x; /**<  */
    short                   src_y; /**<  */
} ;

/** Opcode for xcb_render_create_glyph_set. */
const uint XCB_RENDER_CREATE_GLYPH_SET = 17;

/**
 * @brief xcb_render_create_glyph_set_request_t
 **/
struct xcb_render_create_glyph_set_request_t {
    ubyte                   major_opcode; /**<  */
    ubyte                   minor_opcode; /**<  */
    ushort                  length; /**<  */
    xcb_render_glyphset_t   gsid; /**<  */
    xcb_render_pictformat_t format; /**<  */
} ;

/** Opcode for xcb_render_reference_glyph_set. */
const uint XCB_RENDER_REFERENCE_GLYPH_SET = 18;

/**
 * @brief xcb_render_reference_glyph_set_request_t
 **/
struct xcb_render_reference_glyph_set_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_render_glyphset_t gsid; /**<  */
    xcb_render_glyphset_t existing; /**<  */
} ;

/** Opcode for xcb_render_free_glyph_set. */
const uint XCB_RENDER_FREE_GLYPH_SET = 19;

/**
 * @brief xcb_render_free_glyph_set_request_t
 **/
struct xcb_render_free_glyph_set_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_render_glyphset_t glyphset; /**<  */
} ;

/** Opcode for xcb_render_add_glyphs. */
const uint XCB_RENDER_ADD_GLYPHS = 20;

/**
 * @brief xcb_render_add_glyphs_request_t
 **/
struct xcb_render_add_glyphs_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_render_glyphset_t glyphset; /**<  */
    uint                  glyphs_len; /**<  */
} ;

/** Opcode for xcb_render_free_glyphs. */
const uint XCB_RENDER_FREE_GLYPHS = 22;

/**
 * @brief xcb_render_free_glyphs_request_t
 **/
struct xcb_render_free_glyphs_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_render_glyphset_t glyphset; /**<  */
} ;

/** Opcode for xcb_render_composite_glyphs_8. */
const uint XCB_RENDER_COMPOSITE_GLYPHS_8 = 23;

/**
 * @brief xcb_render_composite_glyphs_8_request_t
 **/
struct xcb_render_composite_glyphs_8_request_t {
    ubyte                   major_opcode; /**<  */
    ubyte                   minor_opcode; /**<  */
    ushort                  length; /**<  */
    ubyte                   op; /**<  */
    ubyte                   pad0[3]; /**<  */
    xcb_render_picture_t    src; /**<  */
    xcb_render_picture_t    dst; /**<  */
    xcb_render_pictformat_t mask_format; /**<  */
    xcb_render_glyphset_t   glyphset; /**<  */
    short                   src_x; /**<  */
    short                   src_y; /**<  */
} ;

/** Opcode for xcb_render_composite_glyphs_16. */
const uint XCB_RENDER_COMPOSITE_GLYPHS_16 = 24;

/**
 * @brief xcb_render_composite_glyphs_16_request_t
 **/
struct xcb_render_composite_glyphs_16_request_t {
    ubyte                   major_opcode; /**<  */
    ubyte                   minor_opcode; /**<  */
    ushort                  length; /**<  */
    ubyte                   op; /**<  */
    ubyte                   pad0[3]; /**<  */
    xcb_render_picture_t    src; /**<  */
    xcb_render_picture_t    dst; /**<  */
    xcb_render_pictformat_t mask_format; /**<  */
    xcb_render_glyphset_t   glyphset; /**<  */
    short                   src_x; /**<  */
    short                   src_y; /**<  */
} ;

/** Opcode for xcb_render_composite_glyphs_32. */
const uint XCB_RENDER_COMPOSITE_GLYPHS_32 = 25;

/**
 * @brief xcb_render_composite_glyphs_32_request_t
 **/
struct xcb_render_composite_glyphs_32_request_t {
    ubyte                   major_opcode; /**<  */
    ubyte                   minor_opcode; /**<  */
    ushort                  length; /**<  */
    ubyte                   op; /**<  */
    ubyte                   pad0[3]; /**<  */
    xcb_render_picture_t    src; /**<  */
    xcb_render_picture_t    dst; /**<  */
    xcb_render_pictformat_t mask_format; /**<  */
    xcb_render_glyphset_t   glyphset; /**<  */
    short                   src_x; /**<  */
    short                   src_y; /**<  */
} ;

/** Opcode for xcb_render_fill_rectangles. */
const uint XCB_RENDER_FILL_RECTANGLES = 26;

/**
 * @brief xcb_render_fill_rectangles_request_t
 **/
struct xcb_render_fill_rectangles_request_t {
    ubyte                major_opcode; /**<  */
    ubyte                minor_opcode; /**<  */
    ushort               length; /**<  */
    ubyte                op; /**<  */
    ubyte                pad0[3]; /**<  */
    xcb_render_picture_t dst; /**<  */
    xcb_render_color_t   color; /**<  */
} ;

/** Opcode for xcb_render_create_cursor. */
const uint XCB_RENDER_CREATE_CURSOR = 27;

/**
 * @brief xcb_render_create_cursor_request_t
 **/
struct xcb_render_create_cursor_request_t {
    ubyte                major_opcode; /**<  */
    ubyte                minor_opcode; /**<  */
    ushort               length; /**<  */
    xcb_cursor_t         cid; /**<  */
    xcb_render_picture_t source; /**<  */
    ushort               x; /**<  */
    ushort               y; /**<  */
} ;

/**
 * @brief xcb_render_transform_t
 **/
struct xcb_render_transform_t {
    xcb_render_fixed_t matrix11; /**<  */
    xcb_render_fixed_t matrix12; /**<  */
    xcb_render_fixed_t matrix13; /**<  */
    xcb_render_fixed_t matrix21; /**<  */
    xcb_render_fixed_t matrix22; /**<  */
    xcb_render_fixed_t matrix23; /**<  */
    xcb_render_fixed_t matrix31; /**<  */
    xcb_render_fixed_t matrix32; /**<  */
    xcb_render_fixed_t matrix33; /**<  */
} ;

/**
 * @brief xcb_render_transform_iterator_t
 **/
struct xcb_render_transform_iterator_t {
    xcb_render_transform_t *data; /**<  */
    int                     rem; /**<  */
    int                     index; /**<  */
} ;

/** Opcode for xcb_render_set_picture_transform. */
const uint XCB_RENDER_SET_PICTURE_TRANSFORM = 28;

/**
 * @brief xcb_render_set_picture_transform_request_t
 **/
struct xcb_render_set_picture_transform_request_t {
    ubyte                  major_opcode; /**<  */
    ubyte                  minor_opcode; /**<  */
    ushort                 length; /**<  */
    xcb_render_picture_t   picture; /**<  */
    xcb_render_transform_t transform; /**<  */
} ;

/**
 * @brief xcb_render_query_filters_cookie_t
 **/
struct xcb_render_query_filters_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_render_query_filters. */
const uint XCB_RENDER_QUERY_FILTERS = 29;

/**
 * @brief xcb_render_query_filters_request_t
 **/
struct xcb_render_query_filters_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          minor_opcode; /**<  */
    ushort         length; /**<  */
    xcb_drawable_t drawable; /**<  */
} ;

/**
 * @brief xcb_render_query_filters_reply_t
 **/
struct xcb_render_query_filters_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    uint   num_aliases; /**<  */
    uint   num_filters; /**<  */
    ubyte  pad1[16]; /**<  */
} ;

/** Opcode for xcb_render_set_picture_filter. */
const uint XCB_RENDER_SET_PICTURE_FILTER = 30;

/**
 * @brief xcb_render_set_picture_filter_request_t
 **/
struct xcb_render_set_picture_filter_request_t {
    ubyte                major_opcode; /**<  */
    ubyte                minor_opcode; /**<  */
    ushort               length; /**<  */
    xcb_render_picture_t picture; /**<  */
    ushort               filter_len; /**<  */
} ;

/**
 * @brief xcb_render_animcursorelt_t
 **/
struct xcb_render_animcursorelt_t {
    xcb_cursor_t cursor; /**<  */
    uint         delay; /**<  */
} ;

/**
 * @brief xcb_render_animcursorelt_iterator_t
 **/
struct xcb_render_animcursorelt_iterator_t {
    xcb_render_animcursorelt_t *data; /**<  */
    int                         rem; /**<  */
    int                         index; /**<  */
} ;

/** Opcode for xcb_render_create_anim_cursor. */
const uint XCB_RENDER_CREATE_ANIM_CURSOR = 31;

/**
 * @brief xcb_render_create_anim_cursor_request_t
 **/
struct xcb_render_create_anim_cursor_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        minor_opcode; /**<  */
    ushort       length; /**<  */
    xcb_cursor_t cid; /**<  */
} ;

/**
 * @brief xcb_render_spanfix_t
 **/
struct xcb_render_spanfix_t {
    xcb_render_fixed_t l; /**<  */
    xcb_render_fixed_t r; /**<  */
    xcb_render_fixed_t y; /**<  */
} ;

/**
 * @brief xcb_render_spanfix_iterator_t
 **/
struct xcb_render_spanfix_iterator_t {
    xcb_render_spanfix_t *data; /**<  */
    int                   rem; /**<  */
    int                   index; /**<  */
} ;

/**
 * @brief xcb_render_trap_t
 **/
struct xcb_render_trap_t {
    xcb_render_spanfix_t top; /**<  */
    xcb_render_spanfix_t bot; /**<  */
} ;

/**
 * @brief xcb_render_trap_iterator_t
 **/
struct xcb_render_trap_iterator_t {
    xcb_render_trap_t *data; /**<  */
    int                rem; /**<  */
    int                index; /**<  */
} ;

/** Opcode for xcb_render_add_traps. */
const uint XCB_RENDER_ADD_TRAPS = 32;

/**
 * @brief xcb_render_add_traps_request_t
 **/
struct xcb_render_add_traps_request_t {
    ubyte                major_opcode; /**<  */
    ubyte                minor_opcode; /**<  */
    ushort               length; /**<  */
    xcb_render_picture_t picture; /**<  */
    short                x_off; /**<  */
    short                y_off; /**<  */
} ;

/** Opcode for xcb_render_create_solid_fill. */
const uint XCB_RENDER_CREATE_SOLID_FILL = 33;

/**
 * @brief xcb_render_create_solid_fill_request_t
 **/
struct xcb_render_create_solid_fill_request_t {
    ubyte                major_opcode; /**<  */
    ubyte                minor_opcode; /**<  */
    ushort               length; /**<  */
    xcb_render_picture_t picture; /**<  */
    xcb_render_color_t   color; /**<  */
} ;

/** Opcode for xcb_render_create_linear_gradient. */
const uint XCB_RENDER_CREATE_LINEAR_GRADIENT = 34;

/**
 * @brief xcb_render_create_linear_gradient_request_t
 **/
struct xcb_render_create_linear_gradient_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_render_picture_t  picture; /**<  */
    xcb_render_pointfix_t p1; /**<  */
    xcb_render_pointfix_t p2; /**<  */
    uint                  num_stops; /**<  */
} ;

/** Opcode for xcb_render_create_radial_gradient. */
const uint XCB_RENDER_CREATE_RADIAL_GRADIENT = 35;

/**
 * @brief xcb_render_create_radial_gradient_request_t
 **/
struct xcb_render_create_radial_gradient_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_render_picture_t  picture; /**<  */
    xcb_render_pointfix_t inner; /**<  */
    xcb_render_pointfix_t outer; /**<  */
    xcb_render_fixed_t    inner_radius; /**<  */
    xcb_render_fixed_t    outer_radius; /**<  */
    uint                  num_stops; /**<  */
} ;

/** Opcode for xcb_render_create_conical_gradient. */
const uint XCB_RENDER_CREATE_CONICAL_GRADIENT = 36;

/**
 * @brief xcb_render_create_conical_gradient_request_t
 **/
struct xcb_render_create_conical_gradient_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_render_picture_t  picture; /**<  */
    xcb_render_pointfix_t center; /**<  */
    xcb_render_fixed_t    angle; /**<  */
    uint                  num_stops; /**<  */
} ;


/*****************************************************************************
 **
 ** void xcb_render_glyph_next
 **
 ** @param xcb_render_glyph_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_render_glyph_next (xcb_render_glyph_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_render_glyph_end
 **
 ** @param xcb_render_glyph_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_render_glyph_end (xcb_render_glyph_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_render_glyphset_next
 **
 ** @param xcb_render_glyphset_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_render_glyphset_next (xcb_render_glyphset_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_render_glyphset_end
 **
 ** @param xcb_render_glyphset_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_render_glyphset_end (xcb_render_glyphset_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_render_picture_next
 **
 ** @param xcb_render_picture_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_render_picture_next (xcb_render_picture_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_render_picture_end
 **
 ** @param xcb_render_picture_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_render_picture_end (xcb_render_picture_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_render_pictformat_next
 **
 ** @param xcb_render_pictformat_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_render_pictformat_next (xcb_render_pictformat_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_render_pictformat_end
 **
 ** @param xcb_render_pictformat_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_render_pictformat_end (xcb_render_pictformat_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_render_fixed_next
 **
 ** @param xcb_render_fixed_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_render_fixed_next (xcb_render_fixed_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_render_fixed_end
 **
 ** @param xcb_render_fixed_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_render_fixed_end (xcb_render_fixed_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_render_directformat_next
 **
 ** @param xcb_render_directformat_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_render_directformat_next (xcb_render_directformat_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_render_directformat_end
 **
 ** @param xcb_render_directformat_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_render_directformat_end (xcb_render_directformat_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_render_pictforminfo_next
 **
 ** @param xcb_render_pictforminfo_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_render_pictforminfo_next (xcb_render_pictforminfo_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_render_pictforminfo_end
 **
 ** @param xcb_render_pictforminfo_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_render_pictforminfo_end (xcb_render_pictforminfo_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_render_pictvisual_next
 **
 ** @param xcb_render_pictvisual_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_render_pictvisual_next (xcb_render_pictvisual_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_render_pictvisual_end
 **
 ** @param xcb_render_pictvisual_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_render_pictvisual_end (xcb_render_pictvisual_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** xcb_render_pictvisual_t * xcb_render_pictdepth_visuals
 **
 ** @param /+const+/ xcb_render_pictdepth_t *R
 ** @returns xcb_render_pictvisual_t *
 **
 *****************************************************************************/

extern(C) xcb_render_pictvisual_t *
xcb_render_pictdepth_visuals (/+const+/ xcb_render_pictdepth_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_render_pictdepth_visuals_length
 **
 ** @param /+const+/ xcb_render_pictdepth_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_render_pictdepth_visuals_length (/+const+/ xcb_render_pictdepth_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_render_pictvisual_iterator_t xcb_render_pictdepth_visuals_iterator
 **
 ** @param /+const+/ xcb_render_pictdepth_t *R
 ** @returns xcb_render_pictvisual_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_render_pictvisual_iterator_t
xcb_render_pictdepth_visuals_iterator (/+const+/ xcb_render_pictdepth_t *R  /**< */);


/*****************************************************************************
 **
 ** void xcb_render_pictdepth_next
 **
 ** @param xcb_render_pictdepth_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_render_pictdepth_next (xcb_render_pictdepth_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_render_pictdepth_end
 **
 ** @param xcb_render_pictdepth_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_render_pictdepth_end (xcb_render_pictdepth_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** int xcb_render_pictscreen_depths_length
 **
 ** @param /+const+/ xcb_render_pictscreen_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_render_pictscreen_depths_length (/+const+/ xcb_render_pictscreen_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_render_pictdepth_iterator_t xcb_render_pictscreen_depths_iterator
 **
 ** @param /+const+/ xcb_render_pictscreen_t *R
 ** @returns xcb_render_pictdepth_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_render_pictdepth_iterator_t
xcb_render_pictscreen_depths_iterator (/+const+/ xcb_render_pictscreen_t *R  /**< */);


/*****************************************************************************
 **
 ** void xcb_render_pictscreen_next
 **
 ** @param xcb_render_pictscreen_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_render_pictscreen_next (xcb_render_pictscreen_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_render_pictscreen_end
 **
 ** @param xcb_render_pictscreen_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_render_pictscreen_end (xcb_render_pictscreen_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_render_indexvalue_next
 **
 ** @param xcb_render_indexvalue_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_render_indexvalue_next (xcb_render_indexvalue_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_render_indexvalue_end
 **
 ** @param xcb_render_indexvalue_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_render_indexvalue_end (xcb_render_indexvalue_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_render_color_next
 **
 ** @param xcb_render_color_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_render_color_next (xcb_render_color_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_render_color_end
 **
 ** @param xcb_render_color_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_render_color_end (xcb_render_color_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_render_pointfix_next
 **
 ** @param xcb_render_pointfix_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_render_pointfix_next (xcb_render_pointfix_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_render_pointfix_end
 **
 ** @param xcb_render_pointfix_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_render_pointfix_end (xcb_render_pointfix_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_render_linefix_next
 **
 ** @param xcb_render_linefix_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_render_linefix_next (xcb_render_linefix_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_render_linefix_end
 **
 ** @param xcb_render_linefix_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_render_linefix_end (xcb_render_linefix_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_render_triangle_next
 **
 ** @param xcb_render_triangle_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_render_triangle_next (xcb_render_triangle_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_render_triangle_end
 **
 ** @param xcb_render_triangle_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_render_triangle_end (xcb_render_triangle_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_render_trapezoid_next
 **
 ** @param xcb_render_trapezoid_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_render_trapezoid_next (xcb_render_trapezoid_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_render_trapezoid_end
 **
 ** @param xcb_render_trapezoid_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_render_trapezoid_end (xcb_render_trapezoid_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_render_glyphinfo_next
 **
 ** @param xcb_render_glyphinfo_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_render_glyphinfo_next (xcb_render_glyphinfo_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_render_glyphinfo_end
 **
 ** @param xcb_render_glyphinfo_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_render_glyphinfo_end (xcb_render_glyphinfo_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** xcb_render_query_version_cookie_t xcb_render_query_version
 **
 ** @param xcb_connection_t *c
 ** @param uint              client_major_version
 ** @param uint              client_minor_version
 ** @returns xcb_render_query_version_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_render_query_version_cookie_t
xcb_render_query_version (xcb_connection_t *c  /**< */,
                          uint              client_major_version  /**< */,
                          uint              client_minor_version  /**< */);


/*****************************************************************************
 **
 ** xcb_render_query_version_cookie_t xcb_render_query_version_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param uint              client_major_version
 ** @param uint              client_minor_version
 ** @returns xcb_render_query_version_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_render_query_version_cookie_t
xcb_render_query_version_unchecked (xcb_connection_t *c  /**< */,
                                    uint              client_major_version  /**< */,
                                    uint              client_minor_version  /**< */);


/*****************************************************************************
 **
 ** xcb_render_query_version_reply_t * xcb_render_query_version_reply
 **
 ** @param xcb_connection_t                   *c
 ** @param xcb_render_query_version_cookie_t   cookie
 ** @param xcb_generic_error_t               **e
 ** @returns xcb_render_query_version_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_render_query_version_reply_t *
xcb_render_query_version_reply (xcb_connection_t                   *c  /**< */,
                                xcb_render_query_version_cookie_t   cookie  /**< */,
                                xcb_generic_error_t               **e  /**< */);


/*****************************************************************************
 **
 ** xcb_render_query_pict_formats_cookie_t xcb_render_query_pict_formats
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_render_query_pict_formats_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_render_query_pict_formats_cookie_t
xcb_render_query_pict_formats (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_render_query_pict_formats_cookie_t xcb_render_query_pict_formats_unchecked
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_render_query_pict_formats_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_render_query_pict_formats_cookie_t
xcb_render_query_pict_formats_unchecked (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_render_pictforminfo_t * xcb_render_query_pict_formats_formats
 **
 ** @param /+const+/ xcb_render_query_pict_formats_reply_t *R
 ** @returns xcb_render_pictforminfo_t *
 **
 *****************************************************************************/

extern(C) xcb_render_pictforminfo_t *
xcb_render_query_pict_formats_formats (/+const+/ xcb_render_query_pict_formats_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_render_query_pict_formats_formats_length
 **
 ** @param /+const+/ xcb_render_query_pict_formats_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_render_query_pict_formats_formats_length (/+const+/ xcb_render_query_pict_formats_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_render_pictforminfo_iterator_t xcb_render_query_pict_formats_formats_iterator
 **
 ** @param /+const+/ xcb_render_query_pict_formats_reply_t *R
 ** @returns xcb_render_pictforminfo_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_render_pictforminfo_iterator_t
xcb_render_query_pict_formats_formats_iterator (/+const+/ xcb_render_query_pict_formats_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_render_query_pict_formats_screens_length
 **
 ** @param /+const+/ xcb_render_query_pict_formats_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_render_query_pict_formats_screens_length (/+const+/ xcb_render_query_pict_formats_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_render_pictscreen_iterator_t xcb_render_query_pict_formats_screens_iterator
 **
 ** @param /+const+/ xcb_render_query_pict_formats_reply_t *R
 ** @returns xcb_render_pictscreen_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_render_pictscreen_iterator_t
xcb_render_query_pict_formats_screens_iterator (/+const+/ xcb_render_query_pict_formats_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** uint * xcb_render_query_pict_formats_subpixels
 **
 ** @param /+const+/ xcb_render_query_pict_formats_reply_t *R
 ** @returns uint *
 **
 *****************************************************************************/

extern(C) uint *
xcb_render_query_pict_formats_subpixels (/+const+/ xcb_render_query_pict_formats_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_render_query_pict_formats_subpixels_length
 **
 ** @param /+const+/ xcb_render_query_pict_formats_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_render_query_pict_formats_subpixels_length (/+const+/ xcb_render_query_pict_formats_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_render_query_pict_formats_subpixels_end
 **
 ** @param /+const+/ xcb_render_query_pict_formats_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_render_query_pict_formats_subpixels_end (/+const+/ xcb_render_query_pict_formats_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_render_query_pict_formats_reply_t * xcb_render_query_pict_formats_reply
 **
 ** @param xcb_connection_t                        *c
 ** @param xcb_render_query_pict_formats_cookie_t   cookie
 ** @param xcb_generic_error_t                    **e
 ** @returns xcb_render_query_pict_formats_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_render_query_pict_formats_reply_t *
xcb_render_query_pict_formats_reply (xcb_connection_t                        *c  /**< */,
                                     xcb_render_query_pict_formats_cookie_t   cookie  /**< */,
                                     xcb_generic_error_t                    **e  /**< */);


/*****************************************************************************
 **
 ** xcb_render_query_pict_index_values_cookie_t xcb_render_query_pict_index_values
 **
 ** @param xcb_connection_t        *c
 ** @param xcb_render_pictformat_t  format
 ** @returns xcb_render_query_pict_index_values_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_render_query_pict_index_values_cookie_t
xcb_render_query_pict_index_values (xcb_connection_t        *c  /**< */,
                                    xcb_render_pictformat_t  format  /**< */);


/*****************************************************************************
 **
 ** xcb_render_query_pict_index_values_cookie_t xcb_render_query_pict_index_values_unchecked
 **
 ** @param xcb_connection_t        *c
 ** @param xcb_render_pictformat_t  format
 ** @returns xcb_render_query_pict_index_values_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_render_query_pict_index_values_cookie_t
xcb_render_query_pict_index_values_unchecked (xcb_connection_t        *c  /**< */,
                                              xcb_render_pictformat_t  format  /**< */);


/*****************************************************************************
 **
 ** xcb_render_indexvalue_t * xcb_render_query_pict_index_values_values
 **
 ** @param /+const+/ xcb_render_query_pict_index_values_reply_t *R
 ** @returns xcb_render_indexvalue_t *
 **
 *****************************************************************************/

extern(C) xcb_render_indexvalue_t *
xcb_render_query_pict_index_values_values (/+const+/ xcb_render_query_pict_index_values_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_render_query_pict_index_values_values_length
 **
 ** @param /+const+/ xcb_render_query_pict_index_values_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_render_query_pict_index_values_values_length (/+const+/ xcb_render_query_pict_index_values_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_render_indexvalue_iterator_t xcb_render_query_pict_index_values_values_iterator
 **
 ** @param /+const+/ xcb_render_query_pict_index_values_reply_t *R
 ** @returns xcb_render_indexvalue_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_render_indexvalue_iterator_t
xcb_render_query_pict_index_values_values_iterator (/+const+/ xcb_render_query_pict_index_values_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_render_query_pict_index_values_reply_t * xcb_render_query_pict_index_values_reply
 **
 ** @param xcb_connection_t                             *c
 ** @param xcb_render_query_pict_index_values_cookie_t   cookie
 ** @param xcb_generic_error_t                         **e
 ** @returns xcb_render_query_pict_index_values_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_render_query_pict_index_values_reply_t *
xcb_render_query_pict_index_values_reply (xcb_connection_t                             *c  /**< */,
                                          xcb_render_query_pict_index_values_cookie_t   cookie  /**< */,
                                          xcb_generic_error_t                         **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_create_picture_checked
 **
 ** @param xcb_connection_t        *c
 ** @param xcb_render_picture_t     pid
 ** @param xcb_drawable_t           drawable
 ** @param xcb_render_pictformat_t  format
 ** @param uint                     value_mask
 ** @param /+const+/ uint          *value_list
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_create_picture_checked (xcb_connection_t        *c  /**< */,
                                   xcb_render_picture_t     pid  /**< */,
                                   xcb_drawable_t           drawable  /**< */,
                                   xcb_render_pictformat_t  format  /**< */,
                                   uint                     value_mask  /**< */,
                                   /+const+/ uint          *value_list  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_create_picture
 **
 ** @param xcb_connection_t        *c
 ** @param xcb_render_picture_t     pid
 ** @param xcb_drawable_t           drawable
 ** @param xcb_render_pictformat_t  format
 ** @param uint                     value_mask
 ** @param /+const+/ uint          *value_list
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_create_picture (xcb_connection_t        *c  /**< */,
                           xcb_render_picture_t     pid  /**< */,
                           xcb_drawable_t           drawable  /**< */,
                           xcb_render_pictformat_t  format  /**< */,
                           uint                     value_mask  /**< */,
                           /+const+/ uint          *value_list  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_change_picture_checked
 **
 ** @param xcb_connection_t     *c
 ** @param xcb_render_picture_t  picture
 ** @param uint                  value_mask
 ** @param /+const+/ uint       *value_list
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_change_picture_checked (xcb_connection_t     *c  /**< */,
                                   xcb_render_picture_t  picture  /**< */,
                                   uint                  value_mask  /**< */,
                                   /+const+/ uint       *value_list  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_change_picture
 **
 ** @param xcb_connection_t     *c
 ** @param xcb_render_picture_t  picture
 ** @param uint                  value_mask
 ** @param /+const+/ uint       *value_list
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_change_picture (xcb_connection_t     *c  /**< */,
                           xcb_render_picture_t  picture  /**< */,
                           uint                  value_mask  /**< */,
                           /+const+/ uint       *value_list  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_set_picture_clip_rectangles_checked
 **
 ** @param xcb_connection_t          *c
 ** @param xcb_render_picture_t       picture
 ** @param short                      clip_x_origin
 ** @param short                      clip_y_origin
 ** @param uint                       rectangles_len
 ** @param /+const+/ xcb_rectangle_t *rectangles
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_set_picture_clip_rectangles_checked (xcb_connection_t          *c  /**< */,
                                                xcb_render_picture_t       picture  /**< */,
                                                short                      clip_x_origin  /**< */,
                                                short                      clip_y_origin  /**< */,
                                                uint                       rectangles_len  /**< */,
                                                /+const+/ xcb_rectangle_t *rectangles  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_set_picture_clip_rectangles
 **
 ** @param xcb_connection_t          *c
 ** @param xcb_render_picture_t       picture
 ** @param short                      clip_x_origin
 ** @param short                      clip_y_origin
 ** @param uint                       rectangles_len
 ** @param /+const+/ xcb_rectangle_t *rectangles
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_set_picture_clip_rectangles (xcb_connection_t          *c  /**< */,
                                        xcb_render_picture_t       picture  /**< */,
                                        short                      clip_x_origin  /**< */,
                                        short                      clip_y_origin  /**< */,
                                        uint                       rectangles_len  /**< */,
                                        /+const+/ xcb_rectangle_t *rectangles  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_free_picture_checked
 **
 ** @param xcb_connection_t     *c
 ** @param xcb_render_picture_t  picture
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_free_picture_checked (xcb_connection_t     *c  /**< */,
                                 xcb_render_picture_t  picture  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_free_picture
 **
 ** @param xcb_connection_t     *c
 ** @param xcb_render_picture_t  picture
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_free_picture (xcb_connection_t     *c  /**< */,
                         xcb_render_picture_t  picture  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_composite_checked
 **
 ** @param xcb_connection_t     *c
 ** @param ubyte                 op
 ** @param xcb_render_picture_t  src
 ** @param xcb_render_picture_t  mask
 ** @param xcb_render_picture_t  dst
 ** @param short                 src_x
 ** @param short                 src_y
 ** @param short                 mask_x
 ** @param short                 mask_y
 ** @param short                 dst_x
 ** @param short                 dst_y
 ** @param ushort                width
 ** @param ushort                height
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_composite_checked (xcb_connection_t     *c  /**< */,
                              ubyte                 op  /**< */,
                              xcb_render_picture_t  src  /**< */,
                              xcb_render_picture_t  mask  /**< */,
                              xcb_render_picture_t  dst  /**< */,
                              short                 src_x  /**< */,
                              short                 src_y  /**< */,
                              short                 mask_x  /**< */,
                              short                 mask_y  /**< */,
                              short                 dst_x  /**< */,
                              short                 dst_y  /**< */,
                              ushort                width  /**< */,
                              ushort                height  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_composite
 **
 ** @param xcb_connection_t     *c
 ** @param ubyte                 op
 ** @param xcb_render_picture_t  src
 ** @param xcb_render_picture_t  mask
 ** @param xcb_render_picture_t  dst
 ** @param short                 src_x
 ** @param short                 src_y
 ** @param short                 mask_x
 ** @param short                 mask_y
 ** @param short                 dst_x
 ** @param short                 dst_y
 ** @param ushort                width
 ** @param ushort                height
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_composite (xcb_connection_t     *c  /**< */,
                      ubyte                 op  /**< */,
                      xcb_render_picture_t  src  /**< */,
                      xcb_render_picture_t  mask  /**< */,
                      xcb_render_picture_t  dst  /**< */,
                      short                 src_x  /**< */,
                      short                 src_y  /**< */,
                      short                 mask_x  /**< */,
                      short                 mask_y  /**< */,
                      short                 dst_x  /**< */,
                      short                 dst_y  /**< */,
                      ushort                width  /**< */,
                      ushort                height  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_trapezoids_checked
 **
 ** @param xcb_connection_t                 *c
 ** @param ubyte                             op
 ** @param xcb_render_picture_t              src
 ** @param xcb_render_picture_t              dst
 ** @param xcb_render_pictformat_t           mask_format
 ** @param short                             src_x
 ** @param short                             src_y
 ** @param uint                              traps_len
 ** @param /+const+/ xcb_render_trapezoid_t *traps
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_trapezoids_checked (xcb_connection_t                 *c  /**< */,
                               ubyte                             op  /**< */,
                               xcb_render_picture_t              src  /**< */,
                               xcb_render_picture_t              dst  /**< */,
                               xcb_render_pictformat_t           mask_format  /**< */,
                               short                             src_x  /**< */,
                               short                             src_y  /**< */,
                               uint                              traps_len  /**< */,
                               /+const+/ xcb_render_trapezoid_t *traps  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_trapezoids
 **
 ** @param xcb_connection_t                 *c
 ** @param ubyte                             op
 ** @param xcb_render_picture_t              src
 ** @param xcb_render_picture_t              dst
 ** @param xcb_render_pictformat_t           mask_format
 ** @param short                             src_x
 ** @param short                             src_y
 ** @param uint                              traps_len
 ** @param /+const+/ xcb_render_trapezoid_t *traps
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_trapezoids (xcb_connection_t                 *c  /**< */,
                       ubyte                             op  /**< */,
                       xcb_render_picture_t              src  /**< */,
                       xcb_render_picture_t              dst  /**< */,
                       xcb_render_pictformat_t           mask_format  /**< */,
                       short                             src_x  /**< */,
                       short                             src_y  /**< */,
                       uint                              traps_len  /**< */,
                       /+const+/ xcb_render_trapezoid_t *traps  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_triangles_checked
 **
 ** @param xcb_connection_t                *c
 ** @param ubyte                            op
 ** @param xcb_render_picture_t             src
 ** @param xcb_render_picture_t             dst
 ** @param xcb_render_pictformat_t          mask_format
 ** @param short                            src_x
 ** @param short                            src_y
 ** @param uint                             triangles_len
 ** @param /+const+/ xcb_render_triangle_t *triangles
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_triangles_checked (xcb_connection_t                *c  /**< */,
                              ubyte                            op  /**< */,
                              xcb_render_picture_t             src  /**< */,
                              xcb_render_picture_t             dst  /**< */,
                              xcb_render_pictformat_t          mask_format  /**< */,
                              short                            src_x  /**< */,
                              short                            src_y  /**< */,
                              uint                             triangles_len  /**< */,
                              /+const+/ xcb_render_triangle_t *triangles  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_triangles
 **
 ** @param xcb_connection_t                *c
 ** @param ubyte                            op
 ** @param xcb_render_picture_t             src
 ** @param xcb_render_picture_t             dst
 ** @param xcb_render_pictformat_t          mask_format
 ** @param short                            src_x
 ** @param short                            src_y
 ** @param uint                             triangles_len
 ** @param /+const+/ xcb_render_triangle_t *triangles
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_triangles (xcb_connection_t                *c  /**< */,
                      ubyte                            op  /**< */,
                      xcb_render_picture_t             src  /**< */,
                      xcb_render_picture_t             dst  /**< */,
                      xcb_render_pictformat_t          mask_format  /**< */,
                      short                            src_x  /**< */,
                      short                            src_y  /**< */,
                      uint                             triangles_len  /**< */,
                      /+const+/ xcb_render_triangle_t *triangles  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_tri_strip_checked
 **
 ** @param xcb_connection_t                *c
 ** @param ubyte                            op
 ** @param xcb_render_picture_t             src
 ** @param xcb_render_picture_t             dst
 ** @param xcb_render_pictformat_t          mask_format
 ** @param short                            src_x
 ** @param short                            src_y
 ** @param uint                             points_len
 ** @param /+const+/ xcb_render_pointfix_t *points
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_tri_strip_checked (xcb_connection_t                *c  /**< */,
                              ubyte                            op  /**< */,
                              xcb_render_picture_t             src  /**< */,
                              xcb_render_picture_t             dst  /**< */,
                              xcb_render_pictformat_t          mask_format  /**< */,
                              short                            src_x  /**< */,
                              short                            src_y  /**< */,
                              uint                             points_len  /**< */,
                              /+const+/ xcb_render_pointfix_t *points  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_tri_strip
 **
 ** @param xcb_connection_t                *c
 ** @param ubyte                            op
 ** @param xcb_render_picture_t             src
 ** @param xcb_render_picture_t             dst
 ** @param xcb_render_pictformat_t          mask_format
 ** @param short                            src_x
 ** @param short                            src_y
 ** @param uint                             points_len
 ** @param /+const+/ xcb_render_pointfix_t *points
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_tri_strip (xcb_connection_t                *c  /**< */,
                      ubyte                            op  /**< */,
                      xcb_render_picture_t             src  /**< */,
                      xcb_render_picture_t             dst  /**< */,
                      xcb_render_pictformat_t          mask_format  /**< */,
                      short                            src_x  /**< */,
                      short                            src_y  /**< */,
                      uint                             points_len  /**< */,
                      /+const+/ xcb_render_pointfix_t *points  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_tri_fan_checked
 **
 ** @param xcb_connection_t                *c
 ** @param ubyte                            op
 ** @param xcb_render_picture_t             src
 ** @param xcb_render_picture_t             dst
 ** @param xcb_render_pictformat_t          mask_format
 ** @param short                            src_x
 ** @param short                            src_y
 ** @param uint                             points_len
 ** @param /+const+/ xcb_render_pointfix_t *points
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_tri_fan_checked (xcb_connection_t                *c  /**< */,
                            ubyte                            op  /**< */,
                            xcb_render_picture_t             src  /**< */,
                            xcb_render_picture_t             dst  /**< */,
                            xcb_render_pictformat_t          mask_format  /**< */,
                            short                            src_x  /**< */,
                            short                            src_y  /**< */,
                            uint                             points_len  /**< */,
                            /+const+/ xcb_render_pointfix_t *points  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_tri_fan
 **
 ** @param xcb_connection_t                *c
 ** @param ubyte                            op
 ** @param xcb_render_picture_t             src
 ** @param xcb_render_picture_t             dst
 ** @param xcb_render_pictformat_t          mask_format
 ** @param short                            src_x
 ** @param short                            src_y
 ** @param uint                             points_len
 ** @param /+const+/ xcb_render_pointfix_t *points
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_tri_fan (xcb_connection_t                *c  /**< */,
                    ubyte                            op  /**< */,
                    xcb_render_picture_t             src  /**< */,
                    xcb_render_picture_t             dst  /**< */,
                    xcb_render_pictformat_t          mask_format  /**< */,
                    short                            src_x  /**< */,
                    short                            src_y  /**< */,
                    uint                             points_len  /**< */,
                    /+const+/ xcb_render_pointfix_t *points  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_create_glyph_set_checked
 **
 ** @param xcb_connection_t        *c
 ** @param xcb_render_glyphset_t    gsid
 ** @param xcb_render_pictformat_t  format
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_create_glyph_set_checked (xcb_connection_t        *c  /**< */,
                                     xcb_render_glyphset_t    gsid  /**< */,
                                     xcb_render_pictformat_t  format  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_create_glyph_set
 **
 ** @param xcb_connection_t        *c
 ** @param xcb_render_glyphset_t    gsid
 ** @param xcb_render_pictformat_t  format
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_create_glyph_set (xcb_connection_t        *c  /**< */,
                             xcb_render_glyphset_t    gsid  /**< */,
                             xcb_render_pictformat_t  format  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_reference_glyph_set_checked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_render_glyphset_t  gsid
 ** @param xcb_render_glyphset_t  existing
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_reference_glyph_set_checked (xcb_connection_t      *c  /**< */,
                                        xcb_render_glyphset_t  gsid  /**< */,
                                        xcb_render_glyphset_t  existing  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_reference_glyph_set
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_render_glyphset_t  gsid
 ** @param xcb_render_glyphset_t  existing
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_reference_glyph_set (xcb_connection_t      *c  /**< */,
                                xcb_render_glyphset_t  gsid  /**< */,
                                xcb_render_glyphset_t  existing  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_free_glyph_set_checked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_render_glyphset_t  glyphset
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_free_glyph_set_checked (xcb_connection_t      *c  /**< */,
                                   xcb_render_glyphset_t  glyphset  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_free_glyph_set
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_render_glyphset_t  glyphset
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_free_glyph_set (xcb_connection_t      *c  /**< */,
                           xcb_render_glyphset_t  glyphset  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_add_glyphs_checked
 **
 ** @param xcb_connection_t                 *c
 ** @param xcb_render_glyphset_t             glyphset
 ** @param uint                              glyphs_len
 ** @param /+const+/ uint                   *glyphids
 ** @param /+const+/ xcb_render_glyphinfo_t *glyphs
 ** @param uint                              data_len
 ** @param /+const+/ ubyte                  *data
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_add_glyphs_checked (xcb_connection_t                 *c  /**< */,
                               xcb_render_glyphset_t             glyphset  /**< */,
                               uint                              glyphs_len  /**< */,
                               /+const+/ uint                   *glyphids  /**< */,
                               /+const+/ xcb_render_glyphinfo_t *glyphs  /**< */,
                               uint                              data_len  /**< */,
                               /+const+/ ubyte                  *data  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_add_glyphs
 **
 ** @param xcb_connection_t                 *c
 ** @param xcb_render_glyphset_t             glyphset
 ** @param uint                              glyphs_len
 ** @param /+const+/ uint                   *glyphids
 ** @param /+const+/ xcb_render_glyphinfo_t *glyphs
 ** @param uint                              data_len
 ** @param /+const+/ ubyte                  *data
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_add_glyphs (xcb_connection_t                 *c  /**< */,
                       xcb_render_glyphset_t             glyphset  /**< */,
                       uint                              glyphs_len  /**< */,
                       /+const+/ uint                   *glyphids  /**< */,
                       /+const+/ xcb_render_glyphinfo_t *glyphs  /**< */,
                       uint                              data_len  /**< */,
                       /+const+/ ubyte                  *data  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_free_glyphs_checked
 **
 ** @param xcb_connection_t             *c
 ** @param xcb_render_glyphset_t         glyphset
 ** @param uint                          glyphs_len
 ** @param /+const+/ xcb_render_glyph_t *glyphs
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_free_glyphs_checked (xcb_connection_t             *c  /**< */,
                                xcb_render_glyphset_t         glyphset  /**< */,
                                uint                          glyphs_len  /**< */,
                                /+const+/ xcb_render_glyph_t *glyphs  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_free_glyphs
 **
 ** @param xcb_connection_t             *c
 ** @param xcb_render_glyphset_t         glyphset
 ** @param uint                          glyphs_len
 ** @param /+const+/ xcb_render_glyph_t *glyphs
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_free_glyphs (xcb_connection_t             *c  /**< */,
                        xcb_render_glyphset_t         glyphset  /**< */,
                        uint                          glyphs_len  /**< */,
                        /+const+/ xcb_render_glyph_t *glyphs  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_composite_glyphs_8_checked
 **
 ** @param xcb_connection_t        *c
 ** @param ubyte                    op
 ** @param xcb_render_picture_t     src
 ** @param xcb_render_picture_t     dst
 ** @param xcb_render_pictformat_t  mask_format
 ** @param xcb_render_glyphset_t    glyphset
 ** @param short                    src_x
 ** @param short                    src_y
 ** @param uint                     glyphcmds_len
 ** @param /+const+/ ubyte         *glyphcmds
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_composite_glyphs_8_checked (xcb_connection_t        *c  /**< */,
                                       ubyte                    op  /**< */,
                                       xcb_render_picture_t     src  /**< */,
                                       xcb_render_picture_t     dst  /**< */,
                                       xcb_render_pictformat_t  mask_format  /**< */,
                                       xcb_render_glyphset_t    glyphset  /**< */,
                                       short                    src_x  /**< */,
                                       short                    src_y  /**< */,
                                       uint                     glyphcmds_len  /**< */,
                                       /+const+/ ubyte         *glyphcmds  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_composite_glyphs_8
 **
 ** @param xcb_connection_t        *c
 ** @param ubyte                    op
 ** @param xcb_render_picture_t     src
 ** @param xcb_render_picture_t     dst
 ** @param xcb_render_pictformat_t  mask_format
 ** @param xcb_render_glyphset_t    glyphset
 ** @param short                    src_x
 ** @param short                    src_y
 ** @param uint                     glyphcmds_len
 ** @param /+const+/ ubyte         *glyphcmds
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_composite_glyphs_8 (xcb_connection_t        *c  /**< */,
                               ubyte                    op  /**< */,
                               xcb_render_picture_t     src  /**< */,
                               xcb_render_picture_t     dst  /**< */,
                               xcb_render_pictformat_t  mask_format  /**< */,
                               xcb_render_glyphset_t    glyphset  /**< */,
                               short                    src_x  /**< */,
                               short                    src_y  /**< */,
                               uint                     glyphcmds_len  /**< */,
                               /+const+/ ubyte         *glyphcmds  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_composite_glyphs_16_checked
 **
 ** @param xcb_connection_t        *c
 ** @param ubyte                    op
 ** @param xcb_render_picture_t     src
 ** @param xcb_render_picture_t     dst
 ** @param xcb_render_pictformat_t  mask_format
 ** @param xcb_render_glyphset_t    glyphset
 ** @param short                    src_x
 ** @param short                    src_y
 ** @param uint                     glyphcmds_len
 ** @param /+const+/ ubyte         *glyphcmds
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_composite_glyphs_16_checked (xcb_connection_t        *c  /**< */,
                                        ubyte                    op  /**< */,
                                        xcb_render_picture_t     src  /**< */,
                                        xcb_render_picture_t     dst  /**< */,
                                        xcb_render_pictformat_t  mask_format  /**< */,
                                        xcb_render_glyphset_t    glyphset  /**< */,
                                        short                    src_x  /**< */,
                                        short                    src_y  /**< */,
                                        uint                     glyphcmds_len  /**< */,
                                        /+const+/ ubyte         *glyphcmds  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_composite_glyphs_16
 **
 ** @param xcb_connection_t        *c
 ** @param ubyte                    op
 ** @param xcb_render_picture_t     src
 ** @param xcb_render_picture_t     dst
 ** @param xcb_render_pictformat_t  mask_format
 ** @param xcb_render_glyphset_t    glyphset
 ** @param short                    src_x
 ** @param short                    src_y
 ** @param uint                     glyphcmds_len
 ** @param /+const+/ ubyte         *glyphcmds
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_composite_glyphs_16 (xcb_connection_t        *c  /**< */,
                                ubyte                    op  /**< */,
                                xcb_render_picture_t     src  /**< */,
                                xcb_render_picture_t     dst  /**< */,
                                xcb_render_pictformat_t  mask_format  /**< */,
                                xcb_render_glyphset_t    glyphset  /**< */,
                                short                    src_x  /**< */,
                                short                    src_y  /**< */,
                                uint                     glyphcmds_len  /**< */,
                                /+const+/ ubyte         *glyphcmds  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_composite_glyphs_32_checked
 **
 ** @param xcb_connection_t        *c
 ** @param ubyte                    op
 ** @param xcb_render_picture_t     src
 ** @param xcb_render_picture_t     dst
 ** @param xcb_render_pictformat_t  mask_format
 ** @param xcb_render_glyphset_t    glyphset
 ** @param short                    src_x
 ** @param short                    src_y
 ** @param uint                     glyphcmds_len
 ** @param /+const+/ ubyte         *glyphcmds
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_composite_glyphs_32_checked (xcb_connection_t        *c  /**< */,
                                        ubyte                    op  /**< */,
                                        xcb_render_picture_t     src  /**< */,
                                        xcb_render_picture_t     dst  /**< */,
                                        xcb_render_pictformat_t  mask_format  /**< */,
                                        xcb_render_glyphset_t    glyphset  /**< */,
                                        short                    src_x  /**< */,
                                        short                    src_y  /**< */,
                                        uint                     glyphcmds_len  /**< */,
                                        /+const+/ ubyte         *glyphcmds  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_composite_glyphs_32
 **
 ** @param xcb_connection_t        *c
 ** @param ubyte                    op
 ** @param xcb_render_picture_t     src
 ** @param xcb_render_picture_t     dst
 ** @param xcb_render_pictformat_t  mask_format
 ** @param xcb_render_glyphset_t    glyphset
 ** @param short                    src_x
 ** @param short                    src_y
 ** @param uint                     glyphcmds_len
 ** @param /+const+/ ubyte         *glyphcmds
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_composite_glyphs_32 (xcb_connection_t        *c  /**< */,
                                ubyte                    op  /**< */,
                                xcb_render_picture_t     src  /**< */,
                                xcb_render_picture_t     dst  /**< */,
                                xcb_render_pictformat_t  mask_format  /**< */,
                                xcb_render_glyphset_t    glyphset  /**< */,
                                short                    src_x  /**< */,
                                short                    src_y  /**< */,
                                uint                     glyphcmds_len  /**< */,
                                /+const+/ ubyte         *glyphcmds  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_fill_rectangles_checked
 **
 ** @param xcb_connection_t          *c
 ** @param ubyte                      op
 ** @param xcb_render_picture_t       dst
 ** @param xcb_render_color_t         color
 ** @param uint                       rects_len
 ** @param /+const+/ xcb_rectangle_t *rects
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_fill_rectangles_checked (xcb_connection_t          *c  /**< */,
                                    ubyte                      op  /**< */,
                                    xcb_render_picture_t       dst  /**< */,
                                    xcb_render_color_t         color  /**< */,
                                    uint                       rects_len  /**< */,
                                    /+const+/ xcb_rectangle_t *rects  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_fill_rectangles
 **
 ** @param xcb_connection_t          *c
 ** @param ubyte                      op
 ** @param xcb_render_picture_t       dst
 ** @param xcb_render_color_t         color
 ** @param uint                       rects_len
 ** @param /+const+/ xcb_rectangle_t *rects
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_fill_rectangles (xcb_connection_t          *c  /**< */,
                            ubyte                      op  /**< */,
                            xcb_render_picture_t       dst  /**< */,
                            xcb_render_color_t         color  /**< */,
                            uint                       rects_len  /**< */,
                            /+const+/ xcb_rectangle_t *rects  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_create_cursor_checked
 **
 ** @param xcb_connection_t     *c
 ** @param xcb_cursor_t          cid
 ** @param xcb_render_picture_t  source
 ** @param ushort                x
 ** @param ushort                y
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_create_cursor_checked (xcb_connection_t     *c  /**< */,
                                  xcb_cursor_t          cid  /**< */,
                                  xcb_render_picture_t  source  /**< */,
                                  ushort                x  /**< */,
                                  ushort                y  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_create_cursor
 **
 ** @param xcb_connection_t     *c
 ** @param xcb_cursor_t          cid
 ** @param xcb_render_picture_t  source
 ** @param ushort                x
 ** @param ushort                y
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_create_cursor (xcb_connection_t     *c  /**< */,
                          xcb_cursor_t          cid  /**< */,
                          xcb_render_picture_t  source  /**< */,
                          ushort                x  /**< */,
                          ushort                y  /**< */);


/*****************************************************************************
 **
 ** void xcb_render_transform_next
 **
 ** @param xcb_render_transform_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_render_transform_next (xcb_render_transform_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_render_transform_end
 **
 ** @param xcb_render_transform_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_render_transform_end (xcb_render_transform_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_set_picture_transform_checked
 **
 ** @param xcb_connection_t       *c
 ** @param xcb_render_picture_t    picture
 ** @param xcb_render_transform_t  transform
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_set_picture_transform_checked (xcb_connection_t       *c  /**< */,
                                          xcb_render_picture_t    picture  /**< */,
                                          xcb_render_transform_t  transform  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_set_picture_transform
 **
 ** @param xcb_connection_t       *c
 ** @param xcb_render_picture_t    picture
 ** @param xcb_render_transform_t  transform
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_set_picture_transform (xcb_connection_t       *c  /**< */,
                                  xcb_render_picture_t    picture  /**< */,
                                  xcb_render_transform_t  transform  /**< */);


/*****************************************************************************
 **
 ** xcb_render_query_filters_cookie_t xcb_render_query_filters
 **
 ** @param xcb_connection_t *c
 ** @param xcb_drawable_t    drawable
 ** @returns xcb_render_query_filters_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_render_query_filters_cookie_t
xcb_render_query_filters (xcb_connection_t *c  /**< */,
                          xcb_drawable_t    drawable  /**< */);


/*****************************************************************************
 **
 ** xcb_render_query_filters_cookie_t xcb_render_query_filters_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_drawable_t    drawable
 ** @returns xcb_render_query_filters_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_render_query_filters_cookie_t
xcb_render_query_filters_unchecked (xcb_connection_t *c  /**< */,
                                    xcb_drawable_t    drawable  /**< */);


/*****************************************************************************
 **
 ** ushort * xcb_render_query_filters_aliases
 **
 ** @param /+const+/ xcb_render_query_filters_reply_t *R
 ** @returns ushort *
 **
 *****************************************************************************/

extern(C) ushort *
xcb_render_query_filters_aliases (/+const+/ xcb_render_query_filters_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_render_query_filters_aliases_length
 **
 ** @param /+const+/ xcb_render_query_filters_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_render_query_filters_aliases_length (/+const+/ xcb_render_query_filters_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_render_query_filters_aliases_end
 **
 ** @param /+const+/ xcb_render_query_filters_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_render_query_filters_aliases_end (/+const+/ xcb_render_query_filters_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_render_query_filters_filters_length
 **
 ** @param /+const+/ xcb_render_query_filters_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_render_query_filters_filters_length (/+const+/ xcb_render_query_filters_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_str_iterator_t xcb_render_query_filters_filters_iterator
 **
 ** @param /+const+/ xcb_render_query_filters_reply_t *R
 ** @returns xcb_str_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_str_iterator_t
xcb_render_query_filters_filters_iterator (/+const+/ xcb_render_query_filters_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_render_query_filters_reply_t * xcb_render_query_filters_reply
 **
 ** @param xcb_connection_t                   *c
 ** @param xcb_render_query_filters_cookie_t   cookie
 ** @param xcb_generic_error_t               **e
 ** @returns xcb_render_query_filters_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_render_query_filters_reply_t *
xcb_render_query_filters_reply (xcb_connection_t                   *c  /**< */,
                                xcb_render_query_filters_cookie_t   cookie  /**< */,
                                xcb_generic_error_t               **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_set_picture_filter_checked
 **
 ** @param xcb_connection_t             *c
 ** @param xcb_render_picture_t          picture
 ** @param ushort                        filter_len
 ** @param /+const+/ char               *filter
 ** @param uint                          values_len
 ** @param /+const+/ xcb_render_fixed_t *values
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_set_picture_filter_checked (xcb_connection_t             *c  /**< */,
                                       xcb_render_picture_t          picture  /**< */,
                                       ushort                        filter_len  /**< */,
                                       /+const+/ char               *filter  /**< */,
                                       uint                          values_len  /**< */,
                                       /+const+/ xcb_render_fixed_t *values  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_set_picture_filter
 **
 ** @param xcb_connection_t             *c
 ** @param xcb_render_picture_t          picture
 ** @param ushort                        filter_len
 ** @param /+const+/ char               *filter
 ** @param uint                          values_len
 ** @param /+const+/ xcb_render_fixed_t *values
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_set_picture_filter (xcb_connection_t             *c  /**< */,
                               xcb_render_picture_t          picture  /**< */,
                               ushort                        filter_len  /**< */,
                               /+const+/ char               *filter  /**< */,
                               uint                          values_len  /**< */,
                               /+const+/ xcb_render_fixed_t *values  /**< */);


/*****************************************************************************
 **
 ** void xcb_render_animcursorelt_next
 **
 ** @param xcb_render_animcursorelt_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_render_animcursorelt_next (xcb_render_animcursorelt_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_render_animcursorelt_end
 **
 ** @param xcb_render_animcursorelt_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_render_animcursorelt_end (xcb_render_animcursorelt_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_create_anim_cursor_checked
 **
 ** @param xcb_connection_t                     *c
 ** @param xcb_cursor_t                          cid
 ** @param uint                                  cursors_len
 ** @param /+const+/ xcb_render_animcursorelt_t *cursors
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_create_anim_cursor_checked (xcb_connection_t                     *c  /**< */,
                                       xcb_cursor_t                          cid  /**< */,
                                       uint                                  cursors_len  /**< */,
                                       /+const+/ xcb_render_animcursorelt_t *cursors  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_create_anim_cursor
 **
 ** @param xcb_connection_t                     *c
 ** @param xcb_cursor_t                          cid
 ** @param uint                                  cursors_len
 ** @param /+const+/ xcb_render_animcursorelt_t *cursors
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_create_anim_cursor (xcb_connection_t                     *c  /**< */,
                               xcb_cursor_t                          cid  /**< */,
                               uint                                  cursors_len  /**< */,
                               /+const+/ xcb_render_animcursorelt_t *cursors  /**< */);


/*****************************************************************************
 **
 ** void xcb_render_spanfix_next
 **
 ** @param xcb_render_spanfix_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_render_spanfix_next (xcb_render_spanfix_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_render_spanfix_end
 **
 ** @param xcb_render_spanfix_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_render_spanfix_end (xcb_render_spanfix_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_render_trap_next
 **
 ** @param xcb_render_trap_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_render_trap_next (xcb_render_trap_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_render_trap_end
 **
 ** @param xcb_render_trap_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_render_trap_end (xcb_render_trap_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_add_traps_checked
 **
 ** @param xcb_connection_t            *c
 ** @param xcb_render_picture_t         picture
 ** @param short                        x_off
 ** @param short                        y_off
 ** @param uint                         traps_len
 ** @param /+const+/ xcb_render_trap_t *traps
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_add_traps_checked (xcb_connection_t            *c  /**< */,
                              xcb_render_picture_t         picture  /**< */,
                              short                        x_off  /**< */,
                              short                        y_off  /**< */,
                              uint                         traps_len  /**< */,
                              /+const+/ xcb_render_trap_t *traps  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_add_traps
 **
 ** @param xcb_connection_t            *c
 ** @param xcb_render_picture_t         picture
 ** @param short                        x_off
 ** @param short                        y_off
 ** @param uint                         traps_len
 ** @param /+const+/ xcb_render_trap_t *traps
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_add_traps (xcb_connection_t            *c  /**< */,
                      xcb_render_picture_t         picture  /**< */,
                      short                        x_off  /**< */,
                      short                        y_off  /**< */,
                      uint                         traps_len  /**< */,
                      /+const+/ xcb_render_trap_t *traps  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_create_solid_fill_checked
 **
 ** @param xcb_connection_t     *c
 ** @param xcb_render_picture_t  picture
 ** @param xcb_render_color_t    color
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_create_solid_fill_checked (xcb_connection_t     *c  /**< */,
                                      xcb_render_picture_t  picture  /**< */,
                                      xcb_render_color_t    color  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_create_solid_fill
 **
 ** @param xcb_connection_t     *c
 ** @param xcb_render_picture_t  picture
 ** @param xcb_render_color_t    color
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_create_solid_fill (xcb_connection_t     *c  /**< */,
                              xcb_render_picture_t  picture  /**< */,
                              xcb_render_color_t    color  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_create_linear_gradient_checked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_render_picture_t   picture
 ** @param xcb_render_pointfix_t  p1
 ** @param xcb_render_pointfix_t  p2
 ** @param uint                   num_stops
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_create_linear_gradient_checked (xcb_connection_t      *c  /**< */,
                                           xcb_render_picture_t   picture  /**< */,
                                           xcb_render_pointfix_t  p1  /**< */,
                                           xcb_render_pointfix_t  p2  /**< */,
                                           uint                   num_stops  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_create_linear_gradient
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_render_picture_t   picture
 ** @param xcb_render_pointfix_t  p1
 ** @param xcb_render_pointfix_t  p2
 ** @param uint                   num_stops
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_create_linear_gradient (xcb_connection_t      *c  /**< */,
                                   xcb_render_picture_t   picture  /**< */,
                                   xcb_render_pointfix_t  p1  /**< */,
                                   xcb_render_pointfix_t  p2  /**< */,
                                   uint                   num_stops  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_create_radial_gradient_checked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_render_picture_t   picture
 ** @param xcb_render_pointfix_t  inner
 ** @param xcb_render_pointfix_t  outer
 ** @param xcb_render_fixed_t     inner_radius
 ** @param xcb_render_fixed_t     outer_radius
 ** @param uint                   num_stops
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_create_radial_gradient_checked (xcb_connection_t      *c  /**< */,
                                           xcb_render_picture_t   picture  /**< */,
                                           xcb_render_pointfix_t  inner  /**< */,
                                           xcb_render_pointfix_t  outer  /**< */,
                                           xcb_render_fixed_t     inner_radius  /**< */,
                                           xcb_render_fixed_t     outer_radius  /**< */,
                                           uint                   num_stops  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_create_radial_gradient
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_render_picture_t   picture
 ** @param xcb_render_pointfix_t  inner
 ** @param xcb_render_pointfix_t  outer
 ** @param xcb_render_fixed_t     inner_radius
 ** @param xcb_render_fixed_t     outer_radius
 ** @param uint                   num_stops
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_create_radial_gradient (xcb_connection_t      *c  /**< */,
                                   xcb_render_picture_t   picture  /**< */,
                                   xcb_render_pointfix_t  inner  /**< */,
                                   xcb_render_pointfix_t  outer  /**< */,
                                   xcb_render_fixed_t     inner_radius  /**< */,
                                   xcb_render_fixed_t     outer_radius  /**< */,
                                   uint                   num_stops  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_create_conical_gradient_checked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_render_picture_t   picture
 ** @param xcb_render_pointfix_t  center
 ** @param xcb_render_fixed_t     angle
 ** @param uint                   num_stops
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_create_conical_gradient_checked (xcb_connection_t      *c  /**< */,
                                            xcb_render_picture_t   picture  /**< */,
                                            xcb_render_pointfix_t  center  /**< */,
                                            xcb_render_fixed_t     angle  /**< */,
                                            uint                   num_stops  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_render_create_conical_gradient
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_render_picture_t   picture
 ** @param xcb_render_pointfix_t  center
 ** @param xcb_render_fixed_t     angle
 ** @param uint                   num_stops
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_render_create_conical_gradient (xcb_connection_t      *c  /**< */,
                                    xcb_render_picture_t   picture  /**< */,
                                    xcb_render_pointfix_t  center  /**< */,
                                    xcb_render_fixed_t     angle  /**< */,
                                    uint                   num_stops  /**< */);



/**
 * @}
 */
