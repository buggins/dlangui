/*
 * This file generated automatically from record.xml by c-client.xsl using XSLT.
 * Edit at your peril.
 */

/**
 * @defgroup XCB_Record_API XCB Record API
 * @brief Record XCB Protocol Implementation.
 * @{
 **/


module std.c.linux.X11.xcb.record;
version(USE_XCB):

import std.c.linux.X11.xcb.xcb;

const int XCB_RECORD_MAJOR_VERSION =1;
const int XCB_RECORD_MINOR_VERSION =13;
  
extern(C) extern xcb_extension_t xcb_record_id;

alias uint xcb_record_context_t;

/**
 * @brief xcb_record_context_iterator_t
 **/
struct xcb_record_context_iterator_t {
    xcb_record_context_t *data; /**<  */
    int                   rem; /**<  */
    int                   index; /**<  */
} ;

/**
 * @brief xcb_record_range_8_t
 **/
struct xcb_record_range_8_t {
    ubyte first; /**<  */
    ubyte last; /**<  */
} ;

/**
 * @brief xcb_record_range_8_iterator_t
 **/
struct xcb_record_range_8_iterator_t {
    xcb_record_range_8_t *data; /**<  */
    int                   rem; /**<  */
    int                   index; /**<  */
} ;

/**
 * @brief xcb_record_range_16_t
 **/
struct xcb_record_range_16_t {
    ushort first; /**<  */
    ushort last; /**<  */
} ;

/**
 * @brief xcb_record_range_16_iterator_t
 **/
struct xcb_record_range_16_iterator_t {
    xcb_record_range_16_t *data; /**<  */
    int                    rem; /**<  */
    int                    index; /**<  */
} ;

/**
 * @brief xcb_record_ext_range_t
 **/
struct xcb_record_ext_range_t {
    xcb_record_range_8_t  major; /**<  */
    xcb_record_range_16_t minor; /**<  */
} ;

/**
 * @brief xcb_record_ext_range_iterator_t
 **/
struct xcb_record_ext_range_iterator_t {
    xcb_record_ext_range_t *data; /**<  */
    int                     rem; /**<  */
    int                     index; /**<  */
} ;

/**
 * @brief xcb_record_range_t
 **/
struct xcb_record_range_t {
    xcb_record_range_8_t   core_requests; /**<  */
    xcb_record_range_8_t   core_replies; /**<  */
    xcb_record_ext_range_t ext_requests; /**<  */
    xcb_record_ext_range_t ext_replies; /**<  */
    xcb_record_range_8_t   delivered_events; /**<  */
    xcb_record_range_8_t   device_events; /**<  */
    xcb_record_range_8_t   errors; /**<  */
    bool                   client_started; /**<  */
    bool                   client_died; /**<  */
} ;

/**
 * @brief xcb_record_range_iterator_t
 **/
struct xcb_record_range_iterator_t {
    xcb_record_range_t *data; /**<  */
    int                 rem; /**<  */
    int                 index; /**<  */
} ;

alias ubyte xcb_record_element_header_t;

/**
 * @brief xcb_record_element_header_iterator_t
 **/
struct xcb_record_element_header_iterator_t {
    xcb_record_element_header_t *data; /**<  */
    int                          rem; /**<  */
    int                          index; /**<  */
} ;

enum :int{
    XCB_RECORD_H_TYPE_FROM_SERVER_TIME = 0x01,
    XCB_RECORD_H_TYPE_FROM_CLIENT_TIME = 0x02,
    XCB_RECORD_H_TYPE_FROM_CLIENT_SEQUENCE = 0x04
};

alias uint xcb_record_client_spec_t;

/**
 * @brief xcb_record_client_spec_iterator_t
 **/
struct xcb_record_client_spec_iterator_t {
    xcb_record_client_spec_t *data; /**<  */
    int                       rem; /**<  */
    int                       index; /**<  */
} ;

enum :int{
    XCB_RECORD_CS_CURRENT_CLIENTS = 1,
    XCB_RECORD_CS_FUTURE_CLIENTS = 2,
    XCB_RECORD_CS_ALL_CLIENTS = 3
};

/**
 * @brief xcb_record_client_info_t
 **/
struct xcb_record_client_info_t {
    xcb_record_client_spec_t client_resource; /**<  */
    uint                     num_ranges; /**<  */
} ;

/**
 * @brief xcb_record_client_info_iterator_t
 **/
struct xcb_record_client_info_iterator_t {
    xcb_record_client_info_t *data; /**<  */
    int                       rem; /**<  */
    int                       index; /**<  */
} ;

/** Opcode for xcb_record_bad_context. */
const uint XCB_RECORD_BAD_CONTEXT = 0;

/**
 * @brief xcb_record_bad_context_error_t
 **/
struct xcb_record_bad_context_error_t {
    ubyte  response_type; /**<  */
    ubyte  error_code; /**<  */
    ushort sequence; /**<  */
    uint   invalid_record; /**<  */
} ;

/**
 * @brief xcb_record_query_version_cookie_t
 **/
struct xcb_record_query_version_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_record_query_version. */
const uint XCB_RECORD_QUERY_VERSION = 0;

/**
 * @brief xcb_record_query_version_request_t
 **/
struct xcb_record_query_version_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
    ushort major_version; /**<  */
    ushort minor_version; /**<  */
} ;

/**
 * @brief xcb_record_query_version_reply_t
 **/
struct xcb_record_query_version_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ushort major_version; /**<  */
    ushort minor_version; /**<  */
} ;

/** Opcode for xcb_record_create_context. */
const uint XCB_RECORD_CREATE_CONTEXT = 1;

/**
 * @brief xcb_record_create_context_request_t
 **/
struct xcb_record_create_context_request_t {
    ubyte                       major_opcode; /**<  */
    ubyte                       minor_opcode; /**<  */
    ushort                      length; /**<  */
    xcb_record_context_t        context; /**<  */
    xcb_record_element_header_t element_header; /**<  */
    ubyte                       pad0[3]; /**<  */
    uint                        num_client_specs; /**<  */
    uint                        num_ranges; /**<  */
} ;

/** Opcode for xcb_record_register_clients. */
const uint XCB_RECORD_REGISTER_CLIENTS = 2;

/**
 * @brief xcb_record_register_clients_request_t
 **/
struct xcb_record_register_clients_request_t {
    ubyte                       major_opcode; /**<  */
    ubyte                       minor_opcode; /**<  */
    ushort                      length; /**<  */
    xcb_record_context_t        context; /**<  */
    xcb_record_element_header_t element_header; /**<  */
    ubyte                       pad0[3]; /**<  */
    uint                        num_client_specs; /**<  */
    uint                        num_ranges; /**<  */
} ;

/** Opcode for xcb_record_unregister_clients. */
const uint XCB_RECORD_UNREGISTER_CLIENTS = 3;

/**
 * @brief xcb_record_unregister_clients_request_t
 **/
struct xcb_record_unregister_clients_request_t {
    ubyte                major_opcode; /**<  */
    ubyte                minor_opcode; /**<  */
    ushort               length; /**<  */
    xcb_record_context_t context; /**<  */
    uint                 num_client_specs; /**<  */
} ;

/**
 * @brief xcb_record_get_context_cookie_t
 **/
struct xcb_record_get_context_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_record_get_context. */
const uint XCB_RECORD_GET_CONTEXT = 4;

/**
 * @brief xcb_record_get_context_request_t
 **/
struct xcb_record_get_context_request_t {
    ubyte                major_opcode; /**<  */
    ubyte                minor_opcode; /**<  */
    ushort               length; /**<  */
    xcb_record_context_t context; /**<  */
} ;

/**
 * @brief xcb_record_get_context_reply_t
 **/
struct xcb_record_get_context_reply_t {
    ubyte                       response_type; /**<  */
    bool                        enabled; /**<  */
    ushort                      sequence; /**<  */
    uint                        length; /**<  */
    xcb_record_element_header_t element_header; /**<  */
    ubyte                       pad0[3]; /**<  */
    uint                        num_intercepted_clients; /**<  */
    ubyte                       pad1[16]; /**<  */
} ;

/**
 * @brief xcb_record_enable_context_cookie_t
 **/
struct xcb_record_enable_context_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_record_enable_context. */
const uint XCB_RECORD_ENABLE_CONTEXT = 5;

/**
 * @brief xcb_record_enable_context_request_t
 **/
struct xcb_record_enable_context_request_t {
    ubyte                major_opcode; /**<  */
    ubyte                minor_opcode; /**<  */
    ushort               length; /**<  */
    xcb_record_context_t context; /**<  */
} ;

/**
 * @brief xcb_record_enable_context_reply_t
 **/
struct xcb_record_enable_context_reply_t {
    ubyte                       response_type; /**<  */
    ubyte                       category; /**<  */
    ushort                      sequence; /**<  */
    uint                        length; /**<  */
    xcb_record_element_header_t element_header; /**<  */
    bool                        client_swapped; /**<  */
    ubyte                       pad0[2]; /**<  */
    uint                        xid_base; /**<  */
    uint                        server_time; /**<  */
    uint                        rec_sequence_num; /**<  */
    ubyte                       pad1[8]; /**<  */
} ;

/** Opcode for xcb_record_disable_context. */
const uint XCB_RECORD_DISABLE_CONTEXT = 6;

/**
 * @brief xcb_record_disable_context_request_t
 **/
struct xcb_record_disable_context_request_t {
    ubyte                major_opcode; /**<  */
    ubyte                minor_opcode; /**<  */
    ushort               length; /**<  */
    xcb_record_context_t context; /**<  */
} ;

/** Opcode for xcb_record_free_context. */
const uint XCB_RECORD_FREE_CONTEXT = 7;

/**
 * @brief xcb_record_free_context_request_t
 **/
struct xcb_record_free_context_request_t {
    ubyte                major_opcode; /**<  */
    ubyte                minor_opcode; /**<  */
    ushort               length; /**<  */
    xcb_record_context_t context; /**<  */
} ;


/*****************************************************************************
 **
 ** void xcb_record_context_next
 ** 
 ** @param xcb_record_context_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/
 
extern(C) void
xcb_record_context_next (xcb_record_context_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_record_context_end
 ** 
 ** @param xcb_record_context_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/
 
extern(C) xcb_generic_iterator_t
xcb_record_context_end (xcb_record_context_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_record_range_8_next
 ** 
 ** @param xcb_record_range_8_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/
 
extern(C) void
xcb_record_range_8_next (xcb_record_range_8_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_record_range_8_end
 ** 
 ** @param xcb_record_range_8_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/
 
extern(C) xcb_generic_iterator_t
xcb_record_range_8_end (xcb_record_range_8_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_record_range_16_next
 ** 
 ** @param xcb_record_range_16_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/
 
extern(C) void
xcb_record_range_16_next (xcb_record_range_16_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_record_range_16_end
 ** 
 ** @param xcb_record_range_16_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/
 
extern(C) xcb_generic_iterator_t
xcb_record_range_16_end (xcb_record_range_16_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_record_ext_range_next
 ** 
 ** @param xcb_record_ext_range_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/
 
extern(C) void
xcb_record_ext_range_next (xcb_record_ext_range_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_record_ext_range_end
 ** 
 ** @param xcb_record_ext_range_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/
 
extern(C) xcb_generic_iterator_t
xcb_record_ext_range_end (xcb_record_ext_range_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_record_range_next
 ** 
 ** @param xcb_record_range_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/
 
extern(C) void
xcb_record_range_next (xcb_record_range_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_record_range_end
 ** 
 ** @param xcb_record_range_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/
 
extern(C) xcb_generic_iterator_t
xcb_record_range_end (xcb_record_range_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_record_element_header_next
 ** 
 ** @param xcb_record_element_header_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/
 
extern(C) void
xcb_record_element_header_next (xcb_record_element_header_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_record_element_header_end
 ** 
 ** @param xcb_record_element_header_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/
 
extern(C) xcb_generic_iterator_t
xcb_record_element_header_end (xcb_record_element_header_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_record_client_spec_next
 ** 
 ** @param xcb_record_client_spec_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/
 
extern(C) void
xcb_record_client_spec_next (xcb_record_client_spec_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_record_client_spec_end
 ** 
 ** @param xcb_record_client_spec_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/
 
extern(C) xcb_generic_iterator_t
xcb_record_client_spec_end (xcb_record_client_spec_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** xcb_record_range_t * xcb_record_client_info_ranges
 ** 
 ** @param /+const+/ xcb_record_client_info_t *R
 ** @returns xcb_record_range_t *
 **
 *****************************************************************************/
 
extern(C) xcb_record_range_t *
xcb_record_client_info_ranges (/+const+/ xcb_record_client_info_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_record_client_info_ranges_length
 ** 
 ** @param /+const+/ xcb_record_client_info_t *R
 ** @returns int
 **
 *****************************************************************************/
 
extern(C) int
xcb_record_client_info_ranges_length (/+const+/ xcb_record_client_info_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_record_range_iterator_t xcb_record_client_info_ranges_iterator
 ** 
 ** @param /+const+/ xcb_record_client_info_t *R
 ** @returns xcb_record_range_iterator_t
 **
 *****************************************************************************/
 
extern(C) xcb_record_range_iterator_t
xcb_record_client_info_ranges_iterator (/+const+/ xcb_record_client_info_t *R  /**< */);


/*****************************************************************************
 **
 ** void xcb_record_client_info_next
 ** 
 ** @param xcb_record_client_info_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/
 
extern(C) void
xcb_record_client_info_next (xcb_record_client_info_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_record_client_info_end
 ** 
 ** @param xcb_record_client_info_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/
 
extern(C) xcb_generic_iterator_t
xcb_record_client_info_end (xcb_record_client_info_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** xcb_record_query_version_cookie_t xcb_record_query_version
 ** 
 ** @param xcb_connection_t *c
 ** @param ushort            major_version
 ** @param ushort            minor_version
 ** @returns xcb_record_query_version_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_record_query_version_cookie_t
xcb_record_query_version (xcb_connection_t *c  /**< */,
                          ushort            major_version  /**< */,
                          ushort            minor_version  /**< */);


/*****************************************************************************
 **
 ** xcb_record_query_version_cookie_t xcb_record_query_version_unchecked
 ** 
 ** @param xcb_connection_t *c
 ** @param ushort            major_version
 ** @param ushort            minor_version
 ** @returns xcb_record_query_version_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_record_query_version_cookie_t
xcb_record_query_version_unchecked (xcb_connection_t *c  /**< */,
                                    ushort            major_version  /**< */,
                                    ushort            minor_version  /**< */);


/*****************************************************************************
 **
 ** xcb_record_query_version_reply_t * xcb_record_query_version_reply
 ** 
 ** @param xcb_connection_t                   *c
 ** @param xcb_record_query_version_cookie_t   cookie
 ** @param xcb_generic_error_t               **e
 ** @returns xcb_record_query_version_reply_t *
 **
 *****************************************************************************/
 
extern(C) xcb_record_query_version_reply_t *
xcb_record_query_version_reply (xcb_connection_t                   *c  /**< */,
                                xcb_record_query_version_cookie_t   cookie  /**< */,
                                xcb_generic_error_t               **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_record_create_context_checked
 ** 
 ** @param xcb_connection_t                   *c
 ** @param xcb_record_context_t                context
 ** @param xcb_record_element_header_t         element_header
 ** @param uint                                num_client_specs
 ** @param uint                                num_ranges
 ** @param /+const+/ xcb_record_client_spec_t *client_specs
 ** @param /+const+/ xcb_record_range_t       *ranges
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_void_cookie_t
xcb_record_create_context_checked (xcb_connection_t                   *c  /**< */,
                                   xcb_record_context_t                context  /**< */,
                                   xcb_record_element_header_t         element_header  /**< */,
                                   uint                                num_client_specs  /**< */,
                                   uint                                num_ranges  /**< */,
                                   /+const+/ xcb_record_client_spec_t *client_specs  /**< */,
                                   /+const+/ xcb_record_range_t       *ranges  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_record_create_context
 ** 
 ** @param xcb_connection_t                   *c
 ** @param xcb_record_context_t                context
 ** @param xcb_record_element_header_t         element_header
 ** @param uint                                num_client_specs
 ** @param uint                                num_ranges
 ** @param /+const+/ xcb_record_client_spec_t *client_specs
 ** @param /+const+/ xcb_record_range_t       *ranges
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_void_cookie_t
xcb_record_create_context (xcb_connection_t                   *c  /**< */,
                           xcb_record_context_t                context  /**< */,
                           xcb_record_element_header_t         element_header  /**< */,
                           uint                                num_client_specs  /**< */,
                           uint                                num_ranges  /**< */,
                           /+const+/ xcb_record_client_spec_t *client_specs  /**< */,
                           /+const+/ xcb_record_range_t       *ranges  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_record_register_clients_checked
 ** 
 ** @param xcb_connection_t                   *c
 ** @param xcb_record_context_t                context
 ** @param xcb_record_element_header_t         element_header
 ** @param uint                                num_client_specs
 ** @param uint                                num_ranges
 ** @param /+const+/ xcb_record_client_spec_t *client_specs
 ** @param /+const+/ xcb_record_range_t       *ranges
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_void_cookie_t
xcb_record_register_clients_checked (xcb_connection_t                   *c  /**< */,
                                     xcb_record_context_t                context  /**< */,
                                     xcb_record_element_header_t         element_header  /**< */,
                                     uint                                num_client_specs  /**< */,
                                     uint                                num_ranges  /**< */,
                                     /+const+/ xcb_record_client_spec_t *client_specs  /**< */,
                                     /+const+/ xcb_record_range_t       *ranges  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_record_register_clients
 ** 
 ** @param xcb_connection_t                   *c
 ** @param xcb_record_context_t                context
 ** @param xcb_record_element_header_t         element_header
 ** @param uint                                num_client_specs
 ** @param uint                                num_ranges
 ** @param /+const+/ xcb_record_client_spec_t *client_specs
 ** @param /+const+/ xcb_record_range_t       *ranges
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_void_cookie_t
xcb_record_register_clients (xcb_connection_t                   *c  /**< */,
                             xcb_record_context_t                context  /**< */,
                             xcb_record_element_header_t         element_header  /**< */,
                             uint                                num_client_specs  /**< */,
                             uint                                num_ranges  /**< */,
                             /+const+/ xcb_record_client_spec_t *client_specs  /**< */,
                             /+const+/ xcb_record_range_t       *ranges  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_record_unregister_clients_checked
 ** 
 ** @param xcb_connection_t                   *c
 ** @param xcb_record_context_t                context
 ** @param uint                                num_client_specs
 ** @param /+const+/ xcb_record_client_spec_t *client_specs
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_void_cookie_t
xcb_record_unregister_clients_checked (xcb_connection_t                   *c  /**< */,
                                       xcb_record_context_t                context  /**< */,
                                       uint                                num_client_specs  /**< */,
                                       /+const+/ xcb_record_client_spec_t *client_specs  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_record_unregister_clients
 ** 
 ** @param xcb_connection_t                   *c
 ** @param xcb_record_context_t                context
 ** @param uint                                num_client_specs
 ** @param /+const+/ xcb_record_client_spec_t *client_specs
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_void_cookie_t
xcb_record_unregister_clients (xcb_connection_t                   *c  /**< */,
                               xcb_record_context_t                context  /**< */,
                               uint                                num_client_specs  /**< */,
                               /+const+/ xcb_record_client_spec_t *client_specs  /**< */);


/*****************************************************************************
 **
 ** xcb_record_get_context_cookie_t xcb_record_get_context
 ** 
 ** @param xcb_connection_t     *c
 ** @param xcb_record_context_t  context
 ** @returns xcb_record_get_context_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_record_get_context_cookie_t
xcb_record_get_context (xcb_connection_t     *c  /**< */,
                        xcb_record_context_t  context  /**< */);


/*****************************************************************************
 **
 ** xcb_record_get_context_cookie_t xcb_record_get_context_unchecked
 ** 
 ** @param xcb_connection_t     *c
 ** @param xcb_record_context_t  context
 ** @returns xcb_record_get_context_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_record_get_context_cookie_t
xcb_record_get_context_unchecked (xcb_connection_t     *c  /**< */,
                                  xcb_record_context_t  context  /**< */);


/*****************************************************************************
 **
 ** int xcb_record_get_context_intercepted_clients_length
 ** 
 ** @param /+const+/ xcb_record_get_context_reply_t *R
 ** @returns int
 **
 *****************************************************************************/
 
extern(C) int
xcb_record_get_context_intercepted_clients_length (/+const+/ xcb_record_get_context_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_record_client_info_iterator_t xcb_record_get_context_intercepted_clients_iterator
 ** 
 ** @param /+const+/ xcb_record_get_context_reply_t *R
 ** @returns xcb_record_client_info_iterator_t
 **
 *****************************************************************************/
 
extern(C) xcb_record_client_info_iterator_t
xcb_record_get_context_intercepted_clients_iterator (/+const+/ xcb_record_get_context_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_record_get_context_reply_t * xcb_record_get_context_reply
 ** 
 ** @param xcb_connection_t                 *c
 ** @param xcb_record_get_context_cookie_t   cookie
 ** @param xcb_generic_error_t             **e
 ** @returns xcb_record_get_context_reply_t *
 **
 *****************************************************************************/
 
extern(C) xcb_record_get_context_reply_t *
xcb_record_get_context_reply (xcb_connection_t                 *c  /**< */,
                              xcb_record_get_context_cookie_t   cookie  /**< */,
                              xcb_generic_error_t             **e  /**< */);


/*****************************************************************************
 **
 ** xcb_record_enable_context_cookie_t xcb_record_enable_context
 ** 
 ** @param xcb_connection_t     *c
 ** @param xcb_record_context_t  context
 ** @returns xcb_record_enable_context_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_record_enable_context_cookie_t
xcb_record_enable_context (xcb_connection_t     *c  /**< */,
                           xcb_record_context_t  context  /**< */);


/*****************************************************************************
 **
 ** xcb_record_enable_context_cookie_t xcb_record_enable_context_unchecked
 ** 
 ** @param xcb_connection_t     *c
 ** @param xcb_record_context_t  context
 ** @returns xcb_record_enable_context_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_record_enable_context_cookie_t
xcb_record_enable_context_unchecked (xcb_connection_t     *c  /**< */,
                                     xcb_record_context_t  context  /**< */);


/*****************************************************************************
 **
 ** ubyte * xcb_record_enable_context_data
 ** 
 ** @param /+const+/ xcb_record_enable_context_reply_t *R
 ** @returns ubyte *
 **
 *****************************************************************************/
 
extern(C) ubyte *
xcb_record_enable_context_data (/+const+/ xcb_record_enable_context_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_record_enable_context_data_length
 ** 
 ** @param /+const+/ xcb_record_enable_context_reply_t *R
 ** @returns int
 **
 *****************************************************************************/
 
extern(C) int
xcb_record_enable_context_data_length (/+const+/ xcb_record_enable_context_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_record_enable_context_data_end
 ** 
 ** @param /+const+/ xcb_record_enable_context_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/
 
extern(C) xcb_generic_iterator_t
xcb_record_enable_context_data_end (/+const+/ xcb_record_enable_context_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_record_enable_context_reply_t * xcb_record_enable_context_reply
 ** 
 ** @param xcb_connection_t                    *c
 ** @param xcb_record_enable_context_cookie_t   cookie
 ** @param xcb_generic_error_t                **e
 ** @returns xcb_record_enable_context_reply_t *
 **
 *****************************************************************************/
 
extern(C) xcb_record_enable_context_reply_t *
xcb_record_enable_context_reply (xcb_connection_t                    *c  /**< */,
                                 xcb_record_enable_context_cookie_t   cookie  /**< */,
                                 xcb_generic_error_t                **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_record_disable_context_checked
 ** 
 ** @param xcb_connection_t     *c
 ** @param xcb_record_context_t  context
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_void_cookie_t
xcb_record_disable_context_checked (xcb_connection_t     *c  /**< */,
                                    xcb_record_context_t  context  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_record_disable_context
 ** 
 ** @param xcb_connection_t     *c
 ** @param xcb_record_context_t  context
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_void_cookie_t
xcb_record_disable_context (xcb_connection_t     *c  /**< */,
                            xcb_record_context_t  context  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_record_free_context_checked
 ** 
 ** @param xcb_connection_t     *c
 ** @param xcb_record_context_t  context
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_void_cookie_t
xcb_record_free_context_checked (xcb_connection_t     *c  /**< */,
                                 xcb_record_context_t  context  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_record_free_context
 ** 
 ** @param xcb_connection_t     *c
 ** @param xcb_record_context_t  context
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_void_cookie_t
xcb_record_free_context (xcb_connection_t     *c  /**< */,
                         xcb_record_context_t  context  /**< */);



/**
 * @}
 */
