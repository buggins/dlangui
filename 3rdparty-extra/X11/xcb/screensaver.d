/*
 * This file generated automatically from screensaver.xml by c-client.xsl using XSLT.
 * Edit at your peril.
 */

/**
 * @defgroup XCB_ScreenSaver_API XCB ScreenSaver API
 * @brief ScreenSaver XCB Protocol Implementation.
 * @{
 **/


module std.c.linux.X11.xcb.screensaver;
version(USE_XCB):

import std.c.linux.X11.xcb.xcb;
import std.c.linux.X11.xcb.xproto;

const int XCB_SCREENSAVER_MAJOR_VERSION =1;
const int XCB_SCREENSAVER_MINOR_VERSION =1;

extern(C) extern xcb_extension_t xcb_screensaver_id;

enum :int{
    XCB_SCREENSAVER_KIND_BLANKED,
    XCB_SCREENSAVER_KIND_INTERNAL,
    XCB_SCREENSAVER_KIND_EXTERNAL
};

enum :int{
    XCB_SCREENSAVER_EVENT_NOTIFY_MASK = (1 << 0),
    XCB_SCREENSAVER_EVENT_CYCLE_MASK = (1 << 1)
};

enum :int{
    XCB_SCREENSAVER_STATE_OFF,
    XCB_SCREENSAVER_STATE_ON,
    XCB_SCREENSAVER_STATE_CYCLE,
    XCB_SCREENSAVER_STATE_DISABLED
};

/**
 * @brief xcb_screensaver_query_version_cookie_t
 **/
struct xcb_screensaver_query_version_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_screensaver_query_version. */
const uint XCB_SCREENSAVER_QUERY_VERSION = 0;

/**
 * @brief xcb_screensaver_query_version_request_t
 **/
struct xcb_screensaver_query_version_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
    ubyte  client_major_version; /**<  */
    ubyte  client_minor_version; /**<  */
    ubyte  pad0[2]; /**<  */
} ;

/**
 * @brief xcb_screensaver_query_version_reply_t
 **/
struct xcb_screensaver_query_version_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ushort server_major_version; /**<  */
    ushort server_minor_version; /**<  */
    ubyte  pad1[20]; /**<  */
} ;

/**
 * @brief xcb_screensaver_query_info_cookie_t
 **/
struct xcb_screensaver_query_info_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_screensaver_query_info. */
const uint XCB_SCREENSAVER_QUERY_INFO = 1;

/**
 * @brief xcb_screensaver_query_info_request_t
 **/
struct xcb_screensaver_query_info_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          minor_opcode; /**<  */
    ushort         length; /**<  */
    xcb_drawable_t drawable; /**<  */
} ;

/**
 * @brief xcb_screensaver_query_info_reply_t
 **/
struct xcb_screensaver_query_info_reply_t {
    ubyte        response_type; /**<  */
    ubyte        state; /**<  */
    ushort       sequence; /**<  */
    uint         length; /**<  */
    xcb_window_t saver_window; /**<  */
    uint         ms_until_server; /**<  */
    uint         ms_since_user_input; /**<  */
    uint         event_mask; /**<  */
    ubyte        kind; /**<  */
    ubyte        pad0[7]; /**<  */
} ;

/** Opcode for xcb_screensaver_select_input. */
const uint XCB_SCREENSAVER_SELECT_INPUT = 2;

/**
 * @brief xcb_screensaver_select_input_request_t
 **/
struct xcb_screensaver_select_input_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          minor_opcode; /**<  */
    ushort         length; /**<  */
    xcb_drawable_t drawable; /**<  */
    uint           event_mask; /**<  */
} ;

/** Opcode for xcb_screensaver_set_attributes. */
const uint XCB_SCREENSAVER_SET_ATTRIBUTES = 3;

/**
 * @brief xcb_screensaver_set_attributes_request_t
 **/
struct xcb_screensaver_set_attributes_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          minor_opcode; /**<  */
    ushort         length; /**<  */
    xcb_drawable_t drawable; /**<  */
    short          x; /**<  */
    short          y; /**<  */
    ushort         width; /**<  */
    ushort         height; /**<  */
    ushort         border_width; /**<  */
    ubyte          _class; /**<  */
    ubyte          depth; /**<  */
    xcb_visualid_t visual; /**<  */
    uint           value_mask; /**<  */
} ;

/** Opcode for xcb_screensaver_unset_attributes. */
const uint XCB_SCREENSAVER_UNSET_ATTRIBUTES = 4;

/**
 * @brief xcb_screensaver_unset_attributes_request_t
 **/
struct xcb_screensaver_unset_attributes_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          minor_opcode; /**<  */
    ushort         length; /**<  */
    xcb_drawable_t drawable; /**<  */
} ;

/** Opcode for xcb_screensaver_suspend. */
const uint XCB_SCREENSAVER_SUSPEND = 5;

/**
 * @brief xcb_screensaver_suspend_request_t
 **/
struct xcb_screensaver_suspend_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
    bool   suspend; /**<  */
    ubyte  pad0[3]; /**<  */
} ;

/** Opcode for xcb_screensaver_notify. */
const uint XCB_SCREENSAVER_NOTIFY = 0;

/**
 * @brief xcb_screensaver_notify_event_t
 **/
struct xcb_screensaver_notify_event_t {
    ubyte           response_type; /**<  */
    ubyte           code; /**<  */
    ushort          sequence; /**<  */
    ubyte           state; /**<  */
    ushort          sequence_number; /**<  */
    xcb_timestamp_t time; /**<  */
    xcb_window_t    root; /**<  */
    xcb_window_t    window; /**<  */
    ubyte           kind; /**<  */
    bool            forced; /**<  */
    ubyte           pad0[14]; /**<  */
} ;


/*****************************************************************************
 **
 ** xcb_screensaver_query_version_cookie_t xcb_screensaver_query_version
 **
 ** @param xcb_connection_t *c
 ** @param ubyte             client_major_version
 ** @param ubyte             client_minor_version
 ** @returns xcb_screensaver_query_version_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_screensaver_query_version_cookie_t
xcb_screensaver_query_version (xcb_connection_t *c  /**< */,
                               ubyte             client_major_version  /**< */,
                               ubyte             client_minor_version  /**< */);


/*****************************************************************************
 **
 ** xcb_screensaver_query_version_cookie_t xcb_screensaver_query_version_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param ubyte             client_major_version
 ** @param ubyte             client_minor_version
 ** @returns xcb_screensaver_query_version_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_screensaver_query_version_cookie_t
xcb_screensaver_query_version_unchecked (xcb_connection_t *c  /**< */,
                                         ubyte             client_major_version  /**< */,
                                         ubyte             client_minor_version  /**< */);


/*****************************************************************************
 **
 ** xcb_screensaver_query_version_reply_t * xcb_screensaver_query_version_reply
 **
 ** @param xcb_connection_t                        *c
 ** @param xcb_screensaver_query_version_cookie_t   cookie
 ** @param xcb_generic_error_t                    **e
 ** @returns xcb_screensaver_query_version_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_screensaver_query_version_reply_t *
xcb_screensaver_query_version_reply (xcb_connection_t                        *c  /**< */,
                                     xcb_screensaver_query_version_cookie_t   cookie  /**< */,
                                     xcb_generic_error_t                    **e  /**< */);


/*****************************************************************************
 **
 ** xcb_screensaver_query_info_cookie_t xcb_screensaver_query_info
 **
 ** @param xcb_connection_t *c
 ** @param xcb_drawable_t    drawable
 ** @returns xcb_screensaver_query_info_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_screensaver_query_info_cookie_t
xcb_screensaver_query_info (xcb_connection_t *c  /**< */,
                            xcb_drawable_t    drawable  /**< */);


/*****************************************************************************
 **
 ** xcb_screensaver_query_info_cookie_t xcb_screensaver_query_info_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_drawable_t    drawable
 ** @returns xcb_screensaver_query_info_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_screensaver_query_info_cookie_t
xcb_screensaver_query_info_unchecked (xcb_connection_t *c  /**< */,
                                      xcb_drawable_t    drawable  /**< */);


/*****************************************************************************
 **
 ** xcb_screensaver_query_info_reply_t * xcb_screensaver_query_info_reply
 **
 ** @param xcb_connection_t                     *c
 ** @param xcb_screensaver_query_info_cookie_t   cookie
 ** @param xcb_generic_error_t                 **e
 ** @returns xcb_screensaver_query_info_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_screensaver_query_info_reply_t *
xcb_screensaver_query_info_reply (xcb_connection_t                     *c  /**< */,
                                  xcb_screensaver_query_info_cookie_t   cookie  /**< */,
                                  xcb_generic_error_t                 **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_screensaver_select_input_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_drawable_t    drawable
 ** @param uint              event_mask
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_screensaver_select_input_checked (xcb_connection_t *c  /**< */,
                                      xcb_drawable_t    drawable  /**< */,
                                      uint              event_mask  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_screensaver_select_input
 **
 ** @param xcb_connection_t *c
 ** @param xcb_drawable_t    drawable
 ** @param uint              event_mask
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_screensaver_select_input (xcb_connection_t *c  /**< */,
                              xcb_drawable_t    drawable  /**< */,
                              uint              event_mask  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_screensaver_set_attributes_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_drawable_t    drawable
 ** @param short             x
 ** @param short             y
 ** @param ushort            width
 ** @param ushort            height
 ** @param ushort            border_width
 ** @param ubyte             _class
 ** @param ubyte             depth
 ** @param xcb_visualid_t    visual
 ** @param uint              value_mask
 ** @param /+const+/ uint   *value_list
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_screensaver_set_attributes_checked (xcb_connection_t *c  /**< */,
                                        xcb_drawable_t    drawable  /**< */,
                                        short             x  /**< */,
                                        short             y  /**< */,
                                        ushort            width  /**< */,
                                        ushort            height  /**< */,
                                        ushort            border_width  /**< */,
                                        ubyte             _class  /**< */,
                                        ubyte             depth  /**< */,
                                        xcb_visualid_t    visual  /**< */,
                                        uint              value_mask  /**< */,
                                        /+const+/ uint   *value_list  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_screensaver_set_attributes
 **
 ** @param xcb_connection_t *c
 ** @param xcb_drawable_t    drawable
 ** @param short             x
 ** @param short             y
 ** @param ushort            width
 ** @param ushort            height
 ** @param ushort            border_width
 ** @param ubyte             _class
 ** @param ubyte             depth
 ** @param xcb_visualid_t    visual
 ** @param uint              value_mask
 ** @param /+const+/ uint   *value_list
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_screensaver_set_attributes (xcb_connection_t *c  /**< */,
                                xcb_drawable_t    drawable  /**< */,
                                short             x  /**< */,
                                short             y  /**< */,
                                ushort            width  /**< */,
                                ushort            height  /**< */,
                                ushort            border_width  /**< */,
                                ubyte             _class  /**< */,
                                ubyte             depth  /**< */,
                                xcb_visualid_t    visual  /**< */,
                                uint              value_mask  /**< */,
                                /+const+/ uint   *value_list  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_screensaver_unset_attributes_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_drawable_t    drawable
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_screensaver_unset_attributes_checked (xcb_connection_t *c  /**< */,
                                          xcb_drawable_t    drawable  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_screensaver_unset_attributes
 **
 ** @param xcb_connection_t *c
 ** @param xcb_drawable_t    drawable
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_screensaver_unset_attributes (xcb_connection_t *c  /**< */,
                                  xcb_drawable_t    drawable  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_screensaver_suspend_checked
 **
 ** @param xcb_connection_t *c
 ** @param bool              suspend
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_screensaver_suspend_checked (xcb_connection_t *c  /**< */,
                                 bool              suspend  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_screensaver_suspend
 **
 ** @param xcb_connection_t *c
 ** @param bool              suspend
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_screensaver_suspend (xcb_connection_t *c  /**< */,
                         bool              suspend  /**< */);



/**
 * @}
 */
