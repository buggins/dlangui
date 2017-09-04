/*
 * This file generated automatically from xf86dri.xml by c-client.xsl using XSLT.
 * Edit at your peril.
 */

/**
 * @defgroup XCB_XF86Dri_API XCB XF86Dri API
 * @brief XF86Dri XCB Protocol Implementation.
 * @{
 **/


module std.c.linux.X11.xcb.xf86dri;
version(USE_XCB):

import std.c.linux.X11.xcb.xcb;

const int XCB_XF86DRI_MAJOR_VERSION =4;
const int XCB_XF86DRI_MINOR_VERSION =1;

extern(C) extern xcb_extension_t xcb_xf86dri_id;

/**
 * @brief xcb_xf86dri_drm_clip_rect_t
 **/
struct xcb_xf86dri_drm_clip_rect_t {
    short x1; /**<  */
    short y1; /**<  */
    short x2; /**<  */
    short x3; /**<  */
} ;

/**
 * @brief xcb_xf86dri_drm_clip_rect_iterator_t
 **/
struct xcb_xf86dri_drm_clip_rect_iterator_t {
    xcb_xf86dri_drm_clip_rect_t *data; /**<  */
    int                          rem; /**<  */
    int                          index; /**<  */
} ;

/**
 * @brief xcb_xf86dri_query_version_cookie_t
 **/
struct xcb_xf86dri_query_version_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_xf86dri_query_version. */
const uint XCB_XF86DRI_QUERY_VERSION = 0;

/**
 * @brief xcb_xf86dri_query_version_request_t
 **/
struct xcb_xf86dri_query_version_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
} ;

/**
 * @brief xcb_xf86dri_query_version_reply_t
 **/
struct xcb_xf86dri_query_version_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ushort dri_major_version; /**<  */
    ushort dri_minor_version; /**<  */
    uint   dri_minor_patch; /**<  */
} ;

/**
 * @brief xcb_xf86dri_query_direct_rendering_capable_cookie_t
 **/
struct xcb_xf86dri_query_direct_rendering_capable_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_xf86dri_query_direct_rendering_capable. */
const uint XCB_XF86DRI_QUERY_DIRECT_RENDERING_CAPABLE = 1;

/**
 * @brief xcb_xf86dri_query_direct_rendering_capable_request_t
 **/
struct xcb_xf86dri_query_direct_rendering_capable_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
    uint   screen; /**<  */
} ;

/**
 * @brief xcb_xf86dri_query_direct_rendering_capable_reply_t
 **/
struct xcb_xf86dri_query_direct_rendering_capable_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    bool   is_capable; /**<  */
} ;

/**
 * @brief xcb_xf86dri_open_connection_cookie_t
 **/
struct xcb_xf86dri_open_connection_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_xf86dri_open_connection. */
const uint XCB_XF86DRI_OPEN_CONNECTION = 2;

/**
 * @brief xcb_xf86dri_open_connection_request_t
 **/
struct xcb_xf86dri_open_connection_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
    uint   screen; /**<  */
} ;

/**
 * @brief xcb_xf86dri_open_connection_reply_t
 **/
struct xcb_xf86dri_open_connection_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    uint   drm_client_key_low; /**<  */
    uint   drm_client_key_high; /**<  */
    uint   sarea_handle_low; /**<  */
    uint   sarea_handle_high; /**<  */
    uint   bus_id_len; /**<  */
    ubyte  pad1[12]; /**<  */
} ;

/** Opcode for xcb_xf86dri_close_connection. */
const uint XCB_XF86DRI_CLOSE_CONNECTION = 3;

/**
 * @brief xcb_xf86dri_close_connection_request_t
 **/
struct xcb_xf86dri_close_connection_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
    uint   screen; /**<  */
} ;

/**
 * @brief xcb_xf86dri_get_client_driver_name_cookie_t
 **/
struct xcb_xf86dri_get_client_driver_name_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_xf86dri_get_client_driver_name. */
const uint XCB_XF86DRI_GET_CLIENT_DRIVER_NAME = 4;

/**
 * @brief xcb_xf86dri_get_client_driver_name_request_t
 **/
struct xcb_xf86dri_get_client_driver_name_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
    uint   screen; /**<  */
} ;

/**
 * @brief xcb_xf86dri_get_client_driver_name_reply_t
 **/
struct xcb_xf86dri_get_client_driver_name_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    uint   client_driver_major_version; /**<  */
    uint   client_driver_minor_version; /**<  */
    uint   client_driver_patch_version; /**<  */
    uint   client_driver_name_len; /**<  */
    ubyte  pad1[8]; /**<  */
} ;

/**
 * @brief xcb_xf86dri_create_context_cookie_t
 **/
struct xcb_xf86dri_create_context_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_xf86dri_create_context. */
const uint XCB_XF86DRI_CREATE_CONTEXT = 5;

/**
 * @brief xcb_xf86dri_create_context_request_t
 **/
struct xcb_xf86dri_create_context_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
    uint   visual; /**<  */
    uint   screen; /**<  */
    uint   context; /**<  */
} ;

/**
 * @brief xcb_xf86dri_create_context_reply_t
 **/
struct xcb_xf86dri_create_context_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    uint   hw_context; /**<  */
} ;

/** Opcode for xcb_xf86dri_destroy_context. */
const uint XCB_XF86DRI_DESTROY_CONTEXT = 6;

/**
 * @brief xcb_xf86dri_destroy_context_request_t
 **/
struct xcb_xf86dri_destroy_context_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
    uint   screen; /**<  */
    uint   context; /**<  */
} ;

/**
 * @brief xcb_xf86dri_create_drawable_cookie_t
 **/
struct xcb_xf86dri_create_drawable_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_xf86dri_create_drawable. */
const uint XCB_XF86DRI_CREATE_DRAWABLE = 7;

/**
 * @brief xcb_xf86dri_create_drawable_request_t
 **/
struct xcb_xf86dri_create_drawable_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
    uint   screen; /**<  */
    uint   drawable; /**<  */
} ;

/**
 * @brief xcb_xf86dri_create_drawable_reply_t
 **/
struct xcb_xf86dri_create_drawable_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    uint   hw_drawable_handle; /**<  */
} ;

/** Opcode for xcb_xf86dri_destroy_drawable. */
const uint XCB_XF86DRI_DESTROY_DRAWABLE = 8;

/**
 * @brief xcb_xf86dri_destroy_drawable_request_t
 **/
struct xcb_xf86dri_destroy_drawable_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
    uint   screen; /**<  */
    uint   drawable; /**<  */
} ;

/**
 * @brief xcb_xf86dri_get_drawable_info_cookie_t
 **/
struct xcb_xf86dri_get_drawable_info_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_xf86dri_get_drawable_info. */
const uint XCB_XF86DRI_GET_DRAWABLE_INFO = 9;

/**
 * @brief xcb_xf86dri_get_drawable_info_request_t
 **/
struct xcb_xf86dri_get_drawable_info_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
    uint   screen; /**<  */
    uint   drawable; /**<  */
} ;

/**
 * @brief xcb_xf86dri_get_drawable_info_reply_t
 **/
struct xcb_xf86dri_get_drawable_info_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    uint   drawable_table_index; /**<  */
    uint   drawable_table_stamp; /**<  */
    short  drawable_origin_X; /**<  */
    short  drawable_origin_Y; /**<  */
    short  drawable_size_W; /**<  */
    short  drawable_size_H; /**<  */
    uint   num_clip_rects; /**<  */
    ubyte  pad1[4]; /**<  */
} ;

/**
 * @brief xcb_xf86dri_get_device_info_cookie_t
 **/
struct xcb_xf86dri_get_device_info_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_xf86dri_get_device_info. */
const uint XCB_XF86DRI_GET_DEVICE_INFO = 10;

/**
 * @brief xcb_xf86dri_get_device_info_request_t
 **/
struct xcb_xf86dri_get_device_info_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
    uint   screen; /**<  */
} ;

/**
 * @brief xcb_xf86dri_get_device_info_reply_t
 **/
struct xcb_xf86dri_get_device_info_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    uint   framebuffer_handle_low; /**<  */
    uint   framebuffer_handle_high; /**<  */
    uint   framebuffer_origin_offset; /**<  */
    uint   framebuffer_size; /**<  */
    uint   framebuffer_stride; /**<  */
    uint   device_private_size; /**<  */
} ;

/**
 * @brief xcb_xf86dri_auth_connection_cookie_t
 **/
struct xcb_xf86dri_auth_connection_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_xf86dri_auth_connection. */
const uint XCB_XF86DRI_AUTH_CONNECTION = 11;

/**
 * @brief xcb_xf86dri_auth_connection_request_t
 **/
struct xcb_xf86dri_auth_connection_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
    uint   screen; /**<  */
    uint   magic; /**<  */
} ;

/**
 * @brief xcb_xf86dri_auth_connection_reply_t
 **/
struct xcb_xf86dri_auth_connection_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    uint   authenticated; /**<  */
} ;


/*****************************************************************************
 **
 ** void xcb_xf86dri_drm_clip_rect_next
 **
 ** @param xcb_xf86dri_drm_clip_rect_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_xf86dri_drm_clip_rect_next (xcb_xf86dri_drm_clip_rect_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_xf86dri_drm_clip_rect_end
 **
 ** @param xcb_xf86dri_drm_clip_rect_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_xf86dri_drm_clip_rect_end (xcb_xf86dri_drm_clip_rect_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** xcb_xf86dri_query_version_cookie_t xcb_xf86dri_query_version
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_xf86dri_query_version_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_xf86dri_query_version_cookie_t
xcb_xf86dri_query_version (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_xf86dri_query_version_cookie_t xcb_xf86dri_query_version_unchecked
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_xf86dri_query_version_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_xf86dri_query_version_cookie_t
xcb_xf86dri_query_version_unchecked (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_xf86dri_query_version_reply_t * xcb_xf86dri_query_version_reply
 **
 ** @param xcb_connection_t                    *c
 ** @param xcb_xf86dri_query_version_cookie_t   cookie
 ** @param xcb_generic_error_t                **e
 ** @returns xcb_xf86dri_query_version_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_xf86dri_query_version_reply_t *
xcb_xf86dri_query_version_reply (xcb_connection_t                    *c  /**< */,
                                 xcb_xf86dri_query_version_cookie_t   cookie  /**< */,
                                 xcb_generic_error_t                **e  /**< */);


/*****************************************************************************
 **
 ** xcb_xf86dri_query_direct_rendering_capable_cookie_t xcb_xf86dri_query_direct_rendering_capable
 **
 ** @param xcb_connection_t *c
 ** @param uint              screen
 ** @returns xcb_xf86dri_query_direct_rendering_capable_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_xf86dri_query_direct_rendering_capable_cookie_t
xcb_xf86dri_query_direct_rendering_capable (xcb_connection_t *c  /**< */,
                                            uint              screen  /**< */);


/*****************************************************************************
 **
 ** xcb_xf86dri_query_direct_rendering_capable_cookie_t xcb_xf86dri_query_direct_rendering_capable_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param uint              screen
 ** @returns xcb_xf86dri_query_direct_rendering_capable_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_xf86dri_query_direct_rendering_capable_cookie_t
xcb_xf86dri_query_direct_rendering_capable_unchecked (xcb_connection_t *c  /**< */,
                                                      uint              screen  /**< */);


/*****************************************************************************
 **
 ** xcb_xf86dri_query_direct_rendering_capable_reply_t * xcb_xf86dri_query_direct_rendering_capable_reply
 **
 ** @param xcb_connection_t                                     *c
 ** @param xcb_xf86dri_query_direct_rendering_capable_cookie_t   cookie
 ** @param xcb_generic_error_t                                 **e
 ** @returns xcb_xf86dri_query_direct_rendering_capable_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_xf86dri_query_direct_rendering_capable_reply_t *
xcb_xf86dri_query_direct_rendering_capable_reply (xcb_connection_t                                     *c  /**< */,
                                                  xcb_xf86dri_query_direct_rendering_capable_cookie_t   cookie  /**< */,
                                                  xcb_generic_error_t                                 **e  /**< */);


/*****************************************************************************
 **
 ** xcb_xf86dri_open_connection_cookie_t xcb_xf86dri_open_connection
 **
 ** @param xcb_connection_t *c
 ** @param uint              screen
 ** @returns xcb_xf86dri_open_connection_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_xf86dri_open_connection_cookie_t
xcb_xf86dri_open_connection (xcb_connection_t *c  /**< */,
                             uint              screen  /**< */);


/*****************************************************************************
 **
 ** xcb_xf86dri_open_connection_cookie_t xcb_xf86dri_open_connection_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param uint              screen
 ** @returns xcb_xf86dri_open_connection_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_xf86dri_open_connection_cookie_t
xcb_xf86dri_open_connection_unchecked (xcb_connection_t *c  /**< */,
                                       uint              screen  /**< */);


/*****************************************************************************
 **
 ** ubyte * xcb_xf86dri_open_connection_bus_id
 **
 ** @param /+const+/ xcb_xf86dri_open_connection_reply_t *R
 ** @returns ubyte *
 **
 *****************************************************************************/

extern(C) ubyte *
xcb_xf86dri_open_connection_bus_id (/+const+/ xcb_xf86dri_open_connection_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_xf86dri_open_connection_bus_id_length
 **
 ** @param /+const+/ xcb_xf86dri_open_connection_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_xf86dri_open_connection_bus_id_length (/+const+/ xcb_xf86dri_open_connection_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_xf86dri_open_connection_bus_id_end
 **
 ** @param /+const+/ xcb_xf86dri_open_connection_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_xf86dri_open_connection_bus_id_end (/+const+/ xcb_xf86dri_open_connection_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_xf86dri_open_connection_reply_t * xcb_xf86dri_open_connection_reply
 **
 ** @param xcb_connection_t                      *c
 ** @param xcb_xf86dri_open_connection_cookie_t   cookie
 ** @param xcb_generic_error_t                  **e
 ** @returns xcb_xf86dri_open_connection_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_xf86dri_open_connection_reply_t *
xcb_xf86dri_open_connection_reply (xcb_connection_t                      *c  /**< */,
                                   xcb_xf86dri_open_connection_cookie_t   cookie  /**< */,
                                   xcb_generic_error_t                  **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xf86dri_close_connection_checked
 **
 ** @param xcb_connection_t *c
 ** @param uint              screen
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xf86dri_close_connection_checked (xcb_connection_t *c  /**< */,
                                      uint              screen  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xf86dri_close_connection
 **
 ** @param xcb_connection_t *c
 ** @param uint              screen
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xf86dri_close_connection (xcb_connection_t *c  /**< */,
                              uint              screen  /**< */);


/*****************************************************************************
 **
 ** xcb_xf86dri_get_client_driver_name_cookie_t xcb_xf86dri_get_client_driver_name
 **
 ** @param xcb_connection_t *c
 ** @param uint              screen
 ** @returns xcb_xf86dri_get_client_driver_name_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_xf86dri_get_client_driver_name_cookie_t
xcb_xf86dri_get_client_driver_name (xcb_connection_t *c  /**< */,
                                    uint              screen  /**< */);


/*****************************************************************************
 **
 ** xcb_xf86dri_get_client_driver_name_cookie_t xcb_xf86dri_get_client_driver_name_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param uint              screen
 ** @returns xcb_xf86dri_get_client_driver_name_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_xf86dri_get_client_driver_name_cookie_t
xcb_xf86dri_get_client_driver_name_unchecked (xcb_connection_t *c  /**< */,
                                              uint              screen  /**< */);


/*****************************************************************************
 **
 ** ubyte * xcb_xf86dri_get_client_driver_name_client_driver_name
 **
 ** @param /+const+/ xcb_xf86dri_get_client_driver_name_reply_t *R
 ** @returns ubyte *
 **
 *****************************************************************************/

extern(C) ubyte *
xcb_xf86dri_get_client_driver_name_client_driver_name (/+const+/ xcb_xf86dri_get_client_driver_name_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_xf86dri_get_client_driver_name_client_driver_name_length
 **
 ** @param /+const+/ xcb_xf86dri_get_client_driver_name_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_xf86dri_get_client_driver_name_client_driver_name_length (/+const+/ xcb_xf86dri_get_client_driver_name_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_xf86dri_get_client_driver_name_client_driver_name_end
 **
 ** @param /+const+/ xcb_xf86dri_get_client_driver_name_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_xf86dri_get_client_driver_name_client_driver_name_end (/+const+/ xcb_xf86dri_get_client_driver_name_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_xf86dri_get_client_driver_name_reply_t * xcb_xf86dri_get_client_driver_name_reply
 **
 ** @param xcb_connection_t                             *c
 ** @param xcb_xf86dri_get_client_driver_name_cookie_t   cookie
 ** @param xcb_generic_error_t                         **e
 ** @returns xcb_xf86dri_get_client_driver_name_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_xf86dri_get_client_driver_name_reply_t *
xcb_xf86dri_get_client_driver_name_reply (xcb_connection_t                             *c  /**< */,
                                          xcb_xf86dri_get_client_driver_name_cookie_t   cookie  /**< */,
                                          xcb_generic_error_t                         **e  /**< */);


/*****************************************************************************
 **
 ** xcb_xf86dri_create_context_cookie_t xcb_xf86dri_create_context
 **
 ** @param xcb_connection_t *c
 ** @param uint              visual
 ** @param uint              screen
 ** @param uint              context
 ** @returns xcb_xf86dri_create_context_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_xf86dri_create_context_cookie_t
xcb_xf86dri_create_context (xcb_connection_t *c  /**< */,
                            uint              visual  /**< */,
                            uint              screen  /**< */,
                            uint              context  /**< */);


/*****************************************************************************
 **
 ** xcb_xf86dri_create_context_cookie_t xcb_xf86dri_create_context_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param uint              visual
 ** @param uint              screen
 ** @param uint              context
 ** @returns xcb_xf86dri_create_context_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_xf86dri_create_context_cookie_t
xcb_xf86dri_create_context_unchecked (xcb_connection_t *c  /**< */,
                                      uint              visual  /**< */,
                                      uint              screen  /**< */,
                                      uint              context  /**< */);


/*****************************************************************************
 **
 ** xcb_xf86dri_create_context_reply_t * xcb_xf86dri_create_context_reply
 **
 ** @param xcb_connection_t                     *c
 ** @param xcb_xf86dri_create_context_cookie_t   cookie
 ** @param xcb_generic_error_t                 **e
 ** @returns xcb_xf86dri_create_context_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_xf86dri_create_context_reply_t *
xcb_xf86dri_create_context_reply (xcb_connection_t                     *c  /**< */,
                                  xcb_xf86dri_create_context_cookie_t   cookie  /**< */,
                                  xcb_generic_error_t                 **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xf86dri_destroy_context_checked
 **
 ** @param xcb_connection_t *c
 ** @param uint              screen
 ** @param uint              context
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xf86dri_destroy_context_checked (xcb_connection_t *c  /**< */,
                                     uint              screen  /**< */,
                                     uint              context  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xf86dri_destroy_context
 **
 ** @param xcb_connection_t *c
 ** @param uint              screen
 ** @param uint              context
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xf86dri_destroy_context (xcb_connection_t *c  /**< */,
                             uint              screen  /**< */,
                             uint              context  /**< */);


/*****************************************************************************
 **
 ** xcb_xf86dri_create_drawable_cookie_t xcb_xf86dri_create_drawable
 **
 ** @param xcb_connection_t *c
 ** @param uint              screen
 ** @param uint              drawable
 ** @returns xcb_xf86dri_create_drawable_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_xf86dri_create_drawable_cookie_t
xcb_xf86dri_create_drawable (xcb_connection_t *c  /**< */,
                             uint              screen  /**< */,
                             uint              drawable  /**< */);


/*****************************************************************************
 **
 ** xcb_xf86dri_create_drawable_cookie_t xcb_xf86dri_create_drawable_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param uint              screen
 ** @param uint              drawable
 ** @returns xcb_xf86dri_create_drawable_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_xf86dri_create_drawable_cookie_t
xcb_xf86dri_create_drawable_unchecked (xcb_connection_t *c  /**< */,
                                       uint              screen  /**< */,
                                       uint              drawable  /**< */);


/*****************************************************************************
 **
 ** xcb_xf86dri_create_drawable_reply_t * xcb_xf86dri_create_drawable_reply
 **
 ** @param xcb_connection_t                      *c
 ** @param xcb_xf86dri_create_drawable_cookie_t   cookie
 ** @param xcb_generic_error_t                  **e
 ** @returns xcb_xf86dri_create_drawable_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_xf86dri_create_drawable_reply_t *
xcb_xf86dri_create_drawable_reply (xcb_connection_t                      *c  /**< */,
                                   xcb_xf86dri_create_drawable_cookie_t   cookie  /**< */,
                                   xcb_generic_error_t                  **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xf86dri_destroy_drawable_checked
 **
 ** @param xcb_connection_t *c
 ** @param uint              screen
 ** @param uint              drawable
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xf86dri_destroy_drawable_checked (xcb_connection_t *c  /**< */,
                                      uint              screen  /**< */,
                                      uint              drawable  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_xf86dri_destroy_drawable
 **
 ** @param xcb_connection_t *c
 ** @param uint              screen
 ** @param uint              drawable
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_xf86dri_destroy_drawable (xcb_connection_t *c  /**< */,
                              uint              screen  /**< */,
                              uint              drawable  /**< */);


/*****************************************************************************
 **
 ** xcb_xf86dri_get_drawable_info_cookie_t xcb_xf86dri_get_drawable_info
 **
 ** @param xcb_connection_t *c
 ** @param uint              screen
 ** @param uint              drawable
 ** @returns xcb_xf86dri_get_drawable_info_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_xf86dri_get_drawable_info_cookie_t
xcb_xf86dri_get_drawable_info (xcb_connection_t *c  /**< */,
                               uint              screen  /**< */,
                               uint              drawable  /**< */);


/*****************************************************************************
 **
 ** xcb_xf86dri_get_drawable_info_cookie_t xcb_xf86dri_get_drawable_info_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param uint              screen
 ** @param uint              drawable
 ** @returns xcb_xf86dri_get_drawable_info_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_xf86dri_get_drawable_info_cookie_t
xcb_xf86dri_get_drawable_info_unchecked (xcb_connection_t *c  /**< */,
                                         uint              screen  /**< */,
                                         uint              drawable  /**< */);


/*****************************************************************************
 **
 ** xcb_xf86dri_drm_clip_rect_t * xcb_xf86dri_get_drawable_info_clip_rects
 **
 ** @param /+const+/ xcb_xf86dri_get_drawable_info_reply_t *R
 ** @returns xcb_xf86dri_drm_clip_rect_t *
 **
 *****************************************************************************/

extern(C) xcb_xf86dri_drm_clip_rect_t *
xcb_xf86dri_get_drawable_info_clip_rects (/+const+/ xcb_xf86dri_get_drawable_info_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_xf86dri_get_drawable_info_clip_rects_length
 **
 ** @param /+const+/ xcb_xf86dri_get_drawable_info_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_xf86dri_get_drawable_info_clip_rects_length (/+const+/ xcb_xf86dri_get_drawable_info_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_xf86dri_drm_clip_rect_iterator_t xcb_xf86dri_get_drawable_info_clip_rects_iterator
 **
 ** @param /+const+/ xcb_xf86dri_get_drawable_info_reply_t *R
 ** @returns xcb_xf86dri_drm_clip_rect_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_xf86dri_drm_clip_rect_iterator_t
xcb_xf86dri_get_drawable_info_clip_rects_iterator (/+const+/ xcb_xf86dri_get_drawable_info_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_xf86dri_get_drawable_info_reply_t * xcb_xf86dri_get_drawable_info_reply
 **
 ** @param xcb_connection_t                        *c
 ** @param xcb_xf86dri_get_drawable_info_cookie_t   cookie
 ** @param xcb_generic_error_t                    **e
 ** @returns xcb_xf86dri_get_drawable_info_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_xf86dri_get_drawable_info_reply_t *
xcb_xf86dri_get_drawable_info_reply (xcb_connection_t                        *c  /**< */,
                                     xcb_xf86dri_get_drawable_info_cookie_t   cookie  /**< */,
                                     xcb_generic_error_t                    **e  /**< */);


/*****************************************************************************
 **
 ** xcb_xf86dri_get_device_info_cookie_t xcb_xf86dri_get_device_info
 **
 ** @param xcb_connection_t *c
 ** @param uint              screen
 ** @returns xcb_xf86dri_get_device_info_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_xf86dri_get_device_info_cookie_t
xcb_xf86dri_get_device_info (xcb_connection_t *c  /**< */,
                             uint              screen  /**< */);


/*****************************************************************************
 **
 ** xcb_xf86dri_get_device_info_cookie_t xcb_xf86dri_get_device_info_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param uint              screen
 ** @returns xcb_xf86dri_get_device_info_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_xf86dri_get_device_info_cookie_t
xcb_xf86dri_get_device_info_unchecked (xcb_connection_t *c  /**< */,
                                       uint              screen  /**< */);


/*****************************************************************************
 **
 ** uint * xcb_xf86dri_get_device_info_device_private
 **
 ** @param /+const+/ xcb_xf86dri_get_device_info_reply_t *R
 ** @returns uint *
 **
 *****************************************************************************/

extern(C) uint *
xcb_xf86dri_get_device_info_device_private (/+const+/ xcb_xf86dri_get_device_info_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_xf86dri_get_device_info_device_private_length
 **
 ** @param /+const+/ xcb_xf86dri_get_device_info_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_xf86dri_get_device_info_device_private_length (/+const+/ xcb_xf86dri_get_device_info_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_xf86dri_get_device_info_device_private_end
 **
 ** @param /+const+/ xcb_xf86dri_get_device_info_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_xf86dri_get_device_info_device_private_end (/+const+/ xcb_xf86dri_get_device_info_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_xf86dri_get_device_info_reply_t * xcb_xf86dri_get_device_info_reply
 **
 ** @param xcb_connection_t                      *c
 ** @param xcb_xf86dri_get_device_info_cookie_t   cookie
 ** @param xcb_generic_error_t                  **e
 ** @returns xcb_xf86dri_get_device_info_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_xf86dri_get_device_info_reply_t *
xcb_xf86dri_get_device_info_reply (xcb_connection_t                      *c  /**< */,
                                   xcb_xf86dri_get_device_info_cookie_t   cookie  /**< */,
                                   xcb_generic_error_t                  **e  /**< */);


/*****************************************************************************
 **
 ** xcb_xf86dri_auth_connection_cookie_t xcb_xf86dri_auth_connection
 **
 ** @param xcb_connection_t *c
 ** @param uint              screen
 ** @param uint              magic
 ** @returns xcb_xf86dri_auth_connection_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_xf86dri_auth_connection_cookie_t
xcb_xf86dri_auth_connection (xcb_connection_t *c  /**< */,
                             uint              screen  /**< */,
                             uint              magic  /**< */);


/*****************************************************************************
 **
 ** xcb_xf86dri_auth_connection_cookie_t xcb_xf86dri_auth_connection_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param uint              screen
 ** @param uint              magic
 ** @returns xcb_xf86dri_auth_connection_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_xf86dri_auth_connection_cookie_t
xcb_xf86dri_auth_connection_unchecked (xcb_connection_t *c  /**< */,
                                       uint              screen  /**< */,
                                       uint              magic  /**< */);


/*****************************************************************************
 **
 ** xcb_xf86dri_auth_connection_reply_t * xcb_xf86dri_auth_connection_reply
 **
 ** @param xcb_connection_t                      *c
 ** @param xcb_xf86dri_auth_connection_cookie_t   cookie
 ** @param xcb_generic_error_t                  **e
 ** @returns xcb_xf86dri_auth_connection_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_xf86dri_auth_connection_reply_t *
xcb_xf86dri_auth_connection_reply (xcb_connection_t                      *c  /**< */,
                                   xcb_xf86dri_auth_connection_cookie_t   cookie  /**< */,
                                   xcb_generic_error_t                  **e  /**< */);



/**
 * @}
 */
