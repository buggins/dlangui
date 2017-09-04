/*
 * This file generated automatically from xfixes.xml by c-client.xsl using XSLT.
 * Edit at your peril.
 */

/**
 * @defgroup XCB_XFixes_API XCB XFixes API
 * @brief XFixes XCB Protocol Implementation.
 * @{
 **/


module std.c.linux.X11.xcb.xfixes;
version(USE_XCB):

import std.c.linux.X11.xcb.xcb;
import std.c.linux.X11.xcb.xproto;
import std.c.linux.X11.xcb.render;
import std.c.linux.X11.xcb.shape;

const int XCB_XFIXES_MAJOR_VERSION =4;
const int XCB_XFIXES_MINOR_VERSION =0;

extern(C) extern xcb_extension_t xcb_xfixes_id;

/**
 * @brief xcb_xfixes_query_version_cookie_t
 **/
struct xcb_xfixes_query_version_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_xfixes_query_version. */
const uint XCB_XFIXES_QUERY_VERSION = 0;

/**
 * @brief xcb_xfixes_query_version_request_t
 **/
struct xcb_xfixes_query_version_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
    uint   client_major_version; /**<  */
    uint   client_minor_version; /**<  */
} ;

/**
 * @brief xcb_xfixes_query_version_reply_t
 **/
struct xcb_xfixes_query_version_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    uint   major_version; /**<  */
    uint   minor_version; /**<  */
    ubyte  pad1[16]; /**<  */
} ;

enum :int{
    XCB_XFIXES_SAVE_SET_MODE_INSERT,
    XCB_XFIXES_SAVE_SET_MODE_DELETE
};

enum :int{
    XCB_XFIXES_SAVE_SET_TARGET_NEAREST,
    XCB_XFIXES_SAVE_SET_TARGET_ROOT
};

enum :int{
    XCB_XFIXES_SAVE_SET_MAPPING_MAP,
    XCB_XFIXES_SAVE_SET_MAPPING_UNMAP
};

/** Opcode for xcb_xfixes_change_save_set. */
const uint XCB_XFIXES_CHANGE_SAVE_SET = 1;

/**
 * @brief xcb_xfixes_change_save_set_request_t
 **/
struct xcb_xfixes_change_save_set_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        minor_opcode; /**<  */
    ushort       length; /**<  */
    ubyte        mode; /**<  */
    ubyte        target; /**<  */
    ubyte        map; /**<  */
    ubyte        pad0; /**<  */
    xcb_window_t window; /**<  */
} ;

enum :int{
    XCB_XFIXES_SELECTION_EVENT_SET_SELECTION_OWNER,
    XCB_XFIXES_SELECTION_EVENT_SELECTION_WINDOW_DESTROY,
    XCB_XFIXES_SELECTION_EVENT_SELECTION_CLIENT_CLOSE
};

enum :int{
    XCB_XFIXES_SELECTION_EVENT_MASK_SET_SELECTION_OWNER = (1 << 0),
    XCB_XFIXES_SELECTION_EVENT_MASK_SELECTION_WINDOW_DESTROY = (1 << 1),
    XCB_XFIXES_SELECTION_EVENT_MASK_SELECTION_CLIENT_CLOSE = (1 << 2)
};

/** Opcode for xcb_xfixes_selection_notify. */
const uint XCB_XFIXES_SELECTION_NOTIFY = 0;

/**
 * @brief xcb_xfixes_selection_notify_event_t
 **/
struct xcb_xfixes_selection_notify_event_t {
    ubyte           response_type; /**<  */
    ubyte           subtype; /**<  */
    ushort          sequence; /**<  */
    xcb_window_t    window; /**<  */
    xcb_window_t    owner; /**<  */
    xcb_atom_t      selection; /**<  */
    xcb_timestamp_t timestamp; /**<  */
    xcb_timestamp_t selection_timestamp; /**<  */
    ubyte           pad0[8]; /**<  */
} ;

/** Opcode for xcb_xfixes_select_selection_input. */
const uint XCB_XFIXES_SELECT_SELECTION_INPUT = 2;

/**
 * @brief xcb_xfixes_select_selection_input_request_t
 **/
struct xcb_xfixes_select_selection_input_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        minor_opcode; /**<  */
    ushort       length; /**<  */
    xcb_window_t window; /**<  */
    xcb_atom_t   selection; /**<  */
    uint         event_mask; /**<  */
} ;

enum :int{
    XCB_XFIXES_CURSOR_NOTIFY_DISPLAY_CURSOR
};

enum :int{
    XCB_XFIXES_CURSOR_NOTIFY_MASK_DISPLAY_CURSOR = (1 << 0)
};

/** Opcode for xcb_xfixes_cursor_notify. */
const uint XCB_XFIXES_CURSOR_NOTIFY = 1;

/**
 * @brief xcb_xfixes_cursor_notify_event_t
 **/
struct xcb_xfixes_cursor_notify_event_t {
    ubyte           response_type; /**<  */
    ubyte           subtype; /**<  */
    ushort          sequence; /**<  */
    xcb_window_t    window; /**<  */
    uint            cursor_serial; /**<  */
    xcb_timestamp_t timestamp; /**<  */
    xcb_atom_t      name; /**<  */
    ubyte           pad0[12]; /**<  */
} ;

/** Opcode for xcb_xfixes_select_cursor_input. */
const uint XCB_XFIXES_SELECT_CURSOR_INPUT = 3;

/**
 * @brief xcb_xfixes_select_cursor_input_request_t
 **/
struct xcb_xfixes_select_cursor_input_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        minor_opcode; /**<  */
    ushort       length; /**<  */
    xcb_window_t window; /**<  */
    uint         event_mask; /**<  */
} ;

/**
 * @brief xcb_xfixes_get_cursor_image_cookie_t
 **/
struct xcb_xfixes_get_cursor_image_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_xfixes_get_cursor_image. */
const uint XCB_XFIXES_GET_CURSOR_IMAGE = 4;

/**
 * @brief xcb_xfixes_get_cursor_image_request_t
 **/
struct xcb_xfixes_get_cursor_image_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
} ;

/**
 * @brief xcb_xfixes_get_cursor_image_reply_t
 **/
struct xcb_xfixes_get_cursor_image_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    short  x; /**<  */
    short  y; /**<  */
    ushort width; /**<  */
    ushort height; /**<  */
    ushort xhot; /**<  */
    ushort yhot; /**<  */
    uint   cursor_serial; /**<  */
    ubyte  pad1[8]; /**<  */
} ;

alias uint xcb_xfixes_region_t;

/**
 * @brief xcb_xfixes_region_iterator_t
 **/
struct xcb_xfixes_region_iterator_t {
    xcb_xfixes_region_t *data; /**<  */
    int                  rem; /**<  */
    int                  index; /**<  */
} ;

/** Opcode for xcb_xfixes_bad_region. */
const uint XCB_XFIXES_BAD_REGION = 0;

/**
 * @brief xcb_xfixes_bad_region_error_t
 **/
struct xcb_xfixes_bad_region_error_t {
    ubyte  response_type; /**<  */
    ubyte  error_code; /**<  */
    ushort sequence; /**<  */
} ;

/** Opcode for xcb_xfixes_create_region. */
const uint XCB_XFIXES_CREATE_REGION = 5;

/**
 * @brief xcb_xfixes_create_region_request_t
 **/
struct xcb_xfixes_create_region_request_t {
    ubyte               major_opcode; /**<  */
    ubyte               minor_opcode; /**<  */
    ushort              length; /**<  */
    xcb_xfixes_region_t region; /**<  */
} ;

/** Opcode for xcb_xfixes_create_region_from_bitmap. */
const uint XCB_XFIXES_CREATE_REGION_FROM_BITMAP = 6;

/**
 * @brief xcb_xfixes_create_region_from_bitmap_request_t
 **/
struct xcb_xfixes_create_region_from_bitmap_request_t {
    ubyte               major_opcode; /**<  */
    ubyte               minor_opcode; /**<  */
    ushort              length; /**<  */
    xcb_xfixes_region_t region; /**<  */
    xcb_pixmap_t        bitmap; /**<  */
} ;

/** Opcode for xcb_xfixes_create_region_from_window. */
const uint XCB_XFIXES_CREATE_REGION_FROM_WINDOW = 7;

/**
 * @brief xcb_xfixes_create_region_from_window_request_t
 **/
struct xcb_xfixes_create_region_from_window_request_t {
    ubyte               major_opcode; /**<  */
    ubyte               minor_opcode; /**<  */
    ushort              length; /**<  */
    xcb_xfixes_region_t region; /**<  */
    xcb_window_t        window; /**<  */
    xcb_shape_kind_t    kind; /**<  */
    ubyte               pad0[3]; /**<  */
} ;

/** Opcode for xcb_xfixes_create_region_from_gc. */
const uint XCB_XFIXES_CREATE_REGION_FROM_GC = 8;

/**
 * @brief xcb_xfixes_create_region_from_gc_request_t
 **/
struct xcb_xfixes_create_region_from_gc_request_t {
    ubyte               major_opcode; /**<  */
    ubyte               minor_opcode; /**<  */
    ushort              length; /**<  */
    xcb_xfixes_region_t region; /**<  */
    xcb_gcontext_t      gc; /**<  */
} ;

/** Opcode for xcb_xfixes_create_region_from_picture. */
const uint XCB_XFIXES_CREATE_REGION_FROM_PICTURE = 9;

/**
 * @brief xcb_xfixes_create_region_from_picture_request_t
 **/
struct xcb_xfixes_create_region_from_picture_request_t {
    ubyte                major_opcode; /**<  */
    ubyte                minor_opcode; /**<  */
    ushort               length; /**<  */
    xcb_xfixes_region_t  region; /**<  */
    xcb_render_picture_t picture; /**<  */
} ;

/** Opcode for xcb_xfixes_destroy_region. */
const uint XCB_XFIXES_DESTROY_REGION = 10;

/**
 * @brief xcb_xfixes_destroy_region_request_t
 **/
struct xcb_xfixes_destroy_region_request_t {
    ubyte               major_opcode; /**<  */
    ubyte               minor_opcode; /**<  */
    ushort              length; /**<  */
    xcb_xfixes_region_t region; /**<  */
} ;

/** Opcode for xcb_xfixes_set_region. */
const uint XCB_XFIXES_SET_REGION = 11;

/**
 * @brief xcb_xfixes_set_region_request_t
 **/
struct xcb_xfixes_set_region_request_t {
    ubyte               major_opcode; /**<  */
    ubyte               minor_opcode; /**<  */
    ushort              length; /**<  */
    xcb_xfixes_region_t region; /**<  */
} ;

/** Opcode for xcb_xfixes_copy_region. */
const uint XCB_XFIXES_COPY_REGION = 12;

/**
 * @brief xcb_xfixes_copy_region_request_t
 **/
struct xcb_xfixes_copy_region_request_t {
    ubyte               major_opcode; /**<  */
    ubyte               minor_opcode; /**<  */
    ushort              length; /**<  */
    xcb_xfixes_region_t source; /**<  */
    xcb_xfixes_region_t destination; /**<  */
} ;

/** Opcode for xcb_xfixes_union_region. */
const uint XCB_XFIXES_UNION_REGION = 13;

/**
 * @brief xcb_xfixes_union_region_request_t
 **/
struct xcb_xfixes_union_region_request_t {
    ubyte               major_opcode; /**<  */
    ubyte               minor_opcode; /**<  */
    ushort              length; /**<  */
    xcb_xfixes_region_t source1; /**<  */
    xcb_xfixes_region_t source2; /**<  */
    xcb_xfixes_region_t destination; /**<  */
} ;

/** Opcode for xcb_xfixes_intersect_region. */
const uint XCB_XFIXES_INTERSECT_REGION = 14;

/**
 * @brief xcb_xfixes_intersect_region_request_t
 **/
struct xcb_xfixes_intersect_region_request_t {
    ubyte               major_opcode; /**<  */
    ubyte               minor_opcode; /**<  */
    ushort              length; /**<  */
    xcb_xfixes_region_t source1; /**<  */
    xcb_xfixes_region_t source2; /**<  */
    xcb_xfixes_region_t destination; /**<  */
} ;

/** Opcode for xcb_xfixes_subtract_region. */
const uint XCB_XFIXES_SUBTRACT_REGION = 15;

/**
 * @brief xcb_xfixes_subtract_region_request_t
 **/
struct xcb_xfixes_subtract_region_request_t {
    ubyte               major_opcode; /**<  */
    ubyte               minor_opcode; /**<  */
    ushort              length; /**<  */
    xcb_xfixes_region_t source1; /**<  */
    xcb_xfixes_region_t source2; /**<  */
    xcb_xfixes_region_t destination; /**<  */
} ;

/** Opcode for xcb_xfixes_invert_region. */
const uint XCB_XFIXES_INVERT_REGION = 16;

/**
 * @brief xcb_xfixes_invert_region_request_t
 **/
struct xcb_xfixes_invert_region_request_t {
    ubyte               major_opcode; /**<  */
    ubyte               minor_opcode; /**<  */
    ushort              length; /**<  */
    xcb_xfixes_region_t source; /**<  */
    xcb_rectangle_t     bounds; /**<  */
    xcb_xfixes_region_t destination; /**<  */
} ;

/** Opcode for xcb_xfixes_translate_region. */
const uint XCB_XFIXES_TRANSLATE_REGION = 17;

/**
 * @brief xcb_xfixes_translate_region_request_t
 **/
struct xcb_xfixes_translate_region_request_t {
    ubyte               major_opcode; /**<  */
    ubyte               minor_opcode; /**<  */
    ushort              length; /**<  */
    xcb_xfixes_region_t region; /**<  */
    short               dx; /**<  */
    short               dy; /**<  */
} ;

/** Opcode for xcb_xfixes_region_extents. */
const uint XCB_XFIXES_REGION_EXTENTS = 18;

/**
 * @brief xcb_xfixes_region_extents_request_t
 **/
struct xcb_xfixes_region_extents_request_t {
    ubyte               major_opcode; /**<  */
    ubyte               minor_opcode; /**<  */
    ushort              length; /**<  */
    xcb_xfixes_region_t source; /**<  */
    xcb_xfixes_region_t destination; /**<  */
} ;

/**
 * @brief xcb_xfixes_fetch_region_cookie_t
 **/
struct xcb_xfixes_fetch_region_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_xfixes_fetch_region. */
const uint XCB_XFIXES_FETCH_REGION = 19;

/**
 * @brief xcb_xfixes_fetch_region_request_t
 **/
struct xcb_xfixes_fetch_region_request_t {
    ubyte               major_opcode; /**<  */
    ubyte               minor_opcode; /**<  */
    ushort              length; /**<  */
    xcb_xfixes_region_t region; /**<  */
} ;

/**
 * @brief xcb_xfixes_fetch_region_reply_t
 **/
struct xcb_xfixes_fetch_region_reply_t {
    ubyte           response_type; /**<  */
    ubyte           pad0; /**<  */
    ushort          sequence; /**<  */
    uint            length; /**<  */
    xcb_rectangle_t extents; /**<  */
    ubyte           pad1[16]; /**<  */
} ;

/** Opcode for xcb_xfixes_set_gc_clip_region. */
const uint XCB_XFIXES_SET_GC_CLIP_REGION = 20;

/**
 * @brief xcb_xfixes_set_gc_clip_region_request_t
 **/
struct xcb_xfixes_set_gc_clip_region_request_t {
    ubyte               major_opcode; /**<  */
    ubyte               minor_opcode; /**<  */
    ushort              length; /**<  */
    xcb_gcontext_t      gc; /**<  */
    xcb_xfixes_region_t region; /**<  */
    short               x_origin; /**<  */
    short               y_origin; /**<  */
} ;

/** Opcode for xcb_xfixes_set_window_shape_region. */
const uint XCB_XFIXES_SET_WINDOW_SHAPE_REGION = 21;

/**
 * @brief xcb_xfixes_set_window_shape_region_request_t
 **/
struct xcb_xfixes_set_window_shape_region_request_t {
    ubyte               major_opcode; /**<  */
    ubyte               minor_opcode; /**<  */
    ushort              length; /**<  */
    xcb_window_t        dest; /**<  */
    xcb_shape_kind_t    dest_kind; /**<  */
    ubyte               pad0[3]; /**<  */
    short               x_offset; /**<  */
    short               y_offset; /**<  */
    xcb_xfixes_region_t region; /**<  */
} ;

/** Opcode for xcb_xfixes_set_picture_clip_region. */
const uint XCB_XFIXES_SET_PICTURE_CLIP_REGION = 22;

/**
 * @brief xcb_xfixes_set_picture_clip_region_request_t
 **/
struct xcb_xfixes_set_picture_clip_region_request_t {
    ubyte                major_opcode; /**<  */
    ubyte                minor_opcode; /**<  */
    ushort               length; /**<  */
    xcb_render_picture_t picture; /**<  */
    xcb_xfixes_region_t  region; /**<  */
    short                x_origin; /**<  */
    short                y_origin; /**<  */
} ;

/** Opcode for xcb_xfixes_set_cursor_name. */
const uint XCB_XFIXES_SET_CURSOR_NAME = 23;

/**
 * @brief xcb_xfixes_set_cursor_name_request_t
 **/
struct xcb_xfixes_set_cursor_name_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        minor_opcode; /**<  */
    ushort       length; /**<  */
    xcb_cursor_t cursor; /**<  */
    ushort       nbytes; /**<  */
    ubyte        pad0[2]; /**<  */
} ;

/**
 * @brief xcb_xfixes_get_cursor_name_cookie_t
 **/
struct xcb_xfixes_get_cursor_name_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_xfixes_get_cursor_name. */
const uint XCB_XFIXES_GET_CURSOR_NAME = 24;

/**
 * @brief xcb_xfixes_get_cursor_name_request_t
 **/
struct xcb_xfixes_get_cursor_name_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        minor_opcode; /**<  */
    ushort       length; /**<  */
    xcb_cursor_t cursor; /**<  */
} ;

/**
 * @brief xcb_xfixes_get_cursor_name_reply_t
 **/
struct xcb_xfixes_get_cursor_name_reply_t {
    ubyte      response_type; /**<  */
    ubyte      pad0; /**<  */
    ushort     sequence; /**<  */
    uint       length; /**<  */
    xcb_atom_t atom; /**<  */
    ushort     nbytes; /**<  */
    ubyte      pad1[18]; /**<  */
} ;

/**
 * @brief xcb_xfixes_get_cursor_image_and_name_cookie_t
 **/
struct xcb_xfixes_get_cursor_image_and_name_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_xfixes_get_cursor_image_and_name. */
const uint XCB_XFIXES_GET_CURSOR_IMAGE_AND_NAME = 25;

/**
 * @brief xcb_xfixes_get_cursor_image_and_name_request_t
 **/
struct xcb_xfixes_get_cursor_image_and_name_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
} ;

/**
 * @brief xcb_xfixes_get_cursor_image_and_name_reply_t
 **/
struct xcb_xfixes_get_cursor_image_and_name_reply_t {
    ubyte      response_type; /**<  */
    ubyte      pad0; /**<  */
    ushort     sequence; /**<  */
    uint       length; /**<  */
    short      x; /**<  */
    short      y; /**<  */
    ushort     width; /**<  */
    ushort     height; /**<  */
    ushort     xhot; /**<  */
    ushort     yhot; /**<  */
    uint       cursor_serial; /**<  */
    xcb_atom_t cursor_atom; /**<  */
    ushort     nbytes; /**<  */
    ubyte      pad1[2]; /**<  */
} ;

/** Opcode for xcb_xfixes_change_cursor. */
const uint XCB_XFIXES_CHANGE_CURSOR = 26;

/**
 * @brief xcb_xfixes_change_cursor_request_t
 **/
struct xcb_xfixes_change_cursor_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        minor_opcode; /**<  */
    ushort       length; /**<  */
    xcb_cursor_t source; /**<  */
    xcb_cursor_t destination; /**<  */
} ;

/** Opcode for xcb_xfixes_change_cursor_by_name. */
const uint XCB_XFIXES_CHANGE_CURSOR_BY_NAME = 27;

/**
 * @brief xcb_xfixes_change_cursor_by_name_request_t
 **/
struct xcb_xfixes_change_cursor_by_name_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        minor_opcode; /**<  */
    ushort       length; /**<  */
    xcb_cursor_t src; /**<  */
    ushort       nbytes; /**<  */
    ubyte        pad0[2]; /**<  */
} ;

/** Opcode for xcb_xfixes_expand_region. */
const uint XCB_XFIXES_EXPAND_REGION = 28;

/**
 * @brief xcb_xfixes_expand_region_request_t
 **/
struct xcb_xfixes_expand_region_request_t {
    ubyte               major_opcode; /**<  */
    ubyte               minor_opcode; /**<  */
    ushort              length; /**<  */
    xcb_xfixes_region_t source; /**<  */
    xcb_xfixes_region_t destination; /**<  */
    ushort              left; /**<  */
    ushort              right; /**<  */
    ushort              top; /**<  */
    ushort              bottom; /**<  */
} ;

/** Opcode for xcb_xfixes_hide_cursor. */
const uint XCB_XFIXES_HIDE_CURSOR = 29;

/**
 * @brief xcb_xfixes_hide_cursor_request_t
 **/
struct xcb_xfixes_hide_cursor_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        minor_opcode; /**<  */
    ushort       length; /**<  */
    xcb_window_t window; /**<  */
} ;

/** Opcode for xcb_xfixes_show_cursor. */
const uint XCB_XFIXES_SHOW_CURSOR = 30;

/**
 * @brief xcb_xfixes_show_cursor_request_t
 **/
struct xcb_xfixes_show_cursor_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        minor_opcode; /**<  */
    ushort       length; /**<  */
    xcb_window_t window; /**<  */
} ;


/*****************************************************************************
 **
 ** xcb_xfixes_query_version_cookie_t xcb_xfixes_query_version
 **
 ** @param xcb_connection_t *c
 ** @param uint              client_major_version
 ** @param uint              client_minor_version
 ** @returns xcb_xfixes_query_version_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_xfixes_query_version_cookie_t
xcb_xfixes_query_version (xcb_connection_t *c  /**< */,
                          uint              client_major_version  /**< */,
                          uint              client_minor_version  /**< */);


/*****************************************************************************
 **
 ** xcb_xfixes_query_version_cookie_t xcb_xfixes_query_version_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param uint              client_major_version
 ** @param uint              client_minor_version
 ** @returns xcb_xfixes_query_version_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_xfixes_query_version_cookie_t
xcb_xfixes_query_version_unchecked (xcb_connection_t *c  /**< */,
                                    uint              client_major_version  /**< */,
                                    uint              client_minor_version  /**< */);


/*****************************************************************************
 **
 ** xcb_xfixes_query_version_reply_t * xcb_xfixes_query_version_reply
 **
 ** @param xcb_connection_t                   *c
 ** @param xcb_xfixes_query_version_cookie_t   cookie
 ** @param xcb_generic_error_t               **e
 ** @returns xcb_xfixes_query_version_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_xfixes_query_version_reply_t *
xcb_xfixes_query_version_reply (xcb_connection_t                   *c  /**< */,
                                xcb_xfixes_query_version_cookie_t   cookie  /**< */,
                                xcb_generic_error_t               **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_change_save_set_checked
 **
 ** @param xcb_connection_t *c
 ** @param ubyte             mode
 ** @param ubyte             target
 ** @param ubyte             map
 ** @param xcb_window_t      window
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_change_save_set_checked (xcb_connection_t *c  /**< */,
                                    ubyte             mode  /**< */,
                                    ubyte             target  /**< */,
                                    ubyte             map  /**< */,
                                    xcb_window_t      window  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_change_save_set
 **
 ** @param xcb_connection_t *c
 ** @param ubyte             mode
 ** @param ubyte             target
 ** @param ubyte             map
 ** @param xcb_window_t      window
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_change_save_set (xcb_connection_t *c  /**< */,
                            ubyte             mode  /**< */,
                            ubyte             target  /**< */,
                            ubyte             map  /**< */,
                            xcb_window_t      window  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_select_selection_input_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @param xcb_atom_t        selection
 ** @param uint              event_mask
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_select_selection_input_checked (xcb_connection_t *c  /**< */,
                                           xcb_window_t      window  /**< */,
                                           xcb_atom_t        selection  /**< */,
                                           uint              event_mask  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_select_selection_input
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @param xcb_atom_t        selection
 ** @param uint              event_mask
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_select_selection_input (xcb_connection_t *c  /**< */,
                                   xcb_window_t      window  /**< */,
                                   xcb_atom_t        selection  /**< */,
                                   uint              event_mask  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_select_cursor_input_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @param uint              event_mask
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_select_cursor_input_checked (xcb_connection_t *c  /**< */,
                                        xcb_window_t      window  /**< */,
                                        uint              event_mask  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_select_cursor_input
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @param uint              event_mask
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_select_cursor_input (xcb_connection_t *c  /**< */,
                                xcb_window_t      window  /**< */,
                                uint              event_mask  /**< */);


/*****************************************************************************
 **
 ** xcb_xfixes_get_cursor_image_cookie_t xcb_xfixes_get_cursor_image
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_xfixes_get_cursor_image_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_xfixes_get_cursor_image_cookie_t
xcb_xfixes_get_cursor_image (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_xfixes_get_cursor_image_cookie_t xcb_xfixes_get_cursor_image_unchecked
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_xfixes_get_cursor_image_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_xfixes_get_cursor_image_cookie_t
xcb_xfixes_get_cursor_image_unchecked (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** uint * xcb_xfixes_get_cursor_image_cursor_image
 **
 ** @param /+const+/ xcb_xfixes_get_cursor_image_reply_t *R
 ** @returns uint *
 **
 *****************************************************************************/

extern(C) uint *
xcb_xfixes_get_cursor_image_cursor_image (/+const+/ xcb_xfixes_get_cursor_image_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_xfixes_get_cursor_image_cursor_image_length
 **
 ** @param /+const+/ xcb_xfixes_get_cursor_image_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_xfixes_get_cursor_image_cursor_image_length (/+const+/ xcb_xfixes_get_cursor_image_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_xfixes_get_cursor_image_cursor_image_end
 **
 ** @param /+const+/ xcb_xfixes_get_cursor_image_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_xfixes_get_cursor_image_cursor_image_end (/+const+/ xcb_xfixes_get_cursor_image_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_xfixes_get_cursor_image_reply_t * xcb_xfixes_get_cursor_image_reply
 **
 ** @param xcb_connection_t                      *c
 ** @param xcb_xfixes_get_cursor_image_cookie_t   cookie
 ** @param xcb_generic_error_t                  **e
 ** @returns xcb_xfixes_get_cursor_image_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_xfixes_get_cursor_image_reply_t *
xcb_xfixes_get_cursor_image_reply (xcb_connection_t                      *c  /**< */,
                                   xcb_xfixes_get_cursor_image_cookie_t   cookie  /**< */,
                                   xcb_generic_error_t                  **e  /**< */);


/*****************************************************************************
 **
 ** void xcb_xfixes_region_next
 **
 ** @param xcb_xfixes_region_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_xfixes_region_next (xcb_xfixes_region_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_xfixes_region_end
 **
 ** @param xcb_xfixes_region_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_xfixes_region_end (xcb_xfixes_region_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_create_region_checked
 **
 ** @param xcb_connection_t          *c
 ** @param xcb_xfixes_region_t        region
 ** @param uint                       rectangles_len
 ** @param /+const+/ xcb_rectangle_t *rectangles
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_create_region_checked (xcb_connection_t          *c  /**< */,
                                  xcb_xfixes_region_t        region  /**< */,
                                  uint                       rectangles_len  /**< */,
                                  /+const+/ xcb_rectangle_t *rectangles  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_create_region
 **
 ** @param xcb_connection_t          *c
 ** @param xcb_xfixes_region_t        region
 ** @param uint                       rectangles_len
 ** @param /+const+/ xcb_rectangle_t *rectangles
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_create_region (xcb_connection_t          *c  /**< */,
                          xcb_xfixes_region_t        region  /**< */,
                          uint                       rectangles_len  /**< */,
                          /+const+/ xcb_rectangle_t *rectangles  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_create_region_from_bitmap_checked
 **
 ** @param xcb_connection_t    *c
 ** @param xcb_xfixes_region_t  region
 ** @param xcb_pixmap_t         bitmap
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_create_region_from_bitmap_checked (xcb_connection_t    *c  /**< */,
                                              xcb_xfixes_region_t  region  /**< */,
                                              xcb_pixmap_t         bitmap  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_create_region_from_bitmap
 **
 ** @param xcb_connection_t    *c
 ** @param xcb_xfixes_region_t  region
 ** @param xcb_pixmap_t         bitmap
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_create_region_from_bitmap (xcb_connection_t    *c  /**< */,
                                      xcb_xfixes_region_t  region  /**< */,
                                      xcb_pixmap_t         bitmap  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_create_region_from_window_checked
 **
 ** @param xcb_connection_t    *c
 ** @param xcb_xfixes_region_t  region
 ** @param xcb_window_t         window
 ** @param xcb_shape_kind_t     kind
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_create_region_from_window_checked (xcb_connection_t    *c  /**< */,
                                              xcb_xfixes_region_t  region  /**< */,
                                              xcb_window_t         window  /**< */,
                                              xcb_shape_kind_t     kind  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_create_region_from_window
 **
 ** @param xcb_connection_t    *c
 ** @param xcb_xfixes_region_t  region
 ** @param xcb_window_t         window
 ** @param xcb_shape_kind_t     kind
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_create_region_from_window (xcb_connection_t    *c  /**< */,
                                      xcb_xfixes_region_t  region  /**< */,
                                      xcb_window_t         window  /**< */,
                                      xcb_shape_kind_t     kind  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_create_region_from_gc_checked
 **
 ** @param xcb_connection_t    *c
 ** @param xcb_xfixes_region_t  region
 ** @param xcb_gcontext_t       gc
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_create_region_from_gc_checked (xcb_connection_t    *c  /**< */,
                                          xcb_xfixes_region_t  region  /**< */,
                                          xcb_gcontext_t       gc  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_create_region_from_gc
 **
 ** @param xcb_connection_t    *c
 ** @param xcb_xfixes_region_t  region
 ** @param xcb_gcontext_t       gc
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_create_region_from_gc (xcb_connection_t    *c  /**< */,
                                  xcb_xfixes_region_t  region  /**< */,
                                  xcb_gcontext_t       gc  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_create_region_from_picture_checked
 **
 ** @param xcb_connection_t     *c
 ** @param xcb_xfixes_region_t   region
 ** @param xcb_render_picture_t  picture
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_create_region_from_picture_checked (xcb_connection_t     *c  /**< */,
                                               xcb_xfixes_region_t   region  /**< */,
                                               xcb_render_picture_t  picture  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_create_region_from_picture
 **
 ** @param xcb_connection_t     *c
 ** @param xcb_xfixes_region_t   region
 ** @param xcb_render_picture_t  picture
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_create_region_from_picture (xcb_connection_t     *c  /**< */,
                                       xcb_xfixes_region_t   region  /**< */,
                                       xcb_render_picture_t  picture  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_destroy_region_checked
 **
 ** @param xcb_connection_t    *c
 ** @param xcb_xfixes_region_t  region
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_destroy_region_checked (xcb_connection_t    *c  /**< */,
                                   xcb_xfixes_region_t  region  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_destroy_region
 **
 ** @param xcb_connection_t    *c
 ** @param xcb_xfixes_region_t  region
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_destroy_region (xcb_connection_t    *c  /**< */,
                           xcb_xfixes_region_t  region  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_set_region_checked
 **
 ** @param xcb_connection_t          *c
 ** @param xcb_xfixes_region_t        region
 ** @param uint                       rectangles_len
 ** @param /+const+/ xcb_rectangle_t *rectangles
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_set_region_checked (xcb_connection_t          *c  /**< */,
                               xcb_xfixes_region_t        region  /**< */,
                               uint                       rectangles_len  /**< */,
                               /+const+/ xcb_rectangle_t *rectangles  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_set_region
 **
 ** @param xcb_connection_t          *c
 ** @param xcb_xfixes_region_t        region
 ** @param uint                       rectangles_len
 ** @param /+const+/ xcb_rectangle_t *rectangles
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_set_region (xcb_connection_t          *c  /**< */,
                       xcb_xfixes_region_t        region  /**< */,
                       uint                       rectangles_len  /**< */,
                       /+const+/ xcb_rectangle_t *rectangles  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_copy_region_checked
 **
 ** @param xcb_connection_t    *c
 ** @param xcb_xfixes_region_t  source
 ** @param xcb_xfixes_region_t  destination
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_copy_region_checked (xcb_connection_t    *c  /**< */,
                                xcb_xfixes_region_t  source  /**< */,
                                xcb_xfixes_region_t  destination  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_copy_region
 **
 ** @param xcb_connection_t    *c
 ** @param xcb_xfixes_region_t  source
 ** @param xcb_xfixes_region_t  destination
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_copy_region (xcb_connection_t    *c  /**< */,
                        xcb_xfixes_region_t  source  /**< */,
                        xcb_xfixes_region_t  destination  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_union_region_checked
 **
 ** @param xcb_connection_t    *c
 ** @param xcb_xfixes_region_t  source1
 ** @param xcb_xfixes_region_t  source2
 ** @param xcb_xfixes_region_t  destination
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_union_region_checked (xcb_connection_t    *c  /**< */,
                                 xcb_xfixes_region_t  source1  /**< */,
                                 xcb_xfixes_region_t  source2  /**< */,
                                 xcb_xfixes_region_t  destination  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_union_region
 **
 ** @param xcb_connection_t    *c
 ** @param xcb_xfixes_region_t  source1
 ** @param xcb_xfixes_region_t  source2
 ** @param xcb_xfixes_region_t  destination
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_union_region (xcb_connection_t    *c  /**< */,
                         xcb_xfixes_region_t  source1  /**< */,
                         xcb_xfixes_region_t  source2  /**< */,
                         xcb_xfixes_region_t  destination  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_intersect_region_checked
 **
 ** @param xcb_connection_t    *c
 ** @param xcb_xfixes_region_t  source1
 ** @param xcb_xfixes_region_t  source2
 ** @param xcb_xfixes_region_t  destination
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_intersect_region_checked (xcb_connection_t    *c  /**< */,
                                     xcb_xfixes_region_t  source1  /**< */,
                                     xcb_xfixes_region_t  source2  /**< */,
                                     xcb_xfixes_region_t  destination  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_intersect_region
 **
 ** @param xcb_connection_t    *c
 ** @param xcb_xfixes_region_t  source1
 ** @param xcb_xfixes_region_t  source2
 ** @param xcb_xfixes_region_t  destination
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_intersect_region (xcb_connection_t    *c  /**< */,
                             xcb_xfixes_region_t  source1  /**< */,
                             xcb_xfixes_region_t  source2  /**< */,
                             xcb_xfixes_region_t  destination  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_subtract_region_checked
 **
 ** @param xcb_connection_t    *c
 ** @param xcb_xfixes_region_t  source1
 ** @param xcb_xfixes_region_t  source2
 ** @param xcb_xfixes_region_t  destination
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_subtract_region_checked (xcb_connection_t    *c  /**< */,
                                    xcb_xfixes_region_t  source1  /**< */,
                                    xcb_xfixes_region_t  source2  /**< */,
                                    xcb_xfixes_region_t  destination  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_subtract_region
 **
 ** @param xcb_connection_t    *c
 ** @param xcb_xfixes_region_t  source1
 ** @param xcb_xfixes_region_t  source2
 ** @param xcb_xfixes_region_t  destination
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_subtract_region (xcb_connection_t    *c  /**< */,
                            xcb_xfixes_region_t  source1  /**< */,
                            xcb_xfixes_region_t  source2  /**< */,
                            xcb_xfixes_region_t  destination  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_invert_region_checked
 **
 ** @param xcb_connection_t    *c
 ** @param xcb_xfixes_region_t  source
 ** @param xcb_rectangle_t      bounds
 ** @param xcb_xfixes_region_t  destination
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_invert_region_checked (xcb_connection_t    *c  /**< */,
                                  xcb_xfixes_region_t  source  /**< */,
                                  xcb_rectangle_t      bounds  /**< */,
                                  xcb_xfixes_region_t  destination  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_invert_region
 **
 ** @param xcb_connection_t    *c
 ** @param xcb_xfixes_region_t  source
 ** @param xcb_rectangle_t      bounds
 ** @param xcb_xfixes_region_t  destination
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_invert_region (xcb_connection_t    *c  /**< */,
                          xcb_xfixes_region_t  source  /**< */,
                          xcb_rectangle_t      bounds  /**< */,
                          xcb_xfixes_region_t  destination  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_translate_region_checked
 **
 ** @param xcb_connection_t    *c
 ** @param xcb_xfixes_region_t  region
 ** @param short                dx
 ** @param short                dy
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_translate_region_checked (xcb_connection_t    *c  /**< */,
                                     xcb_xfixes_region_t  region  /**< */,
                                     short                dx  /**< */,
                                     short                dy  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_translate_region
 **
 ** @param xcb_connection_t    *c
 ** @param xcb_xfixes_region_t  region
 ** @param short                dx
 ** @param short                dy
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_translate_region (xcb_connection_t    *c  /**< */,
                             xcb_xfixes_region_t  region  /**< */,
                             short                dx  /**< */,
                             short                dy  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_region_extents_checked
 **
 ** @param xcb_connection_t    *c
 ** @param xcb_xfixes_region_t  source
 ** @param xcb_xfixes_region_t  destination
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_region_extents_checked (xcb_connection_t    *c  /**< */,
                                   xcb_xfixes_region_t  source  /**< */,
                                   xcb_xfixes_region_t  destination  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_region_extents
 **
 ** @param xcb_connection_t    *c
 ** @param xcb_xfixes_region_t  source
 ** @param xcb_xfixes_region_t  destination
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_region_extents (xcb_connection_t    *c  /**< */,
                           xcb_xfixes_region_t  source  /**< */,
                           xcb_xfixes_region_t  destination  /**< */);


/*****************************************************************************
 **
 ** xcb_xfixes_fetch_region_cookie_t xcb_xfixes_fetch_region
 **
 ** @param xcb_connection_t    *c
 ** @param xcb_xfixes_region_t  region
 ** @returns xcb_xfixes_fetch_region_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_xfixes_fetch_region_cookie_t
xcb_xfixes_fetch_region (xcb_connection_t    *c  /**< */,
                         xcb_xfixes_region_t  region  /**< */);


/*****************************************************************************
 **
 ** xcb_xfixes_fetch_region_cookie_t xcb_xfixes_fetch_region_unchecked
 **
 ** @param xcb_connection_t    *c
 ** @param xcb_xfixes_region_t  region
 ** @returns xcb_xfixes_fetch_region_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_xfixes_fetch_region_cookie_t
xcb_xfixes_fetch_region_unchecked (xcb_connection_t    *c  /**< */,
                                   xcb_xfixes_region_t  region  /**< */);


/*****************************************************************************
 **
 ** xcb_rectangle_t * xcb_xfixes_fetch_region_rectangles
 **
 ** @param /+const+/ xcb_xfixes_fetch_region_reply_t *R
 ** @returns xcb_rectangle_t *
 **
 *****************************************************************************/

extern(C) xcb_rectangle_t *
xcb_xfixes_fetch_region_rectangles (/+const+/ xcb_xfixes_fetch_region_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_xfixes_fetch_region_rectangles_length
 **
 ** @param /+const+/ xcb_xfixes_fetch_region_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_xfixes_fetch_region_rectangles_length (/+const+/ xcb_xfixes_fetch_region_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_rectangle_iterator_t xcb_xfixes_fetch_region_rectangles_iterator
 **
 ** @param /+const+/ xcb_xfixes_fetch_region_reply_t *R
 ** @returns xcb_rectangle_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_rectangle_iterator_t
xcb_xfixes_fetch_region_rectangles_iterator (/+const+/ xcb_xfixes_fetch_region_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_xfixes_fetch_region_reply_t * xcb_xfixes_fetch_region_reply
 **
 ** @param xcb_connection_t                  *c
 ** @param xcb_xfixes_fetch_region_cookie_t   cookie
 ** @param xcb_generic_error_t              **e
 ** @returns xcb_xfixes_fetch_region_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_xfixes_fetch_region_reply_t *
xcb_xfixes_fetch_region_reply (xcb_connection_t                  *c  /**< */,
                               xcb_xfixes_fetch_region_cookie_t   cookie  /**< */,
                               xcb_generic_error_t              **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_set_gc_clip_region_checked
 **
 ** @param xcb_connection_t    *c
 ** @param xcb_gcontext_t       gc
 ** @param xcb_xfixes_region_t  region
 ** @param short                x_origin
 ** @param short                y_origin
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_set_gc_clip_region_checked (xcb_connection_t    *c  /**< */,
                                       xcb_gcontext_t       gc  /**< */,
                                       xcb_xfixes_region_t  region  /**< */,
                                       short                x_origin  /**< */,
                                       short                y_origin  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_set_gc_clip_region
 **
 ** @param xcb_connection_t    *c
 ** @param xcb_gcontext_t       gc
 ** @param xcb_xfixes_region_t  region
 ** @param short                x_origin
 ** @param short                y_origin
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_set_gc_clip_region (xcb_connection_t    *c  /**< */,
                               xcb_gcontext_t       gc  /**< */,
                               xcb_xfixes_region_t  region  /**< */,
                               short                x_origin  /**< */,
                               short                y_origin  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_set_window_shape_region_checked
 **
 ** @param xcb_connection_t    *c
 ** @param xcb_window_t         dest
 ** @param xcb_shape_kind_t     dest_kind
 ** @param short                x_offset
 ** @param short                y_offset
 ** @param xcb_xfixes_region_t  region
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_set_window_shape_region_checked (xcb_connection_t    *c  /**< */,
                                            xcb_window_t         dest  /**< */,
                                            xcb_shape_kind_t     dest_kind  /**< */,
                                            short                x_offset  /**< */,
                                            short                y_offset  /**< */,
                                            xcb_xfixes_region_t  region  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_set_window_shape_region
 **
 ** @param xcb_connection_t    *c
 ** @param xcb_window_t         dest
 ** @param xcb_shape_kind_t     dest_kind
 ** @param short                x_offset
 ** @param short                y_offset
 ** @param xcb_xfixes_region_t  region
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_set_window_shape_region (xcb_connection_t    *c  /**< */,
                                    xcb_window_t         dest  /**< */,
                                    xcb_shape_kind_t     dest_kind  /**< */,
                                    short                x_offset  /**< */,
                                    short                y_offset  /**< */,
                                    xcb_xfixes_region_t  region  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_set_picture_clip_region_checked
 **
 ** @param xcb_connection_t     *c
 ** @param xcb_render_picture_t  picture
 ** @param xcb_xfixes_region_t   region
 ** @param short                 x_origin
 ** @param short                 y_origin
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_set_picture_clip_region_checked (xcb_connection_t     *c  /**< */,
                                            xcb_render_picture_t  picture  /**< */,
                                            xcb_xfixes_region_t   region  /**< */,
                                            short                 x_origin  /**< */,
                                            short                 y_origin  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_set_picture_clip_region
 **
 ** @param xcb_connection_t     *c
 ** @param xcb_render_picture_t  picture
 ** @param xcb_xfixes_region_t   region
 ** @param short                 x_origin
 ** @param short                 y_origin
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_set_picture_clip_region (xcb_connection_t     *c  /**< */,
                                    xcb_render_picture_t  picture  /**< */,
                                    xcb_xfixes_region_t   region  /**< */,
                                    short                 x_origin  /**< */,
                                    short                 y_origin  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_set_cursor_name_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_cursor_t      cursor
 ** @param ushort            nbytes
 ** @param /+const+/ ubyte  *name
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_set_cursor_name_checked (xcb_connection_t *c  /**< */,
                                    xcb_cursor_t      cursor  /**< */,
                                    ushort            nbytes  /**< */,
                                    /+const+/ ubyte  *name  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_set_cursor_name
 **
 ** @param xcb_connection_t *c
 ** @param xcb_cursor_t      cursor
 ** @param ushort            nbytes
 ** @param /+const+/ ubyte  *name
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_set_cursor_name (xcb_connection_t *c  /**< */,
                            xcb_cursor_t      cursor  /**< */,
                            ushort            nbytes  /**< */,
                            /+const+/ ubyte  *name  /**< */);


/*****************************************************************************
 **
 ** xcb_xfixes_get_cursor_name_cookie_t xcb_xfixes_get_cursor_name
 **
 ** @param xcb_connection_t *c
 ** @param xcb_cursor_t      cursor
 ** @returns xcb_xfixes_get_cursor_name_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_xfixes_get_cursor_name_cookie_t
xcb_xfixes_get_cursor_name (xcb_connection_t *c  /**< */,
                            xcb_cursor_t      cursor  /**< */);


/*****************************************************************************
 **
 ** xcb_xfixes_get_cursor_name_cookie_t xcb_xfixes_get_cursor_name_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_cursor_t      cursor
 ** @returns xcb_xfixes_get_cursor_name_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_xfixes_get_cursor_name_cookie_t
xcb_xfixes_get_cursor_name_unchecked (xcb_connection_t *c  /**< */,
                                      xcb_cursor_t      cursor  /**< */);


/*****************************************************************************
 **
 ** ubyte * xcb_xfixes_get_cursor_name_name
 **
 ** @param /+const+/ xcb_xfixes_get_cursor_name_reply_t *R
 ** @returns ubyte *
 **
 *****************************************************************************/

extern(C) ubyte *
xcb_xfixes_get_cursor_name_name (/+const+/ xcb_xfixes_get_cursor_name_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_xfixes_get_cursor_name_name_length
 **
 ** @param /+const+/ xcb_xfixes_get_cursor_name_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_xfixes_get_cursor_name_name_length (/+const+/ xcb_xfixes_get_cursor_name_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_xfixes_get_cursor_name_name_end
 **
 ** @param /+const+/ xcb_xfixes_get_cursor_name_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_xfixes_get_cursor_name_name_end (/+const+/ xcb_xfixes_get_cursor_name_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_xfixes_get_cursor_name_reply_t * xcb_xfixes_get_cursor_name_reply
 **
 ** @param xcb_connection_t                     *c
 ** @param xcb_xfixes_get_cursor_name_cookie_t   cookie
 ** @param xcb_generic_error_t                 **e
 ** @returns xcb_xfixes_get_cursor_name_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_xfixes_get_cursor_name_reply_t *
xcb_xfixes_get_cursor_name_reply (xcb_connection_t                     *c  /**< */,
                                  xcb_xfixes_get_cursor_name_cookie_t   cookie  /**< */,
                                  xcb_generic_error_t                 **e  /**< */);


/*****************************************************************************
 **
 ** xcb_xfixes_get_cursor_image_and_name_cookie_t xcb_xfixes_get_cursor_image_and_name
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_xfixes_get_cursor_image_and_name_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_xfixes_get_cursor_image_and_name_cookie_t
xcb_xfixes_get_cursor_image_and_name (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_xfixes_get_cursor_image_and_name_cookie_t xcb_xfixes_get_cursor_image_and_name_unchecked
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_xfixes_get_cursor_image_and_name_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_xfixes_get_cursor_image_and_name_cookie_t
xcb_xfixes_get_cursor_image_and_name_unchecked (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** ubyte * xcb_xfixes_get_cursor_image_and_name_name
 **
 ** @param /+const+/ xcb_xfixes_get_cursor_image_and_name_reply_t *R
 ** @returns ubyte *
 **
 *****************************************************************************/

extern(C) ubyte *
xcb_xfixes_get_cursor_image_and_name_name (/+const+/ xcb_xfixes_get_cursor_image_and_name_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_xfixes_get_cursor_image_and_name_name_length
 **
 ** @param /+const+/ xcb_xfixes_get_cursor_image_and_name_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_xfixes_get_cursor_image_and_name_name_length (/+const+/ xcb_xfixes_get_cursor_image_and_name_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_xfixes_get_cursor_image_and_name_name_end
 **
 ** @param /+const+/ xcb_xfixes_get_cursor_image_and_name_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_xfixes_get_cursor_image_and_name_name_end (/+const+/ xcb_xfixes_get_cursor_image_and_name_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** uint * xcb_xfixes_get_cursor_image_and_name_cursor_image
 **
 ** @param /+const+/ xcb_xfixes_get_cursor_image_and_name_reply_t *R
 ** @returns uint *
 **
 *****************************************************************************/

extern(C) uint *
xcb_xfixes_get_cursor_image_and_name_cursor_image (/+const+/ xcb_xfixes_get_cursor_image_and_name_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_xfixes_get_cursor_image_and_name_cursor_image_length
 **
 ** @param /+const+/ xcb_xfixes_get_cursor_image_and_name_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_xfixes_get_cursor_image_and_name_cursor_image_length (/+const+/ xcb_xfixes_get_cursor_image_and_name_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_xfixes_get_cursor_image_and_name_cursor_image_end
 **
 ** @param /+const+/ xcb_xfixes_get_cursor_image_and_name_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_xfixes_get_cursor_image_and_name_cursor_image_end (/+const+/ xcb_xfixes_get_cursor_image_and_name_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_xfixes_get_cursor_image_and_name_reply_t * xcb_xfixes_get_cursor_image_and_name_reply
 **
 ** @param xcb_connection_t                               *c
 ** @param xcb_xfixes_get_cursor_image_and_name_cookie_t   cookie
 ** @param xcb_generic_error_t                           **e
 ** @returns xcb_xfixes_get_cursor_image_and_name_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_xfixes_get_cursor_image_and_name_reply_t *
xcb_xfixes_get_cursor_image_and_name_reply (xcb_connection_t                               *c  /**< */,
                                            xcb_xfixes_get_cursor_image_and_name_cookie_t   cookie  /**< */,
                                            xcb_generic_error_t                           **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_change_cursor_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_cursor_t      source
 ** @param xcb_cursor_t      destination
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_change_cursor_checked (xcb_connection_t *c  /**< */,
                                  xcb_cursor_t      source  /**< */,
                                  xcb_cursor_t      destination  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_change_cursor
 **
 ** @param xcb_connection_t *c
 ** @param xcb_cursor_t      source
 ** @param xcb_cursor_t      destination
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_change_cursor (xcb_connection_t *c  /**< */,
                          xcb_cursor_t      source  /**< */,
                          xcb_cursor_t      destination  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_change_cursor_by_name_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_cursor_t      src
 ** @param ushort            nbytes
 ** @param /+const+/ ubyte  *name
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_change_cursor_by_name_checked (xcb_connection_t *c  /**< */,
                                          xcb_cursor_t      src  /**< */,
                                          ushort            nbytes  /**< */,
                                          /+const+/ ubyte  *name  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_change_cursor_by_name
 **
 ** @param xcb_connection_t *c
 ** @param xcb_cursor_t      src
 ** @param ushort            nbytes
 ** @param /+const+/ ubyte  *name
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_change_cursor_by_name (xcb_connection_t *c  /**< */,
                                  xcb_cursor_t      src  /**< */,
                                  ushort            nbytes  /**< */,
                                  /+const+/ ubyte  *name  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_expand_region_checked
 **
 ** @param xcb_connection_t    *c
 ** @param xcb_xfixes_region_t  source
 ** @param xcb_xfixes_region_t  destination
 ** @param ushort               left
 ** @param ushort               right
 ** @param ushort               top
 ** @param ushort               bottom
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_expand_region_checked (xcb_connection_t    *c  /**< */,
                                  xcb_xfixes_region_t  source  /**< */,
                                  xcb_xfixes_region_t  destination  /**< */,
                                  ushort               left  /**< */,
                                  ushort               right  /**< */,
                                  ushort               top  /**< */,
                                  ushort               bottom  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_expand_region
 **
 ** @param xcb_connection_t    *c
 ** @param xcb_xfixes_region_t  source
 ** @param xcb_xfixes_region_t  destination
 ** @param ushort               left
 ** @param ushort               right
 ** @param ushort               top
 ** @param ushort               bottom
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_expand_region (xcb_connection_t    *c  /**< */,
                          xcb_xfixes_region_t  source  /**< */,
                          xcb_xfixes_region_t  destination  /**< */,
                          ushort               left  /**< */,
                          ushort               right  /**< */,
                          ushort               top  /**< */,
                          ushort               bottom  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_hide_cursor_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_hide_cursor_checked (xcb_connection_t *c  /**< */,
                                xcb_window_t      window  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_hide_cursor
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_hide_cursor (xcb_connection_t *c  /**< */,
                        xcb_window_t      window  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_show_cursor_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_show_cursor_checked (xcb_connection_t *c  /**< */,
                                xcb_window_t      window  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xfixes_show_cursor
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xfixes_show_cursor (xcb_connection_t *c  /**< */,
                        xcb_window_t      window  /**< */);



/**
 * @}
 */
