/*
 * This file generated automatically from xevie.xml by c-client.xsl using XSLT.
 * Edit at your peril.
 */

/**
 * @defgroup XCB_Xevie_API XCB Xevie API
 * @brief Xevie XCB Protocol Implementation.
 * @{
 **/


module std.c.linux.X11.xcb.xevie;
version(USE_XCB):

import std.c.linux.X11.xcb.xcb;

const int XCB_XEVIE_MAJOR_VERSION =1;
const int XCB_XEVIE_MINOR_VERSION =0;

extern(C) extern xcb_extension_t xcb_xevie_id;

/**
 * @brief xcb_xevie_query_version_cookie_t
 **/
struct xcb_xevie_query_version_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_xevie_query_version. */
const uint XCB_XEVIE_QUERY_VERSION = 0;

/**
 * @brief xcb_xevie_query_version_request_t
 **/
struct xcb_xevie_query_version_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
    ushort client_major_version; /**<  */
    ushort client_minor_version; /**<  */
} ;

/**
 * @brief xcb_xevie_query_version_reply_t
 **/
struct xcb_xevie_query_version_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ushort server_major_version; /**<  */
    ushort server_minor_version; /**<  */
    ubyte  pad1[20]; /**<  */
} ;

/**
 * @brief xcb_xevie_start_cookie_t
 **/
struct xcb_xevie_start_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_xevie_start. */
const uint XCB_XEVIE_START = 1;

/**
 * @brief xcb_xevie_start_request_t
 **/
struct xcb_xevie_start_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
    uint   screen; /**<  */
} ;

/**
 * @brief xcb_xevie_start_reply_t
 **/
struct xcb_xevie_start_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ubyte  pad1[24]; /**<  */
} ;

/**
 * @brief xcb_xevie_end_cookie_t
 **/
struct xcb_xevie_end_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_xevie_end. */
const uint XCB_XEVIE_END = 2;

/**
 * @brief xcb_xevie_end_request_t
 **/
struct xcb_xevie_end_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
    uint   cmap; /**<  */
} ;

/**
 * @brief xcb_xevie_end_reply_t
 **/
struct xcb_xevie_end_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ubyte  pad1[24]; /**<  */
} ;

enum :int{
    XCB_XEVIE_DATATYPE_UNMODIFIED,
    XCB_XEVIE_DATATYPE_MODIFIED
};

/**
 * @brief xcb_xevie_event_t
 **/
struct xcb_xevie_event_t {
    ubyte pad0[32]; /**<  */
} ;

/**
 * @brief xcb_xevie_event_iterator_t
 **/
struct xcb_xevie_event_iterator_t {
    xcb_xevie_event_t *data; /**<  */
    int                rem; /**<  */
    int                index; /**<  */
} ;

/**
 * @brief xcb_xevie_send_cookie_t
 **/
struct xcb_xevie_send_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_xevie_send. */
const uint XCB_XEVIE_SEND = 3;

/**
 * @brief xcb_xevie_send_request_t
 **/
struct xcb_xevie_send_request_t {
    ubyte             major_opcode; /**<  */
    ubyte             minor_opcode; /**<  */
    ushort            length; /**<  */
    xcb_xevie_event_t event; /**<  */
    uint              data_type; /**<  */
    ubyte             pad0[64]; /**<  */
} ;

/**
 * @brief xcb_xevie_send_reply_t
 **/
struct xcb_xevie_send_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ubyte  pad1[24]; /**<  */
} ;

/**
 * @brief xcb_xevie_select_input_cookie_t
 **/
struct xcb_xevie_select_input_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_xevie_select_input. */
const uint XCB_XEVIE_SELECT_INPUT = 4;

/**
 * @brief xcb_xevie_select_input_request_t
 **/
struct xcb_xevie_select_input_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
    uint   event_mask; /**<  */
} ;

/**
 * @brief xcb_xevie_select_input_reply_t
 **/
struct xcb_xevie_select_input_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ubyte  pad1[24]; /**<  */
} ;


/*****************************************************************************
 **
 ** xcb_xevie_query_version_cookie_t xcb_xevie_query_version
 **
 ** @param xcb_connection_t *c
 ** @param ushort            client_major_version
 ** @param ushort            client_minor_version
 ** @returns xcb_xevie_query_version_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_xevie_query_version_cookie_t
xcb_xevie_query_version (xcb_connection_t *c  /**< */,
                         ushort            client_major_version  /**< */,
                         ushort            client_minor_version  /**< */);


/*****************************************************************************
 **
 ** xcb_xevie_query_version_cookie_t xcb_xevie_query_version_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param ushort            client_major_version
 ** @param ushort            client_minor_version
 ** @returns xcb_xevie_query_version_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_xevie_query_version_cookie_t
xcb_xevie_query_version_unchecked (xcb_connection_t *c  /**< */,
                                   ushort            client_major_version  /**< */,
                                   ushort            client_minor_version  /**< */);


/*****************************************************************************
 **
 ** xcb_xevie_query_version_reply_t * xcb_xevie_query_version_reply
 **
 ** @param xcb_connection_t                  *c
 ** @param xcb_xevie_query_version_cookie_t   cookie
 ** @param xcb_generic_error_t              **e
 ** @returns xcb_xevie_query_version_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_xevie_query_version_reply_t *
xcb_xevie_query_version_reply (xcb_connection_t                  *c  /**< */,
                               xcb_xevie_query_version_cookie_t   cookie  /**< */,
                               xcb_generic_error_t              **e  /**< */);


/*****************************************************************************
 **
 ** xcb_xevie_start_cookie_t xcb_xevie_start
 **
 ** @param xcb_connection_t *c
 ** @param uint              screen
 ** @returns xcb_xevie_start_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_xevie_start_cookie_t
xcb_xevie_start (xcb_connection_t *c  /**< */,
                 uint              screen  /**< */);


/*****************************************************************************
 **
 ** xcb_xevie_start_cookie_t xcb_xevie_start_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param uint              screen
 ** @returns xcb_xevie_start_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_xevie_start_cookie_t
xcb_xevie_start_unchecked (xcb_connection_t *c  /**< */,
                           uint              screen  /**< */);


/*****************************************************************************
 **
 ** xcb_xevie_start_reply_t * xcb_xevie_start_reply
 **
 ** @param xcb_connection_t          *c
 ** @param xcb_xevie_start_cookie_t   cookie
 ** @param xcb_generic_error_t      **e
 ** @returns xcb_xevie_start_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_xevie_start_reply_t *
xcb_xevie_start_reply (xcb_connection_t          *c  /**< */,
                       xcb_xevie_start_cookie_t   cookie  /**< */,
                       xcb_generic_error_t      **e  /**< */);


/*****************************************************************************
 **
 ** xcb_xevie_end_cookie_t xcb_xevie_end
 **
 ** @param xcb_connection_t *c
 ** @param uint              cmap
 ** @returns xcb_xevie_end_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_xevie_end_cookie_t
xcb_xevie_end (xcb_connection_t *c  /**< */,
               uint              cmap  /**< */);


/*****************************************************************************
 **
 ** xcb_xevie_end_cookie_t xcb_xevie_end_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param uint              cmap
 ** @returns xcb_xevie_end_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_xevie_end_cookie_t
xcb_xevie_end_unchecked (xcb_connection_t *c  /**< */,
                         uint              cmap  /**< */);


/*****************************************************************************
 **
 ** xcb_xevie_end_reply_t * xcb_xevie_end_reply
 **
 ** @param xcb_connection_t        *c
 ** @param xcb_xevie_end_cookie_t   cookie
 ** @param xcb_generic_error_t    **e
 ** @returns xcb_xevie_end_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_xevie_end_reply_t *
xcb_xevie_end_reply (xcb_connection_t        *c  /**< */,
                     xcb_xevie_end_cookie_t   cookie  /**< */,
                     xcb_generic_error_t    **e  /**< */);


/*****************************************************************************
 **
 ** void xcb_xevie_event_next
 **
 ** @param xcb_xevie_event_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_xevie_event_next (xcb_xevie_event_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_xevie_event_end
 **
 ** @param xcb_xevie_event_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_xevie_event_end (xcb_xevie_event_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** xcb_xevie_send_cookie_t xcb_xevie_send
 **
 ** @param xcb_connection_t  *c
 ** @param xcb_xevie_event_t  event
 ** @param uint               data_type
 ** @returns xcb_xevie_send_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_xevie_send_cookie_t
xcb_xevie_send (xcb_connection_t  *c  /**< */,
                xcb_xevie_event_t  event  /**< */,
                uint               data_type  /**< */);


/*****************************************************************************
 **
 ** xcb_xevie_send_cookie_t xcb_xevie_send_unchecked
 **
 ** @param xcb_connection_t  *c
 ** @param xcb_xevie_event_t  event
 ** @param uint               data_type
 ** @returns xcb_xevie_send_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_xevie_send_cookie_t
xcb_xevie_send_unchecked (xcb_connection_t  *c  /**< */,
                          xcb_xevie_event_t  event  /**< */,
                          uint               data_type  /**< */);


/*****************************************************************************
 **
 ** xcb_xevie_send_reply_t * xcb_xevie_send_reply
 **
 ** @param xcb_connection_t         *c
 ** @param xcb_xevie_send_cookie_t   cookie
 ** @param xcb_generic_error_t     **e
 ** @returns xcb_xevie_send_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_xevie_send_reply_t *
xcb_xevie_send_reply (xcb_connection_t         *c  /**< */,
                      xcb_xevie_send_cookie_t   cookie  /**< */,
                      xcb_generic_error_t     **e  /**< */);


/*****************************************************************************
 **
 ** xcb_xevie_select_input_cookie_t xcb_xevie_select_input
 **
 ** @param xcb_connection_t *c
 ** @param uint              event_mask
 ** @returns xcb_xevie_select_input_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_xevie_select_input_cookie_t
xcb_xevie_select_input (xcb_connection_t *c  /**< */,
                        uint              event_mask  /**< */);


/*****************************************************************************
 **
 ** xcb_xevie_select_input_cookie_t xcb_xevie_select_input_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param uint              event_mask
 ** @returns xcb_xevie_select_input_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_xevie_select_input_cookie_t
xcb_xevie_select_input_unchecked (xcb_connection_t *c  /**< */,
                                  uint              event_mask  /**< */);


/*****************************************************************************
 **
 ** xcb_xevie_select_input_reply_t * xcb_xevie_select_input_reply
 **
 ** @param xcb_connection_t                 *c
 ** @param xcb_xevie_select_input_cookie_t   cookie
 ** @param xcb_generic_error_t             **e
 ** @returns xcb_xevie_select_input_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_xevie_select_input_reply_t *
xcb_xevie_select_input_reply (xcb_connection_t                 *c  /**< */,
                              xcb_xevie_select_input_cookie_t   cookie  /**< */,
                              xcb_generic_error_t             **e  /**< */);



/**
 * @}
 */
