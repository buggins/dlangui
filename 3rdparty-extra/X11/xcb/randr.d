/*
 * This file generated automatically from randr.xml by c-client.xsl using XSLT.
 * Edit at your peril.
 */

/**
 * @defgroup XCB_RandR_API XCB RandR API
 * @brief RandR XCB Protocol Implementation.
 * @{
 **/


module std.c.linux.X11.xcb.randr;
version(USE_XCB):

import std.c.linux.X11.xcb.xcb;
import std.c.linux.X11.xcb.xproto;

const int XCB_RANDR_MAJOR_VERSION =1;
const int XCB_RANDR_MINOR_VERSION =1;

extern(C) extern xcb_extension_t xcb_randr_id;

enum :int{
    XCB_RANDR_ROTATION_ROTATE_0 = 1,
    XCB_RANDR_ROTATION_ROTATE_90 = 2,
    XCB_RANDR_ROTATION_ROTATE_180 = 4,
    XCB_RANDR_ROTATION_ROTATE_270 = 8,
    XCB_RANDR_ROTATION_REFLECT_X = 16,
    XCB_RANDR_ROTATION_REFLECT_Y = 32
};

/**
 * @brief xcb_randr_screen_size_t
 **/
struct xcb_randr_screen_size_t {
    short width; /**<  */
    short height; /**<  */
    short mwidth; /**<  */
    short mheight; /**<  */
} ;

/**
 * @brief xcb_randr_screen_size_iterator_t
 **/
struct xcb_randr_screen_size_iterator_t {
    xcb_randr_screen_size_t *data; /**<  */
    int                      rem; /**<  */
    int                      index; /**<  */
} ;

/**
 * @brief xcb_randr_refresh_rates_t
 **/
struct xcb_randr_refresh_rates_t {
    ushort nRates; /**<  */
} ;

/**
 * @brief xcb_randr_refresh_rates_iterator_t
 **/
struct xcb_randr_refresh_rates_iterator_t {
    xcb_randr_refresh_rates_t *data; /**<  */
    int                        rem; /**<  */
    int                        index; /**<  */
} ;

/**
 * @brief xcb_randr_query_version_cookie_t
 **/
struct xcb_randr_query_version_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_randr_query_version. */
const uint XCB_RANDR_QUERY_VERSION = 0;

/**
 * @brief xcb_randr_query_version_request_t
 **/
struct xcb_randr_query_version_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
    uint   major_version; /**<  */
    uint   minor_version; /**<  */
} ;

/**
 * @brief xcb_randr_query_version_reply_t
 **/
struct xcb_randr_query_version_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    uint   major_version; /**<  */
    uint   minor_version; /**<  */
    ubyte  pad1[16]; /**<  */
} ;

/**
 * @brief xcb_randr_set_screen_config_cookie_t
 **/
struct xcb_randr_set_screen_config_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_randr_set_screen_config. */
const uint XCB_RANDR_SET_SCREEN_CONFIG = 2;

/**
 * @brief xcb_randr_set_screen_config_request_t
 **/
struct xcb_randr_set_screen_config_request_t {
    ubyte           major_opcode; /**<  */
    ubyte           minor_opcode; /**<  */
    ushort          length; /**<  */
    xcb_drawable_t  drawable; /**<  */
    xcb_timestamp_t timestamp; /**<  */
    xcb_timestamp_t config_timestamp; /**<  */
    ushort          sizeID; /**<  */
    short           rotation; /**<  */
    ushort          rate; /**<  */
    ubyte           pad0[2]; /**<  */
} ;

/**
 * @brief xcb_randr_set_screen_config_reply_t
 **/
struct xcb_randr_set_screen_config_reply_t {
    ubyte           response_type; /**<  */
    ubyte           status; /**<  */
    ushort          sequence; /**<  */
    uint            length; /**<  */
    xcb_timestamp_t new_timestamp; /**<  */
    xcb_timestamp_t config_timestamp; /**<  */
    xcb_window_t    root; /**<  */
    ushort          subpixel_order; /**<  */
    ubyte           pad0[10]; /**<  */
} ;

enum :int{
    XCB_RANDR_SET_CONFIG_SUCCESS = 0,
    XCB_RANDR_SET_CONFIG_INVALID_CONFIG_TIME = 1,
    XCB_RANDR_SET_CONFIG_INVALID_TIME = 2,
    XCB_RANDR_SET_CONFIG_FAILED = 3
};

/** Opcode for xcb_randr_select_input. */
const uint XCB_RANDR_SELECT_INPUT = 4;

/**
 * @brief xcb_randr_select_input_request_t
 **/
struct xcb_randr_select_input_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        minor_opcode; /**<  */
    ushort       length; /**<  */
    xcb_window_t window; /**<  */
    ushort       enable; /**<  */
    ubyte        pad0[2]; /**<  */
} ;

/**
 * @brief xcb_randr_get_screen_info_cookie_t
 **/
struct xcb_randr_get_screen_info_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_randr_get_screen_info. */
const uint XCB_RANDR_GET_SCREEN_INFO = 5;

/**
 * @brief xcb_randr_get_screen_info_request_t
 **/
struct xcb_randr_get_screen_info_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        minor_opcode; /**<  */
    ushort       length; /**<  */
    xcb_window_t window; /**<  */
} ;

/**
 * @brief xcb_randr_get_screen_info_reply_t
 **/
struct xcb_randr_get_screen_info_reply_t {
    ubyte           response_type; /**<  */
    ubyte           rotations; /**<  */
    ushort          sequence; /**<  */
    uint            length; /**<  */
    xcb_window_t    root; /**<  */
    xcb_timestamp_t timestamp; /**<  */
    xcb_timestamp_t config_timestamp; /**<  */
    ushort          nSizes; /**<  */
    ushort          sizeID; /**<  */
    short           rotation; /**<  */
    ushort          rate; /**<  */
    ushort          nInfo; /**<  */
    ubyte           pad0[2]; /**<  */
} ;

enum :int{
    XCB_RANDR_SM_SCREEN_CHANGE_NOTIFY = 1
};

/** Opcode for xcb_randr_screen_change_notify. */
const uint XCB_RANDR_SCREEN_CHANGE_NOTIFY = 0;

/**
 * @brief xcb_randr_screen_change_notify_event_t
 **/
struct xcb_randr_screen_change_notify_event_t {
    ubyte           response_type; /**<  */
    ubyte           rotation; /**<  */
    ushort          sequence; /**<  */
    xcb_timestamp_t timestamp; /**<  */
    xcb_timestamp_t config_timestamp; /**<  */
    xcb_window_t    root; /**<  */
    xcb_window_t    request_window; /**<  */
    ushort          sizeID; /**<  */
    ushort          subpixel_order; /**<  */
    short           width; /**<  */
    short           height; /**<  */
    short           mwidth; /**<  */
    short           mheight; /**<  */
} ;


/*****************************************************************************
 **
 ** void xcb_randr_screen_size_next
 **
 ** @param xcb_randr_screen_size_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_randr_screen_size_next (xcb_randr_screen_size_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_randr_screen_size_end
 **
 ** @param xcb_randr_screen_size_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_randr_screen_size_end (xcb_randr_screen_size_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** ushort * xcb_randr_refresh_rates_rates
 **
 ** @param /+const+/ xcb_randr_refresh_rates_t *R
 ** @returns ushort *
 **
 *****************************************************************************/

extern(C) ushort *
xcb_randr_refresh_rates_rates (/+const+/ xcb_randr_refresh_rates_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_randr_refresh_rates_rates_length
 **
 ** @param /+const+/ xcb_randr_refresh_rates_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_randr_refresh_rates_rates_length (/+const+/ xcb_randr_refresh_rates_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_randr_refresh_rates_rates_end
 **
 ** @param /+const+/ xcb_randr_refresh_rates_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_randr_refresh_rates_rates_end (/+const+/ xcb_randr_refresh_rates_t *R  /**< */);


/*****************************************************************************
 **
 ** void xcb_randr_refresh_rates_next
 **
 ** @param xcb_randr_refresh_rates_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_randr_refresh_rates_next (xcb_randr_refresh_rates_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_randr_refresh_rates_end
 **
 ** @param xcb_randr_refresh_rates_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_randr_refresh_rates_end (xcb_randr_refresh_rates_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** xcb_randr_query_version_cookie_t xcb_randr_query_version
 **
 ** @param xcb_connection_t *c
 ** @param uint              major_version
 ** @param uint              minor_version
 ** @returns xcb_randr_query_version_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_randr_query_version_cookie_t
xcb_randr_query_version (xcb_connection_t *c  /**< */,
                         uint              major_version  /**< */,
                         uint              minor_version  /**< */);


/*****************************************************************************
 **
 ** xcb_randr_query_version_cookie_t xcb_randr_query_version_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param uint              major_version
 ** @param uint              minor_version
 ** @returns xcb_randr_query_version_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_randr_query_version_cookie_t
xcb_randr_query_version_unchecked (xcb_connection_t *c  /**< */,
                                   uint              major_version  /**< */,
                                   uint              minor_version  /**< */);


/*****************************************************************************
 **
 ** xcb_randr_query_version_reply_t * xcb_randr_query_version_reply
 **
 ** @param xcb_connection_t                  *c
 ** @param xcb_randr_query_version_cookie_t   cookie
 ** @param xcb_generic_error_t              **e
 ** @returns xcb_randr_query_version_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_randr_query_version_reply_t *
xcb_randr_query_version_reply (xcb_connection_t                  *c  /**< */,
                               xcb_randr_query_version_cookie_t   cookie  /**< */,
                               xcb_generic_error_t              **e  /**< */);


/*****************************************************************************
 **
 ** xcb_randr_set_screen_config_cookie_t xcb_randr_set_screen_config
 **
 ** @param xcb_connection_t *c
 ** @param xcb_drawable_t    drawable
 ** @param xcb_timestamp_t   timestamp
 ** @param xcb_timestamp_t   config_timestamp
 ** @param ushort            sizeID
 ** @param short             rotation
 ** @param ushort            rate
 ** @returns xcb_randr_set_screen_config_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_randr_set_screen_config_cookie_t
xcb_randr_set_screen_config (xcb_connection_t *c  /**< */,
                             xcb_drawable_t    drawable  /**< */,
                             xcb_timestamp_t   timestamp  /**< */,
                             xcb_timestamp_t   config_timestamp  /**< */,
                             ushort            sizeID  /**< */,
                             short             rotation  /**< */,
                             ushort            rate  /**< */);


/*****************************************************************************
 **
 ** xcb_randr_set_screen_config_cookie_t xcb_randr_set_screen_config_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_drawable_t    drawable
 ** @param xcb_timestamp_t   timestamp
 ** @param xcb_timestamp_t   config_timestamp
 ** @param ushort            sizeID
 ** @param short             rotation
 ** @param ushort            rate
 ** @returns xcb_randr_set_screen_config_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_randr_set_screen_config_cookie_t
xcb_randr_set_screen_config_unchecked (xcb_connection_t *c  /**< */,
                                       xcb_drawable_t    drawable  /**< */,
                                       xcb_timestamp_t   timestamp  /**< */,
                                       xcb_timestamp_t   config_timestamp  /**< */,
                                       ushort            sizeID  /**< */,
                                       short             rotation  /**< */,
                                       ushort            rate  /**< */);


/*****************************************************************************
 **
 ** xcb_randr_set_screen_config_reply_t * xcb_randr_set_screen_config_reply
 **
 ** @param xcb_connection_t                      *c
 ** @param xcb_randr_set_screen_config_cookie_t   cookie
 ** @param xcb_generic_error_t                  **e
 ** @returns xcb_randr_set_screen_config_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_randr_set_screen_config_reply_t *
xcb_randr_set_screen_config_reply (xcb_connection_t                      *c  /**< */,
                                   xcb_randr_set_screen_config_cookie_t   cookie  /**< */,
                                   xcb_generic_error_t                  **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_randr_select_input_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @param ushort            enable
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_randr_select_input_checked (xcb_connection_t *c  /**< */,
                                xcb_window_t      window  /**< */,
                                ushort            enable  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_randr_select_input
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @param ushort            enable
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_randr_select_input (xcb_connection_t *c  /**< */,
                        xcb_window_t      window  /**< */,
                        ushort            enable  /**< */);


/*****************************************************************************
 **
 ** xcb_randr_get_screen_info_cookie_t xcb_randr_get_screen_info
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @returns xcb_randr_get_screen_info_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_randr_get_screen_info_cookie_t
xcb_randr_get_screen_info (xcb_connection_t *c  /**< */,
                           xcb_window_t      window  /**< */);


/*****************************************************************************
 **
 ** xcb_randr_get_screen_info_cookie_t xcb_randr_get_screen_info_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @returns xcb_randr_get_screen_info_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_randr_get_screen_info_cookie_t
xcb_randr_get_screen_info_unchecked (xcb_connection_t *c  /**< */,
                                     xcb_window_t      window  /**< */);


/*****************************************************************************
 **
 ** xcb_randr_screen_size_t * xcb_randr_get_screen_info_sizes
 **
 ** @param /+const+/ xcb_randr_get_screen_info_reply_t *R
 ** @returns xcb_randr_screen_size_t *
 **
 *****************************************************************************/

extern(C) xcb_randr_screen_size_t *
xcb_randr_get_screen_info_sizes (/+const+/ xcb_randr_get_screen_info_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_randr_get_screen_info_sizes_length
 **
 ** @param /+const+/ xcb_randr_get_screen_info_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_randr_get_screen_info_sizes_length (/+const+/ xcb_randr_get_screen_info_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_randr_screen_size_iterator_t xcb_randr_get_screen_info_sizes_iterator
 **
 ** @param /+const+/ xcb_randr_get_screen_info_reply_t *R
 ** @returns xcb_randr_screen_size_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_randr_screen_size_iterator_t
xcb_randr_get_screen_info_sizes_iterator (/+const+/ xcb_randr_get_screen_info_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_randr_get_screen_info_rates_length
 **
 ** @param /+const+/ xcb_randr_get_screen_info_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_randr_get_screen_info_rates_length (/+const+/ xcb_randr_get_screen_info_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_randr_refresh_rates_iterator_t xcb_randr_get_screen_info_rates_iterator
 **
 ** @param /+const+/ xcb_randr_get_screen_info_reply_t *R
 ** @returns xcb_randr_refresh_rates_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_randr_refresh_rates_iterator_t
xcb_randr_get_screen_info_rates_iterator (/+const+/ xcb_randr_get_screen_info_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_randr_get_screen_info_reply_t * xcb_randr_get_screen_info_reply
 **
 ** @param xcb_connection_t                    *c
 ** @param xcb_randr_get_screen_info_cookie_t   cookie
 ** @param xcb_generic_error_t                **e
 ** @returns xcb_randr_get_screen_info_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_randr_get_screen_info_reply_t *
xcb_randr_get_screen_info_reply (xcb_connection_t                    *c  /**< */,
                                 xcb_randr_get_screen_info_cookie_t   cookie  /**< */,
                                 xcb_generic_error_t                **e  /**< */);



/**
 * @}
 */
