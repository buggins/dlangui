/*
 * This file generated automatically from xprint.xml by c-client.xsl using XSLT.
 * Edit at your peril.
 */

/**
 * @defgroup XCB_XPrint_API XCB XPrint API
 * @brief XPrint XCB Protocol Implementation.
 * @{
 **/


module std.c.linux.X11.xcb.xprint;

import std.c.linux.X11.xcb.xcb;
import std.c.linux.X11.xcb.xproto;

const int XCB_XPRINT_MAJOR_VERSION =1;
const int XCB_XPRINT_MINOR_VERSION =0;
  
extern(C) extern xcb_extension_t xcb_x_print_id;

/**
 * @brief xcb_x_print_printer_t
 **/
struct xcb_x_print_printer_t {
    uint nameLen; /**<  */
    uint descLen; /**<  */
} ;

/**
 * @brief xcb_x_print_printer_iterator_t
 **/
struct xcb_x_print_printer_iterator_t {
    xcb_x_print_printer_t *data; /**<  */
    int                    rem; /**<  */
    int                    index; /**<  */
} ;

alias uint xcb_x_print_pcontext_t;

/**
 * @brief xcb_x_print_pcontext_iterator_t
 **/
struct xcb_x_print_pcontext_iterator_t {
    xcb_x_print_pcontext_t *data; /**<  */
    int                     rem; /**<  */
    int                     index; /**<  */
} ;

alias char xcb_x_print_string8_t;

/**
 * @brief xcb_x_print_string8_iterator_t
 **/
struct xcb_x_print_string8_iterator_t {
    xcb_x_print_string8_t *data; /**<  */
    int                    rem; /**<  */
    int                    index; /**<  */
} ;

enum :int{
    XCB_X_PRINT_GET_DOC_FINISHED = 0,
    XCB_X_PRINT_GET_DOC_SECOND_CONSUMER = 1
};

enum :int{
    XCB_X_PRINT_EV_MASK_NO_EVENT_MASK = 0x00000000,
    XCB_X_PRINT_EV_MASK_PRINT_MASK = 0x00000001,
    XCB_X_PRINT_EV_MASK_ATTRIBUTE_MASK = 0x00000002
};

enum :int{
    XCB_X_PRINT_DETAIL_START_JOB_NOTIFY = 1,
    XCB_X_PRINT_DETAIL_END_JOB_NOTIFY = 2,
    XCB_X_PRINT_DETAIL_START_DOC_NOTIFY = 3,
    XCB_X_PRINT_DETAIL_END_DOC_NOTIFY = 4,
    XCB_X_PRINT_DETAIL_START_PAGE_NOTIFY = 5,
    XCB_X_PRINT_DETAIL_END_PAGE_NOTIFY = 6
};

enum :int{
    XCB_X_PRINT_ATTR_JOB_ATTR = 1,
    XCB_X_PRINT_ATTR_DOC_ATTR = 2,
    XCB_X_PRINT_ATTR_PAGE_ATTR = 3,
    XCB_X_PRINT_ATTR_PRINTER_ATTR = 4,
    XCB_X_PRINT_ATTR_SERVER_ATTR = 5,
    XCB_X_PRINT_ATTR_MEDIUM_ATTR = 6,
    XCB_X_PRINT_ATTR_SPOOLER_ATTR = 7
};

/**
 * @brief xcb_x_print_print_query_version_cookie_t
 **/
struct xcb_x_print_print_query_version_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_x_print_print_query_version. */
const uint XCB_X_PRINT_PRINT_QUERY_VERSION = 0;

/**
 * @brief xcb_x_print_print_query_version_request_t
 **/
struct xcb_x_print_print_query_version_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
} ;

/**
 * @brief xcb_x_print_print_query_version_reply_t
 **/
struct xcb_x_print_print_query_version_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ushort major_version; /**<  */
    ushort minor_version; /**<  */
} ;

/**
 * @brief xcb_x_print_print_get_printer_list_cookie_t
 **/
struct xcb_x_print_print_get_printer_list_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_x_print_print_get_printer_list. */
const uint XCB_X_PRINT_PRINT_GET_PRINTER_LIST = 1;

/**
 * @brief xcb_x_print_print_get_printer_list_request_t
 **/
struct xcb_x_print_print_get_printer_list_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
    uint   printerNameLen; /**<  */
    uint   localeLen; /**<  */
} ;

/**
 * @brief xcb_x_print_print_get_printer_list_reply_t
 **/
struct xcb_x_print_print_get_printer_list_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    uint   listCount; /**<  */
    ubyte  pad1[20]; /**<  */
} ;

/** Opcode for xcb_x_print_print_rehash_printer_list. */
const uint XCB_X_PRINT_PRINT_REHASH_PRINTER_LIST = 20;

/**
 * @brief xcb_x_print_print_rehash_printer_list_request_t
 **/
struct xcb_x_print_print_rehash_printer_list_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
} ;

/** Opcode for xcb_x_print_create_context. */
const uint XCB_X_PRINT_CREATE_CONTEXT = 2;

/**
 * @brief xcb_x_print_create_context_request_t
 **/
struct xcb_x_print_create_context_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
    uint   context_id; /**<  */
    uint   printerNameLen; /**<  */
    uint   localeLen; /**<  */
} ;

/** Opcode for xcb_x_print_print_set_context. */
const uint XCB_X_PRINT_PRINT_SET_CONTEXT = 3;

/**
 * @brief xcb_x_print_print_set_context_request_t
 **/
struct xcb_x_print_print_set_context_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
    uint   context; /**<  */
} ;

/**
 * @brief xcb_x_print_print_get_context_cookie_t
 **/
struct xcb_x_print_print_get_context_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_x_print_print_get_context. */
const uint XCB_X_PRINT_PRINT_GET_CONTEXT = 4;

/**
 * @brief xcb_x_print_print_get_context_request_t
 **/
struct xcb_x_print_print_get_context_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
} ;

/**
 * @brief xcb_x_print_print_get_context_reply_t
 **/
struct xcb_x_print_print_get_context_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    uint   context; /**<  */
} ;

/** Opcode for xcb_x_print_print_destroy_context. */
const uint XCB_X_PRINT_PRINT_DESTROY_CONTEXT = 5;

/**
 * @brief xcb_x_print_print_destroy_context_request_t
 **/
struct xcb_x_print_print_destroy_context_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
    uint   context; /**<  */
} ;

/**
 * @brief xcb_x_print_print_get_screen_of_context_cookie_t
 **/
struct xcb_x_print_print_get_screen_of_context_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_x_print_print_get_screen_of_context. */
const uint XCB_X_PRINT_PRINT_GET_SCREEN_OF_CONTEXT = 6;

/**
 * @brief xcb_x_print_print_get_screen_of_context_request_t
 **/
struct xcb_x_print_print_get_screen_of_context_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
} ;

/**
 * @brief xcb_x_print_print_get_screen_of_context_reply_t
 **/
struct xcb_x_print_print_get_screen_of_context_reply_t {
    ubyte        response_type; /**<  */
    ubyte        pad0; /**<  */
    ushort       sequence; /**<  */
    uint         length; /**<  */
    xcb_window_t root; /**<  */
} ;

/** Opcode for xcb_x_print_print_start_job. */
const uint XCB_X_PRINT_PRINT_START_JOB = 7;

/**
 * @brief xcb_x_print_print_start_job_request_t
 **/
struct xcb_x_print_print_start_job_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
    ubyte  output_mode; /**<  */
} ;

/** Opcode for xcb_x_print_print_end_job. */
const uint XCB_X_PRINT_PRINT_END_JOB = 8;

/**
 * @brief xcb_x_print_print_end_job_request_t
 **/
struct xcb_x_print_print_end_job_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
    bool   cancel; /**<  */
} ;

/** Opcode for xcb_x_print_print_start_doc. */
const uint XCB_X_PRINT_PRINT_START_DOC = 9;

/**
 * @brief xcb_x_print_print_start_doc_request_t
 **/
struct xcb_x_print_print_start_doc_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
    ubyte  driver_mode; /**<  */
} ;

/** Opcode for xcb_x_print_print_end_doc. */
const uint XCB_X_PRINT_PRINT_END_DOC = 10;

/**
 * @brief xcb_x_print_print_end_doc_request_t
 **/
struct xcb_x_print_print_end_doc_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
    bool   cancel; /**<  */
} ;

/** Opcode for xcb_x_print_print_put_document_data. */
const uint XCB_X_PRINT_PRINT_PUT_DOCUMENT_DATA = 11;

/**
 * @brief xcb_x_print_print_put_document_data_request_t
 **/
struct xcb_x_print_print_put_document_data_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          minor_opcode; /**<  */
    ushort         length; /**<  */
    xcb_drawable_t drawable; /**<  */
    uint           len_data; /**<  */
    ushort         len_fmt; /**<  */
    ushort         len_options; /**<  */
} ;

/**
 * @brief xcb_x_print_print_get_document_data_cookie_t
 **/
struct xcb_x_print_print_get_document_data_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_x_print_print_get_document_data. */
const uint XCB_X_PRINT_PRINT_GET_DOCUMENT_DATA = 12;

/**
 * @brief xcb_x_print_print_get_document_data_request_t
 **/
struct xcb_x_print_print_get_document_data_request_t {
    ubyte                  major_opcode; /**<  */
    ubyte                  minor_opcode; /**<  */
    ushort                 length; /**<  */
    xcb_x_print_pcontext_t context; /**<  */
    uint                   max_bytes; /**<  */
} ;

/**
 * @brief xcb_x_print_print_get_document_data_reply_t
 **/
struct xcb_x_print_print_get_document_data_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    uint   status_code; /**<  */
    uint   finished_flag; /**<  */
    uint   dataLen; /**<  */
    ubyte  pad1[12]; /**<  */
} ;

/** Opcode for xcb_x_print_print_start_page. */
const uint XCB_X_PRINT_PRINT_START_PAGE = 13;

/**
 * @brief xcb_x_print_print_start_page_request_t
 **/
struct xcb_x_print_print_start_page_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        minor_opcode; /**<  */
    ushort       length; /**<  */
    xcb_window_t window; /**<  */
} ;

/** Opcode for xcb_x_print_print_end_page. */
const uint XCB_X_PRINT_PRINT_END_PAGE = 14;

/**
 * @brief xcb_x_print_print_end_page_request_t
 **/
struct xcb_x_print_print_end_page_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
    bool   cancel; /**<  */
    ubyte  pad0[3]; /**<  */
} ;

/** Opcode for xcb_x_print_print_select_input. */
const uint XCB_X_PRINT_PRINT_SELECT_INPUT = 15;

/**
 * @brief xcb_x_print_print_select_input_request_t
 **/
struct xcb_x_print_print_select_input_request_t {
    ubyte                  major_opcode; /**<  */
    ubyte                  minor_opcode; /**<  */
    ushort                 length; /**<  */
    xcb_x_print_pcontext_t context; /**<  */
    uint                   event_mask; /**<  */
} ;

/**
 * @brief xcb_x_print_print_input_selected_cookie_t
 **/
struct xcb_x_print_print_input_selected_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_x_print_print_input_selected. */
const uint XCB_X_PRINT_PRINT_INPUT_SELECTED = 16;

/**
 * @brief xcb_x_print_print_input_selected_request_t
 **/
struct xcb_x_print_print_input_selected_request_t {
    ubyte                  major_opcode; /**<  */
    ubyte                  minor_opcode; /**<  */
    ushort                 length; /**<  */
    xcb_x_print_pcontext_t context; /**<  */
} ;

/**
 * @brief xcb_x_print_print_input_selected_reply_t
 **/
struct xcb_x_print_print_input_selected_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    uint   event_mask; /**<  */
    uint   all_events_mask; /**<  */
} ;

/**
 * @brief xcb_x_print_print_get_attributes_cookie_t
 **/
struct xcb_x_print_print_get_attributes_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_x_print_print_get_attributes. */
const uint XCB_X_PRINT_PRINT_GET_ATTRIBUTES = 17;

/**
 * @brief xcb_x_print_print_get_attributes_request_t
 **/
struct xcb_x_print_print_get_attributes_request_t {
    ubyte                  major_opcode; /**<  */
    ubyte                  minor_opcode; /**<  */
    ushort                 length; /**<  */
    xcb_x_print_pcontext_t context; /**<  */
    ubyte                  pool; /**<  */
    ubyte                  pad0[3]; /**<  */
} ;

/**
 * @brief xcb_x_print_print_get_attributes_reply_t
 **/
struct xcb_x_print_print_get_attributes_reply_t {
    ubyte                 response_type; /**<  */
    ubyte                 pad0; /**<  */
    ushort                sequence; /**<  */
    uint                  length; /**<  */
    uint                  stringLen; /**<  */
    ubyte                 pad1[20]; /**<  */
    xcb_x_print_string8_t attributes; /**<  */
} ;

/**
 * @brief xcb_x_print_print_get_one_attributes_cookie_t
 **/
struct xcb_x_print_print_get_one_attributes_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_x_print_print_get_one_attributes. */
const uint XCB_X_PRINT_PRINT_GET_ONE_ATTRIBUTES = 19;

/**
 * @brief xcb_x_print_print_get_one_attributes_request_t
 **/
struct xcb_x_print_print_get_one_attributes_request_t {
    ubyte                  major_opcode; /**<  */
    ubyte                  minor_opcode; /**<  */
    ushort                 length; /**<  */
    xcb_x_print_pcontext_t context; /**<  */
    uint                   nameLen; /**<  */
    ubyte                  pool; /**<  */
    ubyte                  pad0[3]; /**<  */
} ;

/**
 * @brief xcb_x_print_print_get_one_attributes_reply_t
 **/
struct xcb_x_print_print_get_one_attributes_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    uint   valueLen; /**<  */
    ubyte  pad1[20]; /**<  */
} ;

/** Opcode for xcb_x_print_print_set_attributes. */
const uint XCB_X_PRINT_PRINT_SET_ATTRIBUTES = 18;

/**
 * @brief xcb_x_print_print_set_attributes_request_t
 **/
struct xcb_x_print_print_set_attributes_request_t {
    ubyte                  major_opcode; /**<  */
    ubyte                  minor_opcode; /**<  */
    ushort                 length; /**<  */
    xcb_x_print_pcontext_t context; /**<  */
    uint                   stringLen; /**<  */
    ubyte                  pool; /**<  */
    ubyte                  rule; /**<  */
    ubyte                  pad0[2]; /**<  */
} ;

/**
 * @brief xcb_x_print_print_get_page_dimensions_cookie_t
 **/
struct xcb_x_print_print_get_page_dimensions_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_x_print_print_get_page_dimensions. */
const uint XCB_X_PRINT_PRINT_GET_PAGE_DIMENSIONS = 21;

/**
 * @brief xcb_x_print_print_get_page_dimensions_request_t
 **/
struct xcb_x_print_print_get_page_dimensions_request_t {
    ubyte                  major_opcode; /**<  */
    ubyte                  minor_opcode; /**<  */
    ushort                 length; /**<  */
    xcb_x_print_pcontext_t context; /**<  */
} ;

/**
 * @brief xcb_x_print_print_get_page_dimensions_reply_t
 **/
struct xcb_x_print_print_get_page_dimensions_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ushort width; /**<  */
    ushort height; /**<  */
    ushort offset_x; /**<  */
    ushort offset_y; /**<  */
    ushort reproducible_width; /**<  */
    ushort reproducible_height; /**<  */
} ;

/**
 * @brief xcb_x_print_print_query_screens_cookie_t
 **/
struct xcb_x_print_print_query_screens_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_x_print_print_query_screens. */
const uint XCB_X_PRINT_PRINT_QUERY_SCREENS = 22;

/**
 * @brief xcb_x_print_print_query_screens_request_t
 **/
struct xcb_x_print_print_query_screens_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
} ;

/**
 * @brief xcb_x_print_print_query_screens_reply_t
 **/
struct xcb_x_print_print_query_screens_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    uint   listCount; /**<  */
    ubyte  pad1[20]; /**<  */
} ;

/**
 * @brief xcb_x_print_print_set_image_resolution_cookie_t
 **/
struct xcb_x_print_print_set_image_resolution_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_x_print_print_set_image_resolution. */
const uint XCB_X_PRINT_PRINT_SET_IMAGE_RESOLUTION = 23;

/**
 * @brief xcb_x_print_print_set_image_resolution_request_t
 **/
struct xcb_x_print_print_set_image_resolution_request_t {
    ubyte                  major_opcode; /**<  */
    ubyte                  minor_opcode; /**<  */
    ushort                 length; /**<  */
    xcb_x_print_pcontext_t context; /**<  */
    ushort                 image_resolution; /**<  */
} ;

/**
 * @brief xcb_x_print_print_set_image_resolution_reply_t
 **/
struct xcb_x_print_print_set_image_resolution_reply_t {
    ubyte  response_type; /**<  */
    bool   status; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ushort previous_resolutions; /**<  */
} ;

/**
 * @brief xcb_x_print_print_get_image_resolution_cookie_t
 **/
struct xcb_x_print_print_get_image_resolution_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_x_print_print_get_image_resolution. */
const uint XCB_X_PRINT_PRINT_GET_IMAGE_RESOLUTION = 24;

/**
 * @brief xcb_x_print_print_get_image_resolution_request_t
 **/
struct xcb_x_print_print_get_image_resolution_request_t {
    ubyte                  major_opcode; /**<  */
    ubyte                  minor_opcode; /**<  */
    ushort                 length; /**<  */
    xcb_x_print_pcontext_t context; /**<  */
} ;

/**
 * @brief xcb_x_print_print_get_image_resolution_reply_t
 **/
struct xcb_x_print_print_get_image_resolution_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ushort image_resolution; /**<  */
} ;

/** Opcode for xcb_x_print_notify. */
const uint XCB_X_PRINT_NOTIFY = 0;

/**
 * @brief xcb_x_print_notify_event_t
 **/
struct xcb_x_print_notify_event_t {
    ubyte                  response_type; /**<  */
    ubyte                  detail; /**<  */
    ushort                 sequence; /**<  */
    xcb_x_print_pcontext_t context; /**<  */
    bool                   cancel; /**<  */
} ;

/** Opcode for xcb_x_print_attribut_notify. */
const uint XCB_X_PRINT_ATTRIBUT_NOTIFY = 1;

/**
 * @brief xcb_x_print_attribut_notify_event_t
 **/
struct xcb_x_print_attribut_notify_event_t {
    ubyte                  response_type; /**<  */
    ubyte                  detail; /**<  */
    ushort                 sequence; /**<  */
    xcb_x_print_pcontext_t context; /**<  */
} ;

/** Opcode for xcb_x_print_bad_context. */
const uint XCB_X_PRINT_BAD_CONTEXT = 0;

/**
 * @brief xcb_x_print_bad_context_error_t
 **/
struct xcb_x_print_bad_context_error_t {
    ubyte  response_type; /**<  */
    ubyte  error_code; /**<  */
    ushort sequence; /**<  */
} ;

/** Opcode for xcb_x_print_bad_sequence. */
const uint XCB_X_PRINT_BAD_SEQUENCE = 1;

/**
 * @brief xcb_x_print_bad_sequence_error_t
 **/
struct xcb_x_print_bad_sequence_error_t {
    ubyte  response_type; /**<  */
    ubyte  error_code; /**<  */
    ushort sequence; /**<  */
} ;


/*****************************************************************************
 **
 ** xcb_x_print_string8_t * xcb_x_print_printer_name
 ** 
 ** @param /+const+/ xcb_x_print_printer_t *R
 ** @returns xcb_x_print_string8_t *
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_string8_t *
xcb_x_print_printer_name (/+const+/ xcb_x_print_printer_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_x_print_printer_name_length
 ** 
 ** @param /+const+/ xcb_x_print_printer_t *R
 ** @returns int
 **
 *****************************************************************************/
 
extern(C) int
xcb_x_print_printer_name_length (/+const+/ xcb_x_print_printer_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_x_print_string8_iterator_t xcb_x_print_printer_name_iterator
 ** 
 ** @param /+const+/ xcb_x_print_printer_t *R
 ** @returns xcb_x_print_string8_iterator_t
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_string8_iterator_t
xcb_x_print_printer_name_iterator (/+const+/ xcb_x_print_printer_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_x_print_string8_t * xcb_x_print_printer_description
 ** 
 ** @param /+const+/ xcb_x_print_printer_t *R
 ** @returns xcb_x_print_string8_t *
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_string8_t *
xcb_x_print_printer_description (/+const+/ xcb_x_print_printer_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_x_print_printer_description_length
 ** 
 ** @param /+const+/ xcb_x_print_printer_t *R
 ** @returns int
 **
 *****************************************************************************/
 
extern(C) int
xcb_x_print_printer_description_length (/+const+/ xcb_x_print_printer_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_x_print_string8_iterator_t xcb_x_print_printer_description_iterator
 ** 
 ** @param /+const+/ xcb_x_print_printer_t *R
 ** @returns xcb_x_print_string8_iterator_t
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_string8_iterator_t
xcb_x_print_printer_description_iterator (/+const+/ xcb_x_print_printer_t *R  /**< */);


/*****************************************************************************
 **
 ** void xcb_x_print_printer_next
 ** 
 ** @param xcb_x_print_printer_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/
 
extern(C) void
xcb_x_print_printer_next (xcb_x_print_printer_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_x_print_printer_end
 ** 
 ** @param xcb_x_print_printer_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/
 
extern(C) xcb_generic_iterator_t
xcb_x_print_printer_end (xcb_x_print_printer_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_x_print_pcontext_next
 ** 
 ** @param xcb_x_print_pcontext_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/
 
extern(C) void
xcb_x_print_pcontext_next (xcb_x_print_pcontext_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_x_print_pcontext_end
 ** 
 ** @param xcb_x_print_pcontext_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/
 
extern(C) xcb_generic_iterator_t
xcb_x_print_pcontext_end (xcb_x_print_pcontext_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_x_print_string8_next
 ** 
 ** @param xcb_x_print_string8_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/
 
extern(C) void
xcb_x_print_string8_next (xcb_x_print_string8_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_x_print_string8_end
 ** 
 ** @param xcb_x_print_string8_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/
 
extern(C) xcb_generic_iterator_t
xcb_x_print_string8_end (xcb_x_print_string8_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** xcb_x_print_print_query_version_cookie_t xcb_x_print_print_query_version
 ** 
 ** @param xcb_connection_t *c
 ** @returns xcb_x_print_print_query_version_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_print_query_version_cookie_t
xcb_x_print_print_query_version (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_x_print_print_query_version_cookie_t xcb_x_print_print_query_version_unchecked
 ** 
 ** @param xcb_connection_t *c
 ** @returns xcb_x_print_print_query_version_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_print_query_version_cookie_t
xcb_x_print_print_query_version_unchecked (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_x_print_print_query_version_reply_t * xcb_x_print_print_query_version_reply
 ** 
 ** @param xcb_connection_t                          *c
 ** @param xcb_x_print_print_query_version_cookie_t   cookie
 ** @param xcb_generic_error_t                      **e
 ** @returns xcb_x_print_print_query_version_reply_t *
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_print_query_version_reply_t *
xcb_x_print_print_query_version_reply (xcb_connection_t                          *c  /**< */,
                                       xcb_x_print_print_query_version_cookie_t   cookie  /**< */,
                                       xcb_generic_error_t                      **e  /**< */);


/*****************************************************************************
 **
 ** xcb_x_print_print_get_printer_list_cookie_t xcb_x_print_print_get_printer_list
 ** 
 ** @param xcb_connection_t                *c
 ** @param uint                             printerNameLen
 ** @param uint                             localeLen
 ** @param /+const+/ xcb_x_print_string8_t *printer_name
 ** @param /+const+/ xcb_x_print_string8_t *locale
 ** @returns xcb_x_print_print_get_printer_list_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_print_get_printer_list_cookie_t
xcb_x_print_print_get_printer_list (xcb_connection_t                *c  /**< */,
                                    uint                             printerNameLen  /**< */,
                                    uint                             localeLen  /**< */,
                                    /+const+/ xcb_x_print_string8_t *printer_name  /**< */,
                                    /+const+/ xcb_x_print_string8_t *locale  /**< */);


/*****************************************************************************
 **
 ** xcb_x_print_print_get_printer_list_cookie_t xcb_x_print_print_get_printer_list_unchecked
 ** 
 ** @param xcb_connection_t                *c
 ** @param uint                             printerNameLen
 ** @param uint                             localeLen
 ** @param /+const+/ xcb_x_print_string8_t *printer_name
 ** @param /+const+/ xcb_x_print_string8_t *locale
 ** @returns xcb_x_print_print_get_printer_list_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_print_get_printer_list_cookie_t
xcb_x_print_print_get_printer_list_unchecked (xcb_connection_t                *c  /**< */,
                                              uint                             printerNameLen  /**< */,
                                              uint                             localeLen  /**< */,
                                              /+const+/ xcb_x_print_string8_t *printer_name  /**< */,
                                              /+const+/ xcb_x_print_string8_t *locale  /**< */);


/*****************************************************************************
 **
 ** int xcb_x_print_print_get_printer_list_printers_length
 ** 
 ** @param /+const+/ xcb_x_print_print_get_printer_list_reply_t *R
 ** @returns int
 **
 *****************************************************************************/
 
extern(C) int
xcb_x_print_print_get_printer_list_printers_length (/+const+/ xcb_x_print_print_get_printer_list_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_x_print_printer_iterator_t xcb_x_print_print_get_printer_list_printers_iterator
 ** 
 ** @param /+const+/ xcb_x_print_print_get_printer_list_reply_t *R
 ** @returns xcb_x_print_printer_iterator_t
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_printer_iterator_t
xcb_x_print_print_get_printer_list_printers_iterator (/+const+/ xcb_x_print_print_get_printer_list_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_x_print_print_get_printer_list_reply_t * xcb_x_print_print_get_printer_list_reply
 ** 
 ** @param xcb_connection_t                             *c
 ** @param xcb_x_print_print_get_printer_list_cookie_t   cookie
 ** @param xcb_generic_error_t                         **e
 ** @returns xcb_x_print_print_get_printer_list_reply_t *
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_print_get_printer_list_reply_t *
xcb_x_print_print_get_printer_list_reply (xcb_connection_t                             *c  /**< */,
                                          xcb_x_print_print_get_printer_list_cookie_t   cookie  /**< */,
                                          xcb_generic_error_t                         **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_x_print_print_rehash_printer_list_checked
 ** 
 ** @param xcb_connection_t *c
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_void_cookie_t
xcb_x_print_print_rehash_printer_list_checked (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_x_print_print_rehash_printer_list
 ** 
 ** @param xcb_connection_t *c
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_void_cookie_t
xcb_x_print_print_rehash_printer_list (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_x_print_create_context_checked
 ** 
 ** @param xcb_connection_t                *c
 ** @param uint                             context_id
 ** @param uint                             printerNameLen
 ** @param uint                             localeLen
 ** @param /+const+/ xcb_x_print_string8_t *printerName
 ** @param /+const+/ xcb_x_print_string8_t *locale
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_void_cookie_t
xcb_x_print_create_context_checked (xcb_connection_t                *c  /**< */,
                                    uint                             context_id  /**< */,
                                    uint                             printerNameLen  /**< */,
                                    uint                             localeLen  /**< */,
                                    /+const+/ xcb_x_print_string8_t *printerName  /**< */,
                                    /+const+/ xcb_x_print_string8_t *locale  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_x_print_create_context
 ** 
 ** @param xcb_connection_t                *c
 ** @param uint                             context_id
 ** @param uint                             printerNameLen
 ** @param uint                             localeLen
 ** @param /+const+/ xcb_x_print_string8_t *printerName
 ** @param /+const+/ xcb_x_print_string8_t *locale
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_void_cookie_t
xcb_x_print_create_context (xcb_connection_t                *c  /**< */,
                            uint                             context_id  /**< */,
                            uint                             printerNameLen  /**< */,
                            uint                             localeLen  /**< */,
                            /+const+/ xcb_x_print_string8_t *printerName  /**< */,
                            /+const+/ xcb_x_print_string8_t *locale  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_x_print_print_set_context_checked
 ** 
 ** @param xcb_connection_t *c
 ** @param uint              context
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_void_cookie_t
xcb_x_print_print_set_context_checked (xcb_connection_t *c  /**< */,
                                       uint              context  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_x_print_print_set_context
 ** 
 ** @param xcb_connection_t *c
 ** @param uint              context
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_void_cookie_t
xcb_x_print_print_set_context (xcb_connection_t *c  /**< */,
                               uint              context  /**< */);


/*****************************************************************************
 **
 ** xcb_x_print_print_get_context_cookie_t xcb_x_print_print_get_context
 ** 
 ** @param xcb_connection_t *c
 ** @returns xcb_x_print_print_get_context_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_print_get_context_cookie_t
xcb_x_print_print_get_context (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_x_print_print_get_context_cookie_t xcb_x_print_print_get_context_unchecked
 ** 
 ** @param xcb_connection_t *c
 ** @returns xcb_x_print_print_get_context_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_print_get_context_cookie_t
xcb_x_print_print_get_context_unchecked (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_x_print_print_get_context_reply_t * xcb_x_print_print_get_context_reply
 ** 
 ** @param xcb_connection_t                        *c
 ** @param xcb_x_print_print_get_context_cookie_t   cookie
 ** @param xcb_generic_error_t                    **e
 ** @returns xcb_x_print_print_get_context_reply_t *
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_print_get_context_reply_t *
xcb_x_print_print_get_context_reply (xcb_connection_t                        *c  /**< */,
                                     xcb_x_print_print_get_context_cookie_t   cookie  /**< */,
                                     xcb_generic_error_t                    **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_x_print_print_destroy_context_checked
 ** 
 ** @param xcb_connection_t *c
 ** @param uint              context
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_void_cookie_t
xcb_x_print_print_destroy_context_checked (xcb_connection_t *c  /**< */,
                                           uint              context  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_x_print_print_destroy_context
 ** 
 ** @param xcb_connection_t *c
 ** @param uint              context
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_void_cookie_t
xcb_x_print_print_destroy_context (xcb_connection_t *c  /**< */,
                                   uint              context  /**< */);


/*****************************************************************************
 **
 ** xcb_x_print_print_get_screen_of_context_cookie_t xcb_x_print_print_get_screen_of_context
 ** 
 ** @param xcb_connection_t *c
 ** @returns xcb_x_print_print_get_screen_of_context_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_print_get_screen_of_context_cookie_t
xcb_x_print_print_get_screen_of_context (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_x_print_print_get_screen_of_context_cookie_t xcb_x_print_print_get_screen_of_context_unchecked
 ** 
 ** @param xcb_connection_t *c
 ** @returns xcb_x_print_print_get_screen_of_context_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_print_get_screen_of_context_cookie_t
xcb_x_print_print_get_screen_of_context_unchecked (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_x_print_print_get_screen_of_context_reply_t * xcb_x_print_print_get_screen_of_context_reply
 ** 
 ** @param xcb_connection_t                                  *c
 ** @param xcb_x_print_print_get_screen_of_context_cookie_t   cookie
 ** @param xcb_generic_error_t                              **e
 ** @returns xcb_x_print_print_get_screen_of_context_reply_t *
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_print_get_screen_of_context_reply_t *
xcb_x_print_print_get_screen_of_context_reply (xcb_connection_t                                  *c  /**< */,
                                               xcb_x_print_print_get_screen_of_context_cookie_t   cookie  /**< */,
                                               xcb_generic_error_t                              **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_x_print_print_start_job_checked
 ** 
 ** @param xcb_connection_t *c
 ** @param ubyte             output_mode
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_void_cookie_t
xcb_x_print_print_start_job_checked (xcb_connection_t *c  /**< */,
                                     ubyte             output_mode  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_x_print_print_start_job
 ** 
 ** @param xcb_connection_t *c
 ** @param ubyte             output_mode
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_void_cookie_t
xcb_x_print_print_start_job (xcb_connection_t *c  /**< */,
                             ubyte             output_mode  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_x_print_print_end_job_checked
 ** 
 ** @param xcb_connection_t *c
 ** @param bool              cancel
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_void_cookie_t
xcb_x_print_print_end_job_checked (xcb_connection_t *c  /**< */,
                                   bool              cancel  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_x_print_print_end_job
 ** 
 ** @param xcb_connection_t *c
 ** @param bool              cancel
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_void_cookie_t
xcb_x_print_print_end_job (xcb_connection_t *c  /**< */,
                           bool              cancel  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_x_print_print_start_doc_checked
 ** 
 ** @param xcb_connection_t *c
 ** @param ubyte             driver_mode
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_void_cookie_t
xcb_x_print_print_start_doc_checked (xcb_connection_t *c  /**< */,
                                     ubyte             driver_mode  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_x_print_print_start_doc
 ** 
 ** @param xcb_connection_t *c
 ** @param ubyte             driver_mode
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_void_cookie_t
xcb_x_print_print_start_doc (xcb_connection_t *c  /**< */,
                             ubyte             driver_mode  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_x_print_print_end_doc_checked
 ** 
 ** @param xcb_connection_t *c
 ** @param bool              cancel
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_void_cookie_t
xcb_x_print_print_end_doc_checked (xcb_connection_t *c  /**< */,
                                   bool              cancel  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_x_print_print_end_doc
 ** 
 ** @param xcb_connection_t *c
 ** @param bool              cancel
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_void_cookie_t
xcb_x_print_print_end_doc (xcb_connection_t *c  /**< */,
                           bool              cancel  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_x_print_print_put_document_data_checked
 ** 
 ** @param xcb_connection_t                *c
 ** @param xcb_drawable_t                   drawable
 ** @param uint                             len_data
 ** @param ushort                           len_fmt
 ** @param ushort                           len_options
 ** @param /+const+/ ubyte                 *data
 ** @param uint                             doc_format_len
 ** @param /+const+/ xcb_x_print_string8_t *doc_format
 ** @param uint                             options_len
 ** @param /+const+/ xcb_x_print_string8_t *options
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_void_cookie_t
xcb_x_print_print_put_document_data_checked (xcb_connection_t                *c  /**< */,
                                             xcb_drawable_t                   drawable  /**< */,
                                             uint                             len_data  /**< */,
                                             ushort                           len_fmt  /**< */,
                                             ushort                           len_options  /**< */,
                                             /+const+/ ubyte                 *data  /**< */,
                                             uint                             doc_format_len  /**< */,
                                             /+const+/ xcb_x_print_string8_t *doc_format  /**< */,
                                             uint                             options_len  /**< */,
                                             /+const+/ xcb_x_print_string8_t *options  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_x_print_print_put_document_data
 ** 
 ** @param xcb_connection_t                *c
 ** @param xcb_drawable_t                   drawable
 ** @param uint                             len_data
 ** @param ushort                           len_fmt
 ** @param ushort                           len_options
 ** @param /+const+/ ubyte                 *data
 ** @param uint                             doc_format_len
 ** @param /+const+/ xcb_x_print_string8_t *doc_format
 ** @param uint                             options_len
 ** @param /+const+/ xcb_x_print_string8_t *options
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_void_cookie_t
xcb_x_print_print_put_document_data (xcb_connection_t                *c  /**< */,
                                     xcb_drawable_t                   drawable  /**< */,
                                     uint                             len_data  /**< */,
                                     ushort                           len_fmt  /**< */,
                                     ushort                           len_options  /**< */,
                                     /+const+/ ubyte                 *data  /**< */,
                                     uint                             doc_format_len  /**< */,
                                     /+const+/ xcb_x_print_string8_t *doc_format  /**< */,
                                     uint                             options_len  /**< */,
                                     /+const+/ xcb_x_print_string8_t *options  /**< */);


/*****************************************************************************
 **
 ** xcb_x_print_print_get_document_data_cookie_t xcb_x_print_print_get_document_data
 ** 
 ** @param xcb_connection_t       *c
 ** @param xcb_x_print_pcontext_t  context
 ** @param uint                    max_bytes
 ** @returns xcb_x_print_print_get_document_data_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_print_get_document_data_cookie_t
xcb_x_print_print_get_document_data (xcb_connection_t       *c  /**< */,
                                     xcb_x_print_pcontext_t  context  /**< */,
                                     uint                    max_bytes  /**< */);


/*****************************************************************************
 **
 ** xcb_x_print_print_get_document_data_cookie_t xcb_x_print_print_get_document_data_unchecked
 ** 
 ** @param xcb_connection_t       *c
 ** @param xcb_x_print_pcontext_t  context
 ** @param uint                    max_bytes
 ** @returns xcb_x_print_print_get_document_data_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_print_get_document_data_cookie_t
xcb_x_print_print_get_document_data_unchecked (xcb_connection_t       *c  /**< */,
                                               xcb_x_print_pcontext_t  context  /**< */,
                                               uint                    max_bytes  /**< */);


/*****************************************************************************
 **
 ** ubyte * xcb_x_print_print_get_document_data_data
 ** 
 ** @param /+const+/ xcb_x_print_print_get_document_data_reply_t *R
 ** @returns ubyte *
 **
 *****************************************************************************/
 
extern(C) ubyte *
xcb_x_print_print_get_document_data_data (/+const+/ xcb_x_print_print_get_document_data_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_x_print_print_get_document_data_data_length
 ** 
 ** @param /+const+/ xcb_x_print_print_get_document_data_reply_t *R
 ** @returns int
 **
 *****************************************************************************/
 
extern(C) int
xcb_x_print_print_get_document_data_data_length (/+const+/ xcb_x_print_print_get_document_data_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_x_print_print_get_document_data_data_end
 ** 
 ** @param /+const+/ xcb_x_print_print_get_document_data_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/
 
extern(C) xcb_generic_iterator_t
xcb_x_print_print_get_document_data_data_end (/+const+/ xcb_x_print_print_get_document_data_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_x_print_print_get_document_data_reply_t * xcb_x_print_print_get_document_data_reply
 ** 
 ** @param xcb_connection_t                              *c
 ** @param xcb_x_print_print_get_document_data_cookie_t   cookie
 ** @param xcb_generic_error_t                          **e
 ** @returns xcb_x_print_print_get_document_data_reply_t *
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_print_get_document_data_reply_t *
xcb_x_print_print_get_document_data_reply (xcb_connection_t                              *c  /**< */,
                                           xcb_x_print_print_get_document_data_cookie_t   cookie  /**< */,
                                           xcb_generic_error_t                          **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_x_print_print_start_page_checked
 ** 
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_void_cookie_t
xcb_x_print_print_start_page_checked (xcb_connection_t *c  /**< */,
                                      xcb_window_t      window  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_x_print_print_start_page
 ** 
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_void_cookie_t
xcb_x_print_print_start_page (xcb_connection_t *c  /**< */,
                              xcb_window_t      window  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_x_print_print_end_page_checked
 ** 
 ** @param xcb_connection_t *c
 ** @param bool              cancel
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_void_cookie_t
xcb_x_print_print_end_page_checked (xcb_connection_t *c  /**< */,
                                    bool              cancel  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_x_print_print_end_page
 ** 
 ** @param xcb_connection_t *c
 ** @param bool              cancel
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_void_cookie_t
xcb_x_print_print_end_page (xcb_connection_t *c  /**< */,
                            bool              cancel  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_x_print_print_select_input_checked
 ** 
 ** @param xcb_connection_t       *c
 ** @param xcb_x_print_pcontext_t  context
 ** @param uint                    event_mask
 ** @param /+const+/ uint         *event_list
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_void_cookie_t
xcb_x_print_print_select_input_checked (xcb_connection_t       *c  /**< */,
                                        xcb_x_print_pcontext_t  context  /**< */,
                                        uint                    event_mask  /**< */,
                                        /+const+/ uint         *event_list  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_x_print_print_select_input
 ** 
 ** @param xcb_connection_t       *c
 ** @param xcb_x_print_pcontext_t  context
 ** @param uint                    event_mask
 ** @param /+const+/ uint         *event_list
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_void_cookie_t
xcb_x_print_print_select_input (xcb_connection_t       *c  /**< */,
                                xcb_x_print_pcontext_t  context  /**< */,
                                uint                    event_mask  /**< */,
                                /+const+/ uint         *event_list  /**< */);


/*****************************************************************************
 **
 ** xcb_x_print_print_input_selected_cookie_t xcb_x_print_print_input_selected
 ** 
 ** @param xcb_connection_t       *c
 ** @param xcb_x_print_pcontext_t  context
 ** @returns xcb_x_print_print_input_selected_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_print_input_selected_cookie_t
xcb_x_print_print_input_selected (xcb_connection_t       *c  /**< */,
                                  xcb_x_print_pcontext_t  context  /**< */);


/*****************************************************************************
 **
 ** xcb_x_print_print_input_selected_cookie_t xcb_x_print_print_input_selected_unchecked
 ** 
 ** @param xcb_connection_t       *c
 ** @param xcb_x_print_pcontext_t  context
 ** @returns xcb_x_print_print_input_selected_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_print_input_selected_cookie_t
xcb_x_print_print_input_selected_unchecked (xcb_connection_t       *c  /**< */,
                                            xcb_x_print_pcontext_t  context  /**< */);


/*****************************************************************************
 **
 ** uint * xcb_x_print_print_input_selected_event_list
 ** 
 ** @param /+const+/ xcb_x_print_print_input_selected_reply_t *R
 ** @returns uint *
 **
 *****************************************************************************/
 
extern(C) uint *
xcb_x_print_print_input_selected_event_list (/+const+/ xcb_x_print_print_input_selected_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_x_print_print_input_selected_event_list_length
 ** 
 ** @param /+const+/ xcb_x_print_print_input_selected_reply_t *R
 ** @returns int
 **
 *****************************************************************************/
 
extern(C) int
xcb_x_print_print_input_selected_event_list_length (/+const+/ xcb_x_print_print_input_selected_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_x_print_print_input_selected_event_list_end
 ** 
 ** @param /+const+/ xcb_x_print_print_input_selected_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/
 
extern(C) xcb_generic_iterator_t
xcb_x_print_print_input_selected_event_list_end (/+const+/ xcb_x_print_print_input_selected_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** uint * xcb_x_print_print_input_selected_all_events_list
 ** 
 ** @param /+const+/ xcb_x_print_print_input_selected_reply_t *R
 ** @returns uint *
 **
 *****************************************************************************/
 
extern(C) uint *
xcb_x_print_print_input_selected_all_events_list (/+const+/ xcb_x_print_print_input_selected_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_x_print_print_input_selected_all_events_list_length
 ** 
 ** @param /+const+/ xcb_x_print_print_input_selected_reply_t *R
 ** @returns int
 **
 *****************************************************************************/
 
extern(C) int
xcb_x_print_print_input_selected_all_events_list_length (/+const+/ xcb_x_print_print_input_selected_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_x_print_print_input_selected_all_events_list_end
 ** 
 ** @param /+const+/ xcb_x_print_print_input_selected_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/
 
extern(C) xcb_generic_iterator_t
xcb_x_print_print_input_selected_all_events_list_end (/+const+/ xcb_x_print_print_input_selected_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_x_print_print_input_selected_reply_t * xcb_x_print_print_input_selected_reply
 ** 
 ** @param xcb_connection_t                           *c
 ** @param xcb_x_print_print_input_selected_cookie_t   cookie
 ** @param xcb_generic_error_t                       **e
 ** @returns xcb_x_print_print_input_selected_reply_t *
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_print_input_selected_reply_t *
xcb_x_print_print_input_selected_reply (xcb_connection_t                           *c  /**< */,
                                        xcb_x_print_print_input_selected_cookie_t   cookie  /**< */,
                                        xcb_generic_error_t                       **e  /**< */);


/*****************************************************************************
 **
 ** xcb_x_print_print_get_attributes_cookie_t xcb_x_print_print_get_attributes
 ** 
 ** @param xcb_connection_t       *c
 ** @param xcb_x_print_pcontext_t  context
 ** @param ubyte                   pool
 ** @returns xcb_x_print_print_get_attributes_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_print_get_attributes_cookie_t
xcb_x_print_print_get_attributes (xcb_connection_t       *c  /**< */,
                                  xcb_x_print_pcontext_t  context  /**< */,
                                  ubyte                   pool  /**< */);


/*****************************************************************************
 **
 ** xcb_x_print_print_get_attributes_cookie_t xcb_x_print_print_get_attributes_unchecked
 ** 
 ** @param xcb_connection_t       *c
 ** @param xcb_x_print_pcontext_t  context
 ** @param ubyte                   pool
 ** @returns xcb_x_print_print_get_attributes_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_print_get_attributes_cookie_t
xcb_x_print_print_get_attributes_unchecked (xcb_connection_t       *c  /**< */,
                                            xcb_x_print_pcontext_t  context  /**< */,
                                            ubyte                   pool  /**< */);


/*****************************************************************************
 **
 ** xcb_x_print_print_get_attributes_reply_t * xcb_x_print_print_get_attributes_reply
 ** 
 ** @param xcb_connection_t                           *c
 ** @param xcb_x_print_print_get_attributes_cookie_t   cookie
 ** @param xcb_generic_error_t                       **e
 ** @returns xcb_x_print_print_get_attributes_reply_t *
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_print_get_attributes_reply_t *
xcb_x_print_print_get_attributes_reply (xcb_connection_t                           *c  /**< */,
                                        xcb_x_print_print_get_attributes_cookie_t   cookie  /**< */,
                                        xcb_generic_error_t                       **e  /**< */);


/*****************************************************************************
 **
 ** xcb_x_print_print_get_one_attributes_cookie_t xcb_x_print_print_get_one_attributes
 ** 
 ** @param xcb_connection_t                *c
 ** @param xcb_x_print_pcontext_t           context
 ** @param uint                             nameLen
 ** @param ubyte                            pool
 ** @param /+const+/ xcb_x_print_string8_t *name
 ** @returns xcb_x_print_print_get_one_attributes_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_print_get_one_attributes_cookie_t
xcb_x_print_print_get_one_attributes (xcb_connection_t                *c  /**< */,
                                      xcb_x_print_pcontext_t           context  /**< */,
                                      uint                             nameLen  /**< */,
                                      ubyte                            pool  /**< */,
                                      /+const+/ xcb_x_print_string8_t *name  /**< */);


/*****************************************************************************
 **
 ** xcb_x_print_print_get_one_attributes_cookie_t xcb_x_print_print_get_one_attributes_unchecked
 ** 
 ** @param xcb_connection_t                *c
 ** @param xcb_x_print_pcontext_t           context
 ** @param uint                             nameLen
 ** @param ubyte                            pool
 ** @param /+const+/ xcb_x_print_string8_t *name
 ** @returns xcb_x_print_print_get_one_attributes_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_print_get_one_attributes_cookie_t
xcb_x_print_print_get_one_attributes_unchecked (xcb_connection_t                *c  /**< */,
                                                xcb_x_print_pcontext_t           context  /**< */,
                                                uint                             nameLen  /**< */,
                                                ubyte                            pool  /**< */,
                                                /+const+/ xcb_x_print_string8_t *name  /**< */);


/*****************************************************************************
 **
 ** xcb_x_print_string8_t * xcb_x_print_print_get_one_attributes_value
 ** 
 ** @param /+const+/ xcb_x_print_print_get_one_attributes_reply_t *R
 ** @returns xcb_x_print_string8_t *
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_string8_t *
xcb_x_print_print_get_one_attributes_value (/+const+/ xcb_x_print_print_get_one_attributes_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_x_print_print_get_one_attributes_value_length
 ** 
 ** @param /+const+/ xcb_x_print_print_get_one_attributes_reply_t *R
 ** @returns int
 **
 *****************************************************************************/
 
extern(C) int
xcb_x_print_print_get_one_attributes_value_length (/+const+/ xcb_x_print_print_get_one_attributes_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_x_print_string8_iterator_t xcb_x_print_print_get_one_attributes_value_iterator
 ** 
 ** @param /+const+/ xcb_x_print_print_get_one_attributes_reply_t *R
 ** @returns xcb_x_print_string8_iterator_t
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_string8_iterator_t
xcb_x_print_print_get_one_attributes_value_iterator (/+const+/ xcb_x_print_print_get_one_attributes_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_x_print_print_get_one_attributes_reply_t * xcb_x_print_print_get_one_attributes_reply
 ** 
 ** @param xcb_connection_t                               *c
 ** @param xcb_x_print_print_get_one_attributes_cookie_t   cookie
 ** @param xcb_generic_error_t                           **e
 ** @returns xcb_x_print_print_get_one_attributes_reply_t *
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_print_get_one_attributes_reply_t *
xcb_x_print_print_get_one_attributes_reply (xcb_connection_t                               *c  /**< */,
                                            xcb_x_print_print_get_one_attributes_cookie_t   cookie  /**< */,
                                            xcb_generic_error_t                           **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_x_print_print_set_attributes_checked
 ** 
 ** @param xcb_connection_t                *c
 ** @param xcb_x_print_pcontext_t           context
 ** @param uint                             stringLen
 ** @param ubyte                            pool
 ** @param ubyte                            rule
 ** @param uint                             attributes_len
 ** @param /+const+/ xcb_x_print_string8_t *attributes
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_void_cookie_t
xcb_x_print_print_set_attributes_checked (xcb_connection_t                *c  /**< */,
                                          xcb_x_print_pcontext_t           context  /**< */,
                                          uint                             stringLen  /**< */,
                                          ubyte                            pool  /**< */,
                                          ubyte                            rule  /**< */,
                                          uint                             attributes_len  /**< */,
                                          /+const+/ xcb_x_print_string8_t *attributes  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_x_print_print_set_attributes
 ** 
 ** @param xcb_connection_t                *c
 ** @param xcb_x_print_pcontext_t           context
 ** @param uint                             stringLen
 ** @param ubyte                            pool
 ** @param ubyte                            rule
 ** @param uint                             attributes_len
 ** @param /+const+/ xcb_x_print_string8_t *attributes
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_void_cookie_t
xcb_x_print_print_set_attributes (xcb_connection_t                *c  /**< */,
                                  xcb_x_print_pcontext_t           context  /**< */,
                                  uint                             stringLen  /**< */,
                                  ubyte                            pool  /**< */,
                                  ubyte                            rule  /**< */,
                                  uint                             attributes_len  /**< */,
                                  /+const+/ xcb_x_print_string8_t *attributes  /**< */);


/*****************************************************************************
 **
 ** xcb_x_print_print_get_page_dimensions_cookie_t xcb_x_print_print_get_page_dimensions
 ** 
 ** @param xcb_connection_t       *c
 ** @param xcb_x_print_pcontext_t  context
 ** @returns xcb_x_print_print_get_page_dimensions_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_print_get_page_dimensions_cookie_t
xcb_x_print_print_get_page_dimensions (xcb_connection_t       *c  /**< */,
                                       xcb_x_print_pcontext_t  context  /**< */);


/*****************************************************************************
 **
 ** xcb_x_print_print_get_page_dimensions_cookie_t xcb_x_print_print_get_page_dimensions_unchecked
 ** 
 ** @param xcb_connection_t       *c
 ** @param xcb_x_print_pcontext_t  context
 ** @returns xcb_x_print_print_get_page_dimensions_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_print_get_page_dimensions_cookie_t
xcb_x_print_print_get_page_dimensions_unchecked (xcb_connection_t       *c  /**< */,
                                                 xcb_x_print_pcontext_t  context  /**< */);


/*****************************************************************************
 **
 ** xcb_x_print_print_get_page_dimensions_reply_t * xcb_x_print_print_get_page_dimensions_reply
 ** 
 ** @param xcb_connection_t                                *c
 ** @param xcb_x_print_print_get_page_dimensions_cookie_t   cookie
 ** @param xcb_generic_error_t                            **e
 ** @returns xcb_x_print_print_get_page_dimensions_reply_t *
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_print_get_page_dimensions_reply_t *
xcb_x_print_print_get_page_dimensions_reply (xcb_connection_t                                *c  /**< */,
                                             xcb_x_print_print_get_page_dimensions_cookie_t   cookie  /**< */,
                                             xcb_generic_error_t                            **e  /**< */);


/*****************************************************************************
 **
 ** xcb_x_print_print_query_screens_cookie_t xcb_x_print_print_query_screens
 ** 
 ** @param xcb_connection_t *c
 ** @returns xcb_x_print_print_query_screens_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_print_query_screens_cookie_t
xcb_x_print_print_query_screens (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_x_print_print_query_screens_cookie_t xcb_x_print_print_query_screens_unchecked
 ** 
 ** @param xcb_connection_t *c
 ** @returns xcb_x_print_print_query_screens_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_print_query_screens_cookie_t
xcb_x_print_print_query_screens_unchecked (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_window_t * xcb_x_print_print_query_screens_roots
 ** 
 ** @param /+const+/ xcb_x_print_print_query_screens_reply_t *R
 ** @returns xcb_window_t *
 **
 *****************************************************************************/
 
extern(C) xcb_window_t *
xcb_x_print_print_query_screens_roots (/+const+/ xcb_x_print_print_query_screens_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_x_print_print_query_screens_roots_length
 ** 
 ** @param /+const+/ xcb_x_print_print_query_screens_reply_t *R
 ** @returns int
 **
 *****************************************************************************/
 
extern(C) int
xcb_x_print_print_query_screens_roots_length (/+const+/ xcb_x_print_print_query_screens_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_window_iterator_t xcb_x_print_print_query_screens_roots_iterator
 ** 
 ** @param /+const+/ xcb_x_print_print_query_screens_reply_t *R
 ** @returns xcb_window_iterator_t
 **
 *****************************************************************************/
 
extern(C) xcb_window_iterator_t
xcb_x_print_print_query_screens_roots_iterator (/+const+/ xcb_x_print_print_query_screens_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_x_print_print_query_screens_reply_t * xcb_x_print_print_query_screens_reply
 ** 
 ** @param xcb_connection_t                          *c
 ** @param xcb_x_print_print_query_screens_cookie_t   cookie
 ** @param xcb_generic_error_t                      **e
 ** @returns xcb_x_print_print_query_screens_reply_t *
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_print_query_screens_reply_t *
xcb_x_print_print_query_screens_reply (xcb_connection_t                          *c  /**< */,
                                       xcb_x_print_print_query_screens_cookie_t   cookie  /**< */,
                                       xcb_generic_error_t                      **e  /**< */);


/*****************************************************************************
 **
 ** xcb_x_print_print_set_image_resolution_cookie_t xcb_x_print_print_set_image_resolution
 ** 
 ** @param xcb_connection_t       *c
 ** @param xcb_x_print_pcontext_t  context
 ** @param ushort                  image_resolution
 ** @returns xcb_x_print_print_set_image_resolution_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_print_set_image_resolution_cookie_t
xcb_x_print_print_set_image_resolution (xcb_connection_t       *c  /**< */,
                                        xcb_x_print_pcontext_t  context  /**< */,
                                        ushort                  image_resolution  /**< */);


/*****************************************************************************
 **
 ** xcb_x_print_print_set_image_resolution_cookie_t xcb_x_print_print_set_image_resolution_unchecked
 ** 
 ** @param xcb_connection_t       *c
 ** @param xcb_x_print_pcontext_t  context
 ** @param ushort                  image_resolution
 ** @returns xcb_x_print_print_set_image_resolution_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_print_set_image_resolution_cookie_t
xcb_x_print_print_set_image_resolution_unchecked (xcb_connection_t       *c  /**< */,
                                                  xcb_x_print_pcontext_t  context  /**< */,
                                                  ushort                  image_resolution  /**< */);


/*****************************************************************************
 **
 ** xcb_x_print_print_set_image_resolution_reply_t * xcb_x_print_print_set_image_resolution_reply
 ** 
 ** @param xcb_connection_t                                 *c
 ** @param xcb_x_print_print_set_image_resolution_cookie_t   cookie
 ** @param xcb_generic_error_t                             **e
 ** @returns xcb_x_print_print_set_image_resolution_reply_t *
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_print_set_image_resolution_reply_t *
xcb_x_print_print_set_image_resolution_reply (xcb_connection_t                                 *c  /**< */,
                                              xcb_x_print_print_set_image_resolution_cookie_t   cookie  /**< */,
                                              xcb_generic_error_t                             **e  /**< */);


/*****************************************************************************
 **
 ** xcb_x_print_print_get_image_resolution_cookie_t xcb_x_print_print_get_image_resolution
 ** 
 ** @param xcb_connection_t       *c
 ** @param xcb_x_print_pcontext_t  context
 ** @returns xcb_x_print_print_get_image_resolution_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_print_get_image_resolution_cookie_t
xcb_x_print_print_get_image_resolution (xcb_connection_t       *c  /**< */,
                                        xcb_x_print_pcontext_t  context  /**< */);


/*****************************************************************************
 **
 ** xcb_x_print_print_get_image_resolution_cookie_t xcb_x_print_print_get_image_resolution_unchecked
 ** 
 ** @param xcb_connection_t       *c
 ** @param xcb_x_print_pcontext_t  context
 ** @returns xcb_x_print_print_get_image_resolution_cookie_t
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_print_get_image_resolution_cookie_t
xcb_x_print_print_get_image_resolution_unchecked (xcb_connection_t       *c  /**< */,
                                                  xcb_x_print_pcontext_t  context  /**< */);


/*****************************************************************************
 **
 ** xcb_x_print_print_get_image_resolution_reply_t * xcb_x_print_print_get_image_resolution_reply
 ** 
 ** @param xcb_connection_t                                 *c
 ** @param xcb_x_print_print_get_image_resolution_cookie_t   cookie
 ** @param xcb_generic_error_t                             **e
 ** @returns xcb_x_print_print_get_image_resolution_reply_t *
 **
 *****************************************************************************/
 
extern(C) xcb_x_print_print_get_image_resolution_reply_t *
xcb_x_print_print_get_image_resolution_reply (xcb_connection_t                                 *c  /**< */,
                                              xcb_x_print_print_get_image_resolution_cookie_t   cookie  /**< */,
                                              xcb_generic_error_t                             **e  /**< */);



/**
 * @}
 */
