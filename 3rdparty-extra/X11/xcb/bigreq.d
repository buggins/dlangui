/*
 * This file generated automatically from bigreq.xml by c-client.xsl using XSLT.
 * Edit at your peril.
 */

/**
 * @defgroup XCB_BigRequests_API XCB BigRequests API
 * @brief BigRequests XCB Protocol Implementation.
 * @{
 **/


module std.c.linux.X11.xcb.bigreq;
version(USE_XCB):

import std.c.linux.X11.xcb.xcb;

const int XCB_BIGREQUESTS_MAJOR_VERSION =0;
const int XCB_BIGREQUESTS_MINOR_VERSION =0;

extern(C) extern xcb_extension_t xcb_big_requests_id;

/**
 * @brief xcb_big_requests_enable_cookie_t
 **/
struct xcb_big_requests_enable_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_big_requests_enable. */
const uint XCB_BIG_REQUESTS_ENABLE = 0;

/**
 * @brief xcb_big_requests_enable_request_t
 **/
struct xcb_big_requests_enable_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
} ;

/**
 * @brief xcb_big_requests_enable_reply_t
 **/
struct xcb_big_requests_enable_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    uint   maximum_request_length; /**<  */
} ;


/*****************************************************************************
 **
 ** xcb_big_requests_enable_cookie_t xcb_big_requests_enable
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_big_requests_enable_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_big_requests_enable_cookie_t
xcb_big_requests_enable (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_big_requests_enable_cookie_t xcb_big_requests_enable_unchecked
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_big_requests_enable_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_big_requests_enable_cookie_t
xcb_big_requests_enable_unchecked (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_big_requests_enable_reply_t * xcb_big_requests_enable_reply
 **
 ** @param xcb_connection_t                  *c
 ** @param xcb_big_requests_enable_cookie_t   cookie
 ** @param xcb_generic_error_t              **e
 ** @returns xcb_big_requests_enable_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_big_requests_enable_reply_t *
xcb_big_requests_enable_reply (xcb_connection_t                  *c  /**< */,
                               xcb_big_requests_enable_cookie_t   cookie  /**< */,
                               xcb_generic_error_t              **e  /**< */);



/**
 * @}
 */
