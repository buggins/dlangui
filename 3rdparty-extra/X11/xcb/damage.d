/*
 * This file generated automatically from damage.xml by c-client.xsl using XSLT.
 * Edit at your peril.
 */

/**
 * @defgroup XCB_Damage_API XCB Damage API
 * @brief Damage XCB Protocol Implementation.
 * @{
 **/


module std.c.linux.X11.xcb.damage;
version(USE_XCB):

import std.c.linux.X11.xcb.xcb;
import std.c.linux.X11.xcb.xproto;
import std.c.linux.X11.xcb.xfixes;

const int XCB_DAMAGE_MAJOR_VERSION =1;
const int XCB_DAMAGE_MINOR_VERSION =0;

extern(C) extern xcb_extension_t xcb_damage_id;

alias uint xcb_damage_damage_t;

/**
 * @brief xcb_damage_damage_iterator_t
 **/
struct xcb_damage_damage_iterator_t {
    xcb_damage_damage_t *data; /**<  */
    int                  rem; /**<  */
    int                  index; /**<  */
} ;

enum :int{
    XCB_DAMAGE_REPORT_LEVEL_RAW_RECTANGLES,
    XCB_DAMAGE_REPORT_LEVEL_DELTA_RECTANGLES,
    XCB_DAMAGE_REPORT_LEVEL_BOUNDING_BOX,
    XCB_DAMAGE_REPORT_LEVEL_NON_EMPTY
};

/** Opcode for xcb_damage_bad_damage. */
const uint XCB_DAMAGE_BAD_DAMAGE = 0;

/**
 * @brief xcb_damage_bad_damage_error_t
 **/
struct xcb_damage_bad_damage_error_t {
    ubyte  response_type; /**<  */
    ubyte  error_code; /**<  */
    ushort sequence; /**<  */
} ;

/**
 * @brief xcb_damage_query_version_cookie_t
 **/
struct xcb_damage_query_version_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_damage_query_version. */
const uint XCB_DAMAGE_QUERY_VERSION = 0;

/**
 * @brief xcb_damage_query_version_request_t
 **/
struct xcb_damage_query_version_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
    uint   client_major_version; /**<  */
    uint   client_minor_version; /**<  */
} ;

/**
 * @brief xcb_damage_query_version_reply_t
 **/
struct xcb_damage_query_version_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    uint   major_version; /**<  */
    uint   minor_version; /**<  */
    ubyte  pad1[16]; /**<  */
} ;

/** Opcode for xcb_damage_create. */
const uint XCB_DAMAGE_CREATE = 1;

/**
 * @brief xcb_damage_create_request_t
 **/
struct xcb_damage_create_request_t {
    ubyte               major_opcode; /**<  */
    ubyte               minor_opcode; /**<  */
    ushort              length; /**<  */
    xcb_damage_damage_t damage; /**<  */
    xcb_drawable_t      drawable; /**<  */
    ubyte               level; /**<  */
    ubyte               pad0[3]; /**<  */
} ;

/** Opcode for xcb_damage_destroy. */
const uint XCB_DAMAGE_DESTROY = 2;

/**
 * @brief xcb_damage_destroy_request_t
 **/
struct xcb_damage_destroy_request_t {
    ubyte               major_opcode; /**<  */
    ubyte               minor_opcode; /**<  */
    ushort              length; /**<  */
    xcb_damage_damage_t damage; /**<  */
} ;

/** Opcode for xcb_damage_subtract. */
const uint XCB_DAMAGE_SUBTRACT = 3;

/**
 * @brief xcb_damage_subtract_request_t
 **/
struct xcb_damage_subtract_request_t {
    ubyte               major_opcode; /**<  */
    ubyte               minor_opcode; /**<  */
    ushort              length; /**<  */
    xcb_damage_damage_t damage; /**<  */
    xcb_xfixes_region_t repair; /**<  */
    xcb_xfixes_region_t parts; /**<  */
} ;

/** Opcode for xcb_damage_notify. */
const uint XCB_DAMAGE_NOTIFY = 0;

/**
 * @brief xcb_damage_notify_event_t
 **/
struct xcb_damage_notify_event_t {
    ubyte               response_type; /**<  */
    ubyte               level; /**<  */
    ushort              sequence; /**<  */
    xcb_drawable_t      drawable; /**<  */
    xcb_damage_damage_t damage; /**<  */
    xcb_timestamp_t     timestamp; /**<  */
    xcb_rectangle_t     area; /**<  */
    xcb_rectangle_t     geometry; /**<  */
} ;


/*****************************************************************************
 **
 ** void xcb_damage_damage_next
 **
 ** @param xcb_damage_damage_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_damage_damage_next (xcb_damage_damage_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_damage_damage_end
 **
 ** @param xcb_damage_damage_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_damage_damage_end (xcb_damage_damage_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** xcb_damage_query_version_cookie_t xcb_damage_query_version
 **
 ** @param xcb_connection_t *c
 ** @param uint              client_major_version
 ** @param uint              client_minor_version
 ** @returns xcb_damage_query_version_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_damage_query_version_cookie_t
xcb_damage_query_version (xcb_connection_t *c  /**< */,
                          uint              client_major_version  /**< */,
                          uint              client_minor_version  /**< */);


/*****************************************************************************
 **
 ** xcb_damage_query_version_cookie_t xcb_damage_query_version_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param uint              client_major_version
 ** @param uint              client_minor_version
 ** @returns xcb_damage_query_version_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_damage_query_version_cookie_t
xcb_damage_query_version_unchecked (xcb_connection_t *c  /**< */,
                                    uint              client_major_version  /**< */,
                                    uint              client_minor_version  /**< */);


/*****************************************************************************
 **
 ** xcb_damage_query_version_reply_t * xcb_damage_query_version_reply
 **
 ** @param xcb_connection_t                   *c
 ** @param xcb_damage_query_version_cookie_t   cookie
 ** @param xcb_generic_error_t               **e
 ** @returns xcb_damage_query_version_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_damage_query_version_reply_t *
xcb_damage_query_version_reply (xcb_connection_t                   *c  /**< */,
                                xcb_damage_query_version_cookie_t   cookie  /**< */,
                                xcb_generic_error_t               **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_damage_create_checked
 **
 ** @param xcb_connection_t    *c
 ** @param xcb_damage_damage_t  damage
 ** @param xcb_drawable_t       drawable
 ** @param ubyte                level
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_damage_create_checked (xcb_connection_t    *c  /**< */,
                           xcb_damage_damage_t  damage  /**< */,
                           xcb_drawable_t       drawable  /**< */,
                           ubyte                level  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_damage_create
 **
 ** @param xcb_connection_t    *c
 ** @param xcb_damage_damage_t  damage
 ** @param xcb_drawable_t       drawable
 ** @param ubyte                level
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_damage_create (xcb_connection_t    *c  /**< */,
                   xcb_damage_damage_t  damage  /**< */,
                   xcb_drawable_t       drawable  /**< */,
                   ubyte                level  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_damage_destroy_checked
 **
 ** @param xcb_connection_t    *c
 ** @param xcb_damage_damage_t  damage
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_damage_destroy_checked (xcb_connection_t    *c  /**< */,
                            xcb_damage_damage_t  damage  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_damage_destroy
 **
 ** @param xcb_connection_t    *c
 ** @param xcb_damage_damage_t  damage
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_damage_destroy (xcb_connection_t    *c  /**< */,
                    xcb_damage_damage_t  damage  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_damage_subtract_checked
 **
 ** @param xcb_connection_t    *c
 ** @param xcb_damage_damage_t  damage
 ** @param xcb_xfixes_region_t  repair
 ** @param xcb_xfixes_region_t  parts
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_damage_subtract_checked (xcb_connection_t    *c  /**< */,
                             xcb_damage_damage_t  damage  /**< */,
                             xcb_xfixes_region_t  repair  /**< */,
                             xcb_xfixes_region_t  parts  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_damage_subtract
 **
 ** @param xcb_connection_t    *c
 ** @param xcb_damage_damage_t  damage
 ** @param xcb_xfixes_region_t  repair
 ** @param xcb_xfixes_region_t  parts
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_damage_subtract (xcb_connection_t    *c  /**< */,
                     xcb_damage_damage_t  damage  /**< */,
                     xcb_xfixes_region_t  repair  /**< */,
                     xcb_xfixes_region_t  parts  /**< */);



/**
 * @}
 */
