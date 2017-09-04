/*
 * This file generated automatically from dpms.xml by c-client.xsl using XSLT.
 * Edit at your peril.
 */

/**
 * @defgroup XCB_DPMS_API XCB DPMS API
 * @brief DPMS XCB Protocol Implementation.
 * @{
 **/


module std.c.linux.X11.xcb.dpms;
version(USE_XCB):

import std.c.linux.X11.xcb.xcb;

const int XCB_DPMS_MAJOR_VERSION =0;
const int XCB_DPMS_MINOR_VERSION =0;

extern(C) extern xcb_extension_t xcb_dpms_id;

/**
 * @brief xcb_dpms_get_version_cookie_t
 **/
struct xcb_dpms_get_version_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_dpms_get_version. */
const uint XCB_DPMS_GET_VERSION = 0;

/**
 * @brief xcb_dpms_get_version_request_t
 **/
struct xcb_dpms_get_version_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
    ushort client_major_version; /**<  */
    ushort client_minor_version; /**<  */
} ;

/**
 * @brief xcb_dpms_get_version_reply_t
 **/
struct xcb_dpms_get_version_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ushort server_major_version; /**<  */
    ushort server_minor_version; /**<  */
} ;

/**
 * @brief xcb_dpms_capable_cookie_t
 **/
struct xcb_dpms_capable_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_dpms_capable. */
const uint XCB_DPMS_CAPABLE = 1;

/**
 * @brief xcb_dpms_capable_request_t
 **/
struct xcb_dpms_capable_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
} ;

/**
 * @brief xcb_dpms_capable_reply_t
 **/
struct xcb_dpms_capable_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    bool   capable; /**<  */
} ;

/**
 * @brief xcb_dpms_get_timeouts_cookie_t
 **/
struct xcb_dpms_get_timeouts_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_dpms_get_timeouts. */
const uint XCB_DPMS_GET_TIMEOUTS = 2;

/**
 * @brief xcb_dpms_get_timeouts_request_t
 **/
struct xcb_dpms_get_timeouts_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
} ;

/**
 * @brief xcb_dpms_get_timeouts_reply_t
 **/
struct xcb_dpms_get_timeouts_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ushort standby_timeout; /**<  */
    ushort suspend_timeout; /**<  */
    ushort off_timeout; /**<  */
} ;

/** Opcode for xcb_dpms_set_timeouts. */
const uint XCB_DPMS_SET_TIMEOUTS = 3;

/**
 * @brief xcb_dpms_set_timeouts_request_t
 **/
struct xcb_dpms_set_timeouts_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
    ushort standby_timeout; /**<  */
    ushort suspend_timeout; /**<  */
    ushort off_timeout; /**<  */
} ;

/** Opcode for xcb_dpms_enable. */
const uint XCB_DPMS_ENABLE = 4;

/**
 * @brief xcb_dpms_enable_request_t
 **/
struct xcb_dpms_enable_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
} ;

/** Opcode for xcb_dpms_disable. */
const uint XCB_DPMS_DISABLE = 5;

/**
 * @brief xcb_dpms_disable_request_t
 **/
struct xcb_dpms_disable_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
} ;

/** Opcode for xcb_dpms_force_level. */
const uint XCB_DPMS_FORCE_LEVEL = 6;

/**
 * @brief xcb_dpms_force_level_request_t
 **/
struct xcb_dpms_force_level_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
    ushort power_level; /**<  */
} ;

/**
 * @brief xcb_dpms_info_cookie_t
 **/
struct xcb_dpms_info_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_dpms_info. */
const uint XCB_DPMS_INFO = 7;

/**
 * @brief xcb_dpms_info_request_t
 **/
struct xcb_dpms_info_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
} ;

/**
 * @brief xcb_dpms_info_reply_t
 **/
struct xcb_dpms_info_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ushort power_level; /**<  */
    bool   state; /**<  */
} ;


/*****************************************************************************
 **
 ** xcb_dpms_get_version_cookie_t xcb_dpms_get_version
 **
 ** @param xcb_connection_t *c
 ** @param ushort            client_major_version
 ** @param ushort            client_minor_version
 ** @returns xcb_dpms_get_version_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_dpms_get_version_cookie_t
xcb_dpms_get_version (xcb_connection_t *c  /**< */,
                      ushort            client_major_version  /**< */,
                      ushort            client_minor_version  /**< */);


/*****************************************************************************
 **
 ** xcb_dpms_get_version_cookie_t xcb_dpms_get_version_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param ushort            client_major_version
 ** @param ushort            client_minor_version
 ** @returns xcb_dpms_get_version_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_dpms_get_version_cookie_t
xcb_dpms_get_version_unchecked (xcb_connection_t *c  /**< */,
                                ushort            client_major_version  /**< */,
                                ushort            client_minor_version  /**< */);


/*****************************************************************************
 **
 ** xcb_dpms_get_version_reply_t * xcb_dpms_get_version_reply
 **
 ** @param xcb_connection_t               *c
 ** @param xcb_dpms_get_version_cookie_t   cookie
 ** @param xcb_generic_error_t           **e
 ** @returns xcb_dpms_get_version_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_dpms_get_version_reply_t *
xcb_dpms_get_version_reply (xcb_connection_t               *c  /**< */,
                            xcb_dpms_get_version_cookie_t   cookie  /**< */,
                            xcb_generic_error_t           **e  /**< */);


/*****************************************************************************
 **
 ** xcb_dpms_capable_cookie_t xcb_dpms_capable
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_dpms_capable_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_dpms_capable_cookie_t
xcb_dpms_capable (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_dpms_capable_cookie_t xcb_dpms_capable_unchecked
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_dpms_capable_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_dpms_capable_cookie_t
xcb_dpms_capable_unchecked (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_dpms_capable_reply_t * xcb_dpms_capable_reply
 **
 ** @param xcb_connection_t           *c
 ** @param xcb_dpms_capable_cookie_t   cookie
 ** @param xcb_generic_error_t       **e
 ** @returns xcb_dpms_capable_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_dpms_capable_reply_t *
xcb_dpms_capable_reply (xcb_connection_t           *c  /**< */,
                        xcb_dpms_capable_cookie_t   cookie  /**< */,
                        xcb_generic_error_t       **e  /**< */);


/*****************************************************************************
 **
 ** xcb_dpms_get_timeouts_cookie_t xcb_dpms_get_timeouts
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_dpms_get_timeouts_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_dpms_get_timeouts_cookie_t
xcb_dpms_get_timeouts (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_dpms_get_timeouts_cookie_t xcb_dpms_get_timeouts_unchecked
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_dpms_get_timeouts_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_dpms_get_timeouts_cookie_t
xcb_dpms_get_timeouts_unchecked (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_dpms_get_timeouts_reply_t * xcb_dpms_get_timeouts_reply
 **
 ** @param xcb_connection_t                *c
 ** @param xcb_dpms_get_timeouts_cookie_t   cookie
 ** @param xcb_generic_error_t            **e
 ** @returns xcb_dpms_get_timeouts_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_dpms_get_timeouts_reply_t *
xcb_dpms_get_timeouts_reply (xcb_connection_t                *c  /**< */,
                             xcb_dpms_get_timeouts_cookie_t   cookie  /**< */,
                             xcb_generic_error_t            **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_dpms_set_timeouts_checked
 **
 ** @param xcb_connection_t *c
 ** @param ushort            standby_timeout
 ** @param ushort            suspend_timeout
 ** @param ushort            off_timeout
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_dpms_set_timeouts_checked (xcb_connection_t *c  /**< */,
                               ushort            standby_timeout  /**< */,
                               ushort            suspend_timeout  /**< */,
                               ushort            off_timeout  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_dpms_set_timeouts
 **
 ** @param xcb_connection_t *c
 ** @param ushort            standby_timeout
 ** @param ushort            suspend_timeout
 ** @param ushort            off_timeout
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_dpms_set_timeouts (xcb_connection_t *c  /**< */,
                       ushort            standby_timeout  /**< */,
                       ushort            suspend_timeout  /**< */,
                       ushort            off_timeout  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_dpms_enable_checked
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_dpms_enable_checked (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_dpms_enable
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_dpms_enable (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_dpms_disable_checked
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_dpms_disable_checked (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_dpms_disable
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_dpms_disable (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_dpms_force_level_checked
 **
 ** @param xcb_connection_t *c
 ** @param ushort            power_level
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_dpms_force_level_checked (xcb_connection_t *c  /**< */,
                              ushort            power_level  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_dpms_force_level
 **
 ** @param xcb_connection_t *c
 ** @param ushort            power_level
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_dpms_force_level (xcb_connection_t *c  /**< */,
                      ushort            power_level  /**< */);


/*****************************************************************************
 **
 ** xcb_dpms_info_cookie_t xcb_dpms_info
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_dpms_info_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_dpms_info_cookie_t
xcb_dpms_info (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_dpms_info_cookie_t xcb_dpms_info_unchecked
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_dpms_info_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_dpms_info_cookie_t
xcb_dpms_info_unchecked (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_dpms_info_reply_t * xcb_dpms_info_reply
 **
 ** @param xcb_connection_t        *c
 ** @param xcb_dpms_info_cookie_t   cookie
 ** @param xcb_generic_error_t    **e
 ** @returns xcb_dpms_info_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_dpms_info_reply_t *
xcb_dpms_info_reply (xcb_connection_t        *c  /**< */,
                     xcb_dpms_info_cookie_t   cookie  /**< */,
                     xcb_generic_error_t    **e  /**< */);



/**
 * @}
 */
