/*
 * This file generated automatically from glx.xml by c-client.xsl using XSLT.
 * Edit at your peril.
 */

/**
 * @defgroup XCB_Glx_API XCB Glx API
 * @brief Glx XCB Protocol Implementation.
 * @{
 **/


module std.c.linux.X11.xcb.glx;
version(USE_XCB):

import std.c.linux.X11.xcb.xcb;
import std.c.linux.X11.xcb.xproto;

const int XCB_GLX_MAJOR_VERSION =1;
const int XCB_GLX_MINOR_VERSION =3;

extern(C) extern xcb_extension_t xcb_glx_id;

alias uint xcb_glx_pixmap_t;

/**
 * @brief xcb_glx_pixmap_iterator_t
 **/
struct xcb_glx_pixmap_iterator_t {
    xcb_glx_pixmap_t *data; /**<  */
    int               rem; /**<  */
    int               index; /**<  */
} ;

alias uint xcb_glx_context_t;

/**
 * @brief xcb_glx_context_iterator_t
 **/
struct xcb_glx_context_iterator_t {
    xcb_glx_context_t *data; /**<  */
    int                rem; /**<  */
    int                index; /**<  */
} ;

alias uint xcb_glx_pbuffer_t;

/**
 * @brief xcb_glx_pbuffer_iterator_t
 **/
struct xcb_glx_pbuffer_iterator_t {
    xcb_glx_pbuffer_t *data; /**<  */
    int                rem; /**<  */
    int                index; /**<  */
} ;

alias uint xcb_glx_window_t;

/**
 * @brief xcb_glx_window_iterator_t
 **/
struct xcb_glx_window_iterator_t {
    xcb_glx_window_t *data; /**<  */
    int               rem; /**<  */
    int               index; /**<  */
} ;

alias uint xcb_glx_fbconfig_t;

/**
 * @brief xcb_glx_fbconfig_iterator_t
 **/
struct xcb_glx_fbconfig_iterator_t {
    xcb_glx_fbconfig_t *data; /**<  */
    int                 rem; /**<  */
    int                 index; /**<  */
} ;

alias uint xcb_glx_drawable_t;

/**
 * @brief xcb_glx_drawable_iterator_t
 **/
struct xcb_glx_drawable_iterator_t {
    xcb_glx_drawable_t *data; /**<  */
    int                 rem; /**<  */
    int                 index; /**<  */
} ;

alias float xcb_glx_float32_t;

/**
 * @brief xcb_glx_float32_iterator_t
 **/
struct xcb_glx_float32_iterator_t {
    xcb_glx_float32_t *data; /**<  */
    int                rem; /**<  */
    int                index; /**<  */
} ;

alias double xcb_glx_float64_t;

/**
 * @brief xcb_glx_float64_iterator_t
 **/
struct xcb_glx_float64_iterator_t {
    xcb_glx_float64_t *data; /**<  */
    int                rem; /**<  */
    int                index; /**<  */
} ;

alias uint xcb_glx_bool32_t;

/**
 * @brief xcb_glx_bool32_iterator_t
 **/
struct xcb_glx_bool32_iterator_t {
    xcb_glx_bool32_t *data; /**<  */
    int               rem; /**<  */
    int               index; /**<  */
} ;

alias uint xcb_glx_context_tag_t;

/**
 * @brief xcb_glx_context_tag_iterator_t
 **/
struct xcb_glx_context_tag_iterator_t {
    xcb_glx_context_tag_t *data; /**<  */
    int                    rem; /**<  */
    int                    index; /**<  */
} ;

/** Opcode for xcb_glx_generic. */
const uint XCB_GLX_GENERIC = -1;

/**
 * @brief xcb_glx_generic_error_t
 **/
struct xcb_glx_generic_error_t {
    ubyte  response_type; /**<  */
    ubyte  error_code; /**<  */
    ushort sequence; /**<  */
    uint   bad_value; /**<  */
    ushort minor_opcode; /**<  */
    ubyte  major_opcode; /**<  */
    ubyte  pad0[21]; /**<  */
} ;

/** Opcode for xcb_glx_bad_context. */
const uint XCB_GLX_BAD_CONTEXT = 0;

alias xcb_glx_generic_error_t xcb_glx_bad_context_error_t;

/** Opcode for xcb_glx_bad_context_state. */
const uint XCB_GLX_BAD_CONTEXT_STATE = 1;

alias xcb_glx_generic_error_t xcb_glx_bad_context_state_error_t;

/** Opcode for xcb_glx_bad_drawable. */
const uint XCB_GLX_BAD_DRAWABLE = 2;

alias xcb_glx_generic_error_t xcb_glx_bad_drawable_error_t;

/** Opcode for xcb_glx_bad_pixmap. */
const uint XCB_GLX_BAD_PIXMAP = 3;

alias xcb_glx_generic_error_t xcb_glx_bad_pixmap_error_t;

/** Opcode for xcb_glx_bad_context_tag. */
const uint XCB_GLX_BAD_CONTEXT_TAG = 4;

alias xcb_glx_generic_error_t xcb_glx_bad_context_tag_error_t;

/** Opcode for xcb_glx_bad_current_window. */
const uint XCB_GLX_BAD_CURRENT_WINDOW = 5;

alias xcb_glx_generic_error_t xcb_glx_bad_current_window_error_t;

/** Opcode for xcb_glx_bad_render_request. */
const uint XCB_GLX_BAD_RENDER_REQUEST = 6;

alias xcb_glx_generic_error_t xcb_glx_bad_render_request_error_t;

/** Opcode for xcb_glx_bad_large_request. */
const uint XCB_GLX_BAD_LARGE_REQUEST = 7;

alias xcb_glx_generic_error_t xcb_glx_bad_large_request_error_t;

/** Opcode for xcb_glx_unsupported_private_request. */
const uint XCB_GLX_UNSUPPORTED_PRIVATE_REQUEST = 8;

alias xcb_glx_generic_error_t xcb_glx_unsupported_private_request_error_t;

/** Opcode for xcb_glx_bad_fb_config. */
const uint XCB_GLX_BAD_FB_CONFIG = 9;

alias xcb_glx_generic_error_t xcb_glx_bad_fb_config_error_t;

/** Opcode for xcb_glx_bad_pbuffer. */
const uint XCB_GLX_BAD_PBUFFER = 10;

alias xcb_glx_generic_error_t xcb_glx_bad_pbuffer_error_t;

/** Opcode for xcb_glx_bad_current_drawable. */
const uint XCB_GLX_BAD_CURRENT_DRAWABLE = 11;

alias xcb_glx_generic_error_t xcb_glx_bad_current_drawable_error_t;

/** Opcode for xcb_glx_bad_window. */
const uint XCB_GLX_BAD_WINDOW = 12;

alias xcb_glx_generic_error_t xcb_glx_bad_window_error_t;

/** Opcode for xcb_glx_pbuffer_clobber. */
const uint XCB_GLX_PBUFFER_CLOBBER = 0;

/**
 * @brief xcb_glx_pbuffer_clobber_event_t
 **/
struct xcb_glx_pbuffer_clobber_event_t {
    ubyte              response_type; /**<  */
    ushort             event_type; /**<  */
    ushort             sequence; /**<  */
    ushort             draw_type; /**<  */
    xcb_glx_drawable_t drawable; /**<  */
    uint               b_mask; /**<  */
    ushort             aux_buffer; /**<  */
    ushort             x; /**<  */
    ushort             y; /**<  */
    ushort             width; /**<  */
    ushort             height; /**<  */
    ushort             count; /**<  */
    ubyte              pad0[4]; /**<  */
} ;

enum :int{
    XCB_GLX_PBCET_DAMAGED = 0x8017,
    XCB_GLX_PBCET_SAVED = 0x8018
};

enum :int{
    XCB_GLX_PBCDT_WINDOW = 0x8019,
    XCB_GLX_PBCDT_PBUFFER = 0x801A
};

/** Opcode for xcb_glx_render. */
const uint XCB_GLX_RENDER = 1;

/**
 * @brief xcb_glx_render_request_t
 **/
struct xcb_glx_render_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
} ;

/** Opcode for xcb_glx_render_large. */
const uint XCB_GLX_RENDER_LARGE = 2;

/**
 * @brief xcb_glx_render_large_request_t
 **/
struct xcb_glx_render_large_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    ushort                request_num; /**<  */
    ushort                request_total; /**<  */
    uint                  data_len; /**<  */
} ;

/** Opcode for xcb_glx_create_context. */
const uint XCB_GLX_CREATE_CONTEXT = 3;

/**
 * @brief xcb_glx_create_context_request_t
 **/
struct xcb_glx_create_context_request_t {
    ubyte             major_opcode; /**<  */
    ubyte             minor_opcode; /**<  */
    ushort            length; /**<  */
    xcb_glx_context_t context; /**<  */
    xcb_visualid_t    visual; /**<  */
    uint              screen; /**<  */
    xcb_glx_context_t share_list; /**<  */
    bool              is_direct; /**<  */
    ubyte             pad0[3]; /**<  */
} ;

/** Opcode for xcb_glx_destroy_context. */
const uint XCB_GLX_DESTROY_CONTEXT = 4;

/**
 * @brief xcb_glx_destroy_context_request_t
 **/
struct xcb_glx_destroy_context_request_t {
    ubyte             major_opcode; /**<  */
    ubyte             minor_opcode; /**<  */
    ushort            length; /**<  */
    xcb_glx_context_t context; /**<  */
} ;

/**
 * @brief xcb_glx_make_current_cookie_t
 **/
struct xcb_glx_make_current_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_make_current. */
const uint XCB_GLX_MAKE_CURRENT = 5;

/**
 * @brief xcb_glx_make_current_request_t
 **/
struct xcb_glx_make_current_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_drawable_t    drawable; /**<  */
    xcb_glx_context_t     context; /**<  */
    xcb_glx_context_tag_t old_context_tag; /**<  */
} ;

/**
 * @brief xcb_glx_make_current_reply_t
 **/
struct xcb_glx_make_current_reply_t {
    ubyte                 response_type; /**<  */
    ubyte                 pad0; /**<  */
    ushort                sequence; /**<  */
    uint                  length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    ubyte                 pad1[20]; /**<  */
} ;

/**
 * @brief xcb_glx_is_direct_cookie_t
 **/
struct xcb_glx_is_direct_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_is_direct. */
const uint XCB_GLX_IS_DIRECT = 6;

/**
 * @brief xcb_glx_is_direct_request_t
 **/
struct xcb_glx_is_direct_request_t {
    ubyte             major_opcode; /**<  */
    ubyte             minor_opcode; /**<  */
    ushort            length; /**<  */
    xcb_glx_context_t context; /**<  */
} ;

/**
 * @brief xcb_glx_is_direct_reply_t
 **/
struct xcb_glx_is_direct_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    bool   is_direct; /**<  */
    ubyte  pad1[23]; /**<  */
} ;

/**
 * @brief xcb_glx_query_version_cookie_t
 **/
struct xcb_glx_query_version_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_query_version. */
const uint XCB_GLX_QUERY_VERSION = 7;

/**
 * @brief xcb_glx_query_version_request_t
 **/
struct xcb_glx_query_version_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
    uint   major_version; /**<  */
    uint   minor_version; /**<  */
} ;

/**
 * @brief xcb_glx_query_version_reply_t
 **/
struct xcb_glx_query_version_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    uint   major_version; /**<  */
    uint   minor_version; /**<  */
    ubyte  pad1[16]; /**<  */
} ;

/** Opcode for xcb_glx_wait_gl. */
const uint XCB_GLX_WAIT_GL = 8;

/**
 * @brief xcb_glx_wait_gl_request_t
 **/
struct xcb_glx_wait_gl_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
} ;

/** Opcode for xcb_glx_wait_x. */
const uint XCB_GLX_WAIT_X = 9;

/**
 * @brief xcb_glx_wait_x_request_t
 **/
struct xcb_glx_wait_x_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
} ;

/** Opcode for xcb_glx_copy_context. */
const uint XCB_GLX_COPY_CONTEXT = 10;

/**
 * @brief xcb_glx_copy_context_request_t
 **/
struct xcb_glx_copy_context_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_t     src; /**<  */
    xcb_glx_context_t     dest; /**<  */
    uint                  mask; /**<  */
    xcb_glx_context_tag_t src_context_tag; /**<  */
} ;

enum :int{
    XCB_GLX_GC_GL_CURRENT_BIT = 0x00000001,
    XCB_GLX_GC_GL_POINT_BIT = 0x00000002,
    XCB_GLX_GC_GL_LINE_BIT = 0x00000004,
    XCB_GLX_GC_GL_POLYGON_BIT = 0x00000008,
    XCB_GLX_GC_GL_POLYGON_STIPPLE_BIT = 0x00000010,
    XCB_GLX_GC_GL_PIXEL_MODE_BIT = 0x00000020,
    XCB_GLX_GC_GL_LIGHTING_BIT = 0x00000040,
    XCB_GLX_GC_GL_FOG_BIT = 0x00000080,
    XCB_GLX_GC_GL_DEPTH_BUFFER_BIT = 0x00000100,
    XCB_GLX_GC_GL_ACCUM_BUFFER_BIT = 0x00000200,
    XCB_GLX_GC_GL_STENCIL_BUFFER_BIT = 0x00000400,
    XCB_GLX_GC_GL_VIEWPORT_BIT = 0x00000800,
    XCB_GLX_GC_GL_TRANSFORM_BIT = 0x00001000,
    XCB_GLX_GC_GL_ENABLE_BIT = 0x00002000,
    XCB_GLX_GC_GL_COLOR_BUFFER_BIT = 0x00004000,
    XCB_GLX_GC_GL_HINT_BIT = 0x00008000,
    XCB_GLX_GC_GL_EVAL_BIT = 0x00010000,
    XCB_GLX_GC_GL_LIST_BIT = 0x00020000,
    XCB_GLX_GC_GL_TEXTURE_BIT = 0x00040000,
    XCB_GLX_GC_GL_SCISSOR_BIT = 0x00080000,
    XCB_GLX_GC_GL_ALL_ATTRIB_BITS = 0x000ffffff
};

/** Opcode for xcb_glx_swap_buffers. */
const uint XCB_GLX_SWAP_BUFFERS = 11;

/**
 * @brief xcb_glx_swap_buffers_request_t
 **/
struct xcb_glx_swap_buffers_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    xcb_glx_drawable_t    drawable; /**<  */
} ;

/** Opcode for xcb_glx_use_x_font. */
const uint XCB_GLX_USE_X_FONT = 12;

/**
 * @brief xcb_glx_use_x_font_request_t
 **/
struct xcb_glx_use_x_font_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    xcb_font_t            font; /**<  */
    uint                  first; /**<  */
    uint                  count; /**<  */
    uint                  list_base; /**<  */
} ;

/** Opcode for xcb_glx_create_glx_pixmap. */
const uint XCB_GLX_CREATE_GLX_PIXMAP = 13;

/**
 * @brief xcb_glx_create_glx_pixmap_request_t
 **/
struct xcb_glx_create_glx_pixmap_request_t {
    ubyte            major_opcode; /**<  */
    ubyte            minor_opcode; /**<  */
    ushort           length; /**<  */
    uint             screen; /**<  */
    xcb_visualid_t   visual; /**<  */
    xcb_pixmap_t     pixmap; /**<  */
    xcb_glx_pixmap_t glx_pixmap; /**<  */
} ;

/**
 * @brief xcb_glx_get_visual_configs_cookie_t
 **/
struct xcb_glx_get_visual_configs_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_visual_configs. */
const uint XCB_GLX_GET_VISUAL_CONFIGS = 14;

/**
 * @brief xcb_glx_get_visual_configs_request_t
 **/
struct xcb_glx_get_visual_configs_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
    uint   screen; /**<  */
} ;

/**
 * @brief xcb_glx_get_visual_configs_reply_t
 **/
struct xcb_glx_get_visual_configs_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    uint   num_visuals; /**<  */
    uint   num_properties; /**<  */
    ubyte  pad1[16]; /**<  */
} ;

/** Opcode for xcb_glx_destroy_glx_pixmap. */
const uint XCB_GLX_DESTROY_GLX_PIXMAP = 15;

/**
 * @brief xcb_glx_destroy_glx_pixmap_request_t
 **/
struct xcb_glx_destroy_glx_pixmap_request_t {
    ubyte            major_opcode; /**<  */
    ubyte            minor_opcode; /**<  */
    ushort           length; /**<  */
    xcb_glx_pixmap_t glx_pixmap; /**<  */
} ;

/** Opcode for xcb_glx_vendor_private. */
const uint XCB_GLX_VENDOR_PRIVATE = 16;

/**
 * @brief xcb_glx_vendor_private_request_t
 **/
struct xcb_glx_vendor_private_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    uint                  vendor_code; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
} ;

/**
 * @brief xcb_glx_vendor_private_with_reply_cookie_t
 **/
struct xcb_glx_vendor_private_with_reply_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_vendor_private_with_reply. */
const uint XCB_GLX_VENDOR_PRIVATE_WITH_REPLY = 17;

/**
 * @brief xcb_glx_vendor_private_with_reply_request_t
 **/
struct xcb_glx_vendor_private_with_reply_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    uint                  vendor_code; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
} ;

/**
 * @brief xcb_glx_vendor_private_with_reply_reply_t
 **/
struct xcb_glx_vendor_private_with_reply_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    uint   retval; /**<  */
    ubyte  data1[24]; /**<  */
} ;

/**
 * @brief xcb_glx_query_extensions_string_cookie_t
 **/
struct xcb_glx_query_extensions_string_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_query_extensions_string. */
const uint XCB_GLX_QUERY_EXTENSIONS_STRING = 18;

/**
 * @brief xcb_glx_query_extensions_string_request_t
 **/
struct xcb_glx_query_extensions_string_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
    uint   screen; /**<  */
} ;

/**
 * @brief xcb_glx_query_extensions_string_reply_t
 **/
struct xcb_glx_query_extensions_string_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ubyte  pad1[4]; /**<  */
    uint   n; /**<  */
    ubyte  pad2[16]; /**<  */
} ;

/**
 * @brief xcb_glx_query_server_string_cookie_t
 **/
struct xcb_glx_query_server_string_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_query_server_string. */
const uint XCB_GLX_QUERY_SERVER_STRING = 19;

/**
 * @brief xcb_glx_query_server_string_request_t
 **/
struct xcb_glx_query_server_string_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
    uint   screen; /**<  */
    uint   name; /**<  */
} ;

/**
 * @brief xcb_glx_query_server_string_reply_t
 **/
struct xcb_glx_query_server_string_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ubyte  pad1[4]; /**<  */
    uint   str_len; /**<  */
    ubyte  pad2[16]; /**<  */
} ;

/** Opcode for xcb_glx_client_info. */
const uint XCB_GLX_CLIENT_INFO = 20;

/**
 * @brief xcb_glx_client_info_request_t
 **/
struct xcb_glx_client_info_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
    uint   major_version; /**<  */
    uint   minor_version; /**<  */
    uint   str_len; /**<  */
} ;

/**
 * @brief xcb_glx_get_fb_configs_cookie_t
 **/
struct xcb_glx_get_fb_configs_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_fb_configs. */
const uint XCB_GLX_GET_FB_CONFIGS = 21;

/**
 * @brief xcb_glx_get_fb_configs_request_t
 **/
struct xcb_glx_get_fb_configs_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
    uint   screen; /**<  */
} ;

/**
 * @brief xcb_glx_get_fb_configs_reply_t
 **/
struct xcb_glx_get_fb_configs_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    uint   num_FB_configs; /**<  */
    uint   num_properties; /**<  */
    ubyte  pad1[16]; /**<  */
} ;

/** Opcode for xcb_glx_create_pixmap. */
const uint XCB_GLX_CREATE_PIXMAP = 22;

/**
 * @brief xcb_glx_create_pixmap_request_t
 **/
struct xcb_glx_create_pixmap_request_t {
    ubyte            major_opcode; /**<  */
    ubyte            minor_opcode; /**<  */
    ushort           length; /**<  */
    uint             screen; /**<  */
    uint             fbconfig; /**<  */
    xcb_pixmap_t     pixmap; /**<  */
    xcb_glx_pixmap_t glx_pixmap; /**<  */
    uint             num_attribs; /**<  */
} ;

/** Opcode for xcb_glx_destroy_pixmap. */
const uint XCB_GLX_DESTROY_PIXMAP = 23;

/**
 * @brief xcb_glx_destroy_pixmap_request_t
 **/
struct xcb_glx_destroy_pixmap_request_t {
    ubyte            major_opcode; /**<  */
    ubyte            minor_opcode; /**<  */
    ushort           length; /**<  */
    xcb_glx_pixmap_t glx_pixmap; /**<  */
} ;

/** Opcode for xcb_glx_create_new_context. */
const uint XCB_GLX_CREATE_NEW_CONTEXT = 24;

/**
 * @brief xcb_glx_create_new_context_request_t
 **/
struct xcb_glx_create_new_context_request_t {
    ubyte             major_opcode; /**<  */
    ubyte             minor_opcode; /**<  */
    ushort            length; /**<  */
    xcb_glx_context_t context; /**<  */
    uint              fbconfig; /**<  */
    uint              screen; /**<  */
    uint              render_type; /**<  */
    uint              share_list; /**<  */
    bool              is_direct; /**<  */
    ubyte             reserved1; /**<  */
    ushort            reserved2; /**<  */
} ;

/**
 * @brief xcb_glx_query_context_cookie_t
 **/
struct xcb_glx_query_context_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_query_context. */
const uint XCB_GLX_QUERY_CONTEXT = 25;

/**
 * @brief xcb_glx_query_context_request_t
 **/
struct xcb_glx_query_context_request_t {
    ubyte             major_opcode; /**<  */
    ubyte             minor_opcode; /**<  */
    ushort            length; /**<  */
    xcb_glx_context_t context; /**<  */
} ;

/**
 * @brief xcb_glx_query_context_reply_t
 **/
struct xcb_glx_query_context_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    uint   num_attribs; /**<  */
    ubyte  pad1[20]; /**<  */
} ;

/**
 * @brief xcb_glx_make_context_current_cookie_t
 **/
struct xcb_glx_make_context_current_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_make_context_current. */
const uint XCB_GLX_MAKE_CONTEXT_CURRENT = 26;

/**
 * @brief xcb_glx_make_context_current_request_t
 **/
struct xcb_glx_make_context_current_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t old_context_tag; /**<  */
    xcb_glx_drawable_t    drawable; /**<  */
    xcb_glx_drawable_t    read_drawable; /**<  */
    xcb_glx_context_t     context; /**<  */
} ;

/**
 * @brief xcb_glx_make_context_current_reply_t
 **/
struct xcb_glx_make_context_current_reply_t {
    ubyte                 response_type; /**<  */
    ubyte                 pad0; /**<  */
    ushort                sequence; /**<  */
    uint                  length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    ubyte                 pad1[20]; /**<  */
} ;

/** Opcode for xcb_glx_create_pbuffer. */
const uint XCB_GLX_CREATE_PBUFFER = 27;

/**
 * @brief xcb_glx_create_pbuffer_request_t
 **/
struct xcb_glx_create_pbuffer_request_t {
    ubyte              major_opcode; /**<  */
    ubyte              minor_opcode; /**<  */
    ushort             length; /**<  */
    uint               screen; /**<  */
    xcb_glx_fbconfig_t fbconfig; /**<  */
    xcb_glx_pbuffer_t  pbuffer; /**<  */
    uint               num_attribs; /**<  */
} ;

/** Opcode for xcb_glx_destroy_pbuffer. */
const uint XCB_GLX_DESTROY_PBUFFER = 28;

/**
 * @brief xcb_glx_destroy_pbuffer_request_t
 **/
struct xcb_glx_destroy_pbuffer_request_t {
    ubyte             major_opcode; /**<  */
    ubyte             minor_opcode; /**<  */
    ushort            length; /**<  */
    xcb_glx_pbuffer_t pbuffer; /**<  */
} ;

/**
 * @brief xcb_glx_get_drawable_attributes_cookie_t
 **/
struct xcb_glx_get_drawable_attributes_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_drawable_attributes. */
const uint XCB_GLX_GET_DRAWABLE_ATTRIBUTES = 29;

/**
 * @brief xcb_glx_get_drawable_attributes_request_t
 **/
struct xcb_glx_get_drawable_attributes_request_t {
    ubyte              major_opcode; /**<  */
    ubyte              minor_opcode; /**<  */
    ushort             length; /**<  */
    xcb_glx_drawable_t drawable; /**<  */
} ;

/**
 * @brief xcb_glx_get_drawable_attributes_reply_t
 **/
struct xcb_glx_get_drawable_attributes_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    uint   num_attribs; /**<  */
    ubyte  pad1[20]; /**<  */
} ;

/** Opcode for xcb_glx_change_drawable_attributes. */
const uint XCB_GLX_CHANGE_DRAWABLE_ATTRIBUTES = 30;

/**
 * @brief xcb_glx_change_drawable_attributes_request_t
 **/
struct xcb_glx_change_drawable_attributes_request_t {
    ubyte              major_opcode; /**<  */
    ubyte              minor_opcode; /**<  */
    ushort             length; /**<  */
    xcb_glx_drawable_t drawable; /**<  */
    uint               num_attribs; /**<  */
} ;

/** Opcode for xcb_glx_create_window. */
const uint XCB_GLX_CREATE_WINDOW = 31;

/**
 * @brief xcb_glx_create_window_request_t
 **/
struct xcb_glx_create_window_request_t {
    ubyte              major_opcode; /**<  */
    ubyte              minor_opcode; /**<  */
    ushort             length; /**<  */
    uint               screen; /**<  */
    xcb_glx_fbconfig_t fbconfig; /**<  */
    xcb_window_t       window; /**<  */
    xcb_glx_window_t   glx_window; /**<  */
    uint               num_attribs; /**<  */
} ;

/** Opcode for xcb_glx_delete_window. */
const uint XCB_GLX_DELETE_WINDOW = 32;

/**
 * @brief xcb_glx_delete_window_request_t
 **/
struct xcb_glx_delete_window_request_t {
    ubyte            major_opcode; /**<  */
    ubyte            minor_opcode; /**<  */
    ushort           length; /**<  */
    xcb_glx_window_t glxwindow; /**<  */
} ;

/** Opcode for xcb_glx_new_list. */
const uint XCB_GLX_NEW_LIST = 101;

/**
 * @brief xcb_glx_new_list_request_t
 **/
struct xcb_glx_new_list_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  list; /**<  */
    uint                  mode; /**<  */
} ;

/** Opcode for xcb_glx_end_list. */
const uint XCB_GLX_END_LIST = 102;

/**
 * @brief xcb_glx_end_list_request_t
 **/
struct xcb_glx_end_list_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
} ;

/** Opcode for xcb_glx_delete_lists. */
const uint XCB_GLX_DELETE_LISTS = 103;

/**
 * @brief xcb_glx_delete_lists_request_t
 **/
struct xcb_glx_delete_lists_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  list; /**<  */
    int                   range; /**<  */
} ;

/**
 * @brief xcb_glx_gen_lists_cookie_t
 **/
struct xcb_glx_gen_lists_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_gen_lists. */
const uint XCB_GLX_GEN_LISTS = 104;

/**
 * @brief xcb_glx_gen_lists_request_t
 **/
struct xcb_glx_gen_lists_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    int                   range; /**<  */
} ;

/**
 * @brief xcb_glx_gen_lists_reply_t
 **/
struct xcb_glx_gen_lists_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    uint   ret_val; /**<  */
} ;

/** Opcode for xcb_glx_feedback_buffer. */
const uint XCB_GLX_FEEDBACK_BUFFER = 105;

/**
 * @brief xcb_glx_feedback_buffer_request_t
 **/
struct xcb_glx_feedback_buffer_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    int                   size; /**<  */
    int                   type; /**<  */
} ;

/** Opcode for xcb_glx_select_buffer. */
const uint XCB_GLX_SELECT_BUFFER = 106;

/**
 * @brief xcb_glx_select_buffer_request_t
 **/
struct xcb_glx_select_buffer_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    int                   size; /**<  */
} ;

/**
 * @brief xcb_glx_render_mode_cookie_t
 **/
struct xcb_glx_render_mode_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_render_mode. */
const uint XCB_GLX_RENDER_MODE = 107;

/**
 * @brief xcb_glx_render_mode_request_t
 **/
struct xcb_glx_render_mode_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  mode; /**<  */
} ;

/**
 * @brief xcb_glx_render_mode_reply_t
 **/
struct xcb_glx_render_mode_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    uint   ret_val; /**<  */
    uint   n; /**<  */
    uint   new_mode; /**<  */
    ubyte  pad1[12]; /**<  */
} ;

enum :int{
    XCB_GLX_RM_GL_RENDER = 0x1C00,
    XCB_GLX_RM_GL_FEEDBACK = 0x1C01,
    XCB_GLX_RM_GL_SELECT = 0x1C02
};

/**
 * @brief xcb_glx_finish_cookie_t
 **/
struct xcb_glx_finish_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_finish. */
const uint XCB_GLX_FINISH = 108;

/**
 * @brief xcb_glx_finish_request_t
 **/
struct xcb_glx_finish_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
} ;

/**
 * @brief xcb_glx_finish_reply_t
 **/
struct xcb_glx_finish_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
} ;

/** Opcode for xcb_glx_pixel_storef. */
const uint XCB_GLX_PIXEL_STOREF = 109;

/**
 * @brief xcb_glx_pixel_storef_request_t
 **/
struct xcb_glx_pixel_storef_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  pname; /**<  */
    xcb_glx_float32_t     datum; /**<  */
} ;

/** Opcode for xcb_glx_pixel_storei. */
const uint XCB_GLX_PIXEL_STOREI = 110;

/**
 * @brief xcb_glx_pixel_storei_request_t
 **/
struct xcb_glx_pixel_storei_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  pname; /**<  */
    int                   datum; /**<  */
} ;

/**
 * @brief xcb_glx_read_pixels_cookie_t
 **/
struct xcb_glx_read_pixels_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_read_pixels. */
const uint XCB_GLX_READ_PIXELS = 111;

/**
 * @brief xcb_glx_read_pixels_request_t
 **/
struct xcb_glx_read_pixels_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    int                   x; /**<  */
    int                   y; /**<  */
    int                   width; /**<  */
    int                   height; /**<  */
    uint                  format; /**<  */
    uint                  type; /**<  */
    bool                  swap_bytes; /**<  */
    bool                  lsb_first; /**<  */
} ;

/**
 * @brief xcb_glx_read_pixels_reply_t
 **/
struct xcb_glx_read_pixels_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ubyte  pad1[24]; /**<  */
} ;

/**
 * @brief xcb_glx_get_booleanv_cookie_t
 **/
struct xcb_glx_get_booleanv_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_booleanv. */
const uint XCB_GLX_GET_BOOLEANV = 112;

/**
 * @brief xcb_glx_get_booleanv_request_t
 **/
struct xcb_glx_get_booleanv_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    int                   pname; /**<  */
} ;

/**
 * @brief xcb_glx_get_booleanv_reply_t
 **/
struct xcb_glx_get_booleanv_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ubyte  pad1[4]; /**<  */
    uint   n; /**<  */
    bool   datum; /**<  */
    ubyte  pad2[15]; /**<  */
} ;

/**
 * @brief xcb_glx_get_clip_plane_cookie_t
 **/
struct xcb_glx_get_clip_plane_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_clip_plane. */
const uint XCB_GLX_GET_CLIP_PLANE = 113;

/**
 * @brief xcb_glx_get_clip_plane_request_t
 **/
struct xcb_glx_get_clip_plane_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    int                   plane; /**<  */
} ;

/**
 * @brief xcb_glx_get_clip_plane_reply_t
 **/
struct xcb_glx_get_clip_plane_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ubyte  pad1[24]; /**<  */
} ;

/**
 * @brief xcb_glx_get_doublev_cookie_t
 **/
struct xcb_glx_get_doublev_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_doublev. */
const uint XCB_GLX_GET_DOUBLEV = 114;

/**
 * @brief xcb_glx_get_doublev_request_t
 **/
struct xcb_glx_get_doublev_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  pname; /**<  */
} ;

/**
 * @brief xcb_glx_get_doublev_reply_t
 **/
struct xcb_glx_get_doublev_reply_t {
    ubyte             response_type; /**<  */
    ubyte             pad0; /**<  */
    ushort            sequence; /**<  */
    uint              length; /**<  */
    ubyte             pad1[4]; /**<  */
    uint              n; /**<  */
    xcb_glx_float64_t datum; /**<  */
    ubyte             pad2[8]; /**<  */
} ;

/**
 * @brief xcb_glx_get_error_cookie_t
 **/
struct xcb_glx_get_error_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_error. */
const uint XCB_GLX_GET_ERROR = 115;

/**
 * @brief xcb_glx_get_error_request_t
 **/
struct xcb_glx_get_error_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
} ;

/**
 * @brief xcb_glx_get_error_reply_t
 **/
struct xcb_glx_get_error_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    int    error; /**<  */
} ;

/**
 * @brief xcb_glx_get_floatv_cookie_t
 **/
struct xcb_glx_get_floatv_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_floatv. */
const uint XCB_GLX_GET_FLOATV = 116;

/**
 * @brief xcb_glx_get_floatv_request_t
 **/
struct xcb_glx_get_floatv_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  pname; /**<  */
} ;

/**
 * @brief xcb_glx_get_floatv_reply_t
 **/
struct xcb_glx_get_floatv_reply_t {
    ubyte             response_type; /**<  */
    ubyte             pad0; /**<  */
    ushort            sequence; /**<  */
    uint              length; /**<  */
    ubyte             pad1[4]; /**<  */
    uint              n; /**<  */
    xcb_glx_float32_t datum; /**<  */
    ubyte             pad2[12]; /**<  */
} ;

/**
 * @brief xcb_glx_get_integerv_cookie_t
 **/
struct xcb_glx_get_integerv_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_integerv. */
const uint XCB_GLX_GET_INTEGERV = 117;

/**
 * @brief xcb_glx_get_integerv_request_t
 **/
struct xcb_glx_get_integerv_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  pname; /**<  */
} ;

/**
 * @brief xcb_glx_get_integerv_reply_t
 **/
struct xcb_glx_get_integerv_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ubyte  pad1[4]; /**<  */
    uint   n; /**<  */
    int    datum; /**<  */
    ubyte  pad2[12]; /**<  */
} ;

/**
 * @brief xcb_glx_get_lightfv_cookie_t
 **/
struct xcb_glx_get_lightfv_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_lightfv. */
const uint XCB_GLX_GET_LIGHTFV = 118;

/**
 * @brief xcb_glx_get_lightfv_request_t
 **/
struct xcb_glx_get_lightfv_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  light; /**<  */
    uint                  pname; /**<  */
} ;

/**
 * @brief xcb_glx_get_lightfv_reply_t
 **/
struct xcb_glx_get_lightfv_reply_t {
    ubyte             response_type; /**<  */
    ubyte             pad0; /**<  */
    ushort            sequence; /**<  */
    uint              length; /**<  */
    ubyte             pad1[4]; /**<  */
    uint              n; /**<  */
    xcb_glx_float32_t datum; /**<  */
    ubyte             pad2[12]; /**<  */
} ;

/**
 * @brief xcb_glx_get_lightiv_cookie_t
 **/
struct xcb_glx_get_lightiv_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_lightiv. */
const uint XCB_GLX_GET_LIGHTIV = 119;

/**
 * @brief xcb_glx_get_lightiv_request_t
 **/
struct xcb_glx_get_lightiv_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  light; /**<  */
    uint                  pname; /**<  */
} ;

/**
 * @brief xcb_glx_get_lightiv_reply_t
 **/
struct xcb_glx_get_lightiv_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ubyte  pad1[4]; /**<  */
    uint   n; /**<  */
    int    datum; /**<  */
    ubyte  pad2[12]; /**<  */
} ;

/**
 * @brief xcb_glx_get_mapdv_cookie_t
 **/
struct xcb_glx_get_mapdv_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_mapdv. */
const uint XCB_GLX_GET_MAPDV = 120;

/**
 * @brief xcb_glx_get_mapdv_request_t
 **/
struct xcb_glx_get_mapdv_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  target; /**<  */
    uint                  query; /**<  */
} ;

/**
 * @brief xcb_glx_get_mapdv_reply_t
 **/
struct xcb_glx_get_mapdv_reply_t {
    ubyte             response_type; /**<  */
    ubyte             pad0; /**<  */
    ushort            sequence; /**<  */
    uint              length; /**<  */
    ubyte             pad1[4]; /**<  */
    uint              n; /**<  */
    xcb_glx_float64_t datum; /**<  */
    ubyte             pad2[8]; /**<  */
} ;

/**
 * @brief xcb_glx_get_mapfv_cookie_t
 **/
struct xcb_glx_get_mapfv_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_mapfv. */
const uint XCB_GLX_GET_MAPFV = 121;

/**
 * @brief xcb_glx_get_mapfv_request_t
 **/
struct xcb_glx_get_mapfv_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  target; /**<  */
    uint                  query; /**<  */
} ;

/**
 * @brief xcb_glx_get_mapfv_reply_t
 **/
struct xcb_glx_get_mapfv_reply_t {
    ubyte             response_type; /**<  */
    ubyte             pad0; /**<  */
    ushort            sequence; /**<  */
    uint              length; /**<  */
    ubyte             pad1[4]; /**<  */
    uint              n; /**<  */
    xcb_glx_float32_t datum; /**<  */
    ubyte             pad2[12]; /**<  */
} ;

/**
 * @brief xcb_glx_get_mapiv_cookie_t
 **/
struct xcb_glx_get_mapiv_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_mapiv. */
const uint XCB_GLX_GET_MAPIV = 122;

/**
 * @brief xcb_glx_get_mapiv_request_t
 **/
struct xcb_glx_get_mapiv_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  target; /**<  */
    uint                  query; /**<  */
} ;

/**
 * @brief xcb_glx_get_mapiv_reply_t
 **/
struct xcb_glx_get_mapiv_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ubyte  pad1[4]; /**<  */
    uint   n; /**<  */
    int    datum; /**<  */
    ubyte  pad2[12]; /**<  */
} ;

/**
 * @brief xcb_glx_get_materialfv_cookie_t
 **/
struct xcb_glx_get_materialfv_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_materialfv. */
const uint XCB_GLX_GET_MATERIALFV = 123;

/**
 * @brief xcb_glx_get_materialfv_request_t
 **/
struct xcb_glx_get_materialfv_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  face; /**<  */
    uint                  pname; /**<  */
} ;

/**
 * @brief xcb_glx_get_materialfv_reply_t
 **/
struct xcb_glx_get_materialfv_reply_t {
    ubyte             response_type; /**<  */
    ubyte             pad0; /**<  */
    ushort            sequence; /**<  */
    uint              length; /**<  */
    ubyte             pad1[4]; /**<  */
    uint              n; /**<  */
    xcb_glx_float32_t datum; /**<  */
    ubyte             pad2[12]; /**<  */
} ;

/**
 * @brief xcb_glx_get_materialiv_cookie_t
 **/
struct xcb_glx_get_materialiv_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_materialiv. */
const uint XCB_GLX_GET_MATERIALIV = 124;

/**
 * @brief xcb_glx_get_materialiv_request_t
 **/
struct xcb_glx_get_materialiv_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  face; /**<  */
    uint                  pname; /**<  */
} ;

/**
 * @brief xcb_glx_get_materialiv_reply_t
 **/
struct xcb_glx_get_materialiv_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ubyte  pad1[4]; /**<  */
    uint   n; /**<  */
    int    datum; /**<  */
    ubyte  pad2[12]; /**<  */
} ;

/**
 * @brief xcb_glx_get_pixel_mapfv_cookie_t
 **/
struct xcb_glx_get_pixel_mapfv_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_pixel_mapfv. */
const uint XCB_GLX_GET_PIXEL_MAPFV = 125;

/**
 * @brief xcb_glx_get_pixel_mapfv_request_t
 **/
struct xcb_glx_get_pixel_mapfv_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  map; /**<  */
} ;

/**
 * @brief xcb_glx_get_pixel_mapfv_reply_t
 **/
struct xcb_glx_get_pixel_mapfv_reply_t {
    ubyte             response_type; /**<  */
    ubyte             pad0; /**<  */
    ushort            sequence; /**<  */
    uint              length; /**<  */
    ubyte             pad1[4]; /**<  */
    uint              n; /**<  */
    xcb_glx_float32_t datum; /**<  */
    ubyte             pad2[12]; /**<  */
} ;

/**
 * @brief xcb_glx_get_pixel_mapuiv_cookie_t
 **/
struct xcb_glx_get_pixel_mapuiv_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_pixel_mapuiv. */
const uint XCB_GLX_GET_PIXEL_MAPUIV = 126;

/**
 * @brief xcb_glx_get_pixel_mapuiv_request_t
 **/
struct xcb_glx_get_pixel_mapuiv_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  map; /**<  */
} ;

/**
 * @brief xcb_glx_get_pixel_mapuiv_reply_t
 **/
struct xcb_glx_get_pixel_mapuiv_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ubyte  pad1[4]; /**<  */
    uint   n; /**<  */
    uint   datum; /**<  */
    ubyte  pad2[12]; /**<  */
} ;

/**
 * @brief xcb_glx_get_pixel_mapusv_cookie_t
 **/
struct xcb_glx_get_pixel_mapusv_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_pixel_mapusv. */
const uint XCB_GLX_GET_PIXEL_MAPUSV = 127;

/**
 * @brief xcb_glx_get_pixel_mapusv_request_t
 **/
struct xcb_glx_get_pixel_mapusv_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  map; /**<  */
} ;

/**
 * @brief xcb_glx_get_pixel_mapusv_reply_t
 **/
struct xcb_glx_get_pixel_mapusv_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ubyte  pad1[4]; /**<  */
    uint   n; /**<  */
    ushort datum; /**<  */
    ubyte  pad2[16]; /**<  */
} ;

/**
 * @brief xcb_glx_get_polygon_stipple_cookie_t
 **/
struct xcb_glx_get_polygon_stipple_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_polygon_stipple. */
const uint XCB_GLX_GET_POLYGON_STIPPLE = 128;

/**
 * @brief xcb_glx_get_polygon_stipple_request_t
 **/
struct xcb_glx_get_polygon_stipple_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    bool                  lsb_first; /**<  */
} ;

/**
 * @brief xcb_glx_get_polygon_stipple_reply_t
 **/
struct xcb_glx_get_polygon_stipple_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ubyte  pad1[24]; /**<  */
} ;

/**
 * @brief xcb_glx_get_string_cookie_t
 **/
struct xcb_glx_get_string_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_string. */
const uint XCB_GLX_GET_STRING = 129;

/**
 * @brief xcb_glx_get_string_request_t
 **/
struct xcb_glx_get_string_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  name; /**<  */
} ;

/**
 * @brief xcb_glx_get_string_reply_t
 **/
struct xcb_glx_get_string_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ubyte  pad1[4]; /**<  */
    uint   n; /**<  */
    ubyte  pad2[16]; /**<  */
} ;

/**
 * @brief xcb_glx_get_tex_envfv_cookie_t
 **/
struct xcb_glx_get_tex_envfv_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_tex_envfv. */
const uint XCB_GLX_GET_TEX_ENVFV = 130;

/**
 * @brief xcb_glx_get_tex_envfv_request_t
 **/
struct xcb_glx_get_tex_envfv_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  target; /**<  */
    uint                  pname; /**<  */
} ;

/**
 * @brief xcb_glx_get_tex_envfv_reply_t
 **/
struct xcb_glx_get_tex_envfv_reply_t {
    ubyte             response_type; /**<  */
    ubyte             pad0; /**<  */
    ushort            sequence; /**<  */
    uint              length; /**<  */
    ubyte             pad1[4]; /**<  */
    uint              n; /**<  */
    xcb_glx_float32_t datum; /**<  */
    ubyte             pad2[12]; /**<  */
} ;

/**
 * @brief xcb_glx_get_tex_enviv_cookie_t
 **/
struct xcb_glx_get_tex_enviv_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_tex_enviv. */
const uint XCB_GLX_GET_TEX_ENVIV = 131;

/**
 * @brief xcb_glx_get_tex_enviv_request_t
 **/
struct xcb_glx_get_tex_enviv_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  target; /**<  */
    uint                  pname; /**<  */
} ;

/**
 * @brief xcb_glx_get_tex_enviv_reply_t
 **/
struct xcb_glx_get_tex_enviv_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ubyte  pad1[4]; /**<  */
    uint   n; /**<  */
    int    datum; /**<  */
    ubyte  pad2[12]; /**<  */
} ;

/**
 * @brief xcb_glx_get_tex_gendv_cookie_t
 **/
struct xcb_glx_get_tex_gendv_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_tex_gendv. */
const uint XCB_GLX_GET_TEX_GENDV = 132;

/**
 * @brief xcb_glx_get_tex_gendv_request_t
 **/
struct xcb_glx_get_tex_gendv_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  coord; /**<  */
    uint                  pname; /**<  */
} ;

/**
 * @brief xcb_glx_get_tex_gendv_reply_t
 **/
struct xcb_glx_get_tex_gendv_reply_t {
    ubyte             response_type; /**<  */
    ubyte             pad0; /**<  */
    ushort            sequence; /**<  */
    uint              length; /**<  */
    ubyte             pad1[4]; /**<  */
    uint              n; /**<  */
    xcb_glx_float64_t datum; /**<  */
    ubyte             pad2[8]; /**<  */
} ;

/**
 * @brief xcb_glx_get_tex_genfv_cookie_t
 **/
struct xcb_glx_get_tex_genfv_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_tex_genfv. */
const uint XCB_GLX_GET_TEX_GENFV = 133;

/**
 * @brief xcb_glx_get_tex_genfv_request_t
 **/
struct xcb_glx_get_tex_genfv_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  coord; /**<  */
    uint                  pname; /**<  */
} ;

/**
 * @brief xcb_glx_get_tex_genfv_reply_t
 **/
struct xcb_glx_get_tex_genfv_reply_t {
    ubyte             response_type; /**<  */
    ubyte             pad0; /**<  */
    ushort            sequence; /**<  */
    uint              length; /**<  */
    ubyte             pad1[4]; /**<  */
    uint              n; /**<  */
    xcb_glx_float32_t datum; /**<  */
    ubyte             pad2[12]; /**<  */
} ;

/**
 * @brief xcb_glx_get_tex_geniv_cookie_t
 **/
struct xcb_glx_get_tex_geniv_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_tex_geniv. */
const uint XCB_GLX_GET_TEX_GENIV = 134;

/**
 * @brief xcb_glx_get_tex_geniv_request_t
 **/
struct xcb_glx_get_tex_geniv_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  coord; /**<  */
    uint                  pname; /**<  */
} ;

/**
 * @brief xcb_glx_get_tex_geniv_reply_t
 **/
struct xcb_glx_get_tex_geniv_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ubyte  pad1[4]; /**<  */
    uint   n; /**<  */
    int    datum; /**<  */
    ubyte  pad2[12]; /**<  */
} ;

/**
 * @brief xcb_glx_get_tex_image_cookie_t
 **/
struct xcb_glx_get_tex_image_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_tex_image. */
const uint XCB_GLX_GET_TEX_IMAGE = 135;

/**
 * @brief xcb_glx_get_tex_image_request_t
 **/
struct xcb_glx_get_tex_image_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  target; /**<  */
    int                   level; /**<  */
    uint                  format; /**<  */
    uint                  type; /**<  */
    bool                  swap_bytes; /**<  */
} ;

/**
 * @brief xcb_glx_get_tex_image_reply_t
 **/
struct xcb_glx_get_tex_image_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ubyte  pad1[8]; /**<  */
    int    width; /**<  */
    int    height; /**<  */
    int    depth; /**<  */
    ubyte  pad2[4]; /**<  */
} ;

/**
 * @brief xcb_glx_get_tex_parameterfv_cookie_t
 **/
struct xcb_glx_get_tex_parameterfv_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_tex_parameterfv. */
const uint XCB_GLX_GET_TEX_PARAMETERFV = 136;

/**
 * @brief xcb_glx_get_tex_parameterfv_request_t
 **/
struct xcb_glx_get_tex_parameterfv_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  target; /**<  */
    uint                  pname; /**<  */
} ;

/**
 * @brief xcb_glx_get_tex_parameterfv_reply_t
 **/
struct xcb_glx_get_tex_parameterfv_reply_t {
    ubyte             response_type; /**<  */
    ubyte             pad0; /**<  */
    ushort            sequence; /**<  */
    uint              length; /**<  */
    ubyte             pad1[4]; /**<  */
    uint              n; /**<  */
    xcb_glx_float32_t datum; /**<  */
    ubyte             pad2[12]; /**<  */
} ;

/**
 * @brief xcb_glx_get_tex_parameteriv_cookie_t
 **/
struct xcb_glx_get_tex_parameteriv_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_tex_parameteriv. */
const uint XCB_GLX_GET_TEX_PARAMETERIV = 137;

/**
 * @brief xcb_glx_get_tex_parameteriv_request_t
 **/
struct xcb_glx_get_tex_parameteriv_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  target; /**<  */
    uint                  pname; /**<  */
} ;

/**
 * @brief xcb_glx_get_tex_parameteriv_reply_t
 **/
struct xcb_glx_get_tex_parameteriv_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ubyte  pad1[4]; /**<  */
    uint   n; /**<  */
    int    datum; /**<  */
    ubyte  pad2[12]; /**<  */
} ;

/**
 * @brief xcb_glx_get_tex_level_parameterfv_cookie_t
 **/
struct xcb_glx_get_tex_level_parameterfv_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_tex_level_parameterfv. */
const uint XCB_GLX_GET_TEX_LEVEL_PARAMETERFV = 138;

/**
 * @brief xcb_glx_get_tex_level_parameterfv_request_t
 **/
struct xcb_glx_get_tex_level_parameterfv_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  target; /**<  */
    int                   level; /**<  */
    uint                  pname; /**<  */
} ;

/**
 * @brief xcb_glx_get_tex_level_parameterfv_reply_t
 **/
struct xcb_glx_get_tex_level_parameterfv_reply_t {
    ubyte             response_type; /**<  */
    ubyte             pad0; /**<  */
    ushort            sequence; /**<  */
    uint              length; /**<  */
    ubyte             pad1[4]; /**<  */
    uint              n; /**<  */
    xcb_glx_float32_t datum; /**<  */
    ubyte             pad2[12]; /**<  */
} ;

/**
 * @brief xcb_glx_get_tex_level_parameteriv_cookie_t
 **/
struct xcb_glx_get_tex_level_parameteriv_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_tex_level_parameteriv. */
const uint XCB_GLX_GET_TEX_LEVEL_PARAMETERIV = 139;

/**
 * @brief xcb_glx_get_tex_level_parameteriv_request_t
 **/
struct xcb_glx_get_tex_level_parameteriv_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  target; /**<  */
    int                   level; /**<  */
    uint                  pname; /**<  */
} ;

/**
 * @brief xcb_glx_get_tex_level_parameteriv_reply_t
 **/
struct xcb_glx_get_tex_level_parameteriv_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ubyte  pad1[4]; /**<  */
    uint   n; /**<  */
    int    datum; /**<  */
    ubyte  pad2[12]; /**<  */
} ;

/**
 * @brief xcb_glx_is_list_cookie_t
 **/
struct xcb_glx_is_list_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_is_list. */
const uint XCB_GLX_IS_LIST = 141;

/**
 * @brief xcb_glx_is_list_request_t
 **/
struct xcb_glx_is_list_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  list; /**<  */
} ;

/**
 * @brief xcb_glx_is_list_reply_t
 **/
struct xcb_glx_is_list_reply_t {
    ubyte            response_type; /**<  */
    ubyte            pad0; /**<  */
    ushort           sequence; /**<  */
    uint             length; /**<  */
    xcb_glx_bool32_t ret_val; /**<  */
} ;

/** Opcode for xcb_glx_flush. */
const uint XCB_GLX_FLUSH = 142;

/**
 * @brief xcb_glx_flush_request_t
 **/
struct xcb_glx_flush_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
} ;

/**
 * @brief xcb_glx_are_textures_resident_cookie_t
 **/
struct xcb_glx_are_textures_resident_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_are_textures_resident. */
const uint XCB_GLX_ARE_TEXTURES_RESIDENT = 143;

/**
 * @brief xcb_glx_are_textures_resident_request_t
 **/
struct xcb_glx_are_textures_resident_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    int                   n; /**<  */
} ;

/**
 * @brief xcb_glx_are_textures_resident_reply_t
 **/
struct xcb_glx_are_textures_resident_reply_t {
    ubyte            response_type; /**<  */
    ubyte            pad0; /**<  */
    ushort           sequence; /**<  */
    uint             length; /**<  */
    xcb_glx_bool32_t ret_val; /**<  */
    ubyte            pad1[20]; /**<  */
} ;

/** Opcode for xcb_glx_delete_textures. */
const uint XCB_GLX_DELETE_TEXTURES = 144;

/**
 * @brief xcb_glx_delete_textures_request_t
 **/
struct xcb_glx_delete_textures_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    int                   n; /**<  */
} ;

/**
 * @brief xcb_glx_gen_textures_cookie_t
 **/
struct xcb_glx_gen_textures_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_gen_textures. */
const uint XCB_GLX_GEN_TEXTURES = 145;

/**
 * @brief xcb_glx_gen_textures_request_t
 **/
struct xcb_glx_gen_textures_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    int                   n; /**<  */
} ;

/**
 * @brief xcb_glx_gen_textures_reply_t
 **/
struct xcb_glx_gen_textures_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ubyte  pad1[24]; /**<  */
} ;

/**
 * @brief xcb_glx_is_texture_cookie_t
 **/
struct xcb_glx_is_texture_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_is_texture. */
const uint XCB_GLX_IS_TEXTURE = 146;

/**
 * @brief xcb_glx_is_texture_request_t
 **/
struct xcb_glx_is_texture_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  texture; /**<  */
} ;

/**
 * @brief xcb_glx_is_texture_reply_t
 **/
struct xcb_glx_is_texture_reply_t {
    ubyte            response_type; /**<  */
    ubyte            pad0; /**<  */
    ushort           sequence; /**<  */
    uint             length; /**<  */
    xcb_glx_bool32_t ret_val; /**<  */
} ;

/**
 * @brief xcb_glx_get_color_table_cookie_t
 **/
struct xcb_glx_get_color_table_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_color_table. */
const uint XCB_GLX_GET_COLOR_TABLE = 147;

/**
 * @brief xcb_glx_get_color_table_request_t
 **/
struct xcb_glx_get_color_table_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  target; /**<  */
    uint                  format; /**<  */
    uint                  type; /**<  */
    bool                  swap_bytes; /**<  */
} ;

/**
 * @brief xcb_glx_get_color_table_reply_t
 **/
struct xcb_glx_get_color_table_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ubyte  pad1[8]; /**<  */
    int    width; /**<  */
    ubyte  pad2[12]; /**<  */
} ;

/**
 * @brief xcb_glx_get_color_table_parameterfv_cookie_t
 **/
struct xcb_glx_get_color_table_parameterfv_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_color_table_parameterfv. */
const uint XCB_GLX_GET_COLOR_TABLE_PARAMETERFV = 148;

/**
 * @brief xcb_glx_get_color_table_parameterfv_request_t
 **/
struct xcb_glx_get_color_table_parameterfv_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  target; /**<  */
    uint                  pname; /**<  */
} ;

/**
 * @brief xcb_glx_get_color_table_parameterfv_reply_t
 **/
struct xcb_glx_get_color_table_parameterfv_reply_t {
    ubyte             response_type; /**<  */
    ubyte             pad0; /**<  */
    ushort            sequence; /**<  */
    uint              length; /**<  */
    ubyte             pad1[4]; /**<  */
    uint              n; /**<  */
    xcb_glx_float32_t datum; /**<  */
    ubyte             pad2[12]; /**<  */
} ;

/**
 * @brief xcb_glx_get_color_table_parameteriv_cookie_t
 **/
struct xcb_glx_get_color_table_parameteriv_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_color_table_parameteriv. */
const uint XCB_GLX_GET_COLOR_TABLE_PARAMETERIV = 149;

/**
 * @brief xcb_glx_get_color_table_parameteriv_request_t
 **/
struct xcb_glx_get_color_table_parameteriv_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  target; /**<  */
    uint                  pname; /**<  */
} ;

/**
 * @brief xcb_glx_get_color_table_parameteriv_reply_t
 **/
struct xcb_glx_get_color_table_parameteriv_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ubyte  pad1[4]; /**<  */
    uint   n; /**<  */
    int    datum; /**<  */
    ubyte  pad2[12]; /**<  */
} ;

/**
 * @brief xcb_glx_get_convolution_filter_cookie_t
 **/
struct xcb_glx_get_convolution_filter_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_convolution_filter. */
const uint XCB_GLX_GET_CONVOLUTION_FILTER = 150;

/**
 * @brief xcb_glx_get_convolution_filter_request_t
 **/
struct xcb_glx_get_convolution_filter_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  target; /**<  */
    uint                  format; /**<  */
    uint                  type; /**<  */
    bool                  swap_bytes; /**<  */
} ;

/**
 * @brief xcb_glx_get_convolution_filter_reply_t
 **/
struct xcb_glx_get_convolution_filter_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ubyte  pad1[8]; /**<  */
    int    width; /**<  */
    int    height; /**<  */
    ubyte  pad2[8]; /**<  */
} ;

/**
 * @brief xcb_glx_get_convolution_parameterfv_cookie_t
 **/
struct xcb_glx_get_convolution_parameterfv_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_convolution_parameterfv. */
const uint XCB_GLX_GET_CONVOLUTION_PARAMETERFV = 151;

/**
 * @brief xcb_glx_get_convolution_parameterfv_request_t
 **/
struct xcb_glx_get_convolution_parameterfv_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  target; /**<  */
    uint                  pname; /**<  */
} ;

/**
 * @brief xcb_glx_get_convolution_parameterfv_reply_t
 **/
struct xcb_glx_get_convolution_parameterfv_reply_t {
    ubyte             response_type; /**<  */
    ubyte             pad0; /**<  */
    ushort            sequence; /**<  */
    uint              length; /**<  */
    ubyte             pad1[4]; /**<  */
    uint              n; /**<  */
    xcb_glx_float32_t datum; /**<  */
    ubyte             pad2[12]; /**<  */
} ;

/**
 * @brief xcb_glx_get_convolution_parameteriv_cookie_t
 **/
struct xcb_glx_get_convolution_parameteriv_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_convolution_parameteriv. */
const uint XCB_GLX_GET_CONVOLUTION_PARAMETERIV = 152;

/**
 * @brief xcb_glx_get_convolution_parameteriv_request_t
 **/
struct xcb_glx_get_convolution_parameteriv_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  target; /**<  */
    uint                  pname; /**<  */
} ;

/**
 * @brief xcb_glx_get_convolution_parameteriv_reply_t
 **/
struct xcb_glx_get_convolution_parameteriv_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ubyte  pad1[4]; /**<  */
    uint   n; /**<  */
    int    datum; /**<  */
    ubyte  pad2[12]; /**<  */
} ;

/**
 * @brief xcb_glx_get_separable_filter_cookie_t
 **/
struct xcb_glx_get_separable_filter_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_separable_filter. */
const uint XCB_GLX_GET_SEPARABLE_FILTER = 153;

/**
 * @brief xcb_glx_get_separable_filter_request_t
 **/
struct xcb_glx_get_separable_filter_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  target; /**<  */
    uint                  format; /**<  */
    uint                  type; /**<  */
    bool                  swap_bytes; /**<  */
} ;

/**
 * @brief xcb_glx_get_separable_filter_reply_t
 **/
struct xcb_glx_get_separable_filter_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ubyte  pad1[8]; /**<  */
    int    row_w; /**<  */
    int    col_h; /**<  */
    ubyte  pad2[8]; /**<  */
} ;

/**
 * @brief xcb_glx_get_histogram_cookie_t
 **/
struct xcb_glx_get_histogram_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_histogram. */
const uint XCB_GLX_GET_HISTOGRAM = 154;

/**
 * @brief xcb_glx_get_histogram_request_t
 **/
struct xcb_glx_get_histogram_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  target; /**<  */
    uint                  format; /**<  */
    uint                  type; /**<  */
    bool                  swap_bytes; /**<  */
    bool                  reset; /**<  */
} ;

/**
 * @brief xcb_glx_get_histogram_reply_t
 **/
struct xcb_glx_get_histogram_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ubyte  pad1[8]; /**<  */
    int    width; /**<  */
    ubyte  pad2[12]; /**<  */
} ;

/**
 * @brief xcb_glx_get_histogram_parameterfv_cookie_t
 **/
struct xcb_glx_get_histogram_parameterfv_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_histogram_parameterfv. */
const uint XCB_GLX_GET_HISTOGRAM_PARAMETERFV = 155;

/**
 * @brief xcb_glx_get_histogram_parameterfv_request_t
 **/
struct xcb_glx_get_histogram_parameterfv_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  target; /**<  */
    uint                  pname; /**<  */
} ;

/**
 * @brief xcb_glx_get_histogram_parameterfv_reply_t
 **/
struct xcb_glx_get_histogram_parameterfv_reply_t {
    ubyte             response_type; /**<  */
    ubyte             pad0; /**<  */
    ushort            sequence; /**<  */
    uint              length; /**<  */
    ubyte             pad1[4]; /**<  */
    uint              n; /**<  */
    xcb_glx_float32_t datum; /**<  */
    ubyte             pad2[12]; /**<  */
} ;

/**
 * @brief xcb_glx_get_histogram_parameteriv_cookie_t
 **/
struct xcb_glx_get_histogram_parameteriv_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_histogram_parameteriv. */
const uint XCB_GLX_GET_HISTOGRAM_PARAMETERIV = 156;

/**
 * @brief xcb_glx_get_histogram_parameteriv_request_t
 **/
struct xcb_glx_get_histogram_parameteriv_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  target; /**<  */
    uint                  pname; /**<  */
} ;

/**
 * @brief xcb_glx_get_histogram_parameteriv_reply_t
 **/
struct xcb_glx_get_histogram_parameteriv_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ubyte  pad1[4]; /**<  */
    uint   n; /**<  */
    int    datum; /**<  */
    ubyte  pad2[12]; /**<  */
} ;

/**
 * @brief xcb_glx_get_minmax_cookie_t
 **/
struct xcb_glx_get_minmax_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_minmax. */
const uint XCB_GLX_GET_MINMAX = 157;

/**
 * @brief xcb_glx_get_minmax_request_t
 **/
struct xcb_glx_get_minmax_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  target; /**<  */
    uint                  format; /**<  */
    uint                  type; /**<  */
    bool                  swap_bytes; /**<  */
    bool                  reset; /**<  */
} ;

/**
 * @brief xcb_glx_get_minmax_reply_t
 **/
struct xcb_glx_get_minmax_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ubyte  pad1[24]; /**<  */
} ;

/**
 * @brief xcb_glx_get_minmax_parameterfv_cookie_t
 **/
struct xcb_glx_get_minmax_parameterfv_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_minmax_parameterfv. */
const uint XCB_GLX_GET_MINMAX_PARAMETERFV = 158;

/**
 * @brief xcb_glx_get_minmax_parameterfv_request_t
 **/
struct xcb_glx_get_minmax_parameterfv_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  target; /**<  */
    uint                  pname; /**<  */
} ;

/**
 * @brief xcb_glx_get_minmax_parameterfv_reply_t
 **/
struct xcb_glx_get_minmax_parameterfv_reply_t {
    ubyte             response_type; /**<  */
    ubyte             pad0; /**<  */
    ushort            sequence; /**<  */
    uint              length; /**<  */
    ubyte             pad1[4]; /**<  */
    uint              n; /**<  */
    xcb_glx_float32_t datum; /**<  */
    ubyte             pad2[12]; /**<  */
} ;

/**
 * @brief xcb_glx_get_minmax_parameteriv_cookie_t
 **/
struct xcb_glx_get_minmax_parameteriv_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_minmax_parameteriv. */
const uint XCB_GLX_GET_MINMAX_PARAMETERIV = 159;

/**
 * @brief xcb_glx_get_minmax_parameteriv_request_t
 **/
struct xcb_glx_get_minmax_parameteriv_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  target; /**<  */
    uint                  pname; /**<  */
} ;

/**
 * @brief xcb_glx_get_minmax_parameteriv_reply_t
 **/
struct xcb_glx_get_minmax_parameteriv_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ubyte  pad1[4]; /**<  */
    uint   n; /**<  */
    int    datum; /**<  */
    ubyte  pad2[12]; /**<  */
} ;

/**
 * @brief xcb_glx_get_compressed_tex_image_arb_cookie_t
 **/
struct xcb_glx_get_compressed_tex_image_arb_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_compressed_tex_image_arb. */
const uint XCB_GLX_GET_COMPRESSED_TEX_IMAGE_ARB = 160;

/**
 * @brief xcb_glx_get_compressed_tex_image_arb_request_t
 **/
struct xcb_glx_get_compressed_tex_image_arb_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  target; /**<  */
    int                   level; /**<  */
} ;

/**
 * @brief xcb_glx_get_compressed_tex_image_arb_reply_t
 **/
struct xcb_glx_get_compressed_tex_image_arb_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ubyte  pad1[8]; /**<  */
    int    size; /**<  */
    ubyte  pad2[12]; /**<  */
} ;

/** Opcode for xcb_glx_delete_queries_arb. */
const uint XCB_GLX_DELETE_QUERIES_ARB = 161;

/**
 * @brief xcb_glx_delete_queries_arb_request_t
 **/
struct xcb_glx_delete_queries_arb_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    int                   n; /**<  */
} ;

/**
 * @brief xcb_glx_gen_queries_arb_cookie_t
 **/
struct xcb_glx_gen_queries_arb_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_gen_queries_arb. */
const uint XCB_GLX_GEN_QUERIES_ARB = 162;

/**
 * @brief xcb_glx_gen_queries_arb_request_t
 **/
struct xcb_glx_gen_queries_arb_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    int                   n; /**<  */
} ;

/**
 * @brief xcb_glx_gen_queries_arb_reply_t
 **/
struct xcb_glx_gen_queries_arb_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ubyte  pad1[24]; /**<  */
} ;

/**
 * @brief xcb_glx_is_query_arb_cookie_t
 **/
struct xcb_glx_is_query_arb_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_is_query_arb. */
const uint XCB_GLX_IS_QUERY_ARB = 163;

/**
 * @brief xcb_glx_is_query_arb_request_t
 **/
struct xcb_glx_is_query_arb_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  id; /**<  */
} ;

/**
 * @brief xcb_glx_is_query_arb_reply_t
 **/
struct xcb_glx_is_query_arb_reply_t {
    ubyte            response_type; /**<  */
    ubyte            pad0; /**<  */
    ushort           sequence; /**<  */
    uint             length; /**<  */
    xcb_glx_bool32_t ret_val; /**<  */
} ;

/**
 * @brief xcb_glx_get_queryiv_arb_cookie_t
 **/
struct xcb_glx_get_queryiv_arb_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_queryiv_arb. */
const uint XCB_GLX_GET_QUERYIV_ARB = 164;

/**
 * @brief xcb_glx_get_queryiv_arb_request_t
 **/
struct xcb_glx_get_queryiv_arb_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  target; /**<  */
    uint                  pname; /**<  */
} ;

/**
 * @brief xcb_glx_get_queryiv_arb_reply_t
 **/
struct xcb_glx_get_queryiv_arb_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ubyte  pad1[4]; /**<  */
    uint   n; /**<  */
    int    datum; /**<  */
    ubyte  pad2[12]; /**<  */
} ;

/**
 * @brief xcb_glx_get_query_objectiv_arb_cookie_t
 **/
struct xcb_glx_get_query_objectiv_arb_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_query_objectiv_arb. */
const uint XCB_GLX_GET_QUERY_OBJECTIV_ARB = 165;

/**
 * @brief xcb_glx_get_query_objectiv_arb_request_t
 **/
struct xcb_glx_get_query_objectiv_arb_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  id; /**<  */
    uint                  pname; /**<  */
} ;

/**
 * @brief xcb_glx_get_query_objectiv_arb_reply_t
 **/
struct xcb_glx_get_query_objectiv_arb_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ubyte  pad1[4]; /**<  */
    uint   n; /**<  */
    int    datum; /**<  */
    ubyte  pad2[12]; /**<  */
} ;

/**
 * @brief xcb_glx_get_query_objectuiv_arb_cookie_t
 **/
struct xcb_glx_get_query_objectuiv_arb_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_glx_get_query_objectuiv_arb. */
const uint XCB_GLX_GET_QUERY_OBJECTUIV_ARB = 166;

/**
 * @brief xcb_glx_get_query_objectuiv_arb_request_t
 **/
struct xcb_glx_get_query_objectuiv_arb_request_t {
    ubyte                 major_opcode; /**<  */
    ubyte                 minor_opcode; /**<  */
    ushort                length; /**<  */
    xcb_glx_context_tag_t context_tag; /**<  */
    uint                  id; /**<  */
    uint                  pname; /**<  */
} ;

/**
 * @brief xcb_glx_get_query_objectuiv_arb_reply_t
 **/
struct xcb_glx_get_query_objectuiv_arb_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ubyte  pad1[4]; /**<  */
    uint   n; /**<  */
    uint   datum; /**<  */
    ubyte  pad2[12]; /**<  */
} ;


/*****************************************************************************
 **
 ** void xcb_glx_pixmap_next
 **
 ** @param xcb_glx_pixmap_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_glx_pixmap_next (xcb_glx_pixmap_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_pixmap_end
 **
 ** @param xcb_glx_pixmap_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_pixmap_end (xcb_glx_pixmap_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_glx_context_next
 **
 ** @param xcb_glx_context_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_glx_context_next (xcb_glx_context_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_context_end
 **
 ** @param xcb_glx_context_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_context_end (xcb_glx_context_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_glx_pbuffer_next
 **
 ** @param xcb_glx_pbuffer_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_glx_pbuffer_next (xcb_glx_pbuffer_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_pbuffer_end
 **
 ** @param xcb_glx_pbuffer_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_pbuffer_end (xcb_glx_pbuffer_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_glx_window_next
 **
 ** @param xcb_glx_window_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_glx_window_next (xcb_glx_window_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_window_end
 **
 ** @param xcb_glx_window_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_window_end (xcb_glx_window_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_glx_fbconfig_next
 **
 ** @param xcb_glx_fbconfig_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_glx_fbconfig_next (xcb_glx_fbconfig_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_fbconfig_end
 **
 ** @param xcb_glx_fbconfig_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_fbconfig_end (xcb_glx_fbconfig_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_glx_drawable_next
 **
 ** @param xcb_glx_drawable_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_glx_drawable_next (xcb_glx_drawable_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_drawable_end
 **
 ** @param xcb_glx_drawable_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_drawable_end (xcb_glx_drawable_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_glx_float32_next
 **
 ** @param xcb_glx_float32_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_glx_float32_next (xcb_glx_float32_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_float32_end
 **
 ** @param xcb_glx_float32_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_float32_end (xcb_glx_float32_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_glx_float64_next
 **
 ** @param xcb_glx_float64_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_glx_float64_next (xcb_glx_float64_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_float64_end
 **
 ** @param xcb_glx_float64_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_float64_end (xcb_glx_float64_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_glx_bool32_next
 **
 ** @param xcb_glx_bool32_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_glx_bool32_next (xcb_glx_bool32_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_bool32_end
 **
 ** @param xcb_glx_bool32_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_bool32_end (xcb_glx_bool32_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_glx_context_tag_next
 **
 ** @param xcb_glx_context_tag_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_glx_context_tag_next (xcb_glx_context_tag_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_context_tag_end
 **
 ** @param xcb_glx_context_tag_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_context_tag_end (xcb_glx_context_tag_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_render_checked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   data_len
 ** @param /+const+/ ubyte       *data
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_render_checked (xcb_connection_t      *c  /**< */,
                        xcb_glx_context_tag_t  context_tag  /**< */,
                        uint                   data_len  /**< */,
                        /+const+/ ubyte       *data  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_render
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   data_len
 ** @param /+const+/ ubyte       *data
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_render (xcb_connection_t      *c  /**< */,
                xcb_glx_context_tag_t  context_tag  /**< */,
                uint                   data_len  /**< */,
                /+const+/ ubyte       *data  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_render_large_checked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param ushort                 request_num
 ** @param ushort                 request_total
 ** @param uint                   data_len
 ** @param /+const+/ ubyte       *data
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_render_large_checked (xcb_connection_t      *c  /**< */,
                              xcb_glx_context_tag_t  context_tag  /**< */,
                              ushort                 request_num  /**< */,
                              ushort                 request_total  /**< */,
                              uint                   data_len  /**< */,
                              /+const+/ ubyte       *data  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_render_large
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param ushort                 request_num
 ** @param ushort                 request_total
 ** @param uint                   data_len
 ** @param /+const+/ ubyte       *data
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_render_large (xcb_connection_t      *c  /**< */,
                      xcb_glx_context_tag_t  context_tag  /**< */,
                      ushort                 request_num  /**< */,
                      ushort                 request_total  /**< */,
                      uint                   data_len  /**< */,
                      /+const+/ ubyte       *data  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_create_context_checked
 **
 ** @param xcb_connection_t  *c
 ** @param xcb_glx_context_t  context
 ** @param xcb_visualid_t     visual
 ** @param uint               screen
 ** @param xcb_glx_context_t  share_list
 ** @param bool               is_direct
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_create_context_checked (xcb_connection_t  *c  /**< */,
                                xcb_glx_context_t  context  /**< */,
                                xcb_visualid_t     visual  /**< */,
                                uint               screen  /**< */,
                                xcb_glx_context_t  share_list  /**< */,
                                bool               is_direct  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_create_context
 **
 ** @param xcb_connection_t  *c
 ** @param xcb_glx_context_t  context
 ** @param xcb_visualid_t     visual
 ** @param uint               screen
 ** @param xcb_glx_context_t  share_list
 ** @param bool               is_direct
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_create_context (xcb_connection_t  *c  /**< */,
                        xcb_glx_context_t  context  /**< */,
                        xcb_visualid_t     visual  /**< */,
                        uint               screen  /**< */,
                        xcb_glx_context_t  share_list  /**< */,
                        bool               is_direct  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_destroy_context_checked
 **
 ** @param xcb_connection_t  *c
 ** @param xcb_glx_context_t  context
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_destroy_context_checked (xcb_connection_t  *c  /**< */,
                                 xcb_glx_context_t  context  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_destroy_context
 **
 ** @param xcb_connection_t  *c
 ** @param xcb_glx_context_t  context
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_destroy_context (xcb_connection_t  *c  /**< */,
                         xcb_glx_context_t  context  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_make_current_cookie_t xcb_glx_make_current
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_drawable_t     drawable
 ** @param xcb_glx_context_t      context
 ** @param xcb_glx_context_tag_t  old_context_tag
 ** @returns xcb_glx_make_current_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_make_current_cookie_t
xcb_glx_make_current (xcb_connection_t      *c  /**< */,
                      xcb_glx_drawable_t     drawable  /**< */,
                      xcb_glx_context_t      context  /**< */,
                      xcb_glx_context_tag_t  old_context_tag  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_make_current_cookie_t xcb_glx_make_current_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_drawable_t     drawable
 ** @param xcb_glx_context_t      context
 ** @param xcb_glx_context_tag_t  old_context_tag
 ** @returns xcb_glx_make_current_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_make_current_cookie_t
xcb_glx_make_current_unchecked (xcb_connection_t      *c  /**< */,
                                xcb_glx_drawable_t     drawable  /**< */,
                                xcb_glx_context_t      context  /**< */,
                                xcb_glx_context_tag_t  old_context_tag  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_make_current_reply_t * xcb_glx_make_current_reply
 **
 ** @param xcb_connection_t               *c
 ** @param xcb_glx_make_current_cookie_t   cookie
 ** @param xcb_generic_error_t           **e
 ** @returns xcb_glx_make_current_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_make_current_reply_t *
xcb_glx_make_current_reply (xcb_connection_t               *c  /**< */,
                            xcb_glx_make_current_cookie_t   cookie  /**< */,
                            xcb_generic_error_t           **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_is_direct_cookie_t xcb_glx_is_direct
 **
 ** @param xcb_connection_t  *c
 ** @param xcb_glx_context_t  context
 ** @returns xcb_glx_is_direct_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_is_direct_cookie_t
xcb_glx_is_direct (xcb_connection_t  *c  /**< */,
                   xcb_glx_context_t  context  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_is_direct_cookie_t xcb_glx_is_direct_unchecked
 **
 ** @param xcb_connection_t  *c
 ** @param xcb_glx_context_t  context
 ** @returns xcb_glx_is_direct_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_is_direct_cookie_t
xcb_glx_is_direct_unchecked (xcb_connection_t  *c  /**< */,
                             xcb_glx_context_t  context  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_is_direct_reply_t * xcb_glx_is_direct_reply
 **
 ** @param xcb_connection_t            *c
 ** @param xcb_glx_is_direct_cookie_t   cookie
 ** @param xcb_generic_error_t        **e
 ** @returns xcb_glx_is_direct_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_is_direct_reply_t *
xcb_glx_is_direct_reply (xcb_connection_t            *c  /**< */,
                         xcb_glx_is_direct_cookie_t   cookie  /**< */,
                         xcb_generic_error_t        **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_query_version_cookie_t xcb_glx_query_version
 **
 ** @param xcb_connection_t *c
 ** @param uint              major_version
 ** @param uint              minor_version
 ** @returns xcb_glx_query_version_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_query_version_cookie_t
xcb_glx_query_version (xcb_connection_t *c  /**< */,
                       uint              major_version  /**< */,
                       uint              minor_version  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_query_version_cookie_t xcb_glx_query_version_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param uint              major_version
 ** @param uint              minor_version
 ** @returns xcb_glx_query_version_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_query_version_cookie_t
xcb_glx_query_version_unchecked (xcb_connection_t *c  /**< */,
                                 uint              major_version  /**< */,
                                 uint              minor_version  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_query_version_reply_t * xcb_glx_query_version_reply
 **
 ** @param xcb_connection_t                *c
 ** @param xcb_glx_query_version_cookie_t   cookie
 ** @param xcb_generic_error_t            **e
 ** @returns xcb_glx_query_version_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_query_version_reply_t *
xcb_glx_query_version_reply (xcb_connection_t                *c  /**< */,
                             xcb_glx_query_version_cookie_t   cookie  /**< */,
                             xcb_generic_error_t            **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_wait_gl_checked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_wait_gl_checked (xcb_connection_t      *c  /**< */,
                         xcb_glx_context_tag_t  context_tag  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_wait_gl
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_wait_gl (xcb_connection_t      *c  /**< */,
                 xcb_glx_context_tag_t  context_tag  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_wait_x_checked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_wait_x_checked (xcb_connection_t      *c  /**< */,
                        xcb_glx_context_tag_t  context_tag  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_wait_x
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_wait_x (xcb_connection_t      *c  /**< */,
                xcb_glx_context_tag_t  context_tag  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_copy_context_checked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_t      src
 ** @param xcb_glx_context_t      dest
 ** @param uint                   mask
 ** @param xcb_glx_context_tag_t  src_context_tag
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_copy_context_checked (xcb_connection_t      *c  /**< */,
                              xcb_glx_context_t      src  /**< */,
                              xcb_glx_context_t      dest  /**< */,
                              uint                   mask  /**< */,
                              xcb_glx_context_tag_t  src_context_tag  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_copy_context
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_t      src
 ** @param xcb_glx_context_t      dest
 ** @param uint                   mask
 ** @param xcb_glx_context_tag_t  src_context_tag
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_copy_context (xcb_connection_t      *c  /**< */,
                      xcb_glx_context_t      src  /**< */,
                      xcb_glx_context_t      dest  /**< */,
                      uint                   mask  /**< */,
                      xcb_glx_context_tag_t  src_context_tag  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_swap_buffers_checked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param xcb_glx_drawable_t     drawable
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_swap_buffers_checked (xcb_connection_t      *c  /**< */,
                              xcb_glx_context_tag_t  context_tag  /**< */,
                              xcb_glx_drawable_t     drawable  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_swap_buffers
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param xcb_glx_drawable_t     drawable
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_swap_buffers (xcb_connection_t      *c  /**< */,
                      xcb_glx_context_tag_t  context_tag  /**< */,
                      xcb_glx_drawable_t     drawable  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_use_x_font_checked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param xcb_font_t             font
 ** @param uint                   first
 ** @param uint                   count
 ** @param uint                   list_base
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_use_x_font_checked (xcb_connection_t      *c  /**< */,
                            xcb_glx_context_tag_t  context_tag  /**< */,
                            xcb_font_t             font  /**< */,
                            uint                   first  /**< */,
                            uint                   count  /**< */,
                            uint                   list_base  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_use_x_font
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param xcb_font_t             font
 ** @param uint                   first
 ** @param uint                   count
 ** @param uint                   list_base
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_use_x_font (xcb_connection_t      *c  /**< */,
                    xcb_glx_context_tag_t  context_tag  /**< */,
                    xcb_font_t             font  /**< */,
                    uint                   first  /**< */,
                    uint                   count  /**< */,
                    uint                   list_base  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_create_glx_pixmap_checked
 **
 ** @param xcb_connection_t *c
 ** @param uint              screen
 ** @param xcb_visualid_t    visual
 ** @param xcb_pixmap_t      pixmap
 ** @param xcb_glx_pixmap_t  glx_pixmap
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_create_glx_pixmap_checked (xcb_connection_t *c  /**< */,
                                   uint              screen  /**< */,
                                   xcb_visualid_t    visual  /**< */,
                                   xcb_pixmap_t      pixmap  /**< */,
                                   xcb_glx_pixmap_t  glx_pixmap  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_create_glx_pixmap
 **
 ** @param xcb_connection_t *c
 ** @param uint              screen
 ** @param xcb_visualid_t    visual
 ** @param xcb_pixmap_t      pixmap
 ** @param xcb_glx_pixmap_t  glx_pixmap
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_create_glx_pixmap (xcb_connection_t *c  /**< */,
                           uint              screen  /**< */,
                           xcb_visualid_t    visual  /**< */,
                           xcb_pixmap_t      pixmap  /**< */,
                           xcb_glx_pixmap_t  glx_pixmap  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_visual_configs_cookie_t xcb_glx_get_visual_configs
 **
 ** @param xcb_connection_t *c
 ** @param uint              screen
 ** @returns xcb_glx_get_visual_configs_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_visual_configs_cookie_t
xcb_glx_get_visual_configs (xcb_connection_t *c  /**< */,
                            uint              screen  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_visual_configs_cookie_t xcb_glx_get_visual_configs_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param uint              screen
 ** @returns xcb_glx_get_visual_configs_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_visual_configs_cookie_t
xcb_glx_get_visual_configs_unchecked (xcb_connection_t *c  /**< */,
                                      uint              screen  /**< */);


/*****************************************************************************
 **
 ** uint * xcb_glx_get_visual_configs_property_list
 **
 ** @param /+const+/ xcb_glx_get_visual_configs_reply_t *R
 ** @returns uint *
 **
 *****************************************************************************/

extern(C) uint *
xcb_glx_get_visual_configs_property_list (/+const+/ xcb_glx_get_visual_configs_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_visual_configs_property_list_length
 **
 ** @param /+const+/ xcb_glx_get_visual_configs_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_visual_configs_property_list_length (/+const+/ xcb_glx_get_visual_configs_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_get_visual_configs_property_list_end
 **
 ** @param /+const+/ xcb_glx_get_visual_configs_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_get_visual_configs_property_list_end (/+const+/ xcb_glx_get_visual_configs_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_visual_configs_reply_t * xcb_glx_get_visual_configs_reply
 **
 ** @param xcb_connection_t                     *c
 ** @param xcb_glx_get_visual_configs_cookie_t   cookie
 ** @param xcb_generic_error_t                 **e
 ** @returns xcb_glx_get_visual_configs_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_visual_configs_reply_t *
xcb_glx_get_visual_configs_reply (xcb_connection_t                     *c  /**< */,
                                  xcb_glx_get_visual_configs_cookie_t   cookie  /**< */,
                                  xcb_generic_error_t                 **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_destroy_glx_pixmap_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_glx_pixmap_t  glx_pixmap
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_destroy_glx_pixmap_checked (xcb_connection_t *c  /**< */,
                                    xcb_glx_pixmap_t  glx_pixmap  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_destroy_glx_pixmap
 **
 ** @param xcb_connection_t *c
 ** @param xcb_glx_pixmap_t  glx_pixmap
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_destroy_glx_pixmap (xcb_connection_t *c  /**< */,
                            xcb_glx_pixmap_t  glx_pixmap  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_vendor_private_checked
 **
 ** @param xcb_connection_t      *c
 ** @param uint                   vendor_code
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   data_len
 ** @param /+const+/ ubyte       *data
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_vendor_private_checked (xcb_connection_t      *c  /**< */,
                                uint                   vendor_code  /**< */,
                                xcb_glx_context_tag_t  context_tag  /**< */,
                                uint                   data_len  /**< */,
                                /+const+/ ubyte       *data  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_vendor_private
 **
 ** @param xcb_connection_t      *c
 ** @param uint                   vendor_code
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   data_len
 ** @param /+const+/ ubyte       *data
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_vendor_private (xcb_connection_t      *c  /**< */,
                        uint                   vendor_code  /**< */,
                        xcb_glx_context_tag_t  context_tag  /**< */,
                        uint                   data_len  /**< */,
                        /+const+/ ubyte       *data  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_vendor_private_with_reply_cookie_t xcb_glx_vendor_private_with_reply
 **
 ** @param xcb_connection_t      *c
 ** @param uint                   vendor_code
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   data_len
 ** @param /+const+/ ubyte       *data
 ** @returns xcb_glx_vendor_private_with_reply_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_vendor_private_with_reply_cookie_t
xcb_glx_vendor_private_with_reply (xcb_connection_t      *c  /**< */,
                                   uint                   vendor_code  /**< */,
                                   xcb_glx_context_tag_t  context_tag  /**< */,
                                   uint                   data_len  /**< */,
                                   /+const+/ ubyte       *data  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_vendor_private_with_reply_cookie_t xcb_glx_vendor_private_with_reply_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param uint                   vendor_code
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   data_len
 ** @param /+const+/ ubyte       *data
 ** @returns xcb_glx_vendor_private_with_reply_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_vendor_private_with_reply_cookie_t
xcb_glx_vendor_private_with_reply_unchecked (xcb_connection_t      *c  /**< */,
                                             uint                   vendor_code  /**< */,
                                             xcb_glx_context_tag_t  context_tag  /**< */,
                                             uint                   data_len  /**< */,
                                             /+const+/ ubyte       *data  /**< */);


/*****************************************************************************
 **
 ** ubyte * xcb_glx_vendor_private_with_reply_data_2
 **
 ** @param /+const+/ xcb_glx_vendor_private_with_reply_reply_t *R
 ** @returns ubyte *
 **
 *****************************************************************************/

extern(C) ubyte *
xcb_glx_vendor_private_with_reply_data_2 (/+const+/ xcb_glx_vendor_private_with_reply_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_vendor_private_with_reply_data_2_length
 **
 ** @param /+const+/ xcb_glx_vendor_private_with_reply_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_vendor_private_with_reply_data_2_length (/+const+/ xcb_glx_vendor_private_with_reply_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_vendor_private_with_reply_data_2_end
 **
 ** @param /+const+/ xcb_glx_vendor_private_with_reply_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_vendor_private_with_reply_data_2_end (/+const+/ xcb_glx_vendor_private_with_reply_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_vendor_private_with_reply_reply_t * xcb_glx_vendor_private_with_reply_reply
 **
 ** @param xcb_connection_t                            *c
 ** @param xcb_glx_vendor_private_with_reply_cookie_t   cookie
 ** @param xcb_generic_error_t                        **e
 ** @returns xcb_glx_vendor_private_with_reply_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_vendor_private_with_reply_reply_t *
xcb_glx_vendor_private_with_reply_reply (xcb_connection_t                            *c  /**< */,
                                         xcb_glx_vendor_private_with_reply_cookie_t   cookie  /**< */,
                                         xcb_generic_error_t                        **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_query_extensions_string_cookie_t xcb_glx_query_extensions_string
 **
 ** @param xcb_connection_t *c
 ** @param uint              screen
 ** @returns xcb_glx_query_extensions_string_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_query_extensions_string_cookie_t
xcb_glx_query_extensions_string (xcb_connection_t *c  /**< */,
                                 uint              screen  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_query_extensions_string_cookie_t xcb_glx_query_extensions_string_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param uint              screen
 ** @returns xcb_glx_query_extensions_string_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_query_extensions_string_cookie_t
xcb_glx_query_extensions_string_unchecked (xcb_connection_t *c  /**< */,
                                           uint              screen  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_query_extensions_string_reply_t * xcb_glx_query_extensions_string_reply
 **
 ** @param xcb_connection_t                          *c
 ** @param xcb_glx_query_extensions_string_cookie_t   cookie
 ** @param xcb_generic_error_t                      **e
 ** @returns xcb_glx_query_extensions_string_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_query_extensions_string_reply_t *
xcb_glx_query_extensions_string_reply (xcb_connection_t                          *c  /**< */,
                                       xcb_glx_query_extensions_string_cookie_t   cookie  /**< */,
                                       xcb_generic_error_t                      **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_query_server_string_cookie_t xcb_glx_query_server_string
 **
 ** @param xcb_connection_t *c
 ** @param uint              screen
 ** @param uint              name
 ** @returns xcb_glx_query_server_string_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_query_server_string_cookie_t
xcb_glx_query_server_string (xcb_connection_t *c  /**< */,
                             uint              screen  /**< */,
                             uint              name  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_query_server_string_cookie_t xcb_glx_query_server_string_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param uint              screen
 ** @param uint              name
 ** @returns xcb_glx_query_server_string_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_query_server_string_cookie_t
xcb_glx_query_server_string_unchecked (xcb_connection_t *c  /**< */,
                                       uint              screen  /**< */,
                                       uint              name  /**< */);


/*****************************************************************************
 **
 ** ubyte * xcb_glx_query_server_string_string
 **
 ** @param /+const+/ xcb_glx_query_server_string_reply_t *R
 ** @returns ubyte *
 **
 *****************************************************************************/

extern(C) ubyte *
xcb_glx_query_server_string_string (/+const+/ xcb_glx_query_server_string_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_query_server_string_string_length
 **
 ** @param /+const+/ xcb_glx_query_server_string_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_query_server_string_string_length (/+const+/ xcb_glx_query_server_string_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_query_server_string_string_end
 **
 ** @param /+const+/ xcb_glx_query_server_string_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_query_server_string_string_end (/+const+/ xcb_glx_query_server_string_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_query_server_string_reply_t * xcb_glx_query_server_string_reply
 **
 ** @param xcb_connection_t                      *c
 ** @param xcb_glx_query_server_string_cookie_t   cookie
 ** @param xcb_generic_error_t                  **e
 ** @returns xcb_glx_query_server_string_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_query_server_string_reply_t *
xcb_glx_query_server_string_reply (xcb_connection_t                      *c  /**< */,
                                   xcb_glx_query_server_string_cookie_t   cookie  /**< */,
                                   xcb_generic_error_t                  **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_client_info_checked
 **
 ** @param xcb_connection_t *c
 ** @param uint              major_version
 ** @param uint              minor_version
 ** @param uint              str_len
 ** @param /+const+/ ubyte  *string
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_client_info_checked (xcb_connection_t *c  /**< */,
                             uint              major_version  /**< */,
                             uint              minor_version  /**< */,
                             uint              str_len  /**< */,
                             /+const+/ ubyte  *string  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_client_info
 **
 ** @param xcb_connection_t *c
 ** @param uint              major_version
 ** @param uint              minor_version
 ** @param uint              str_len
 ** @param /+const+/ ubyte  *string
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_client_info (xcb_connection_t *c  /**< */,
                     uint              major_version  /**< */,
                     uint              minor_version  /**< */,
                     uint              str_len  /**< */,
                     /+const+/ ubyte  *string  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_fb_configs_cookie_t xcb_glx_get_fb_configs
 **
 ** @param xcb_connection_t *c
 ** @param uint              screen
 ** @returns xcb_glx_get_fb_configs_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_fb_configs_cookie_t
xcb_glx_get_fb_configs (xcb_connection_t *c  /**< */,
                        uint              screen  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_fb_configs_cookie_t xcb_glx_get_fb_configs_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param uint              screen
 ** @returns xcb_glx_get_fb_configs_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_fb_configs_cookie_t
xcb_glx_get_fb_configs_unchecked (xcb_connection_t *c  /**< */,
                                  uint              screen  /**< */);


/*****************************************************************************
 **
 ** uint * xcb_glx_get_fb_configs_property_list
 **
 ** @param /+const+/ xcb_glx_get_fb_configs_reply_t *R
 ** @returns uint *
 **
 *****************************************************************************/

extern(C) uint *
xcb_glx_get_fb_configs_property_list (/+const+/ xcb_glx_get_fb_configs_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_fb_configs_property_list_length
 **
 ** @param /+const+/ xcb_glx_get_fb_configs_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_fb_configs_property_list_length (/+const+/ xcb_glx_get_fb_configs_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_get_fb_configs_property_list_end
 **
 ** @param /+const+/ xcb_glx_get_fb_configs_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_get_fb_configs_property_list_end (/+const+/ xcb_glx_get_fb_configs_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_fb_configs_reply_t * xcb_glx_get_fb_configs_reply
 **
 ** @param xcb_connection_t                 *c
 ** @param xcb_glx_get_fb_configs_cookie_t   cookie
 ** @param xcb_generic_error_t             **e
 ** @returns xcb_glx_get_fb_configs_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_fb_configs_reply_t *
xcb_glx_get_fb_configs_reply (xcb_connection_t                 *c  /**< */,
                              xcb_glx_get_fb_configs_cookie_t   cookie  /**< */,
                              xcb_generic_error_t             **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_create_pixmap_checked
 **
 ** @param xcb_connection_t *c
 ** @param uint              screen
 ** @param uint              fbconfig
 ** @param xcb_pixmap_t      pixmap
 ** @param xcb_glx_pixmap_t  glx_pixmap
 ** @param uint              num_attribs
 ** @param /+const+/ uint   *attribs
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_create_pixmap_checked (xcb_connection_t *c  /**< */,
                               uint              screen  /**< */,
                               uint              fbconfig  /**< */,
                               xcb_pixmap_t      pixmap  /**< */,
                               xcb_glx_pixmap_t  glx_pixmap  /**< */,
                               uint              num_attribs  /**< */,
                               /+const+/ uint   *attribs  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_create_pixmap
 **
 ** @param xcb_connection_t *c
 ** @param uint              screen
 ** @param uint              fbconfig
 ** @param xcb_pixmap_t      pixmap
 ** @param xcb_glx_pixmap_t  glx_pixmap
 ** @param uint              num_attribs
 ** @param /+const+/ uint   *attribs
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_create_pixmap (xcb_connection_t *c  /**< */,
                       uint              screen  /**< */,
                       uint              fbconfig  /**< */,
                       xcb_pixmap_t      pixmap  /**< */,
                       xcb_glx_pixmap_t  glx_pixmap  /**< */,
                       uint              num_attribs  /**< */,
                       /+const+/ uint   *attribs  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_destroy_pixmap_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_glx_pixmap_t  glx_pixmap
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_destroy_pixmap_checked (xcb_connection_t *c  /**< */,
                                xcb_glx_pixmap_t  glx_pixmap  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_destroy_pixmap
 **
 ** @param xcb_connection_t *c
 ** @param xcb_glx_pixmap_t  glx_pixmap
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_destroy_pixmap (xcb_connection_t *c  /**< */,
                        xcb_glx_pixmap_t  glx_pixmap  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_create_new_context_checked
 **
 ** @param xcb_connection_t  *c
 ** @param xcb_glx_context_t  context
 ** @param uint               fbconfig
 ** @param uint               screen
 ** @param uint               render_type
 ** @param uint               share_list
 ** @param bool               is_direct
 ** @param ubyte              reserved1
 ** @param ushort             reserved2
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_create_new_context_checked (xcb_connection_t  *c  /**< */,
                                    xcb_glx_context_t  context  /**< */,
                                    uint               fbconfig  /**< */,
                                    uint               screen  /**< */,
                                    uint               render_type  /**< */,
                                    uint               share_list  /**< */,
                                    bool               is_direct  /**< */,
                                    ubyte              reserved1  /**< */,
                                    ushort             reserved2  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_create_new_context
 **
 ** @param xcb_connection_t  *c
 ** @param xcb_glx_context_t  context
 ** @param uint               fbconfig
 ** @param uint               screen
 ** @param uint               render_type
 ** @param uint               share_list
 ** @param bool               is_direct
 ** @param ubyte              reserved1
 ** @param ushort             reserved2
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_create_new_context (xcb_connection_t  *c  /**< */,
                            xcb_glx_context_t  context  /**< */,
                            uint               fbconfig  /**< */,
                            uint               screen  /**< */,
                            uint               render_type  /**< */,
                            uint               share_list  /**< */,
                            bool               is_direct  /**< */,
                            ubyte              reserved1  /**< */,
                            ushort             reserved2  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_query_context_cookie_t xcb_glx_query_context
 **
 ** @param xcb_connection_t  *c
 ** @param xcb_glx_context_t  context
 ** @returns xcb_glx_query_context_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_query_context_cookie_t
xcb_glx_query_context (xcb_connection_t  *c  /**< */,
                       xcb_glx_context_t  context  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_query_context_cookie_t xcb_glx_query_context_unchecked
 **
 ** @param xcb_connection_t  *c
 ** @param xcb_glx_context_t  context
 ** @returns xcb_glx_query_context_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_query_context_cookie_t
xcb_glx_query_context_unchecked (xcb_connection_t  *c  /**< */,
                                 xcb_glx_context_t  context  /**< */);


/*****************************************************************************
 **
 ** uint * xcb_glx_query_context_attribs
 **
 ** @param /+const+/ xcb_glx_query_context_reply_t *R
 ** @returns uint *
 **
 *****************************************************************************/

extern(C) uint *
xcb_glx_query_context_attribs (/+const+/ xcb_glx_query_context_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_query_context_attribs_length
 **
 ** @param /+const+/ xcb_glx_query_context_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_query_context_attribs_length (/+const+/ xcb_glx_query_context_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_query_context_attribs_end
 **
 ** @param /+const+/ xcb_glx_query_context_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_query_context_attribs_end (/+const+/ xcb_glx_query_context_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_query_context_reply_t * xcb_glx_query_context_reply
 **
 ** @param xcb_connection_t                *c
 ** @param xcb_glx_query_context_cookie_t   cookie
 ** @param xcb_generic_error_t            **e
 ** @returns xcb_glx_query_context_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_query_context_reply_t *
xcb_glx_query_context_reply (xcb_connection_t                *c  /**< */,
                             xcb_glx_query_context_cookie_t   cookie  /**< */,
                             xcb_generic_error_t            **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_make_context_current_cookie_t xcb_glx_make_context_current
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  old_context_tag
 ** @param xcb_glx_drawable_t     drawable
 ** @param xcb_glx_drawable_t     read_drawable
 ** @param xcb_glx_context_t      context
 ** @returns xcb_glx_make_context_current_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_make_context_current_cookie_t
xcb_glx_make_context_current (xcb_connection_t      *c  /**< */,
                              xcb_glx_context_tag_t  old_context_tag  /**< */,
                              xcb_glx_drawable_t     drawable  /**< */,
                              xcb_glx_drawable_t     read_drawable  /**< */,
                              xcb_glx_context_t      context  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_make_context_current_cookie_t xcb_glx_make_context_current_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  old_context_tag
 ** @param xcb_glx_drawable_t     drawable
 ** @param xcb_glx_drawable_t     read_drawable
 ** @param xcb_glx_context_t      context
 ** @returns xcb_glx_make_context_current_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_make_context_current_cookie_t
xcb_glx_make_context_current_unchecked (xcb_connection_t      *c  /**< */,
                                        xcb_glx_context_tag_t  old_context_tag  /**< */,
                                        xcb_glx_drawable_t     drawable  /**< */,
                                        xcb_glx_drawable_t     read_drawable  /**< */,
                                        xcb_glx_context_t      context  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_make_context_current_reply_t * xcb_glx_make_context_current_reply
 **
 ** @param xcb_connection_t                       *c
 ** @param xcb_glx_make_context_current_cookie_t   cookie
 ** @param xcb_generic_error_t                   **e
 ** @returns xcb_glx_make_context_current_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_make_context_current_reply_t *
xcb_glx_make_context_current_reply (xcb_connection_t                       *c  /**< */,
                                    xcb_glx_make_context_current_cookie_t   cookie  /**< */,
                                    xcb_generic_error_t                   **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_create_pbuffer_checked
 **
 ** @param xcb_connection_t   *c
 ** @param uint                screen
 ** @param xcb_glx_fbconfig_t  fbconfig
 ** @param xcb_glx_pbuffer_t   pbuffer
 ** @param uint                num_attribs
 ** @param /+const+/ uint     *attribs
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_create_pbuffer_checked (xcb_connection_t   *c  /**< */,
                                uint                screen  /**< */,
                                xcb_glx_fbconfig_t  fbconfig  /**< */,
                                xcb_glx_pbuffer_t   pbuffer  /**< */,
                                uint                num_attribs  /**< */,
                                /+const+/ uint     *attribs  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_create_pbuffer
 **
 ** @param xcb_connection_t   *c
 ** @param uint                screen
 ** @param xcb_glx_fbconfig_t  fbconfig
 ** @param xcb_glx_pbuffer_t   pbuffer
 ** @param uint                num_attribs
 ** @param /+const+/ uint     *attribs
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_create_pbuffer (xcb_connection_t   *c  /**< */,
                        uint                screen  /**< */,
                        xcb_glx_fbconfig_t  fbconfig  /**< */,
                        xcb_glx_pbuffer_t   pbuffer  /**< */,
                        uint                num_attribs  /**< */,
                        /+const+/ uint     *attribs  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_destroy_pbuffer_checked
 **
 ** @param xcb_connection_t  *c
 ** @param xcb_glx_pbuffer_t  pbuffer
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_destroy_pbuffer_checked (xcb_connection_t  *c  /**< */,
                                 xcb_glx_pbuffer_t  pbuffer  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_destroy_pbuffer
 **
 ** @param xcb_connection_t  *c
 ** @param xcb_glx_pbuffer_t  pbuffer
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_destroy_pbuffer (xcb_connection_t  *c  /**< */,
                         xcb_glx_pbuffer_t  pbuffer  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_drawable_attributes_cookie_t xcb_glx_get_drawable_attributes
 **
 ** @param xcb_connection_t   *c
 ** @param xcb_glx_drawable_t  drawable
 ** @returns xcb_glx_get_drawable_attributes_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_drawable_attributes_cookie_t
xcb_glx_get_drawable_attributes (xcb_connection_t   *c  /**< */,
                                 xcb_glx_drawable_t  drawable  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_drawable_attributes_cookie_t xcb_glx_get_drawable_attributes_unchecked
 **
 ** @param xcb_connection_t   *c
 ** @param xcb_glx_drawable_t  drawable
 ** @returns xcb_glx_get_drawable_attributes_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_drawable_attributes_cookie_t
xcb_glx_get_drawable_attributes_unchecked (xcb_connection_t   *c  /**< */,
                                           xcb_glx_drawable_t  drawable  /**< */);


/*****************************************************************************
 **
 ** uint * xcb_glx_get_drawable_attributes_attribs
 **
 ** @param /+const+/ xcb_glx_get_drawable_attributes_reply_t *R
 ** @returns uint *
 **
 *****************************************************************************/

extern(C) uint *
xcb_glx_get_drawable_attributes_attribs (/+const+/ xcb_glx_get_drawable_attributes_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_drawable_attributes_attribs_length
 **
 ** @param /+const+/ xcb_glx_get_drawable_attributes_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_drawable_attributes_attribs_length (/+const+/ xcb_glx_get_drawable_attributes_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_get_drawable_attributes_attribs_end
 **
 ** @param /+const+/ xcb_glx_get_drawable_attributes_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_get_drawable_attributes_attribs_end (/+const+/ xcb_glx_get_drawable_attributes_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_drawable_attributes_reply_t * xcb_glx_get_drawable_attributes_reply
 **
 ** @param xcb_connection_t                          *c
 ** @param xcb_glx_get_drawable_attributes_cookie_t   cookie
 ** @param xcb_generic_error_t                      **e
 ** @returns xcb_glx_get_drawable_attributes_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_drawable_attributes_reply_t *
xcb_glx_get_drawable_attributes_reply (xcb_connection_t                          *c  /**< */,
                                       xcb_glx_get_drawable_attributes_cookie_t   cookie  /**< */,
                                       xcb_generic_error_t                      **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_change_drawable_attributes_checked
 **
 ** @param xcb_connection_t   *c
 ** @param xcb_glx_drawable_t  drawable
 ** @param uint                num_attribs
 ** @param /+const+/ uint     *attribs
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_change_drawable_attributes_checked (xcb_connection_t   *c  /**< */,
                                            xcb_glx_drawable_t  drawable  /**< */,
                                            uint                num_attribs  /**< */,
                                            /+const+/ uint     *attribs  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_change_drawable_attributes
 **
 ** @param xcb_connection_t   *c
 ** @param xcb_glx_drawable_t  drawable
 ** @param uint                num_attribs
 ** @param /+const+/ uint     *attribs
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_change_drawable_attributes (xcb_connection_t   *c  /**< */,
                                    xcb_glx_drawable_t  drawable  /**< */,
                                    uint                num_attribs  /**< */,
                                    /+const+/ uint     *attribs  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_create_window_checked
 **
 ** @param xcb_connection_t   *c
 ** @param uint                screen
 ** @param xcb_glx_fbconfig_t  fbconfig
 ** @param xcb_window_t        window
 ** @param xcb_glx_window_t    glx_window
 ** @param uint                num_attribs
 ** @param /+const+/ uint     *attribs
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_create_window_checked (xcb_connection_t   *c  /**< */,
                               uint                screen  /**< */,
                               xcb_glx_fbconfig_t  fbconfig  /**< */,
                               xcb_window_t        window  /**< */,
                               xcb_glx_window_t    glx_window  /**< */,
                               uint                num_attribs  /**< */,
                               /+const+/ uint     *attribs  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_create_window
 **
 ** @param xcb_connection_t   *c
 ** @param uint                screen
 ** @param xcb_glx_fbconfig_t  fbconfig
 ** @param xcb_window_t        window
 ** @param xcb_glx_window_t    glx_window
 ** @param uint                num_attribs
 ** @param /+const+/ uint     *attribs
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_create_window (xcb_connection_t   *c  /**< */,
                       uint                screen  /**< */,
                       xcb_glx_fbconfig_t  fbconfig  /**< */,
                       xcb_window_t        window  /**< */,
                       xcb_glx_window_t    glx_window  /**< */,
                       uint                num_attribs  /**< */,
                       /+const+/ uint     *attribs  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_delete_window_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_glx_window_t  glxwindow
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_delete_window_checked (xcb_connection_t *c  /**< */,
                               xcb_glx_window_t  glxwindow  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_delete_window
 **
 ** @param xcb_connection_t *c
 ** @param xcb_glx_window_t  glxwindow
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_delete_window (xcb_connection_t *c  /**< */,
                       xcb_glx_window_t  glxwindow  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_new_list_checked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   list
 ** @param uint                   mode
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_new_list_checked (xcb_connection_t      *c  /**< */,
                          xcb_glx_context_tag_t  context_tag  /**< */,
                          uint                   list  /**< */,
                          uint                   mode  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_new_list
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   list
 ** @param uint                   mode
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_new_list (xcb_connection_t      *c  /**< */,
                  xcb_glx_context_tag_t  context_tag  /**< */,
                  uint                   list  /**< */,
                  uint                   mode  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_end_list_checked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_end_list_checked (xcb_connection_t      *c  /**< */,
                          xcb_glx_context_tag_t  context_tag  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_end_list
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_end_list (xcb_connection_t      *c  /**< */,
                  xcb_glx_context_tag_t  context_tag  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_delete_lists_checked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   list
 ** @param int                    range
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_delete_lists_checked (xcb_connection_t      *c  /**< */,
                              xcb_glx_context_tag_t  context_tag  /**< */,
                              uint                   list  /**< */,
                              int                    range  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_delete_lists
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   list
 ** @param int                    range
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_delete_lists (xcb_connection_t      *c  /**< */,
                      xcb_glx_context_tag_t  context_tag  /**< */,
                      uint                   list  /**< */,
                      int                    range  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_gen_lists_cookie_t xcb_glx_gen_lists
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param int                    range
 ** @returns xcb_glx_gen_lists_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_gen_lists_cookie_t
xcb_glx_gen_lists (xcb_connection_t      *c  /**< */,
                   xcb_glx_context_tag_t  context_tag  /**< */,
                   int                    range  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_gen_lists_cookie_t xcb_glx_gen_lists_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param int                    range
 ** @returns xcb_glx_gen_lists_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_gen_lists_cookie_t
xcb_glx_gen_lists_unchecked (xcb_connection_t      *c  /**< */,
                             xcb_glx_context_tag_t  context_tag  /**< */,
                             int                    range  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_gen_lists_reply_t * xcb_glx_gen_lists_reply
 **
 ** @param xcb_connection_t            *c
 ** @param xcb_glx_gen_lists_cookie_t   cookie
 ** @param xcb_generic_error_t        **e
 ** @returns xcb_glx_gen_lists_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_gen_lists_reply_t *
xcb_glx_gen_lists_reply (xcb_connection_t            *c  /**< */,
                         xcb_glx_gen_lists_cookie_t   cookie  /**< */,
                         xcb_generic_error_t        **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_feedback_buffer_checked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param int                    size
 ** @param int                    type
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_feedback_buffer_checked (xcb_connection_t      *c  /**< */,
                                 xcb_glx_context_tag_t  context_tag  /**< */,
                                 int                    size  /**< */,
                                 int                    type  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_feedback_buffer
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param int                    size
 ** @param int                    type
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_feedback_buffer (xcb_connection_t      *c  /**< */,
                         xcb_glx_context_tag_t  context_tag  /**< */,
                         int                    size  /**< */,
                         int                    type  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_select_buffer_checked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param int                    size
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_select_buffer_checked (xcb_connection_t      *c  /**< */,
                               xcb_glx_context_tag_t  context_tag  /**< */,
                               int                    size  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_select_buffer
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param int                    size
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_select_buffer (xcb_connection_t      *c  /**< */,
                       xcb_glx_context_tag_t  context_tag  /**< */,
                       int                    size  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_render_mode_cookie_t xcb_glx_render_mode
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   mode
 ** @returns xcb_glx_render_mode_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_render_mode_cookie_t
xcb_glx_render_mode (xcb_connection_t      *c  /**< */,
                     xcb_glx_context_tag_t  context_tag  /**< */,
                     uint                   mode  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_render_mode_cookie_t xcb_glx_render_mode_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   mode
 ** @returns xcb_glx_render_mode_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_render_mode_cookie_t
xcb_glx_render_mode_unchecked (xcb_connection_t      *c  /**< */,
                               xcb_glx_context_tag_t  context_tag  /**< */,
                               uint                   mode  /**< */);


/*****************************************************************************
 **
 ** uint * xcb_glx_render_mode_data
 **
 ** @param /+const+/ xcb_glx_render_mode_reply_t *R
 ** @returns uint *
 **
 *****************************************************************************/

extern(C) uint *
xcb_glx_render_mode_data (/+const+/ xcb_glx_render_mode_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_render_mode_data_length
 **
 ** @param /+const+/ xcb_glx_render_mode_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_render_mode_data_length (/+const+/ xcb_glx_render_mode_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_render_mode_data_end
 **
 ** @param /+const+/ xcb_glx_render_mode_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_render_mode_data_end (/+const+/ xcb_glx_render_mode_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_render_mode_reply_t * xcb_glx_render_mode_reply
 **
 ** @param xcb_connection_t              *c
 ** @param xcb_glx_render_mode_cookie_t   cookie
 ** @param xcb_generic_error_t          **e
 ** @returns xcb_glx_render_mode_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_render_mode_reply_t *
xcb_glx_render_mode_reply (xcb_connection_t              *c  /**< */,
                           xcb_glx_render_mode_cookie_t   cookie  /**< */,
                           xcb_generic_error_t          **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_finish_cookie_t xcb_glx_finish
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @returns xcb_glx_finish_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_finish_cookie_t
xcb_glx_finish (xcb_connection_t      *c  /**< */,
                xcb_glx_context_tag_t  context_tag  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_finish_cookie_t xcb_glx_finish_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @returns xcb_glx_finish_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_finish_cookie_t
xcb_glx_finish_unchecked (xcb_connection_t      *c  /**< */,
                          xcb_glx_context_tag_t  context_tag  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_finish_reply_t * xcb_glx_finish_reply
 **
 ** @param xcb_connection_t         *c
 ** @param xcb_glx_finish_cookie_t   cookie
 ** @param xcb_generic_error_t     **e
 ** @returns xcb_glx_finish_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_finish_reply_t *
xcb_glx_finish_reply (xcb_connection_t         *c  /**< */,
                      xcb_glx_finish_cookie_t   cookie  /**< */,
                      xcb_generic_error_t     **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_pixel_storef_checked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   pname
 ** @param xcb_glx_float32_t      datum
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_pixel_storef_checked (xcb_connection_t      *c  /**< */,
                              xcb_glx_context_tag_t  context_tag  /**< */,
                              uint                   pname  /**< */,
                              xcb_glx_float32_t      datum  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_pixel_storef
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   pname
 ** @param xcb_glx_float32_t      datum
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_pixel_storef (xcb_connection_t      *c  /**< */,
                      xcb_glx_context_tag_t  context_tag  /**< */,
                      uint                   pname  /**< */,
                      xcb_glx_float32_t      datum  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_pixel_storei_checked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   pname
 ** @param int                    datum
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_pixel_storei_checked (xcb_connection_t      *c  /**< */,
                              xcb_glx_context_tag_t  context_tag  /**< */,
                              uint                   pname  /**< */,
                              int                    datum  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_pixel_storei
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   pname
 ** @param int                    datum
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_pixel_storei (xcb_connection_t      *c  /**< */,
                      xcb_glx_context_tag_t  context_tag  /**< */,
                      uint                   pname  /**< */,
                      int                    datum  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_read_pixels_cookie_t xcb_glx_read_pixels
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param int                    x
 ** @param int                    y
 ** @param int                    width
 ** @param int                    height
 ** @param uint                   format
 ** @param uint                   type
 ** @param bool                   swap_bytes
 ** @param bool                   lsb_first
 ** @returns xcb_glx_read_pixels_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_read_pixels_cookie_t
xcb_glx_read_pixels (xcb_connection_t      *c  /**< */,
                     xcb_glx_context_tag_t  context_tag  /**< */,
                     int                    x  /**< */,
                     int                    y  /**< */,
                     int                    width  /**< */,
                     int                    height  /**< */,
                     uint                   format  /**< */,
                     uint                   type  /**< */,
                     bool                   swap_bytes  /**< */,
                     bool                   lsb_first  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_read_pixels_cookie_t xcb_glx_read_pixels_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param int                    x
 ** @param int                    y
 ** @param int                    width
 ** @param int                    height
 ** @param uint                   format
 ** @param uint                   type
 ** @param bool                   swap_bytes
 ** @param bool                   lsb_first
 ** @returns xcb_glx_read_pixels_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_read_pixels_cookie_t
xcb_glx_read_pixels_unchecked (xcb_connection_t      *c  /**< */,
                               xcb_glx_context_tag_t  context_tag  /**< */,
                               int                    x  /**< */,
                               int                    y  /**< */,
                               int                    width  /**< */,
                               int                    height  /**< */,
                               uint                   format  /**< */,
                               uint                   type  /**< */,
                               bool                   swap_bytes  /**< */,
                               bool                   lsb_first  /**< */);


/*****************************************************************************
 **
 ** ubyte * xcb_glx_read_pixels_data
 **
 ** @param /+const+/ xcb_glx_read_pixels_reply_t *R
 ** @returns ubyte *
 **
 *****************************************************************************/

extern(C) ubyte *
xcb_glx_read_pixels_data (/+const+/ xcb_glx_read_pixels_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_read_pixels_data_length
 **
 ** @param /+const+/ xcb_glx_read_pixels_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_read_pixels_data_length (/+const+/ xcb_glx_read_pixels_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_read_pixels_data_end
 **
 ** @param /+const+/ xcb_glx_read_pixels_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_read_pixels_data_end (/+const+/ xcb_glx_read_pixels_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_read_pixels_reply_t * xcb_glx_read_pixels_reply
 **
 ** @param xcb_connection_t              *c
 ** @param xcb_glx_read_pixels_cookie_t   cookie
 ** @param xcb_generic_error_t          **e
 ** @returns xcb_glx_read_pixels_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_read_pixels_reply_t *
xcb_glx_read_pixels_reply (xcb_connection_t              *c  /**< */,
                           xcb_glx_read_pixels_cookie_t   cookie  /**< */,
                           xcb_generic_error_t          **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_booleanv_cookie_t xcb_glx_get_booleanv
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param int                    pname
 ** @returns xcb_glx_get_booleanv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_booleanv_cookie_t
xcb_glx_get_booleanv (xcb_connection_t      *c  /**< */,
                      xcb_glx_context_tag_t  context_tag  /**< */,
                      int                    pname  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_booleanv_cookie_t xcb_glx_get_booleanv_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param int                    pname
 ** @returns xcb_glx_get_booleanv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_booleanv_cookie_t
xcb_glx_get_booleanv_unchecked (xcb_connection_t      *c  /**< */,
                                xcb_glx_context_tag_t  context_tag  /**< */,
                                int                    pname  /**< */);


/*****************************************************************************
 **
 ** bool * xcb_glx_get_booleanv_data
 **
 ** @param /+const+/ xcb_glx_get_booleanv_reply_t *R
 ** @returns bool *
 **
 *****************************************************************************/

extern(C) bool *
xcb_glx_get_booleanv_data (/+const+/ xcb_glx_get_booleanv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_booleanv_data_length
 **
 ** @param /+const+/ xcb_glx_get_booleanv_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_booleanv_data_length (/+const+/ xcb_glx_get_booleanv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_get_booleanv_data_end
 **
 ** @param /+const+/ xcb_glx_get_booleanv_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_get_booleanv_data_end (/+const+/ xcb_glx_get_booleanv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_booleanv_reply_t * xcb_glx_get_booleanv_reply
 **
 ** @param xcb_connection_t               *c
 ** @param xcb_glx_get_booleanv_cookie_t   cookie
 ** @param xcb_generic_error_t           **e
 ** @returns xcb_glx_get_booleanv_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_booleanv_reply_t *
xcb_glx_get_booleanv_reply (xcb_connection_t               *c  /**< */,
                            xcb_glx_get_booleanv_cookie_t   cookie  /**< */,
                            xcb_generic_error_t           **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_clip_plane_cookie_t xcb_glx_get_clip_plane
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param int                    plane
 ** @returns xcb_glx_get_clip_plane_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_clip_plane_cookie_t
xcb_glx_get_clip_plane (xcb_connection_t      *c  /**< */,
                        xcb_glx_context_tag_t  context_tag  /**< */,
                        int                    plane  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_clip_plane_cookie_t xcb_glx_get_clip_plane_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param int                    plane
 ** @returns xcb_glx_get_clip_plane_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_clip_plane_cookie_t
xcb_glx_get_clip_plane_unchecked (xcb_connection_t      *c  /**< */,
                                  xcb_glx_context_tag_t  context_tag  /**< */,
                                  int                    plane  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_float64_t * xcb_glx_get_clip_plane_data
 **
 ** @param /+const+/ xcb_glx_get_clip_plane_reply_t *R
 ** @returns xcb_glx_float64_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_float64_t *
xcb_glx_get_clip_plane_data (/+const+/ xcb_glx_get_clip_plane_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_clip_plane_data_length
 **
 ** @param /+const+/ xcb_glx_get_clip_plane_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_clip_plane_data_length (/+const+/ xcb_glx_get_clip_plane_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_float64_iterator_t xcb_glx_get_clip_plane_data_iterator
 **
 ** @param /+const+/ xcb_glx_get_clip_plane_reply_t *R
 ** @returns xcb_glx_float64_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_glx_float64_iterator_t
xcb_glx_get_clip_plane_data_iterator (/+const+/ xcb_glx_get_clip_plane_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_clip_plane_reply_t * xcb_glx_get_clip_plane_reply
 **
 ** @param xcb_connection_t                 *c
 ** @param xcb_glx_get_clip_plane_cookie_t   cookie
 ** @param xcb_generic_error_t             **e
 ** @returns xcb_glx_get_clip_plane_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_clip_plane_reply_t *
xcb_glx_get_clip_plane_reply (xcb_connection_t                 *c  /**< */,
                              xcb_glx_get_clip_plane_cookie_t   cookie  /**< */,
                              xcb_generic_error_t             **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_doublev_cookie_t xcb_glx_get_doublev
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   pname
 ** @returns xcb_glx_get_doublev_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_doublev_cookie_t
xcb_glx_get_doublev (xcb_connection_t      *c  /**< */,
                     xcb_glx_context_tag_t  context_tag  /**< */,
                     uint                   pname  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_doublev_cookie_t xcb_glx_get_doublev_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   pname
 ** @returns xcb_glx_get_doublev_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_doublev_cookie_t
xcb_glx_get_doublev_unchecked (xcb_connection_t      *c  /**< */,
                               xcb_glx_context_tag_t  context_tag  /**< */,
                               uint                   pname  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_float64_t * xcb_glx_get_doublev_data
 **
 ** @param /+const+/ xcb_glx_get_doublev_reply_t *R
 ** @returns xcb_glx_float64_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_float64_t *
xcb_glx_get_doublev_data (/+const+/ xcb_glx_get_doublev_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_doublev_data_length
 **
 ** @param /+const+/ xcb_glx_get_doublev_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_doublev_data_length (/+const+/ xcb_glx_get_doublev_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_float64_iterator_t xcb_glx_get_doublev_data_iterator
 **
 ** @param /+const+/ xcb_glx_get_doublev_reply_t *R
 ** @returns xcb_glx_float64_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_glx_float64_iterator_t
xcb_glx_get_doublev_data_iterator (/+const+/ xcb_glx_get_doublev_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_doublev_reply_t * xcb_glx_get_doublev_reply
 **
 ** @param xcb_connection_t              *c
 ** @param xcb_glx_get_doublev_cookie_t   cookie
 ** @param xcb_generic_error_t          **e
 ** @returns xcb_glx_get_doublev_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_doublev_reply_t *
xcb_glx_get_doublev_reply (xcb_connection_t              *c  /**< */,
                           xcb_glx_get_doublev_cookie_t   cookie  /**< */,
                           xcb_generic_error_t          **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_error_cookie_t xcb_glx_get_error
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @returns xcb_glx_get_error_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_error_cookie_t
xcb_glx_get_error (xcb_connection_t      *c  /**< */,
                   xcb_glx_context_tag_t  context_tag  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_error_cookie_t xcb_glx_get_error_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @returns xcb_glx_get_error_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_error_cookie_t
xcb_glx_get_error_unchecked (xcb_connection_t      *c  /**< */,
                             xcb_glx_context_tag_t  context_tag  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_error_reply_t * xcb_glx_get_error_reply
 **
 ** @param xcb_connection_t            *c
 ** @param xcb_glx_get_error_cookie_t   cookie
 ** @param xcb_generic_error_t        **e
 ** @returns xcb_glx_get_error_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_error_reply_t *
xcb_glx_get_error_reply (xcb_connection_t            *c  /**< */,
                         xcb_glx_get_error_cookie_t   cookie  /**< */,
                         xcb_generic_error_t        **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_floatv_cookie_t xcb_glx_get_floatv
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   pname
 ** @returns xcb_glx_get_floatv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_floatv_cookie_t
xcb_glx_get_floatv (xcb_connection_t      *c  /**< */,
                    xcb_glx_context_tag_t  context_tag  /**< */,
                    uint                   pname  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_floatv_cookie_t xcb_glx_get_floatv_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   pname
 ** @returns xcb_glx_get_floatv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_floatv_cookie_t
xcb_glx_get_floatv_unchecked (xcb_connection_t      *c  /**< */,
                              xcb_glx_context_tag_t  context_tag  /**< */,
                              uint                   pname  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_float32_t * xcb_glx_get_floatv_data
 **
 ** @param /+const+/ xcb_glx_get_floatv_reply_t *R
 ** @returns xcb_glx_float32_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_float32_t *
xcb_glx_get_floatv_data (/+const+/ xcb_glx_get_floatv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_floatv_data_length
 **
 ** @param /+const+/ xcb_glx_get_floatv_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_floatv_data_length (/+const+/ xcb_glx_get_floatv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_float32_iterator_t xcb_glx_get_floatv_data_iterator
 **
 ** @param /+const+/ xcb_glx_get_floatv_reply_t *R
 ** @returns xcb_glx_float32_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_glx_float32_iterator_t
xcb_glx_get_floatv_data_iterator (/+const+/ xcb_glx_get_floatv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_floatv_reply_t * xcb_glx_get_floatv_reply
 **
 ** @param xcb_connection_t             *c
 ** @param xcb_glx_get_floatv_cookie_t   cookie
 ** @param xcb_generic_error_t         **e
 ** @returns xcb_glx_get_floatv_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_floatv_reply_t *
xcb_glx_get_floatv_reply (xcb_connection_t             *c  /**< */,
                          xcb_glx_get_floatv_cookie_t   cookie  /**< */,
                          xcb_generic_error_t         **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_integerv_cookie_t xcb_glx_get_integerv
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   pname
 ** @returns xcb_glx_get_integerv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_integerv_cookie_t
xcb_glx_get_integerv (xcb_connection_t      *c  /**< */,
                      xcb_glx_context_tag_t  context_tag  /**< */,
                      uint                   pname  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_integerv_cookie_t xcb_glx_get_integerv_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   pname
 ** @returns xcb_glx_get_integerv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_integerv_cookie_t
xcb_glx_get_integerv_unchecked (xcb_connection_t      *c  /**< */,
                                xcb_glx_context_tag_t  context_tag  /**< */,
                                uint                   pname  /**< */);


/*****************************************************************************
 **
 ** int * xcb_glx_get_integerv_data
 **
 ** @param /+const+/ xcb_glx_get_integerv_reply_t *R
 ** @returns int *
 **
 *****************************************************************************/

extern(C) int *
xcb_glx_get_integerv_data (/+const+/ xcb_glx_get_integerv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_integerv_data_length
 **
 ** @param /+const+/ xcb_glx_get_integerv_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_integerv_data_length (/+const+/ xcb_glx_get_integerv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_get_integerv_data_end
 **
 ** @param /+const+/ xcb_glx_get_integerv_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_get_integerv_data_end (/+const+/ xcb_glx_get_integerv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_integerv_reply_t * xcb_glx_get_integerv_reply
 **
 ** @param xcb_connection_t               *c
 ** @param xcb_glx_get_integerv_cookie_t   cookie
 ** @param xcb_generic_error_t           **e
 ** @returns xcb_glx_get_integerv_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_integerv_reply_t *
xcb_glx_get_integerv_reply (xcb_connection_t               *c  /**< */,
                            xcb_glx_get_integerv_cookie_t   cookie  /**< */,
                            xcb_generic_error_t           **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_lightfv_cookie_t xcb_glx_get_lightfv
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   light
 ** @param uint                   pname
 ** @returns xcb_glx_get_lightfv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_lightfv_cookie_t
xcb_glx_get_lightfv (xcb_connection_t      *c  /**< */,
                     xcb_glx_context_tag_t  context_tag  /**< */,
                     uint                   light  /**< */,
                     uint                   pname  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_lightfv_cookie_t xcb_glx_get_lightfv_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   light
 ** @param uint                   pname
 ** @returns xcb_glx_get_lightfv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_lightfv_cookie_t
xcb_glx_get_lightfv_unchecked (xcb_connection_t      *c  /**< */,
                               xcb_glx_context_tag_t  context_tag  /**< */,
                               uint                   light  /**< */,
                               uint                   pname  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_float32_t * xcb_glx_get_lightfv_data
 **
 ** @param /+const+/ xcb_glx_get_lightfv_reply_t *R
 ** @returns xcb_glx_float32_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_float32_t *
xcb_glx_get_lightfv_data (/+const+/ xcb_glx_get_lightfv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_lightfv_data_length
 **
 ** @param /+const+/ xcb_glx_get_lightfv_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_lightfv_data_length (/+const+/ xcb_glx_get_lightfv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_float32_iterator_t xcb_glx_get_lightfv_data_iterator
 **
 ** @param /+const+/ xcb_glx_get_lightfv_reply_t *R
 ** @returns xcb_glx_float32_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_glx_float32_iterator_t
xcb_glx_get_lightfv_data_iterator (/+const+/ xcb_glx_get_lightfv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_lightfv_reply_t * xcb_glx_get_lightfv_reply
 **
 ** @param xcb_connection_t              *c
 ** @param xcb_glx_get_lightfv_cookie_t   cookie
 ** @param xcb_generic_error_t          **e
 ** @returns xcb_glx_get_lightfv_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_lightfv_reply_t *
xcb_glx_get_lightfv_reply (xcb_connection_t              *c  /**< */,
                           xcb_glx_get_lightfv_cookie_t   cookie  /**< */,
                           xcb_generic_error_t          **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_lightiv_cookie_t xcb_glx_get_lightiv
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   light
 ** @param uint                   pname
 ** @returns xcb_glx_get_lightiv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_lightiv_cookie_t
xcb_glx_get_lightiv (xcb_connection_t      *c  /**< */,
                     xcb_glx_context_tag_t  context_tag  /**< */,
                     uint                   light  /**< */,
                     uint                   pname  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_lightiv_cookie_t xcb_glx_get_lightiv_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   light
 ** @param uint                   pname
 ** @returns xcb_glx_get_lightiv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_lightiv_cookie_t
xcb_glx_get_lightiv_unchecked (xcb_connection_t      *c  /**< */,
                               xcb_glx_context_tag_t  context_tag  /**< */,
                               uint                   light  /**< */,
                               uint                   pname  /**< */);


/*****************************************************************************
 **
 ** int * xcb_glx_get_lightiv_data
 **
 ** @param /+const+/ xcb_glx_get_lightiv_reply_t *R
 ** @returns int *
 **
 *****************************************************************************/

extern(C) int *
xcb_glx_get_lightiv_data (/+const+/ xcb_glx_get_lightiv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_lightiv_data_length
 **
 ** @param /+const+/ xcb_glx_get_lightiv_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_lightiv_data_length (/+const+/ xcb_glx_get_lightiv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_get_lightiv_data_end
 **
 ** @param /+const+/ xcb_glx_get_lightiv_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_get_lightiv_data_end (/+const+/ xcb_glx_get_lightiv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_lightiv_reply_t * xcb_glx_get_lightiv_reply
 **
 ** @param xcb_connection_t              *c
 ** @param xcb_glx_get_lightiv_cookie_t   cookie
 ** @param xcb_generic_error_t          **e
 ** @returns xcb_glx_get_lightiv_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_lightiv_reply_t *
xcb_glx_get_lightiv_reply (xcb_connection_t              *c  /**< */,
                           xcb_glx_get_lightiv_cookie_t   cookie  /**< */,
                           xcb_generic_error_t          **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_mapdv_cookie_t xcb_glx_get_mapdv
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param uint                   query
 ** @returns xcb_glx_get_mapdv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_mapdv_cookie_t
xcb_glx_get_mapdv (xcb_connection_t      *c  /**< */,
                   xcb_glx_context_tag_t  context_tag  /**< */,
                   uint                   target  /**< */,
                   uint                   query  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_mapdv_cookie_t xcb_glx_get_mapdv_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param uint                   query
 ** @returns xcb_glx_get_mapdv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_mapdv_cookie_t
xcb_glx_get_mapdv_unchecked (xcb_connection_t      *c  /**< */,
                             xcb_glx_context_tag_t  context_tag  /**< */,
                             uint                   target  /**< */,
                             uint                   query  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_float64_t * xcb_glx_get_mapdv_data
 **
 ** @param /+const+/ xcb_glx_get_mapdv_reply_t *R
 ** @returns xcb_glx_float64_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_float64_t *
xcb_glx_get_mapdv_data (/+const+/ xcb_glx_get_mapdv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_mapdv_data_length
 **
 ** @param /+const+/ xcb_glx_get_mapdv_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_mapdv_data_length (/+const+/ xcb_glx_get_mapdv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_float64_iterator_t xcb_glx_get_mapdv_data_iterator
 **
 ** @param /+const+/ xcb_glx_get_mapdv_reply_t *R
 ** @returns xcb_glx_float64_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_glx_float64_iterator_t
xcb_glx_get_mapdv_data_iterator (/+const+/ xcb_glx_get_mapdv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_mapdv_reply_t * xcb_glx_get_mapdv_reply
 **
 ** @param xcb_connection_t            *c
 ** @param xcb_glx_get_mapdv_cookie_t   cookie
 ** @param xcb_generic_error_t        **e
 ** @returns xcb_glx_get_mapdv_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_mapdv_reply_t *
xcb_glx_get_mapdv_reply (xcb_connection_t            *c  /**< */,
                         xcb_glx_get_mapdv_cookie_t   cookie  /**< */,
                         xcb_generic_error_t        **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_mapfv_cookie_t xcb_glx_get_mapfv
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param uint                   query
 ** @returns xcb_glx_get_mapfv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_mapfv_cookie_t
xcb_glx_get_mapfv (xcb_connection_t      *c  /**< */,
                   xcb_glx_context_tag_t  context_tag  /**< */,
                   uint                   target  /**< */,
                   uint                   query  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_mapfv_cookie_t xcb_glx_get_mapfv_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param uint                   query
 ** @returns xcb_glx_get_mapfv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_mapfv_cookie_t
xcb_glx_get_mapfv_unchecked (xcb_connection_t      *c  /**< */,
                             xcb_glx_context_tag_t  context_tag  /**< */,
                             uint                   target  /**< */,
                             uint                   query  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_float32_t * xcb_glx_get_mapfv_data
 **
 ** @param /+const+/ xcb_glx_get_mapfv_reply_t *R
 ** @returns xcb_glx_float32_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_float32_t *
xcb_glx_get_mapfv_data (/+const+/ xcb_glx_get_mapfv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_mapfv_data_length
 **
 ** @param /+const+/ xcb_glx_get_mapfv_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_mapfv_data_length (/+const+/ xcb_glx_get_mapfv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_float32_iterator_t xcb_glx_get_mapfv_data_iterator
 **
 ** @param /+const+/ xcb_glx_get_mapfv_reply_t *R
 ** @returns xcb_glx_float32_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_glx_float32_iterator_t
xcb_glx_get_mapfv_data_iterator (/+const+/ xcb_glx_get_mapfv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_mapfv_reply_t * xcb_glx_get_mapfv_reply
 **
 ** @param xcb_connection_t            *c
 ** @param xcb_glx_get_mapfv_cookie_t   cookie
 ** @param xcb_generic_error_t        **e
 ** @returns xcb_glx_get_mapfv_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_mapfv_reply_t *
xcb_glx_get_mapfv_reply (xcb_connection_t            *c  /**< */,
                         xcb_glx_get_mapfv_cookie_t   cookie  /**< */,
                         xcb_generic_error_t        **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_mapiv_cookie_t xcb_glx_get_mapiv
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param uint                   query
 ** @returns xcb_glx_get_mapiv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_mapiv_cookie_t
xcb_glx_get_mapiv (xcb_connection_t      *c  /**< */,
                   xcb_glx_context_tag_t  context_tag  /**< */,
                   uint                   target  /**< */,
                   uint                   query  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_mapiv_cookie_t xcb_glx_get_mapiv_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param uint                   query
 ** @returns xcb_glx_get_mapiv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_mapiv_cookie_t
xcb_glx_get_mapiv_unchecked (xcb_connection_t      *c  /**< */,
                             xcb_glx_context_tag_t  context_tag  /**< */,
                             uint                   target  /**< */,
                             uint                   query  /**< */);


/*****************************************************************************
 **
 ** int * xcb_glx_get_mapiv_data
 **
 ** @param /+const+/ xcb_glx_get_mapiv_reply_t *R
 ** @returns int *
 **
 *****************************************************************************/

extern(C) int *
xcb_glx_get_mapiv_data (/+const+/ xcb_glx_get_mapiv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_mapiv_data_length
 **
 ** @param /+const+/ xcb_glx_get_mapiv_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_mapiv_data_length (/+const+/ xcb_glx_get_mapiv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_get_mapiv_data_end
 **
 ** @param /+const+/ xcb_glx_get_mapiv_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_get_mapiv_data_end (/+const+/ xcb_glx_get_mapiv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_mapiv_reply_t * xcb_glx_get_mapiv_reply
 **
 ** @param xcb_connection_t            *c
 ** @param xcb_glx_get_mapiv_cookie_t   cookie
 ** @param xcb_generic_error_t        **e
 ** @returns xcb_glx_get_mapiv_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_mapiv_reply_t *
xcb_glx_get_mapiv_reply (xcb_connection_t            *c  /**< */,
                         xcb_glx_get_mapiv_cookie_t   cookie  /**< */,
                         xcb_generic_error_t        **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_materialfv_cookie_t xcb_glx_get_materialfv
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   face
 ** @param uint                   pname
 ** @returns xcb_glx_get_materialfv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_materialfv_cookie_t
xcb_glx_get_materialfv (xcb_connection_t      *c  /**< */,
                        xcb_glx_context_tag_t  context_tag  /**< */,
                        uint                   face  /**< */,
                        uint                   pname  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_materialfv_cookie_t xcb_glx_get_materialfv_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   face
 ** @param uint                   pname
 ** @returns xcb_glx_get_materialfv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_materialfv_cookie_t
xcb_glx_get_materialfv_unchecked (xcb_connection_t      *c  /**< */,
                                  xcb_glx_context_tag_t  context_tag  /**< */,
                                  uint                   face  /**< */,
                                  uint                   pname  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_float32_t * xcb_glx_get_materialfv_data
 **
 ** @param /+const+/ xcb_glx_get_materialfv_reply_t *R
 ** @returns xcb_glx_float32_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_float32_t *
xcb_glx_get_materialfv_data (/+const+/ xcb_glx_get_materialfv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_materialfv_data_length
 **
 ** @param /+const+/ xcb_glx_get_materialfv_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_materialfv_data_length (/+const+/ xcb_glx_get_materialfv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_float32_iterator_t xcb_glx_get_materialfv_data_iterator
 **
 ** @param /+const+/ xcb_glx_get_materialfv_reply_t *R
 ** @returns xcb_glx_float32_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_glx_float32_iterator_t
xcb_glx_get_materialfv_data_iterator (/+const+/ xcb_glx_get_materialfv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_materialfv_reply_t * xcb_glx_get_materialfv_reply
 **
 ** @param xcb_connection_t                 *c
 ** @param xcb_glx_get_materialfv_cookie_t   cookie
 ** @param xcb_generic_error_t             **e
 ** @returns xcb_glx_get_materialfv_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_materialfv_reply_t *
xcb_glx_get_materialfv_reply (xcb_connection_t                 *c  /**< */,
                              xcb_glx_get_materialfv_cookie_t   cookie  /**< */,
                              xcb_generic_error_t             **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_materialiv_cookie_t xcb_glx_get_materialiv
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   face
 ** @param uint                   pname
 ** @returns xcb_glx_get_materialiv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_materialiv_cookie_t
xcb_glx_get_materialiv (xcb_connection_t      *c  /**< */,
                        xcb_glx_context_tag_t  context_tag  /**< */,
                        uint                   face  /**< */,
                        uint                   pname  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_materialiv_cookie_t xcb_glx_get_materialiv_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   face
 ** @param uint                   pname
 ** @returns xcb_glx_get_materialiv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_materialiv_cookie_t
xcb_glx_get_materialiv_unchecked (xcb_connection_t      *c  /**< */,
                                  xcb_glx_context_tag_t  context_tag  /**< */,
                                  uint                   face  /**< */,
                                  uint                   pname  /**< */);


/*****************************************************************************
 **
 ** int * xcb_glx_get_materialiv_data
 **
 ** @param /+const+/ xcb_glx_get_materialiv_reply_t *R
 ** @returns int *
 **
 *****************************************************************************/

extern(C) int *
xcb_glx_get_materialiv_data (/+const+/ xcb_glx_get_materialiv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_materialiv_data_length
 **
 ** @param /+const+/ xcb_glx_get_materialiv_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_materialiv_data_length (/+const+/ xcb_glx_get_materialiv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_get_materialiv_data_end
 **
 ** @param /+const+/ xcb_glx_get_materialiv_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_get_materialiv_data_end (/+const+/ xcb_glx_get_materialiv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_materialiv_reply_t * xcb_glx_get_materialiv_reply
 **
 ** @param xcb_connection_t                 *c
 ** @param xcb_glx_get_materialiv_cookie_t   cookie
 ** @param xcb_generic_error_t             **e
 ** @returns xcb_glx_get_materialiv_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_materialiv_reply_t *
xcb_glx_get_materialiv_reply (xcb_connection_t                 *c  /**< */,
                              xcb_glx_get_materialiv_cookie_t   cookie  /**< */,
                              xcb_generic_error_t             **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_pixel_mapfv_cookie_t xcb_glx_get_pixel_mapfv
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   map
 ** @returns xcb_glx_get_pixel_mapfv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_pixel_mapfv_cookie_t
xcb_glx_get_pixel_mapfv (xcb_connection_t      *c  /**< */,
                         xcb_glx_context_tag_t  context_tag  /**< */,
                         uint                   map  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_pixel_mapfv_cookie_t xcb_glx_get_pixel_mapfv_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   map
 ** @returns xcb_glx_get_pixel_mapfv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_pixel_mapfv_cookie_t
xcb_glx_get_pixel_mapfv_unchecked (xcb_connection_t      *c  /**< */,
                                   xcb_glx_context_tag_t  context_tag  /**< */,
                                   uint                   map  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_float32_t * xcb_glx_get_pixel_mapfv_data
 **
 ** @param /+const+/ xcb_glx_get_pixel_mapfv_reply_t *R
 ** @returns xcb_glx_float32_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_float32_t *
xcb_glx_get_pixel_mapfv_data (/+const+/ xcb_glx_get_pixel_mapfv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_pixel_mapfv_data_length
 **
 ** @param /+const+/ xcb_glx_get_pixel_mapfv_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_pixel_mapfv_data_length (/+const+/ xcb_glx_get_pixel_mapfv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_float32_iterator_t xcb_glx_get_pixel_mapfv_data_iterator
 **
 ** @param /+const+/ xcb_glx_get_pixel_mapfv_reply_t *R
 ** @returns xcb_glx_float32_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_glx_float32_iterator_t
xcb_glx_get_pixel_mapfv_data_iterator (/+const+/ xcb_glx_get_pixel_mapfv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_pixel_mapfv_reply_t * xcb_glx_get_pixel_mapfv_reply
 **
 ** @param xcb_connection_t                  *c
 ** @param xcb_glx_get_pixel_mapfv_cookie_t   cookie
 ** @param xcb_generic_error_t              **e
 ** @returns xcb_glx_get_pixel_mapfv_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_pixel_mapfv_reply_t *
xcb_glx_get_pixel_mapfv_reply (xcb_connection_t                  *c  /**< */,
                               xcb_glx_get_pixel_mapfv_cookie_t   cookie  /**< */,
                               xcb_generic_error_t              **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_pixel_mapuiv_cookie_t xcb_glx_get_pixel_mapuiv
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   map
 ** @returns xcb_glx_get_pixel_mapuiv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_pixel_mapuiv_cookie_t
xcb_glx_get_pixel_mapuiv (xcb_connection_t      *c  /**< */,
                          xcb_glx_context_tag_t  context_tag  /**< */,
                          uint                   map  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_pixel_mapuiv_cookie_t xcb_glx_get_pixel_mapuiv_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   map
 ** @returns xcb_glx_get_pixel_mapuiv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_pixel_mapuiv_cookie_t
xcb_glx_get_pixel_mapuiv_unchecked (xcb_connection_t      *c  /**< */,
                                    xcb_glx_context_tag_t  context_tag  /**< */,
                                    uint                   map  /**< */);


/*****************************************************************************
 **
 ** uint * xcb_glx_get_pixel_mapuiv_data
 **
 ** @param /+const+/ xcb_glx_get_pixel_mapuiv_reply_t *R
 ** @returns uint *
 **
 *****************************************************************************/

extern(C) uint *
xcb_glx_get_pixel_mapuiv_data (/+const+/ xcb_glx_get_pixel_mapuiv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_pixel_mapuiv_data_length
 **
 ** @param /+const+/ xcb_glx_get_pixel_mapuiv_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_pixel_mapuiv_data_length (/+const+/ xcb_glx_get_pixel_mapuiv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_get_pixel_mapuiv_data_end
 **
 ** @param /+const+/ xcb_glx_get_pixel_mapuiv_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_get_pixel_mapuiv_data_end (/+const+/ xcb_glx_get_pixel_mapuiv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_pixel_mapuiv_reply_t * xcb_glx_get_pixel_mapuiv_reply
 **
 ** @param xcb_connection_t                   *c
 ** @param xcb_glx_get_pixel_mapuiv_cookie_t   cookie
 ** @param xcb_generic_error_t               **e
 ** @returns xcb_glx_get_pixel_mapuiv_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_pixel_mapuiv_reply_t *
xcb_glx_get_pixel_mapuiv_reply (xcb_connection_t                   *c  /**< */,
                                xcb_glx_get_pixel_mapuiv_cookie_t   cookie  /**< */,
                                xcb_generic_error_t               **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_pixel_mapusv_cookie_t xcb_glx_get_pixel_mapusv
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   map
 ** @returns xcb_glx_get_pixel_mapusv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_pixel_mapusv_cookie_t
xcb_glx_get_pixel_mapusv (xcb_connection_t      *c  /**< */,
                          xcb_glx_context_tag_t  context_tag  /**< */,
                          uint                   map  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_pixel_mapusv_cookie_t xcb_glx_get_pixel_mapusv_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   map
 ** @returns xcb_glx_get_pixel_mapusv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_pixel_mapusv_cookie_t
xcb_glx_get_pixel_mapusv_unchecked (xcb_connection_t      *c  /**< */,
                                    xcb_glx_context_tag_t  context_tag  /**< */,
                                    uint                   map  /**< */);


/*****************************************************************************
 **
 ** ushort * xcb_glx_get_pixel_mapusv_data
 **
 ** @param /+const+/ xcb_glx_get_pixel_mapusv_reply_t *R
 ** @returns ushort *
 **
 *****************************************************************************/

extern(C) ushort *
xcb_glx_get_pixel_mapusv_data (/+const+/ xcb_glx_get_pixel_mapusv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_pixel_mapusv_data_length
 **
 ** @param /+const+/ xcb_glx_get_pixel_mapusv_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_pixel_mapusv_data_length (/+const+/ xcb_glx_get_pixel_mapusv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_get_pixel_mapusv_data_end
 **
 ** @param /+const+/ xcb_glx_get_pixel_mapusv_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_get_pixel_mapusv_data_end (/+const+/ xcb_glx_get_pixel_mapusv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_pixel_mapusv_reply_t * xcb_glx_get_pixel_mapusv_reply
 **
 ** @param xcb_connection_t                   *c
 ** @param xcb_glx_get_pixel_mapusv_cookie_t   cookie
 ** @param xcb_generic_error_t               **e
 ** @returns xcb_glx_get_pixel_mapusv_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_pixel_mapusv_reply_t *
xcb_glx_get_pixel_mapusv_reply (xcb_connection_t                   *c  /**< */,
                                xcb_glx_get_pixel_mapusv_cookie_t   cookie  /**< */,
                                xcb_generic_error_t               **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_polygon_stipple_cookie_t xcb_glx_get_polygon_stipple
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param bool                   lsb_first
 ** @returns xcb_glx_get_polygon_stipple_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_polygon_stipple_cookie_t
xcb_glx_get_polygon_stipple (xcb_connection_t      *c  /**< */,
                             xcb_glx_context_tag_t  context_tag  /**< */,
                             bool                   lsb_first  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_polygon_stipple_cookie_t xcb_glx_get_polygon_stipple_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param bool                   lsb_first
 ** @returns xcb_glx_get_polygon_stipple_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_polygon_stipple_cookie_t
xcb_glx_get_polygon_stipple_unchecked (xcb_connection_t      *c  /**< */,
                                       xcb_glx_context_tag_t  context_tag  /**< */,
                                       bool                   lsb_first  /**< */);


/*****************************************************************************
 **
 ** ubyte * xcb_glx_get_polygon_stipple_data
 **
 ** @param /+const+/ xcb_glx_get_polygon_stipple_reply_t *R
 ** @returns ubyte *
 **
 *****************************************************************************/

extern(C) ubyte *
xcb_glx_get_polygon_stipple_data (/+const+/ xcb_glx_get_polygon_stipple_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_polygon_stipple_data_length
 **
 ** @param /+const+/ xcb_glx_get_polygon_stipple_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_polygon_stipple_data_length (/+const+/ xcb_glx_get_polygon_stipple_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_get_polygon_stipple_data_end
 **
 ** @param /+const+/ xcb_glx_get_polygon_stipple_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_get_polygon_stipple_data_end (/+const+/ xcb_glx_get_polygon_stipple_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_polygon_stipple_reply_t * xcb_glx_get_polygon_stipple_reply
 **
 ** @param xcb_connection_t                      *c
 ** @param xcb_glx_get_polygon_stipple_cookie_t   cookie
 ** @param xcb_generic_error_t                  **e
 ** @returns xcb_glx_get_polygon_stipple_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_polygon_stipple_reply_t *
xcb_glx_get_polygon_stipple_reply (xcb_connection_t                      *c  /**< */,
                                   xcb_glx_get_polygon_stipple_cookie_t   cookie  /**< */,
                                   xcb_generic_error_t                  **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_string_cookie_t xcb_glx_get_string
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   name
 ** @returns xcb_glx_get_string_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_string_cookie_t
xcb_glx_get_string (xcb_connection_t      *c  /**< */,
                    xcb_glx_context_tag_t  context_tag  /**< */,
                    uint                   name  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_string_cookie_t xcb_glx_get_string_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   name
 ** @returns xcb_glx_get_string_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_string_cookie_t
xcb_glx_get_string_unchecked (xcb_connection_t      *c  /**< */,
                              xcb_glx_context_tag_t  context_tag  /**< */,
                              uint                   name  /**< */);


/*****************************************************************************
 **
 ** ubyte * xcb_glx_get_string_string
 **
 ** @param /+const+/ xcb_glx_get_string_reply_t *R
 ** @returns ubyte *
 **
 *****************************************************************************/

extern(C) ubyte *
xcb_glx_get_string_string (/+const+/ xcb_glx_get_string_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_string_string_length
 **
 ** @param /+const+/ xcb_glx_get_string_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_string_string_length (/+const+/ xcb_glx_get_string_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_get_string_string_end
 **
 ** @param /+const+/ xcb_glx_get_string_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_get_string_string_end (/+const+/ xcb_glx_get_string_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_string_reply_t * xcb_glx_get_string_reply
 **
 ** @param xcb_connection_t             *c
 ** @param xcb_glx_get_string_cookie_t   cookie
 ** @param xcb_generic_error_t         **e
 ** @returns xcb_glx_get_string_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_string_reply_t *
xcb_glx_get_string_reply (xcb_connection_t             *c  /**< */,
                          xcb_glx_get_string_cookie_t   cookie  /**< */,
                          xcb_generic_error_t         **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_tex_envfv_cookie_t xcb_glx_get_tex_envfv
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param uint                   pname
 ** @returns xcb_glx_get_tex_envfv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_tex_envfv_cookie_t
xcb_glx_get_tex_envfv (xcb_connection_t      *c  /**< */,
                       xcb_glx_context_tag_t  context_tag  /**< */,
                       uint                   target  /**< */,
                       uint                   pname  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_tex_envfv_cookie_t xcb_glx_get_tex_envfv_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param uint                   pname
 ** @returns xcb_glx_get_tex_envfv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_tex_envfv_cookie_t
xcb_glx_get_tex_envfv_unchecked (xcb_connection_t      *c  /**< */,
                                 xcb_glx_context_tag_t  context_tag  /**< */,
                                 uint                   target  /**< */,
                                 uint                   pname  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_float32_t * xcb_glx_get_tex_envfv_data
 **
 ** @param /+const+/ xcb_glx_get_tex_envfv_reply_t *R
 ** @returns xcb_glx_float32_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_float32_t *
xcb_glx_get_tex_envfv_data (/+const+/ xcb_glx_get_tex_envfv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_tex_envfv_data_length
 **
 ** @param /+const+/ xcb_glx_get_tex_envfv_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_tex_envfv_data_length (/+const+/ xcb_glx_get_tex_envfv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_float32_iterator_t xcb_glx_get_tex_envfv_data_iterator
 **
 ** @param /+const+/ xcb_glx_get_tex_envfv_reply_t *R
 ** @returns xcb_glx_float32_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_glx_float32_iterator_t
xcb_glx_get_tex_envfv_data_iterator (/+const+/ xcb_glx_get_tex_envfv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_tex_envfv_reply_t * xcb_glx_get_tex_envfv_reply
 **
 ** @param xcb_connection_t                *c
 ** @param xcb_glx_get_tex_envfv_cookie_t   cookie
 ** @param xcb_generic_error_t            **e
 ** @returns xcb_glx_get_tex_envfv_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_tex_envfv_reply_t *
xcb_glx_get_tex_envfv_reply (xcb_connection_t                *c  /**< */,
                             xcb_glx_get_tex_envfv_cookie_t   cookie  /**< */,
                             xcb_generic_error_t            **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_tex_enviv_cookie_t xcb_glx_get_tex_enviv
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param uint                   pname
 ** @returns xcb_glx_get_tex_enviv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_tex_enviv_cookie_t
xcb_glx_get_tex_enviv (xcb_connection_t      *c  /**< */,
                       xcb_glx_context_tag_t  context_tag  /**< */,
                       uint                   target  /**< */,
                       uint                   pname  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_tex_enviv_cookie_t xcb_glx_get_tex_enviv_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param uint                   pname
 ** @returns xcb_glx_get_tex_enviv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_tex_enviv_cookie_t
xcb_glx_get_tex_enviv_unchecked (xcb_connection_t      *c  /**< */,
                                 xcb_glx_context_tag_t  context_tag  /**< */,
                                 uint                   target  /**< */,
                                 uint                   pname  /**< */);


/*****************************************************************************
 **
 ** int * xcb_glx_get_tex_enviv_data
 **
 ** @param /+const+/ xcb_glx_get_tex_enviv_reply_t *R
 ** @returns int *
 **
 *****************************************************************************/

extern(C) int *
xcb_glx_get_tex_enviv_data (/+const+/ xcb_glx_get_tex_enviv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_tex_enviv_data_length
 **
 ** @param /+const+/ xcb_glx_get_tex_enviv_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_tex_enviv_data_length (/+const+/ xcb_glx_get_tex_enviv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_get_tex_enviv_data_end
 **
 ** @param /+const+/ xcb_glx_get_tex_enviv_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_get_tex_enviv_data_end (/+const+/ xcb_glx_get_tex_enviv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_tex_enviv_reply_t * xcb_glx_get_tex_enviv_reply
 **
 ** @param xcb_connection_t                *c
 ** @param xcb_glx_get_tex_enviv_cookie_t   cookie
 ** @param xcb_generic_error_t            **e
 ** @returns xcb_glx_get_tex_enviv_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_tex_enviv_reply_t *
xcb_glx_get_tex_enviv_reply (xcb_connection_t                *c  /**< */,
                             xcb_glx_get_tex_enviv_cookie_t   cookie  /**< */,
                             xcb_generic_error_t            **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_tex_gendv_cookie_t xcb_glx_get_tex_gendv
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   coord
 ** @param uint                   pname
 ** @returns xcb_glx_get_tex_gendv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_tex_gendv_cookie_t
xcb_glx_get_tex_gendv (xcb_connection_t      *c  /**< */,
                       xcb_glx_context_tag_t  context_tag  /**< */,
                       uint                   coord  /**< */,
                       uint                   pname  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_tex_gendv_cookie_t xcb_glx_get_tex_gendv_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   coord
 ** @param uint                   pname
 ** @returns xcb_glx_get_tex_gendv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_tex_gendv_cookie_t
xcb_glx_get_tex_gendv_unchecked (xcb_connection_t      *c  /**< */,
                                 xcb_glx_context_tag_t  context_tag  /**< */,
                                 uint                   coord  /**< */,
                                 uint                   pname  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_float64_t * xcb_glx_get_tex_gendv_data
 **
 ** @param /+const+/ xcb_glx_get_tex_gendv_reply_t *R
 ** @returns xcb_glx_float64_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_float64_t *
xcb_glx_get_tex_gendv_data (/+const+/ xcb_glx_get_tex_gendv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_tex_gendv_data_length
 **
 ** @param /+const+/ xcb_glx_get_tex_gendv_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_tex_gendv_data_length (/+const+/ xcb_glx_get_tex_gendv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_float64_iterator_t xcb_glx_get_tex_gendv_data_iterator
 **
 ** @param /+const+/ xcb_glx_get_tex_gendv_reply_t *R
 ** @returns xcb_glx_float64_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_glx_float64_iterator_t
xcb_glx_get_tex_gendv_data_iterator (/+const+/ xcb_glx_get_tex_gendv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_tex_gendv_reply_t * xcb_glx_get_tex_gendv_reply
 **
 ** @param xcb_connection_t                *c
 ** @param xcb_glx_get_tex_gendv_cookie_t   cookie
 ** @param xcb_generic_error_t            **e
 ** @returns xcb_glx_get_tex_gendv_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_tex_gendv_reply_t *
xcb_glx_get_tex_gendv_reply (xcb_connection_t                *c  /**< */,
                             xcb_glx_get_tex_gendv_cookie_t   cookie  /**< */,
                             xcb_generic_error_t            **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_tex_genfv_cookie_t xcb_glx_get_tex_genfv
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   coord
 ** @param uint                   pname
 ** @returns xcb_glx_get_tex_genfv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_tex_genfv_cookie_t
xcb_glx_get_tex_genfv (xcb_connection_t      *c  /**< */,
                       xcb_glx_context_tag_t  context_tag  /**< */,
                       uint                   coord  /**< */,
                       uint                   pname  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_tex_genfv_cookie_t xcb_glx_get_tex_genfv_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   coord
 ** @param uint                   pname
 ** @returns xcb_glx_get_tex_genfv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_tex_genfv_cookie_t
xcb_glx_get_tex_genfv_unchecked (xcb_connection_t      *c  /**< */,
                                 xcb_glx_context_tag_t  context_tag  /**< */,
                                 uint                   coord  /**< */,
                                 uint                   pname  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_float32_t * xcb_glx_get_tex_genfv_data
 **
 ** @param /+const+/ xcb_glx_get_tex_genfv_reply_t *R
 ** @returns xcb_glx_float32_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_float32_t *
xcb_glx_get_tex_genfv_data (/+const+/ xcb_glx_get_tex_genfv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_tex_genfv_data_length
 **
 ** @param /+const+/ xcb_glx_get_tex_genfv_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_tex_genfv_data_length (/+const+/ xcb_glx_get_tex_genfv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_float32_iterator_t xcb_glx_get_tex_genfv_data_iterator
 **
 ** @param /+const+/ xcb_glx_get_tex_genfv_reply_t *R
 ** @returns xcb_glx_float32_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_glx_float32_iterator_t
xcb_glx_get_tex_genfv_data_iterator (/+const+/ xcb_glx_get_tex_genfv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_tex_genfv_reply_t * xcb_glx_get_tex_genfv_reply
 **
 ** @param xcb_connection_t                *c
 ** @param xcb_glx_get_tex_genfv_cookie_t   cookie
 ** @param xcb_generic_error_t            **e
 ** @returns xcb_glx_get_tex_genfv_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_tex_genfv_reply_t *
xcb_glx_get_tex_genfv_reply (xcb_connection_t                *c  /**< */,
                             xcb_glx_get_tex_genfv_cookie_t   cookie  /**< */,
                             xcb_generic_error_t            **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_tex_geniv_cookie_t xcb_glx_get_tex_geniv
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   coord
 ** @param uint                   pname
 ** @returns xcb_glx_get_tex_geniv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_tex_geniv_cookie_t
xcb_glx_get_tex_geniv (xcb_connection_t      *c  /**< */,
                       xcb_glx_context_tag_t  context_tag  /**< */,
                       uint                   coord  /**< */,
                       uint                   pname  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_tex_geniv_cookie_t xcb_glx_get_tex_geniv_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   coord
 ** @param uint                   pname
 ** @returns xcb_glx_get_tex_geniv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_tex_geniv_cookie_t
xcb_glx_get_tex_geniv_unchecked (xcb_connection_t      *c  /**< */,
                                 xcb_glx_context_tag_t  context_tag  /**< */,
                                 uint                   coord  /**< */,
                                 uint                   pname  /**< */);


/*****************************************************************************
 **
 ** int * xcb_glx_get_tex_geniv_data
 **
 ** @param /+const+/ xcb_glx_get_tex_geniv_reply_t *R
 ** @returns int *
 **
 *****************************************************************************/

extern(C) int *
xcb_glx_get_tex_geniv_data (/+const+/ xcb_glx_get_tex_geniv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_tex_geniv_data_length
 **
 ** @param /+const+/ xcb_glx_get_tex_geniv_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_tex_geniv_data_length (/+const+/ xcb_glx_get_tex_geniv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_get_tex_geniv_data_end
 **
 ** @param /+const+/ xcb_glx_get_tex_geniv_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_get_tex_geniv_data_end (/+const+/ xcb_glx_get_tex_geniv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_tex_geniv_reply_t * xcb_glx_get_tex_geniv_reply
 **
 ** @param xcb_connection_t                *c
 ** @param xcb_glx_get_tex_geniv_cookie_t   cookie
 ** @param xcb_generic_error_t            **e
 ** @returns xcb_glx_get_tex_geniv_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_tex_geniv_reply_t *
xcb_glx_get_tex_geniv_reply (xcb_connection_t                *c  /**< */,
                             xcb_glx_get_tex_geniv_cookie_t   cookie  /**< */,
                             xcb_generic_error_t            **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_tex_image_cookie_t xcb_glx_get_tex_image
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param int                    level
 ** @param uint                   format
 ** @param uint                   type
 ** @param bool                   swap_bytes
 ** @returns xcb_glx_get_tex_image_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_tex_image_cookie_t
xcb_glx_get_tex_image (xcb_connection_t      *c  /**< */,
                       xcb_glx_context_tag_t  context_tag  /**< */,
                       uint                   target  /**< */,
                       int                    level  /**< */,
                       uint                   format  /**< */,
                       uint                   type  /**< */,
                       bool                   swap_bytes  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_tex_image_cookie_t xcb_glx_get_tex_image_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param int                    level
 ** @param uint                   format
 ** @param uint                   type
 ** @param bool                   swap_bytes
 ** @returns xcb_glx_get_tex_image_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_tex_image_cookie_t
xcb_glx_get_tex_image_unchecked (xcb_connection_t      *c  /**< */,
                                 xcb_glx_context_tag_t  context_tag  /**< */,
                                 uint                   target  /**< */,
                                 int                    level  /**< */,
                                 uint                   format  /**< */,
                                 uint                   type  /**< */,
                                 bool                   swap_bytes  /**< */);


/*****************************************************************************
 **
 ** ubyte * xcb_glx_get_tex_image_data
 **
 ** @param /+const+/ xcb_glx_get_tex_image_reply_t *R
 ** @returns ubyte *
 **
 *****************************************************************************/

extern(C) ubyte *
xcb_glx_get_tex_image_data (/+const+/ xcb_glx_get_tex_image_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_tex_image_data_length
 **
 ** @param /+const+/ xcb_glx_get_tex_image_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_tex_image_data_length (/+const+/ xcb_glx_get_tex_image_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_get_tex_image_data_end
 **
 ** @param /+const+/ xcb_glx_get_tex_image_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_get_tex_image_data_end (/+const+/ xcb_glx_get_tex_image_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_tex_image_reply_t * xcb_glx_get_tex_image_reply
 **
 ** @param xcb_connection_t                *c
 ** @param xcb_glx_get_tex_image_cookie_t   cookie
 ** @param xcb_generic_error_t            **e
 ** @returns xcb_glx_get_tex_image_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_tex_image_reply_t *
xcb_glx_get_tex_image_reply (xcb_connection_t                *c  /**< */,
                             xcb_glx_get_tex_image_cookie_t   cookie  /**< */,
                             xcb_generic_error_t            **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_tex_parameterfv_cookie_t xcb_glx_get_tex_parameterfv
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param uint                   pname
 ** @returns xcb_glx_get_tex_parameterfv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_tex_parameterfv_cookie_t
xcb_glx_get_tex_parameterfv (xcb_connection_t      *c  /**< */,
                             xcb_glx_context_tag_t  context_tag  /**< */,
                             uint                   target  /**< */,
                             uint                   pname  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_tex_parameterfv_cookie_t xcb_glx_get_tex_parameterfv_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param uint                   pname
 ** @returns xcb_glx_get_tex_parameterfv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_tex_parameterfv_cookie_t
xcb_glx_get_tex_parameterfv_unchecked (xcb_connection_t      *c  /**< */,
                                       xcb_glx_context_tag_t  context_tag  /**< */,
                                       uint                   target  /**< */,
                                       uint                   pname  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_float32_t * xcb_glx_get_tex_parameterfv_data
 **
 ** @param /+const+/ xcb_glx_get_tex_parameterfv_reply_t *R
 ** @returns xcb_glx_float32_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_float32_t *
xcb_glx_get_tex_parameterfv_data (/+const+/ xcb_glx_get_tex_parameterfv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_tex_parameterfv_data_length
 **
 ** @param /+const+/ xcb_glx_get_tex_parameterfv_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_tex_parameterfv_data_length (/+const+/ xcb_glx_get_tex_parameterfv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_float32_iterator_t xcb_glx_get_tex_parameterfv_data_iterator
 **
 ** @param /+const+/ xcb_glx_get_tex_parameterfv_reply_t *R
 ** @returns xcb_glx_float32_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_glx_float32_iterator_t
xcb_glx_get_tex_parameterfv_data_iterator (/+const+/ xcb_glx_get_tex_parameterfv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_tex_parameterfv_reply_t * xcb_glx_get_tex_parameterfv_reply
 **
 ** @param xcb_connection_t                      *c
 ** @param xcb_glx_get_tex_parameterfv_cookie_t   cookie
 ** @param xcb_generic_error_t                  **e
 ** @returns xcb_glx_get_tex_parameterfv_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_tex_parameterfv_reply_t *
xcb_glx_get_tex_parameterfv_reply (xcb_connection_t                      *c  /**< */,
                                   xcb_glx_get_tex_parameterfv_cookie_t   cookie  /**< */,
                                   xcb_generic_error_t                  **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_tex_parameteriv_cookie_t xcb_glx_get_tex_parameteriv
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param uint                   pname
 ** @returns xcb_glx_get_tex_parameteriv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_tex_parameteriv_cookie_t
xcb_glx_get_tex_parameteriv (xcb_connection_t      *c  /**< */,
                             xcb_glx_context_tag_t  context_tag  /**< */,
                             uint                   target  /**< */,
                             uint                   pname  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_tex_parameteriv_cookie_t xcb_glx_get_tex_parameteriv_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param uint                   pname
 ** @returns xcb_glx_get_tex_parameteriv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_tex_parameteriv_cookie_t
xcb_glx_get_tex_parameteriv_unchecked (xcb_connection_t      *c  /**< */,
                                       xcb_glx_context_tag_t  context_tag  /**< */,
                                       uint                   target  /**< */,
                                       uint                   pname  /**< */);


/*****************************************************************************
 **
 ** int * xcb_glx_get_tex_parameteriv_data
 **
 ** @param /+const+/ xcb_glx_get_tex_parameteriv_reply_t *R
 ** @returns int *
 **
 *****************************************************************************/

extern(C) int *
xcb_glx_get_tex_parameteriv_data (/+const+/ xcb_glx_get_tex_parameteriv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_tex_parameteriv_data_length
 **
 ** @param /+const+/ xcb_glx_get_tex_parameteriv_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_tex_parameteriv_data_length (/+const+/ xcb_glx_get_tex_parameteriv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_get_tex_parameteriv_data_end
 **
 ** @param /+const+/ xcb_glx_get_tex_parameteriv_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_get_tex_parameteriv_data_end (/+const+/ xcb_glx_get_tex_parameteriv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_tex_parameteriv_reply_t * xcb_glx_get_tex_parameteriv_reply
 **
 ** @param xcb_connection_t                      *c
 ** @param xcb_glx_get_tex_parameteriv_cookie_t   cookie
 ** @param xcb_generic_error_t                  **e
 ** @returns xcb_glx_get_tex_parameteriv_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_tex_parameteriv_reply_t *
xcb_glx_get_tex_parameteriv_reply (xcb_connection_t                      *c  /**< */,
                                   xcb_glx_get_tex_parameteriv_cookie_t   cookie  /**< */,
                                   xcb_generic_error_t                  **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_tex_level_parameterfv_cookie_t xcb_glx_get_tex_level_parameterfv
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param int                    level
 ** @param uint                   pname
 ** @returns xcb_glx_get_tex_level_parameterfv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_tex_level_parameterfv_cookie_t
xcb_glx_get_tex_level_parameterfv (xcb_connection_t      *c  /**< */,
                                   xcb_glx_context_tag_t  context_tag  /**< */,
                                   uint                   target  /**< */,
                                   int                    level  /**< */,
                                   uint                   pname  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_tex_level_parameterfv_cookie_t xcb_glx_get_tex_level_parameterfv_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param int                    level
 ** @param uint                   pname
 ** @returns xcb_glx_get_tex_level_parameterfv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_tex_level_parameterfv_cookie_t
xcb_glx_get_tex_level_parameterfv_unchecked (xcb_connection_t      *c  /**< */,
                                             xcb_glx_context_tag_t  context_tag  /**< */,
                                             uint                   target  /**< */,
                                             int                    level  /**< */,
                                             uint                   pname  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_float32_t * xcb_glx_get_tex_level_parameterfv_data
 **
 ** @param /+const+/ xcb_glx_get_tex_level_parameterfv_reply_t *R
 ** @returns xcb_glx_float32_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_float32_t *
xcb_glx_get_tex_level_parameterfv_data (/+const+/ xcb_glx_get_tex_level_parameterfv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_tex_level_parameterfv_data_length
 **
 ** @param /+const+/ xcb_glx_get_tex_level_parameterfv_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_tex_level_parameterfv_data_length (/+const+/ xcb_glx_get_tex_level_parameterfv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_float32_iterator_t xcb_glx_get_tex_level_parameterfv_data_iterator
 **
 ** @param /+const+/ xcb_glx_get_tex_level_parameterfv_reply_t *R
 ** @returns xcb_glx_float32_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_glx_float32_iterator_t
xcb_glx_get_tex_level_parameterfv_data_iterator (/+const+/ xcb_glx_get_tex_level_parameterfv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_tex_level_parameterfv_reply_t * xcb_glx_get_tex_level_parameterfv_reply
 **
 ** @param xcb_connection_t                            *c
 ** @param xcb_glx_get_tex_level_parameterfv_cookie_t   cookie
 ** @param xcb_generic_error_t                        **e
 ** @returns xcb_glx_get_tex_level_parameterfv_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_tex_level_parameterfv_reply_t *
xcb_glx_get_tex_level_parameterfv_reply (xcb_connection_t                            *c  /**< */,
                                         xcb_glx_get_tex_level_parameterfv_cookie_t   cookie  /**< */,
                                         xcb_generic_error_t                        **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_tex_level_parameteriv_cookie_t xcb_glx_get_tex_level_parameteriv
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param int                    level
 ** @param uint                   pname
 ** @returns xcb_glx_get_tex_level_parameteriv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_tex_level_parameteriv_cookie_t
xcb_glx_get_tex_level_parameteriv (xcb_connection_t      *c  /**< */,
                                   xcb_glx_context_tag_t  context_tag  /**< */,
                                   uint                   target  /**< */,
                                   int                    level  /**< */,
                                   uint                   pname  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_tex_level_parameteriv_cookie_t xcb_glx_get_tex_level_parameteriv_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param int                    level
 ** @param uint                   pname
 ** @returns xcb_glx_get_tex_level_parameteriv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_tex_level_parameteriv_cookie_t
xcb_glx_get_tex_level_parameteriv_unchecked (xcb_connection_t      *c  /**< */,
                                             xcb_glx_context_tag_t  context_tag  /**< */,
                                             uint                   target  /**< */,
                                             int                    level  /**< */,
                                             uint                   pname  /**< */);


/*****************************************************************************
 **
 ** int * xcb_glx_get_tex_level_parameteriv_data
 **
 ** @param /+const+/ xcb_glx_get_tex_level_parameteriv_reply_t *R
 ** @returns int *
 **
 *****************************************************************************/

extern(C) int *
xcb_glx_get_tex_level_parameteriv_data (/+const+/ xcb_glx_get_tex_level_parameteriv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_tex_level_parameteriv_data_length
 **
 ** @param /+const+/ xcb_glx_get_tex_level_parameteriv_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_tex_level_parameteriv_data_length (/+const+/ xcb_glx_get_tex_level_parameteriv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_get_tex_level_parameteriv_data_end
 **
 ** @param /+const+/ xcb_glx_get_tex_level_parameteriv_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_get_tex_level_parameteriv_data_end (/+const+/ xcb_glx_get_tex_level_parameteriv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_tex_level_parameteriv_reply_t * xcb_glx_get_tex_level_parameteriv_reply
 **
 ** @param xcb_connection_t                            *c
 ** @param xcb_glx_get_tex_level_parameteriv_cookie_t   cookie
 ** @param xcb_generic_error_t                        **e
 ** @returns xcb_glx_get_tex_level_parameteriv_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_tex_level_parameteriv_reply_t *
xcb_glx_get_tex_level_parameteriv_reply (xcb_connection_t                            *c  /**< */,
                                         xcb_glx_get_tex_level_parameteriv_cookie_t   cookie  /**< */,
                                         xcb_generic_error_t                        **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_is_list_cookie_t xcb_glx_is_list
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   list
 ** @returns xcb_glx_is_list_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_is_list_cookie_t
xcb_glx_is_list (xcb_connection_t      *c  /**< */,
                 xcb_glx_context_tag_t  context_tag  /**< */,
                 uint                   list  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_is_list_cookie_t xcb_glx_is_list_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   list
 ** @returns xcb_glx_is_list_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_is_list_cookie_t
xcb_glx_is_list_unchecked (xcb_connection_t      *c  /**< */,
                           xcb_glx_context_tag_t  context_tag  /**< */,
                           uint                   list  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_is_list_reply_t * xcb_glx_is_list_reply
 **
 ** @param xcb_connection_t          *c
 ** @param xcb_glx_is_list_cookie_t   cookie
 ** @param xcb_generic_error_t      **e
 ** @returns xcb_glx_is_list_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_is_list_reply_t *
xcb_glx_is_list_reply (xcb_connection_t          *c  /**< */,
                       xcb_glx_is_list_cookie_t   cookie  /**< */,
                       xcb_generic_error_t      **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_flush_checked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_flush_checked (xcb_connection_t      *c  /**< */,
                       xcb_glx_context_tag_t  context_tag  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_flush
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_flush (xcb_connection_t      *c  /**< */,
               xcb_glx_context_tag_t  context_tag  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_are_textures_resident_cookie_t xcb_glx_are_textures_resident
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param int                    n
 ** @param /+const+/ uint        *textures
 ** @returns xcb_glx_are_textures_resident_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_are_textures_resident_cookie_t
xcb_glx_are_textures_resident (xcb_connection_t      *c  /**< */,
                               xcb_glx_context_tag_t  context_tag  /**< */,
                               int                    n  /**< */,
                               /+const+/ uint        *textures  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_are_textures_resident_cookie_t xcb_glx_are_textures_resident_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param int                    n
 ** @param /+const+/ uint        *textures
 ** @returns xcb_glx_are_textures_resident_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_are_textures_resident_cookie_t
xcb_glx_are_textures_resident_unchecked (xcb_connection_t      *c  /**< */,
                                         xcb_glx_context_tag_t  context_tag  /**< */,
                                         int                    n  /**< */,
                                         /+const+/ uint        *textures  /**< */);


/*****************************************************************************
 **
 ** bool * xcb_glx_are_textures_resident_data
 **
 ** @param /+const+/ xcb_glx_are_textures_resident_reply_t *R
 ** @returns bool *
 **
 *****************************************************************************/

extern(C) bool *
xcb_glx_are_textures_resident_data (/+const+/ xcb_glx_are_textures_resident_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_are_textures_resident_data_length
 **
 ** @param /+const+/ xcb_glx_are_textures_resident_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_are_textures_resident_data_length (/+const+/ xcb_glx_are_textures_resident_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_are_textures_resident_data_end
 **
 ** @param /+const+/ xcb_glx_are_textures_resident_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_are_textures_resident_data_end (/+const+/ xcb_glx_are_textures_resident_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_are_textures_resident_reply_t * xcb_glx_are_textures_resident_reply
 **
 ** @param xcb_connection_t                        *c
 ** @param xcb_glx_are_textures_resident_cookie_t   cookie
 ** @param xcb_generic_error_t                    **e
 ** @returns xcb_glx_are_textures_resident_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_are_textures_resident_reply_t *
xcb_glx_are_textures_resident_reply (xcb_connection_t                        *c  /**< */,
                                     xcb_glx_are_textures_resident_cookie_t   cookie  /**< */,
                                     xcb_generic_error_t                    **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_delete_textures_checked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param int                    n
 ** @param /+const+/ uint        *textures
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_delete_textures_checked (xcb_connection_t      *c  /**< */,
                                 xcb_glx_context_tag_t  context_tag  /**< */,
                                 int                    n  /**< */,
                                 /+const+/ uint        *textures  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_delete_textures
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param int                    n
 ** @param /+const+/ uint        *textures
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_delete_textures (xcb_connection_t      *c  /**< */,
                         xcb_glx_context_tag_t  context_tag  /**< */,
                         int                    n  /**< */,
                         /+const+/ uint        *textures  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_gen_textures_cookie_t xcb_glx_gen_textures
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param int                    n
 ** @returns xcb_glx_gen_textures_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_gen_textures_cookie_t
xcb_glx_gen_textures (xcb_connection_t      *c  /**< */,
                      xcb_glx_context_tag_t  context_tag  /**< */,
                      int                    n  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_gen_textures_cookie_t xcb_glx_gen_textures_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param int                    n
 ** @returns xcb_glx_gen_textures_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_gen_textures_cookie_t
xcb_glx_gen_textures_unchecked (xcb_connection_t      *c  /**< */,
                                xcb_glx_context_tag_t  context_tag  /**< */,
                                int                    n  /**< */);


/*****************************************************************************
 **
 ** uint * xcb_glx_gen_textures_data
 **
 ** @param /+const+/ xcb_glx_gen_textures_reply_t *R
 ** @returns uint *
 **
 *****************************************************************************/

extern(C) uint *
xcb_glx_gen_textures_data (/+const+/ xcb_glx_gen_textures_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_gen_textures_data_length
 **
 ** @param /+const+/ xcb_glx_gen_textures_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_gen_textures_data_length (/+const+/ xcb_glx_gen_textures_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_gen_textures_data_end
 **
 ** @param /+const+/ xcb_glx_gen_textures_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_gen_textures_data_end (/+const+/ xcb_glx_gen_textures_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_gen_textures_reply_t * xcb_glx_gen_textures_reply
 **
 ** @param xcb_connection_t               *c
 ** @param xcb_glx_gen_textures_cookie_t   cookie
 ** @param xcb_generic_error_t           **e
 ** @returns xcb_glx_gen_textures_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_gen_textures_reply_t *
xcb_glx_gen_textures_reply (xcb_connection_t               *c  /**< */,
                            xcb_glx_gen_textures_cookie_t   cookie  /**< */,
                            xcb_generic_error_t           **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_is_texture_cookie_t xcb_glx_is_texture
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   texture
 ** @returns xcb_glx_is_texture_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_is_texture_cookie_t
xcb_glx_is_texture (xcb_connection_t      *c  /**< */,
                    xcb_glx_context_tag_t  context_tag  /**< */,
                    uint                   texture  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_is_texture_cookie_t xcb_glx_is_texture_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   texture
 ** @returns xcb_glx_is_texture_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_is_texture_cookie_t
xcb_glx_is_texture_unchecked (xcb_connection_t      *c  /**< */,
                              xcb_glx_context_tag_t  context_tag  /**< */,
                              uint                   texture  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_is_texture_reply_t * xcb_glx_is_texture_reply
 **
 ** @param xcb_connection_t             *c
 ** @param xcb_glx_is_texture_cookie_t   cookie
 ** @param xcb_generic_error_t         **e
 ** @returns xcb_glx_is_texture_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_is_texture_reply_t *
xcb_glx_is_texture_reply (xcb_connection_t             *c  /**< */,
                          xcb_glx_is_texture_cookie_t   cookie  /**< */,
                          xcb_generic_error_t         **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_color_table_cookie_t xcb_glx_get_color_table
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param uint                   format
 ** @param uint                   type
 ** @param bool                   swap_bytes
 ** @returns xcb_glx_get_color_table_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_color_table_cookie_t
xcb_glx_get_color_table (xcb_connection_t      *c  /**< */,
                         xcb_glx_context_tag_t  context_tag  /**< */,
                         uint                   target  /**< */,
                         uint                   format  /**< */,
                         uint                   type  /**< */,
                         bool                   swap_bytes  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_color_table_cookie_t xcb_glx_get_color_table_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param uint                   format
 ** @param uint                   type
 ** @param bool                   swap_bytes
 ** @returns xcb_glx_get_color_table_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_color_table_cookie_t
xcb_glx_get_color_table_unchecked (xcb_connection_t      *c  /**< */,
                                   xcb_glx_context_tag_t  context_tag  /**< */,
                                   uint                   target  /**< */,
                                   uint                   format  /**< */,
                                   uint                   type  /**< */,
                                   bool                   swap_bytes  /**< */);


/*****************************************************************************
 **
 ** ubyte * xcb_glx_get_color_table_data
 **
 ** @param /+const+/ xcb_glx_get_color_table_reply_t *R
 ** @returns ubyte *
 **
 *****************************************************************************/

extern(C) ubyte *
xcb_glx_get_color_table_data (/+const+/ xcb_glx_get_color_table_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_color_table_data_length
 **
 ** @param /+const+/ xcb_glx_get_color_table_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_color_table_data_length (/+const+/ xcb_glx_get_color_table_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_get_color_table_data_end
 **
 ** @param /+const+/ xcb_glx_get_color_table_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_get_color_table_data_end (/+const+/ xcb_glx_get_color_table_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_color_table_reply_t * xcb_glx_get_color_table_reply
 **
 ** @param xcb_connection_t                  *c
 ** @param xcb_glx_get_color_table_cookie_t   cookie
 ** @param xcb_generic_error_t              **e
 ** @returns xcb_glx_get_color_table_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_color_table_reply_t *
xcb_glx_get_color_table_reply (xcb_connection_t                  *c  /**< */,
                               xcb_glx_get_color_table_cookie_t   cookie  /**< */,
                               xcb_generic_error_t              **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_color_table_parameterfv_cookie_t xcb_glx_get_color_table_parameterfv
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param uint                   pname
 ** @returns xcb_glx_get_color_table_parameterfv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_color_table_parameterfv_cookie_t
xcb_glx_get_color_table_parameterfv (xcb_connection_t      *c  /**< */,
                                     xcb_glx_context_tag_t  context_tag  /**< */,
                                     uint                   target  /**< */,
                                     uint                   pname  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_color_table_parameterfv_cookie_t xcb_glx_get_color_table_parameterfv_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param uint                   pname
 ** @returns xcb_glx_get_color_table_parameterfv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_color_table_parameterfv_cookie_t
xcb_glx_get_color_table_parameterfv_unchecked (xcb_connection_t      *c  /**< */,
                                               xcb_glx_context_tag_t  context_tag  /**< */,
                                               uint                   target  /**< */,
                                               uint                   pname  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_float32_t * xcb_glx_get_color_table_parameterfv_data
 **
 ** @param /+const+/ xcb_glx_get_color_table_parameterfv_reply_t *R
 ** @returns xcb_glx_float32_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_float32_t *
xcb_glx_get_color_table_parameterfv_data (/+const+/ xcb_glx_get_color_table_parameterfv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_color_table_parameterfv_data_length
 **
 ** @param /+const+/ xcb_glx_get_color_table_parameterfv_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_color_table_parameterfv_data_length (/+const+/ xcb_glx_get_color_table_parameterfv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_float32_iterator_t xcb_glx_get_color_table_parameterfv_data_iterator
 **
 ** @param /+const+/ xcb_glx_get_color_table_parameterfv_reply_t *R
 ** @returns xcb_glx_float32_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_glx_float32_iterator_t
xcb_glx_get_color_table_parameterfv_data_iterator (/+const+/ xcb_glx_get_color_table_parameterfv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_color_table_parameterfv_reply_t * xcb_glx_get_color_table_parameterfv_reply
 **
 ** @param xcb_connection_t                              *c
 ** @param xcb_glx_get_color_table_parameterfv_cookie_t   cookie
 ** @param xcb_generic_error_t                          **e
 ** @returns xcb_glx_get_color_table_parameterfv_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_color_table_parameterfv_reply_t *
xcb_glx_get_color_table_parameterfv_reply (xcb_connection_t                              *c  /**< */,
                                           xcb_glx_get_color_table_parameterfv_cookie_t   cookie  /**< */,
                                           xcb_generic_error_t                          **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_color_table_parameteriv_cookie_t xcb_glx_get_color_table_parameteriv
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param uint                   pname
 ** @returns xcb_glx_get_color_table_parameteriv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_color_table_parameteriv_cookie_t
xcb_glx_get_color_table_parameteriv (xcb_connection_t      *c  /**< */,
                                     xcb_glx_context_tag_t  context_tag  /**< */,
                                     uint                   target  /**< */,
                                     uint                   pname  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_color_table_parameteriv_cookie_t xcb_glx_get_color_table_parameteriv_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param uint                   pname
 ** @returns xcb_glx_get_color_table_parameteriv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_color_table_parameteriv_cookie_t
xcb_glx_get_color_table_parameteriv_unchecked (xcb_connection_t      *c  /**< */,
                                               xcb_glx_context_tag_t  context_tag  /**< */,
                                               uint                   target  /**< */,
                                               uint                   pname  /**< */);


/*****************************************************************************
 **
 ** int * xcb_glx_get_color_table_parameteriv_data
 **
 ** @param /+const+/ xcb_glx_get_color_table_parameteriv_reply_t *R
 ** @returns int *
 **
 *****************************************************************************/

extern(C) int *
xcb_glx_get_color_table_parameteriv_data (/+const+/ xcb_glx_get_color_table_parameteriv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_color_table_parameteriv_data_length
 **
 ** @param /+const+/ xcb_glx_get_color_table_parameteriv_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_color_table_parameteriv_data_length (/+const+/ xcb_glx_get_color_table_parameteriv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_get_color_table_parameteriv_data_end
 **
 ** @param /+const+/ xcb_glx_get_color_table_parameteriv_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_get_color_table_parameteriv_data_end (/+const+/ xcb_glx_get_color_table_parameteriv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_color_table_parameteriv_reply_t * xcb_glx_get_color_table_parameteriv_reply
 **
 ** @param xcb_connection_t                              *c
 ** @param xcb_glx_get_color_table_parameteriv_cookie_t   cookie
 ** @param xcb_generic_error_t                          **e
 ** @returns xcb_glx_get_color_table_parameteriv_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_color_table_parameteriv_reply_t *
xcb_glx_get_color_table_parameteriv_reply (xcb_connection_t                              *c  /**< */,
                                           xcb_glx_get_color_table_parameteriv_cookie_t   cookie  /**< */,
                                           xcb_generic_error_t                          **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_convolution_filter_cookie_t xcb_glx_get_convolution_filter
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param uint                   format
 ** @param uint                   type
 ** @param bool                   swap_bytes
 ** @returns xcb_glx_get_convolution_filter_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_convolution_filter_cookie_t
xcb_glx_get_convolution_filter (xcb_connection_t      *c  /**< */,
                                xcb_glx_context_tag_t  context_tag  /**< */,
                                uint                   target  /**< */,
                                uint                   format  /**< */,
                                uint                   type  /**< */,
                                bool                   swap_bytes  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_convolution_filter_cookie_t xcb_glx_get_convolution_filter_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param uint                   format
 ** @param uint                   type
 ** @param bool                   swap_bytes
 ** @returns xcb_glx_get_convolution_filter_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_convolution_filter_cookie_t
xcb_glx_get_convolution_filter_unchecked (xcb_connection_t      *c  /**< */,
                                          xcb_glx_context_tag_t  context_tag  /**< */,
                                          uint                   target  /**< */,
                                          uint                   format  /**< */,
                                          uint                   type  /**< */,
                                          bool                   swap_bytes  /**< */);


/*****************************************************************************
 **
 ** ubyte * xcb_glx_get_convolution_filter_data
 **
 ** @param /+const+/ xcb_glx_get_convolution_filter_reply_t *R
 ** @returns ubyte *
 **
 *****************************************************************************/

extern(C) ubyte *
xcb_glx_get_convolution_filter_data (/+const+/ xcb_glx_get_convolution_filter_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_convolution_filter_data_length
 **
 ** @param /+const+/ xcb_glx_get_convolution_filter_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_convolution_filter_data_length (/+const+/ xcb_glx_get_convolution_filter_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_get_convolution_filter_data_end
 **
 ** @param /+const+/ xcb_glx_get_convolution_filter_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_get_convolution_filter_data_end (/+const+/ xcb_glx_get_convolution_filter_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_convolution_filter_reply_t * xcb_glx_get_convolution_filter_reply
 **
 ** @param xcb_connection_t                         *c
 ** @param xcb_glx_get_convolution_filter_cookie_t   cookie
 ** @param xcb_generic_error_t                     **e
 ** @returns xcb_glx_get_convolution_filter_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_convolution_filter_reply_t *
xcb_glx_get_convolution_filter_reply (xcb_connection_t                         *c  /**< */,
                                      xcb_glx_get_convolution_filter_cookie_t   cookie  /**< */,
                                      xcb_generic_error_t                     **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_convolution_parameterfv_cookie_t xcb_glx_get_convolution_parameterfv
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param uint                   pname
 ** @returns xcb_glx_get_convolution_parameterfv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_convolution_parameterfv_cookie_t
xcb_glx_get_convolution_parameterfv (xcb_connection_t      *c  /**< */,
                                     xcb_glx_context_tag_t  context_tag  /**< */,
                                     uint                   target  /**< */,
                                     uint                   pname  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_convolution_parameterfv_cookie_t xcb_glx_get_convolution_parameterfv_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param uint                   pname
 ** @returns xcb_glx_get_convolution_parameterfv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_convolution_parameterfv_cookie_t
xcb_glx_get_convolution_parameterfv_unchecked (xcb_connection_t      *c  /**< */,
                                               xcb_glx_context_tag_t  context_tag  /**< */,
                                               uint                   target  /**< */,
                                               uint                   pname  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_float32_t * xcb_glx_get_convolution_parameterfv_data
 **
 ** @param /+const+/ xcb_glx_get_convolution_parameterfv_reply_t *R
 ** @returns xcb_glx_float32_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_float32_t *
xcb_glx_get_convolution_parameterfv_data (/+const+/ xcb_glx_get_convolution_parameterfv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_convolution_parameterfv_data_length
 **
 ** @param /+const+/ xcb_glx_get_convolution_parameterfv_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_convolution_parameterfv_data_length (/+const+/ xcb_glx_get_convolution_parameterfv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_float32_iterator_t xcb_glx_get_convolution_parameterfv_data_iterator
 **
 ** @param /+const+/ xcb_glx_get_convolution_parameterfv_reply_t *R
 ** @returns xcb_glx_float32_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_glx_float32_iterator_t
xcb_glx_get_convolution_parameterfv_data_iterator (/+const+/ xcb_glx_get_convolution_parameterfv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_convolution_parameterfv_reply_t * xcb_glx_get_convolution_parameterfv_reply
 **
 ** @param xcb_connection_t                              *c
 ** @param xcb_glx_get_convolution_parameterfv_cookie_t   cookie
 ** @param xcb_generic_error_t                          **e
 ** @returns xcb_glx_get_convolution_parameterfv_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_convolution_parameterfv_reply_t *
xcb_glx_get_convolution_parameterfv_reply (xcb_connection_t                              *c  /**< */,
                                           xcb_glx_get_convolution_parameterfv_cookie_t   cookie  /**< */,
                                           xcb_generic_error_t                          **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_convolution_parameteriv_cookie_t xcb_glx_get_convolution_parameteriv
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param uint                   pname
 ** @returns xcb_glx_get_convolution_parameteriv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_convolution_parameteriv_cookie_t
xcb_glx_get_convolution_parameteriv (xcb_connection_t      *c  /**< */,
                                     xcb_glx_context_tag_t  context_tag  /**< */,
                                     uint                   target  /**< */,
                                     uint                   pname  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_convolution_parameteriv_cookie_t xcb_glx_get_convolution_parameteriv_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param uint                   pname
 ** @returns xcb_glx_get_convolution_parameteriv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_convolution_parameteriv_cookie_t
xcb_glx_get_convolution_parameteriv_unchecked (xcb_connection_t      *c  /**< */,
                                               xcb_glx_context_tag_t  context_tag  /**< */,
                                               uint                   target  /**< */,
                                               uint                   pname  /**< */);


/*****************************************************************************
 **
 ** int * xcb_glx_get_convolution_parameteriv_data
 **
 ** @param /+const+/ xcb_glx_get_convolution_parameteriv_reply_t *R
 ** @returns int *
 **
 *****************************************************************************/

extern(C) int *
xcb_glx_get_convolution_parameteriv_data (/+const+/ xcb_glx_get_convolution_parameteriv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_convolution_parameteriv_data_length
 **
 ** @param /+const+/ xcb_glx_get_convolution_parameteriv_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_convolution_parameteriv_data_length (/+const+/ xcb_glx_get_convolution_parameteriv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_get_convolution_parameteriv_data_end
 **
 ** @param /+const+/ xcb_glx_get_convolution_parameteriv_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_get_convolution_parameteriv_data_end (/+const+/ xcb_glx_get_convolution_parameteriv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_convolution_parameteriv_reply_t * xcb_glx_get_convolution_parameteriv_reply
 **
 ** @param xcb_connection_t                              *c
 ** @param xcb_glx_get_convolution_parameteriv_cookie_t   cookie
 ** @param xcb_generic_error_t                          **e
 ** @returns xcb_glx_get_convolution_parameteriv_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_convolution_parameteriv_reply_t *
xcb_glx_get_convolution_parameteriv_reply (xcb_connection_t                              *c  /**< */,
                                           xcb_glx_get_convolution_parameteriv_cookie_t   cookie  /**< */,
                                           xcb_generic_error_t                          **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_separable_filter_cookie_t xcb_glx_get_separable_filter
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param uint                   format
 ** @param uint                   type
 ** @param bool                   swap_bytes
 ** @returns xcb_glx_get_separable_filter_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_separable_filter_cookie_t
xcb_glx_get_separable_filter (xcb_connection_t      *c  /**< */,
                              xcb_glx_context_tag_t  context_tag  /**< */,
                              uint                   target  /**< */,
                              uint                   format  /**< */,
                              uint                   type  /**< */,
                              bool                   swap_bytes  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_separable_filter_cookie_t xcb_glx_get_separable_filter_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param uint                   format
 ** @param uint                   type
 ** @param bool                   swap_bytes
 ** @returns xcb_glx_get_separable_filter_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_separable_filter_cookie_t
xcb_glx_get_separable_filter_unchecked (xcb_connection_t      *c  /**< */,
                                        xcb_glx_context_tag_t  context_tag  /**< */,
                                        uint                   target  /**< */,
                                        uint                   format  /**< */,
                                        uint                   type  /**< */,
                                        bool                   swap_bytes  /**< */);


/*****************************************************************************
 **
 ** ubyte * xcb_glx_get_separable_filter_rows_and_cols
 **
 ** @param /+const+/ xcb_glx_get_separable_filter_reply_t *R
 ** @returns ubyte *
 **
 *****************************************************************************/

extern(C) ubyte *
xcb_glx_get_separable_filter_rows_and_cols (/+const+/ xcb_glx_get_separable_filter_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_separable_filter_rows_and_cols_length
 **
 ** @param /+const+/ xcb_glx_get_separable_filter_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_separable_filter_rows_and_cols_length (/+const+/ xcb_glx_get_separable_filter_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_get_separable_filter_rows_and_cols_end
 **
 ** @param /+const+/ xcb_glx_get_separable_filter_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_get_separable_filter_rows_and_cols_end (/+const+/ xcb_glx_get_separable_filter_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_separable_filter_reply_t * xcb_glx_get_separable_filter_reply
 **
 ** @param xcb_connection_t                       *c
 ** @param xcb_glx_get_separable_filter_cookie_t   cookie
 ** @param xcb_generic_error_t                   **e
 ** @returns xcb_glx_get_separable_filter_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_separable_filter_reply_t *
xcb_glx_get_separable_filter_reply (xcb_connection_t                       *c  /**< */,
                                    xcb_glx_get_separable_filter_cookie_t   cookie  /**< */,
                                    xcb_generic_error_t                   **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_histogram_cookie_t xcb_glx_get_histogram
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param uint                   format
 ** @param uint                   type
 ** @param bool                   swap_bytes
 ** @param bool                   reset
 ** @returns xcb_glx_get_histogram_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_histogram_cookie_t
xcb_glx_get_histogram (xcb_connection_t      *c  /**< */,
                       xcb_glx_context_tag_t  context_tag  /**< */,
                       uint                   target  /**< */,
                       uint                   format  /**< */,
                       uint                   type  /**< */,
                       bool                   swap_bytes  /**< */,
                       bool                   reset  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_histogram_cookie_t xcb_glx_get_histogram_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param uint                   format
 ** @param uint                   type
 ** @param bool                   swap_bytes
 ** @param bool                   reset
 ** @returns xcb_glx_get_histogram_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_histogram_cookie_t
xcb_glx_get_histogram_unchecked (xcb_connection_t      *c  /**< */,
                                 xcb_glx_context_tag_t  context_tag  /**< */,
                                 uint                   target  /**< */,
                                 uint                   format  /**< */,
                                 uint                   type  /**< */,
                                 bool                   swap_bytes  /**< */,
                                 bool                   reset  /**< */);


/*****************************************************************************
 **
 ** ubyte * xcb_glx_get_histogram_data
 **
 ** @param /+const+/ xcb_glx_get_histogram_reply_t *R
 ** @returns ubyte *
 **
 *****************************************************************************/

extern(C) ubyte *
xcb_glx_get_histogram_data (/+const+/ xcb_glx_get_histogram_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_histogram_data_length
 **
 ** @param /+const+/ xcb_glx_get_histogram_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_histogram_data_length (/+const+/ xcb_glx_get_histogram_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_get_histogram_data_end
 **
 ** @param /+const+/ xcb_glx_get_histogram_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_get_histogram_data_end (/+const+/ xcb_glx_get_histogram_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_histogram_reply_t * xcb_glx_get_histogram_reply
 **
 ** @param xcb_connection_t                *c
 ** @param xcb_glx_get_histogram_cookie_t   cookie
 ** @param xcb_generic_error_t            **e
 ** @returns xcb_glx_get_histogram_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_histogram_reply_t *
xcb_glx_get_histogram_reply (xcb_connection_t                *c  /**< */,
                             xcb_glx_get_histogram_cookie_t   cookie  /**< */,
                             xcb_generic_error_t            **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_histogram_parameterfv_cookie_t xcb_glx_get_histogram_parameterfv
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param uint                   pname
 ** @returns xcb_glx_get_histogram_parameterfv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_histogram_parameterfv_cookie_t
xcb_glx_get_histogram_parameterfv (xcb_connection_t      *c  /**< */,
                                   xcb_glx_context_tag_t  context_tag  /**< */,
                                   uint                   target  /**< */,
                                   uint                   pname  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_histogram_parameterfv_cookie_t xcb_glx_get_histogram_parameterfv_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param uint                   pname
 ** @returns xcb_glx_get_histogram_parameterfv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_histogram_parameterfv_cookie_t
xcb_glx_get_histogram_parameterfv_unchecked (xcb_connection_t      *c  /**< */,
                                             xcb_glx_context_tag_t  context_tag  /**< */,
                                             uint                   target  /**< */,
                                             uint                   pname  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_float32_t * xcb_glx_get_histogram_parameterfv_data
 **
 ** @param /+const+/ xcb_glx_get_histogram_parameterfv_reply_t *R
 ** @returns xcb_glx_float32_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_float32_t *
xcb_glx_get_histogram_parameterfv_data (/+const+/ xcb_glx_get_histogram_parameterfv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_histogram_parameterfv_data_length
 **
 ** @param /+const+/ xcb_glx_get_histogram_parameterfv_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_histogram_parameterfv_data_length (/+const+/ xcb_glx_get_histogram_parameterfv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_float32_iterator_t xcb_glx_get_histogram_parameterfv_data_iterator
 **
 ** @param /+const+/ xcb_glx_get_histogram_parameterfv_reply_t *R
 ** @returns xcb_glx_float32_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_glx_float32_iterator_t
xcb_glx_get_histogram_parameterfv_data_iterator (/+const+/ xcb_glx_get_histogram_parameterfv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_histogram_parameterfv_reply_t * xcb_glx_get_histogram_parameterfv_reply
 **
 ** @param xcb_connection_t                            *c
 ** @param xcb_glx_get_histogram_parameterfv_cookie_t   cookie
 ** @param xcb_generic_error_t                        **e
 ** @returns xcb_glx_get_histogram_parameterfv_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_histogram_parameterfv_reply_t *
xcb_glx_get_histogram_parameterfv_reply (xcb_connection_t                            *c  /**< */,
                                         xcb_glx_get_histogram_parameterfv_cookie_t   cookie  /**< */,
                                         xcb_generic_error_t                        **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_histogram_parameteriv_cookie_t xcb_glx_get_histogram_parameteriv
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param uint                   pname
 ** @returns xcb_glx_get_histogram_parameteriv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_histogram_parameteriv_cookie_t
xcb_glx_get_histogram_parameteriv (xcb_connection_t      *c  /**< */,
                                   xcb_glx_context_tag_t  context_tag  /**< */,
                                   uint                   target  /**< */,
                                   uint                   pname  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_histogram_parameteriv_cookie_t xcb_glx_get_histogram_parameteriv_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param uint                   pname
 ** @returns xcb_glx_get_histogram_parameteriv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_histogram_parameteriv_cookie_t
xcb_glx_get_histogram_parameteriv_unchecked (xcb_connection_t      *c  /**< */,
                                             xcb_glx_context_tag_t  context_tag  /**< */,
                                             uint                   target  /**< */,
                                             uint                   pname  /**< */);


/*****************************************************************************
 **
 ** int * xcb_glx_get_histogram_parameteriv_data
 **
 ** @param /+const+/ xcb_glx_get_histogram_parameteriv_reply_t *R
 ** @returns int *
 **
 *****************************************************************************/

extern(C) int *
xcb_glx_get_histogram_parameteriv_data (/+const+/ xcb_glx_get_histogram_parameteriv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_histogram_parameteriv_data_length
 **
 ** @param /+const+/ xcb_glx_get_histogram_parameteriv_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_histogram_parameteriv_data_length (/+const+/ xcb_glx_get_histogram_parameteriv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_get_histogram_parameteriv_data_end
 **
 ** @param /+const+/ xcb_glx_get_histogram_parameteriv_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_get_histogram_parameteriv_data_end (/+const+/ xcb_glx_get_histogram_parameteriv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_histogram_parameteriv_reply_t * xcb_glx_get_histogram_parameteriv_reply
 **
 ** @param xcb_connection_t                            *c
 ** @param xcb_glx_get_histogram_parameteriv_cookie_t   cookie
 ** @param xcb_generic_error_t                        **e
 ** @returns xcb_glx_get_histogram_parameteriv_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_histogram_parameteriv_reply_t *
xcb_glx_get_histogram_parameteriv_reply (xcb_connection_t                            *c  /**< */,
                                         xcb_glx_get_histogram_parameteriv_cookie_t   cookie  /**< */,
                                         xcb_generic_error_t                        **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_minmax_cookie_t xcb_glx_get_minmax
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param uint                   format
 ** @param uint                   type
 ** @param bool                   swap_bytes
 ** @param bool                   reset
 ** @returns xcb_glx_get_minmax_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_minmax_cookie_t
xcb_glx_get_minmax (xcb_connection_t      *c  /**< */,
                    xcb_glx_context_tag_t  context_tag  /**< */,
                    uint                   target  /**< */,
                    uint                   format  /**< */,
                    uint                   type  /**< */,
                    bool                   swap_bytes  /**< */,
                    bool                   reset  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_minmax_cookie_t xcb_glx_get_minmax_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param uint                   format
 ** @param uint                   type
 ** @param bool                   swap_bytes
 ** @param bool                   reset
 ** @returns xcb_glx_get_minmax_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_minmax_cookie_t
xcb_glx_get_minmax_unchecked (xcb_connection_t      *c  /**< */,
                              xcb_glx_context_tag_t  context_tag  /**< */,
                              uint                   target  /**< */,
                              uint                   format  /**< */,
                              uint                   type  /**< */,
                              bool                   swap_bytes  /**< */,
                              bool                   reset  /**< */);


/*****************************************************************************
 **
 ** ubyte * xcb_glx_get_minmax_data
 **
 ** @param /+const+/ xcb_glx_get_minmax_reply_t *R
 ** @returns ubyte *
 **
 *****************************************************************************/

extern(C) ubyte *
xcb_glx_get_minmax_data (/+const+/ xcb_glx_get_minmax_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_minmax_data_length
 **
 ** @param /+const+/ xcb_glx_get_minmax_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_minmax_data_length (/+const+/ xcb_glx_get_minmax_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_get_minmax_data_end
 **
 ** @param /+const+/ xcb_glx_get_minmax_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_get_minmax_data_end (/+const+/ xcb_glx_get_minmax_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_minmax_reply_t * xcb_glx_get_minmax_reply
 **
 ** @param xcb_connection_t             *c
 ** @param xcb_glx_get_minmax_cookie_t   cookie
 ** @param xcb_generic_error_t         **e
 ** @returns xcb_glx_get_minmax_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_minmax_reply_t *
xcb_glx_get_minmax_reply (xcb_connection_t             *c  /**< */,
                          xcb_glx_get_minmax_cookie_t   cookie  /**< */,
                          xcb_generic_error_t         **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_minmax_parameterfv_cookie_t xcb_glx_get_minmax_parameterfv
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param uint                   pname
 ** @returns xcb_glx_get_minmax_parameterfv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_minmax_parameterfv_cookie_t
xcb_glx_get_minmax_parameterfv (xcb_connection_t      *c  /**< */,
                                xcb_glx_context_tag_t  context_tag  /**< */,
                                uint                   target  /**< */,
                                uint                   pname  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_minmax_parameterfv_cookie_t xcb_glx_get_minmax_parameterfv_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param uint                   pname
 ** @returns xcb_glx_get_minmax_parameterfv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_minmax_parameterfv_cookie_t
xcb_glx_get_minmax_parameterfv_unchecked (xcb_connection_t      *c  /**< */,
                                          xcb_glx_context_tag_t  context_tag  /**< */,
                                          uint                   target  /**< */,
                                          uint                   pname  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_float32_t * xcb_glx_get_minmax_parameterfv_data
 **
 ** @param /+const+/ xcb_glx_get_minmax_parameterfv_reply_t *R
 ** @returns xcb_glx_float32_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_float32_t *
xcb_glx_get_minmax_parameterfv_data (/+const+/ xcb_glx_get_minmax_parameterfv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_minmax_parameterfv_data_length
 **
 ** @param /+const+/ xcb_glx_get_minmax_parameterfv_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_minmax_parameterfv_data_length (/+const+/ xcb_glx_get_minmax_parameterfv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_float32_iterator_t xcb_glx_get_minmax_parameterfv_data_iterator
 **
 ** @param /+const+/ xcb_glx_get_minmax_parameterfv_reply_t *R
 ** @returns xcb_glx_float32_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_glx_float32_iterator_t
xcb_glx_get_minmax_parameterfv_data_iterator (/+const+/ xcb_glx_get_minmax_parameterfv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_minmax_parameterfv_reply_t * xcb_glx_get_minmax_parameterfv_reply
 **
 ** @param xcb_connection_t                         *c
 ** @param xcb_glx_get_minmax_parameterfv_cookie_t   cookie
 ** @param xcb_generic_error_t                     **e
 ** @returns xcb_glx_get_minmax_parameterfv_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_minmax_parameterfv_reply_t *
xcb_glx_get_minmax_parameterfv_reply (xcb_connection_t                         *c  /**< */,
                                      xcb_glx_get_minmax_parameterfv_cookie_t   cookie  /**< */,
                                      xcb_generic_error_t                     **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_minmax_parameteriv_cookie_t xcb_glx_get_minmax_parameteriv
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param uint                   pname
 ** @returns xcb_glx_get_minmax_parameteriv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_minmax_parameteriv_cookie_t
xcb_glx_get_minmax_parameteriv (xcb_connection_t      *c  /**< */,
                                xcb_glx_context_tag_t  context_tag  /**< */,
                                uint                   target  /**< */,
                                uint                   pname  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_minmax_parameteriv_cookie_t xcb_glx_get_minmax_parameteriv_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param uint                   pname
 ** @returns xcb_glx_get_minmax_parameteriv_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_minmax_parameteriv_cookie_t
xcb_glx_get_minmax_parameteriv_unchecked (xcb_connection_t      *c  /**< */,
                                          xcb_glx_context_tag_t  context_tag  /**< */,
                                          uint                   target  /**< */,
                                          uint                   pname  /**< */);


/*****************************************************************************
 **
 ** int * xcb_glx_get_minmax_parameteriv_data
 **
 ** @param /+const+/ xcb_glx_get_minmax_parameteriv_reply_t *R
 ** @returns int *
 **
 *****************************************************************************/

extern(C) int *
xcb_glx_get_minmax_parameteriv_data (/+const+/ xcb_glx_get_minmax_parameteriv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_minmax_parameteriv_data_length
 **
 ** @param /+const+/ xcb_glx_get_minmax_parameteriv_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_minmax_parameteriv_data_length (/+const+/ xcb_glx_get_minmax_parameteriv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_get_minmax_parameteriv_data_end
 **
 ** @param /+const+/ xcb_glx_get_minmax_parameteriv_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_get_minmax_parameteriv_data_end (/+const+/ xcb_glx_get_minmax_parameteriv_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_minmax_parameteriv_reply_t * xcb_glx_get_minmax_parameteriv_reply
 **
 ** @param xcb_connection_t                         *c
 ** @param xcb_glx_get_minmax_parameteriv_cookie_t   cookie
 ** @param xcb_generic_error_t                     **e
 ** @returns xcb_glx_get_minmax_parameteriv_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_minmax_parameteriv_reply_t *
xcb_glx_get_minmax_parameteriv_reply (xcb_connection_t                         *c  /**< */,
                                      xcb_glx_get_minmax_parameteriv_cookie_t   cookie  /**< */,
                                      xcb_generic_error_t                     **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_compressed_tex_image_arb_cookie_t xcb_glx_get_compressed_tex_image_arb
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param int                    level
 ** @returns xcb_glx_get_compressed_tex_image_arb_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_compressed_tex_image_arb_cookie_t
xcb_glx_get_compressed_tex_image_arb (xcb_connection_t      *c  /**< */,
                                      xcb_glx_context_tag_t  context_tag  /**< */,
                                      uint                   target  /**< */,
                                      int                    level  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_compressed_tex_image_arb_cookie_t xcb_glx_get_compressed_tex_image_arb_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param int                    level
 ** @returns xcb_glx_get_compressed_tex_image_arb_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_compressed_tex_image_arb_cookie_t
xcb_glx_get_compressed_tex_image_arb_unchecked (xcb_connection_t      *c  /**< */,
                                                xcb_glx_context_tag_t  context_tag  /**< */,
                                                uint                   target  /**< */,
                                                int                    level  /**< */);


/*****************************************************************************
 **
 ** ubyte * xcb_glx_get_compressed_tex_image_arb_data
 **
 ** @param /+const+/ xcb_glx_get_compressed_tex_image_arb_reply_t *R
 ** @returns ubyte *
 **
 *****************************************************************************/

extern(C) ubyte *
xcb_glx_get_compressed_tex_image_arb_data (/+const+/ xcb_glx_get_compressed_tex_image_arb_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_compressed_tex_image_arb_data_length
 **
 ** @param /+const+/ xcb_glx_get_compressed_tex_image_arb_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_compressed_tex_image_arb_data_length (/+const+/ xcb_glx_get_compressed_tex_image_arb_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_get_compressed_tex_image_arb_data_end
 **
 ** @param /+const+/ xcb_glx_get_compressed_tex_image_arb_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_get_compressed_tex_image_arb_data_end (/+const+/ xcb_glx_get_compressed_tex_image_arb_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_compressed_tex_image_arb_reply_t * xcb_glx_get_compressed_tex_image_arb_reply
 **
 ** @param xcb_connection_t                               *c
 ** @param xcb_glx_get_compressed_tex_image_arb_cookie_t   cookie
 ** @param xcb_generic_error_t                           **e
 ** @returns xcb_glx_get_compressed_tex_image_arb_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_compressed_tex_image_arb_reply_t *
xcb_glx_get_compressed_tex_image_arb_reply (xcb_connection_t                               *c  /**< */,
                                            xcb_glx_get_compressed_tex_image_arb_cookie_t   cookie  /**< */,
                                            xcb_generic_error_t                           **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_delete_queries_arb_checked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param int                    n
 ** @param /+const+/ uint        *ids
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_delete_queries_arb_checked (xcb_connection_t      *c  /**< */,
                                    xcb_glx_context_tag_t  context_tag  /**< */,
                                    int                    n  /**< */,
                                    /+const+/ uint        *ids  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_glx_delete_queries_arb
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param int                    n
 ** @param /+const+/ uint        *ids
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_glx_delete_queries_arb (xcb_connection_t      *c  /**< */,
                            xcb_glx_context_tag_t  context_tag  /**< */,
                            int                    n  /**< */,
                            /+const+/ uint        *ids  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_gen_queries_arb_cookie_t xcb_glx_gen_queries_arb
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param int                    n
 ** @returns xcb_glx_gen_queries_arb_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_gen_queries_arb_cookie_t
xcb_glx_gen_queries_arb (xcb_connection_t      *c  /**< */,
                         xcb_glx_context_tag_t  context_tag  /**< */,
                         int                    n  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_gen_queries_arb_cookie_t xcb_glx_gen_queries_arb_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param int                    n
 ** @returns xcb_glx_gen_queries_arb_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_gen_queries_arb_cookie_t
xcb_glx_gen_queries_arb_unchecked (xcb_connection_t      *c  /**< */,
                                   xcb_glx_context_tag_t  context_tag  /**< */,
                                   int                    n  /**< */);


/*****************************************************************************
 **
 ** uint * xcb_glx_gen_queries_arb_data
 **
 ** @param /+const+/ xcb_glx_gen_queries_arb_reply_t *R
 ** @returns uint *
 **
 *****************************************************************************/

extern(C) uint *
xcb_glx_gen_queries_arb_data (/+const+/ xcb_glx_gen_queries_arb_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_gen_queries_arb_data_length
 **
 ** @param /+const+/ xcb_glx_gen_queries_arb_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_gen_queries_arb_data_length (/+const+/ xcb_glx_gen_queries_arb_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_gen_queries_arb_data_end
 **
 ** @param /+const+/ xcb_glx_gen_queries_arb_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_gen_queries_arb_data_end (/+const+/ xcb_glx_gen_queries_arb_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_gen_queries_arb_reply_t * xcb_glx_gen_queries_arb_reply
 **
 ** @param xcb_connection_t                  *c
 ** @param xcb_glx_gen_queries_arb_cookie_t   cookie
 ** @param xcb_generic_error_t              **e
 ** @returns xcb_glx_gen_queries_arb_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_gen_queries_arb_reply_t *
xcb_glx_gen_queries_arb_reply (xcb_connection_t                  *c  /**< */,
                               xcb_glx_gen_queries_arb_cookie_t   cookie  /**< */,
                               xcb_generic_error_t              **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_is_query_arb_cookie_t xcb_glx_is_query_arb
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   id
 ** @returns xcb_glx_is_query_arb_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_is_query_arb_cookie_t
xcb_glx_is_query_arb (xcb_connection_t      *c  /**< */,
                      xcb_glx_context_tag_t  context_tag  /**< */,
                      uint                   id  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_is_query_arb_cookie_t xcb_glx_is_query_arb_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   id
 ** @returns xcb_glx_is_query_arb_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_is_query_arb_cookie_t
xcb_glx_is_query_arb_unchecked (xcb_connection_t      *c  /**< */,
                                xcb_glx_context_tag_t  context_tag  /**< */,
                                uint                   id  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_is_query_arb_reply_t * xcb_glx_is_query_arb_reply
 **
 ** @param xcb_connection_t               *c
 ** @param xcb_glx_is_query_arb_cookie_t   cookie
 ** @param xcb_generic_error_t           **e
 ** @returns xcb_glx_is_query_arb_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_is_query_arb_reply_t *
xcb_glx_is_query_arb_reply (xcb_connection_t               *c  /**< */,
                            xcb_glx_is_query_arb_cookie_t   cookie  /**< */,
                            xcb_generic_error_t           **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_queryiv_arb_cookie_t xcb_glx_get_queryiv_arb
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param uint                   pname
 ** @returns xcb_glx_get_queryiv_arb_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_queryiv_arb_cookie_t
xcb_glx_get_queryiv_arb (xcb_connection_t      *c  /**< */,
                         xcb_glx_context_tag_t  context_tag  /**< */,
                         uint                   target  /**< */,
                         uint                   pname  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_queryiv_arb_cookie_t xcb_glx_get_queryiv_arb_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   target
 ** @param uint                   pname
 ** @returns xcb_glx_get_queryiv_arb_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_queryiv_arb_cookie_t
xcb_glx_get_queryiv_arb_unchecked (xcb_connection_t      *c  /**< */,
                                   xcb_glx_context_tag_t  context_tag  /**< */,
                                   uint                   target  /**< */,
                                   uint                   pname  /**< */);


/*****************************************************************************
 **
 ** int * xcb_glx_get_queryiv_arb_data
 **
 ** @param /+const+/ xcb_glx_get_queryiv_arb_reply_t *R
 ** @returns int *
 **
 *****************************************************************************/

extern(C) int *
xcb_glx_get_queryiv_arb_data (/+const+/ xcb_glx_get_queryiv_arb_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_queryiv_arb_data_length
 **
 ** @param /+const+/ xcb_glx_get_queryiv_arb_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_queryiv_arb_data_length (/+const+/ xcb_glx_get_queryiv_arb_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_get_queryiv_arb_data_end
 **
 ** @param /+const+/ xcb_glx_get_queryiv_arb_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_get_queryiv_arb_data_end (/+const+/ xcb_glx_get_queryiv_arb_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_queryiv_arb_reply_t * xcb_glx_get_queryiv_arb_reply
 **
 ** @param xcb_connection_t                  *c
 ** @param xcb_glx_get_queryiv_arb_cookie_t   cookie
 ** @param xcb_generic_error_t              **e
 ** @returns xcb_glx_get_queryiv_arb_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_queryiv_arb_reply_t *
xcb_glx_get_queryiv_arb_reply (xcb_connection_t                  *c  /**< */,
                               xcb_glx_get_queryiv_arb_cookie_t   cookie  /**< */,
                               xcb_generic_error_t              **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_query_objectiv_arb_cookie_t xcb_glx_get_query_objectiv_arb
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   id
 ** @param uint                   pname
 ** @returns xcb_glx_get_query_objectiv_arb_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_query_objectiv_arb_cookie_t
xcb_glx_get_query_objectiv_arb (xcb_connection_t      *c  /**< */,
                                xcb_glx_context_tag_t  context_tag  /**< */,
                                uint                   id  /**< */,
                                uint                   pname  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_query_objectiv_arb_cookie_t xcb_glx_get_query_objectiv_arb_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   id
 ** @param uint                   pname
 ** @returns xcb_glx_get_query_objectiv_arb_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_query_objectiv_arb_cookie_t
xcb_glx_get_query_objectiv_arb_unchecked (xcb_connection_t      *c  /**< */,
                                          xcb_glx_context_tag_t  context_tag  /**< */,
                                          uint                   id  /**< */,
                                          uint                   pname  /**< */);


/*****************************************************************************
 **
 ** int * xcb_glx_get_query_objectiv_arb_data
 **
 ** @param /+const+/ xcb_glx_get_query_objectiv_arb_reply_t *R
 ** @returns int *
 **
 *****************************************************************************/

extern(C) int *
xcb_glx_get_query_objectiv_arb_data (/+const+/ xcb_glx_get_query_objectiv_arb_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_query_objectiv_arb_data_length
 **
 ** @param /+const+/ xcb_glx_get_query_objectiv_arb_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_query_objectiv_arb_data_length (/+const+/ xcb_glx_get_query_objectiv_arb_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_get_query_objectiv_arb_data_end
 **
 ** @param /+const+/ xcb_glx_get_query_objectiv_arb_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_get_query_objectiv_arb_data_end (/+const+/ xcb_glx_get_query_objectiv_arb_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_query_objectiv_arb_reply_t * xcb_glx_get_query_objectiv_arb_reply
 **
 ** @param xcb_connection_t                         *c
 ** @param xcb_glx_get_query_objectiv_arb_cookie_t   cookie
 ** @param xcb_generic_error_t                     **e
 ** @returns xcb_glx_get_query_objectiv_arb_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_query_objectiv_arb_reply_t *
xcb_glx_get_query_objectiv_arb_reply (xcb_connection_t                         *c  /**< */,
                                      xcb_glx_get_query_objectiv_arb_cookie_t   cookie  /**< */,
                                      xcb_generic_error_t                     **e  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_query_objectuiv_arb_cookie_t xcb_glx_get_query_objectuiv_arb
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   id
 ** @param uint                   pname
 ** @returns xcb_glx_get_query_objectuiv_arb_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_query_objectuiv_arb_cookie_t
xcb_glx_get_query_objectuiv_arb (xcb_connection_t      *c  /**< */,
                                 xcb_glx_context_tag_t  context_tag  /**< */,
                                 uint                   id  /**< */,
                                 uint                   pname  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_query_objectuiv_arb_cookie_t xcb_glx_get_query_objectuiv_arb_unchecked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_glx_context_tag_t  context_tag
 ** @param uint                   id
 ** @param uint                   pname
 ** @returns xcb_glx_get_query_objectuiv_arb_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_glx_get_query_objectuiv_arb_cookie_t
xcb_glx_get_query_objectuiv_arb_unchecked (xcb_connection_t      *c  /**< */,
                                           xcb_glx_context_tag_t  context_tag  /**< */,
                                           uint                   id  /**< */,
                                           uint                   pname  /**< */);


/*****************************************************************************
 **
 ** uint * xcb_glx_get_query_objectuiv_arb_data
 **
 ** @param /+const+/ xcb_glx_get_query_objectuiv_arb_reply_t *R
 ** @returns uint *
 **
 *****************************************************************************/

extern(C) uint *
xcb_glx_get_query_objectuiv_arb_data (/+const+/ xcb_glx_get_query_objectuiv_arb_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_glx_get_query_objectuiv_arb_data_length
 **
 ** @param /+const+/ xcb_glx_get_query_objectuiv_arb_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_glx_get_query_objectuiv_arb_data_length (/+const+/ xcb_glx_get_query_objectuiv_arb_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_glx_get_query_objectuiv_arb_data_end
 **
 ** @param /+const+/ xcb_glx_get_query_objectuiv_arb_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_glx_get_query_objectuiv_arb_data_end (/+const+/ xcb_glx_get_query_objectuiv_arb_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_glx_get_query_objectuiv_arb_reply_t * xcb_glx_get_query_objectuiv_arb_reply
 **
 ** @param xcb_connection_t                          *c
 ** @param xcb_glx_get_query_objectuiv_arb_cookie_t   cookie
 ** @param xcb_generic_error_t                      **e
 ** @returns xcb_glx_get_query_objectuiv_arb_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_glx_get_query_objectuiv_arb_reply_t *
xcb_glx_get_query_objectuiv_arb_reply (xcb_connection_t                          *c  /**< */,
                                       xcb_glx_get_query_objectuiv_arb_cookie_t   cookie  /**< */,
                                       xcb_generic_error_t                      **e  /**< */);



/**
 * @}
 */
