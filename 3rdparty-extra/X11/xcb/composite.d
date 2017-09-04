/*
 * This file generated automatically from composite.xml by c-client.xsl using XSLT.
 * Edit at your peril.
 */

/**
 * @defgroup XCB_Composite_API XCB Composite API
 * @brief Composite XCB Protocol Implementation.
 * @{
 **/


module std.c.linux.X11.xcb.composite;
version(USE_XCB):

import std.c.linux.X11.xcb.xcb;
import std.c.linux.X11.xcb.xproto;
import std.c.linux.X11.xcb.xfixes;

const int XCB_COMPOSITE_MAJOR_VERSION =0;
const int XCB_COMPOSITE_MINOR_VERSION =3;

extern(C) extern xcb_extension_t xcb_composite_id;

enum :int{
    XCB_COMPOSITE_REDIRECT_AUTOMATIC,
    XCB_COMPOSITE_REDIRECT_MANUAL
};

/**
 * @brief xcb_composite_query_version_cookie_t
 **/
struct xcb_composite_query_version_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_composite_query_version. */
const uint XCB_COMPOSITE_QUERY_VERSION = 0;

/**
 * @brief xcb_composite_query_version_request_t
 **/
struct xcb_composite_query_version_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
    uint   client_major_version; /**<  */
    uint   client_minor_version; /**<  */
} ;

/**
 * @brief xcb_composite_query_version_reply_t
 **/
struct xcb_composite_query_version_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    uint   major_version; /**<  */
    uint   minor_version; /**<  */
    ubyte  pad1[16]; /**<  */
} ;

/** Opcode for xcb_composite_redirect_window. */
const uint XCB_COMPOSITE_REDIRECT_WINDOW = 1;

/**
 * @brief xcb_composite_redirect_window_request_t
 **/
struct xcb_composite_redirect_window_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        minor_opcode; /**<  */
    ushort       length; /**<  */
    xcb_window_t window; /**<  */
    ubyte        update; /**<  */
    ubyte        pad0[3]; /**<  */
} ;

/** Opcode for xcb_composite_redirect_subwindows. */
const uint XCB_COMPOSITE_REDIRECT_SUBWINDOWS = 2;

/**
 * @brief xcb_composite_redirect_subwindows_request_t
 **/
struct xcb_composite_redirect_subwindows_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        minor_opcode; /**<  */
    ushort       length; /**<  */
    xcb_window_t window; /**<  */
    ubyte        update; /**<  */
    ubyte        pad0[3]; /**<  */
} ;

/** Opcode for xcb_composite_unredirect_window. */
const uint XCB_COMPOSITE_UNREDIRECT_WINDOW = 3;

/**
 * @brief xcb_composite_unredirect_window_request_t
 **/
struct xcb_composite_unredirect_window_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        minor_opcode; /**<  */
    ushort       length; /**<  */
    xcb_window_t window; /**<  */
    ubyte        update; /**<  */
    ubyte        pad0[3]; /**<  */
} ;

/** Opcode for xcb_composite_unredirect_subwindows. */
const uint XCB_COMPOSITE_UNREDIRECT_SUBWINDOWS = 4;

/**
 * @brief xcb_composite_unredirect_subwindows_request_t
 **/
struct xcb_composite_unredirect_subwindows_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        minor_opcode; /**<  */
    ushort       length; /**<  */
    xcb_window_t window; /**<  */
    ubyte        update; /**<  */
    ubyte        pad0[3]; /**<  */
} ;

/** Opcode for xcb_composite_create_region_from_border_clip. */
const uint XCB_COMPOSITE_CREATE_REGION_FROM_BORDER_CLIP = 5;

/**
 * @brief xcb_composite_create_region_from_border_clip_request_t
 **/
struct xcb_composite_create_region_from_border_clip_request_t {
    ubyte               major_opcode; /**<  */
    ubyte               minor_opcode; /**<  */
    ushort              length; /**<  */
    xcb_xfixes_region_t region; /**<  */
    xcb_window_t        window; /**<  */
} ;

/** Opcode for xcb_composite_name_window_pixmap. */
const uint XCB_COMPOSITE_NAME_WINDOW_PIXMAP = 6;

/**
 * @brief xcb_composite_name_window_pixmap_request_t
 **/
struct xcb_composite_name_window_pixmap_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        minor_opcode; /**<  */
    ushort       length; /**<  */
    xcb_window_t window; /**<  */
    xcb_pixmap_t pixmap; /**<  */
} ;

/**
 * @brief xcb_composite_get_overlay_window_cookie_t
 **/
struct xcb_composite_get_overlay_window_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_composite_get_overlay_window. */
const uint XCB_COMPOSITE_GET_OVERLAY_WINDOW = 7;

/**
 * @brief xcb_composite_get_overlay_window_request_t
 **/
struct xcb_composite_get_overlay_window_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        minor_opcode; /**<  */
    ushort       length; /**<  */
    xcb_window_t window; /**<  */
} ;

/**
 * @brief xcb_composite_get_overlay_window_reply_t
 **/
struct xcb_composite_get_overlay_window_reply_t {
    ubyte        response_type; /**<  */
    ubyte        pad0; /**<  */
    ushort       sequence; /**<  */
    uint         length; /**<  */
    xcb_window_t overlay_win; /**<  */
    ubyte        pad1[20]; /**<  */
} ;

/** Opcode for xcb_composite_release_overlay_window. */
const uint XCB_COMPOSITE_RELEASE_OVERLAY_WINDOW = 8;

/**
 * @brief xcb_composite_release_overlay_window_request_t
 **/
struct xcb_composite_release_overlay_window_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        minor_opcode; /**<  */
    ushort       length; /**<  */
    xcb_window_t window; /**<  */
} ;


/*****************************************************************************
 **
 ** xcb_composite_query_version_cookie_t xcb_composite_query_version
 **
 ** @param xcb_connection_t *c
 ** @param uint              client_major_version
 ** @param uint              client_minor_version
 ** @returns xcb_composite_query_version_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_composite_query_version_cookie_t
xcb_composite_query_version (xcb_connection_t *c  /**< */,
                             uint              client_major_version  /**< */,
                             uint              client_minor_version  /**< */);


/*****************************************************************************
 **
 ** xcb_composite_query_version_cookie_t xcb_composite_query_version_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param uint              client_major_version
 ** @param uint              client_minor_version
 ** @returns xcb_composite_query_version_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_composite_query_version_cookie_t
xcb_composite_query_version_unchecked (xcb_connection_t *c  /**< */,
                                       uint              client_major_version  /**< */,
                                       uint              client_minor_version  /**< */);


/*****************************************************************************
 **
 ** xcb_composite_query_version_reply_t * xcb_composite_query_version_reply
 **
 ** @param xcb_connection_t                      *c
 ** @param xcb_composite_query_version_cookie_t   cookie
 ** @param xcb_generic_error_t                  **e
 ** @returns xcb_composite_query_version_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_composite_query_version_reply_t *
xcb_composite_query_version_reply (xcb_connection_t                      *c  /**< */,
                                   xcb_composite_query_version_cookie_t   cookie  /**< */,
                                   xcb_generic_error_t                  **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_composite_redirect_window_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @param ubyte             update
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_composite_redirect_window_checked (xcb_connection_t *c  /**< */,
                                       xcb_window_t      window  /**< */,
                                       ubyte             update  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_composite_redirect_window
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @param ubyte             update
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_composite_redirect_window (xcb_connection_t *c  /**< */,
                               xcb_window_t      window  /**< */,
                               ubyte             update  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_composite_redirect_subwindows_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @param ubyte             update
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_composite_redirect_subwindows_checked (xcb_connection_t *c  /**< */,
                                           xcb_window_t      window  /**< */,
                                           ubyte             update  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_composite_redirect_subwindows
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @param ubyte             update
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_composite_redirect_subwindows (xcb_connection_t *c  /**< */,
                                   xcb_window_t      window  /**< */,
                                   ubyte             update  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_composite_unredirect_window_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @param ubyte             update
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_composite_unredirect_window_checked (xcb_connection_t *c  /**< */,
                                         xcb_window_t      window  /**< */,
                                         ubyte             update  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_composite_unredirect_window
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @param ubyte             update
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_composite_unredirect_window (xcb_connection_t *c  /**< */,
                                 xcb_window_t      window  /**< */,
                                 ubyte             update  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_composite_unredirect_subwindows_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @param ubyte             update
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_composite_unredirect_subwindows_checked (xcb_connection_t *c  /**< */,
                                             xcb_window_t      window  /**< */,
                                             ubyte             update  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_composite_unredirect_subwindows
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @param ubyte             update
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_composite_unredirect_subwindows (xcb_connection_t *c  /**< */,
                                     xcb_window_t      window  /**< */,
                                     ubyte             update  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_composite_create_region_from_border_clip_checked
 **
 ** @param xcb_connection_t    *c
 ** @param xcb_xfixes_region_t  region
 ** @param xcb_window_t         window
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_composite_create_region_from_border_clip_checked (xcb_connection_t    *c  /**< */,
                                                      xcb_xfixes_region_t  region  /**< */,
                                                      xcb_window_t         window  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_composite_create_region_from_border_clip
 **
 ** @param xcb_connection_t    *c
 ** @param xcb_xfixes_region_t  region
 ** @param xcb_window_t         window
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_composite_create_region_from_border_clip (xcb_connection_t    *c  /**< */,
                                              xcb_xfixes_region_t  region  /**< */,
                                              xcb_window_t         window  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_composite_name_window_pixmap_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @param xcb_pixmap_t      pixmap
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_composite_name_window_pixmap_checked (xcb_connection_t *c  /**< */,
                                          xcb_window_t      window  /**< */,
                                          xcb_pixmap_t      pixmap  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_composite_name_window_pixmap
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @param xcb_pixmap_t      pixmap
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_composite_name_window_pixmap (xcb_connection_t *c  /**< */,
                                  xcb_window_t      window  /**< */,
                                  xcb_pixmap_t      pixmap  /**< */);


/*****************************************************************************
 **
 ** xcb_composite_get_overlay_window_cookie_t xcb_composite_get_overlay_window
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @returns xcb_composite_get_overlay_window_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_composite_get_overlay_window_cookie_t
xcb_composite_get_overlay_window (xcb_connection_t *c  /**< */,
                                  xcb_window_t      window  /**< */);


/*****************************************************************************
 **
 ** xcb_composite_get_overlay_window_cookie_t xcb_composite_get_overlay_window_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @returns xcb_composite_get_overlay_window_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_composite_get_overlay_window_cookie_t
xcb_composite_get_overlay_window_unchecked (xcb_connection_t *c  /**< */,
                                            xcb_window_t      window  /**< */);


/*****************************************************************************
 **
 ** xcb_composite_get_overlay_window_reply_t * xcb_composite_get_overlay_window_reply
 **
 ** @param xcb_connection_t                           *c
 ** @param xcb_composite_get_overlay_window_cookie_t   cookie
 ** @param xcb_generic_error_t                       **e
 ** @returns xcb_composite_get_overlay_window_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_composite_get_overlay_window_reply_t *
xcb_composite_get_overlay_window_reply (xcb_connection_t                           *c  /**< */,
                                        xcb_composite_get_overlay_window_cookie_t   cookie  /**< */,
                                        xcb_generic_error_t                       **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_composite_release_overlay_window_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_composite_release_overlay_window_checked (xcb_connection_t *c  /**< */,
                                              xcb_window_t      window  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_composite_release_overlay_window
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_composite_release_overlay_window (xcb_connection_t *c  /**< */,
                                      xcb_window_t      window  /**< */);



/**
 * @}
 */
