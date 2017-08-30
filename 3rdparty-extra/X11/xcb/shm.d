/*
 * This file generated automatically from shm.xml by c-client.xsl using XSLT.
 * Edit at your peril.
 */

/**
 * @defgroup XCB_Shm_API XCB Shm API
 * @brief Shm XCB Protocol Implementation.
 * @{
 **/


module std.c.linux.X11.xcb.shm;
version(USE_XCB):

import std.c.linux.X11.xcb.xcb;
import std.c.linux.X11.xcb.xproto;

const int XCB_SHM_MAJOR_VERSION =1;
const int XCB_SHM_MINOR_VERSION =1;

extern(C) extern xcb_extension_t xcb_shm_id;

alias uint xcb_shm_seg_t;

/**
 * @brief xcb_shm_seg_iterator_t
 **/
struct xcb_shm_seg_iterator_t {
    xcb_shm_seg_t *data; /**<  */
    int            rem; /**<  */
    int            index; /**<  */
} ;

/** Opcode for xcb_shm_completion. */
const uint XCB_SHM_COMPLETION = 0;

/**
 * @brief xcb_shm_completion_event_t
 **/
struct xcb_shm_completion_event_t {
    ubyte          response_type; /**<  */
    ubyte          pad0; /**<  */
    ushort         sequence; /**<  */
    xcb_drawable_t drawable; /**<  */
    xcb_shm_seg_t  shmseg; /**<  */
    ushort         minor_event; /**<  */
    ubyte          major_event; /**<  */
    ubyte          pad1; /**<  */
    uint           offset; /**<  */
} ;

/** Opcode for xcb_shm_bad_seg. */
const uint XCB_SHM_BAD_SEG = 0;

alias xcb_value_error_t xcb_shm_bad_seg_error_t;

/**
 * @brief xcb_shm_query_version_cookie_t
 **/
struct xcb_shm_query_version_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_shm_query_version. */
const uint XCB_SHM_QUERY_VERSION = 0;

/**
 * @brief xcb_shm_query_version_request_t
 **/
struct xcb_shm_query_version_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  minor_opcode; /**<  */
    ushort length; /**<  */
} ;

/**
 * @brief xcb_shm_query_version_reply_t
 **/
struct xcb_shm_query_version_reply_t {
    ubyte  response_type; /**<  */
    bool   shared_pixmaps; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ushort major_version; /**<  */
    ushort minor_version; /**<  */
    ushort uid; /**<  */
    ushort gid; /**<  */
    ubyte  pixmap_format; /**<  */
} ;

/** Opcode for xcb_shm_attach. */
const uint XCB_SHM_ATTACH = 1;

/**
 * @brief xcb_shm_attach_request_t
 **/
struct xcb_shm_attach_request_t {
    ubyte         major_opcode; /**<  */
    ubyte         minor_opcode; /**<  */
    ushort        length; /**<  */
    xcb_shm_seg_t shmseg; /**<  */
    uint          shmid; /**<  */
    bool          read_only; /**<  */
} ;

/** Opcode for xcb_shm_detach. */
const uint XCB_SHM_DETACH = 2;

/**
 * @brief xcb_shm_detach_request_t
 **/
struct xcb_shm_detach_request_t {
    ubyte         major_opcode; /**<  */
    ubyte         minor_opcode; /**<  */
    ushort        length; /**<  */
    xcb_shm_seg_t shmseg; /**<  */
} ;

/** Opcode for xcb_shm_put_image. */
const uint XCB_SHM_PUT_IMAGE = 3;

/**
 * @brief xcb_shm_put_image_request_t
 **/
struct xcb_shm_put_image_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          minor_opcode; /**<  */
    ushort         length; /**<  */
    xcb_drawable_t drawable; /**<  */
    xcb_gcontext_t gc; /**<  */
    ushort         total_width; /**<  */
    ushort         total_height; /**<  */
    ushort         src_x; /**<  */
    ushort         src_y; /**<  */
    ushort         src_width; /**<  */
    ushort         src_height; /**<  */
    short          dst_x; /**<  */
    short          dst_y; /**<  */
    ubyte          depth; /**<  */
    ubyte          format; /**<  */
    ubyte          send_event; /**<  */
    ubyte          pad0; /**<  */
    xcb_shm_seg_t  shmseg; /**<  */
    uint           offset; /**<  */
} ;

/**
 * @brief xcb_shm_get_image_cookie_t
 **/
struct xcb_shm_get_image_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_shm_get_image. */
const uint XCB_SHM_GET_IMAGE = 4;

/**
 * @brief xcb_shm_get_image_request_t
 **/
struct xcb_shm_get_image_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          minor_opcode; /**<  */
    ushort         length; /**<  */
    xcb_drawable_t drawable; /**<  */
    short          x; /**<  */
    short          y; /**<  */
    ushort         width; /**<  */
    ushort         height; /**<  */
    uint           plane_mask; /**<  */
    ubyte          format; /**<  */
    ubyte          pad0[3]; /**<  */
    xcb_shm_seg_t  shmseg; /**<  */
    uint           offset; /**<  */
} ;

/**
 * @brief xcb_shm_get_image_reply_t
 **/
struct xcb_shm_get_image_reply_t {
    ubyte          response_type; /**<  */
    ubyte          depth; /**<  */
    ushort         sequence; /**<  */
    uint           length; /**<  */
    xcb_visualid_t visual; /**<  */
    uint           size; /**<  */
} ;

/** Opcode for xcb_shm_create_pixmap. */
const uint XCB_SHM_CREATE_PIXMAP = 5;

/**
 * @brief xcb_shm_create_pixmap_request_t
 **/
struct xcb_shm_create_pixmap_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          minor_opcode; /**<  */
    ushort         length; /**<  */
    xcb_pixmap_t   pid; /**<  */
    xcb_drawable_t drawable; /**<  */
    ushort         width; /**<  */
    ushort         height; /**<  */
    ubyte          depth; /**<  */
    ubyte          pad0[3]; /**<  */
    xcb_shm_seg_t  shmseg; /**<  */
    uint           offset; /**<  */
} ;


/*****************************************************************************
 **
 ** void xcb_shm_seg_next
 **
 ** @param xcb_shm_seg_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_shm_seg_next (xcb_shm_seg_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_shm_seg_end
 **
 ** @param xcb_shm_seg_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_shm_seg_end (xcb_shm_seg_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** xcb_shm_query_version_cookie_t xcb_shm_query_version
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_shm_query_version_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_shm_query_version_cookie_t
xcb_shm_query_version (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_shm_query_version_cookie_t xcb_shm_query_version_unchecked
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_shm_query_version_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_shm_query_version_cookie_t
xcb_shm_query_version_unchecked (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_shm_query_version_reply_t * xcb_shm_query_version_reply
 **
 ** @param xcb_connection_t                *c
 ** @param xcb_shm_query_version_cookie_t   cookie
 ** @param xcb_generic_error_t            **e
 ** @returns xcb_shm_query_version_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_shm_query_version_reply_t *
xcb_shm_query_version_reply (xcb_connection_t                *c  /**< */,
                             xcb_shm_query_version_cookie_t   cookie  /**< */,
                             xcb_generic_error_t            **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_shm_attach_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_shm_seg_t     shmseg
 ** @param uint              shmid
 ** @param bool              read_only
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_shm_attach_checked (xcb_connection_t *c  /**< */,
                        xcb_shm_seg_t     shmseg  /**< */,
                        uint              shmid  /**< */,
                        bool              read_only  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_shm_attach
 **
 ** @param xcb_connection_t *c
 ** @param xcb_shm_seg_t     shmseg
 ** @param uint              shmid
 ** @param bool              read_only
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_shm_attach (xcb_connection_t *c  /**< */,
                xcb_shm_seg_t     shmseg  /**< */,
                uint              shmid  /**< */,
                bool              read_only  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_shm_detach_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_shm_seg_t     shmseg
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_shm_detach_checked (xcb_connection_t *c  /**< */,
                        xcb_shm_seg_t     shmseg  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_shm_detach
 **
 ** @param xcb_connection_t *c
 ** @param xcb_shm_seg_t     shmseg
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_shm_detach (xcb_connection_t *c  /**< */,
                xcb_shm_seg_t     shmseg  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_shm_put_image_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_drawable_t    drawable
 ** @param xcb_gcontext_t    gc
 ** @param ushort            total_width
 ** @param ushort            total_height
 ** @param ushort            src_x
 ** @param ushort            src_y
 ** @param ushort            src_width
 ** @param ushort            src_height
 ** @param short             dst_x
 ** @param short             dst_y
 ** @param ubyte             depth
 ** @param ubyte             format
 ** @param ubyte             send_event
 ** @param xcb_shm_seg_t     shmseg
 ** @param uint              offset
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_shm_put_image_checked (xcb_connection_t *c  /**< */,
                           xcb_drawable_t    drawable  /**< */,
                           xcb_gcontext_t    gc  /**< */,
                           ushort            total_width  /**< */,
                           ushort            total_height  /**< */,
                           ushort            src_x  /**< */,
                           ushort            src_y  /**< */,
                           ushort            src_width  /**< */,
                           ushort            src_height  /**< */,
                           short             dst_x  /**< */,
                           short             dst_y  /**< */,
                           ubyte             depth  /**< */,
                           ubyte             format  /**< */,
                           ubyte             send_event  /**< */,
                           xcb_shm_seg_t     shmseg  /**< */,
                           uint              offset  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_shm_put_image
 **
 ** @param xcb_connection_t *c
 ** @param xcb_drawable_t    drawable
 ** @param xcb_gcontext_t    gc
 ** @param ushort            total_width
 ** @param ushort            total_height
 ** @param ushort            src_x
 ** @param ushort            src_y
 ** @param ushort            src_width
 ** @param ushort            src_height
 ** @param short             dst_x
 ** @param short             dst_y
 ** @param ubyte             depth
 ** @param ubyte             format
 ** @param ubyte             send_event
 ** @param xcb_shm_seg_t     shmseg
 ** @param uint              offset
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_shm_put_image (xcb_connection_t *c  /**< */,
                   xcb_drawable_t    drawable  /**< */,
                   xcb_gcontext_t    gc  /**< */,
                   ushort            total_width  /**< */,
                   ushort            total_height  /**< */,
                   ushort            src_x  /**< */,
                   ushort            src_y  /**< */,
                   ushort            src_width  /**< */,
                   ushort            src_height  /**< */,
                   short             dst_x  /**< */,
                   short             dst_y  /**< */,
                   ubyte             depth  /**< */,
                   ubyte             format  /**< */,
                   ubyte             send_event  /**< */,
                   xcb_shm_seg_t     shmseg  /**< */,
                   uint              offset  /**< */);


/*****************************************************************************
 **
 ** xcb_shm_get_image_cookie_t xcb_shm_get_image
 **
 ** @param xcb_connection_t *c
 ** @param xcb_drawable_t    drawable
 ** @param short             x
 ** @param short             y
 ** @param ushort            width
 ** @param ushort            height
 ** @param uint              plane_mask
 ** @param ubyte             format
 ** @param xcb_shm_seg_t     shmseg
 ** @param uint              offset
 ** @returns xcb_shm_get_image_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_shm_get_image_cookie_t
xcb_shm_get_image (xcb_connection_t *c  /**< */,
                   xcb_drawable_t    drawable  /**< */,
                   short             x  /**< */,
                   short             y  /**< */,
                   ushort            width  /**< */,
                   ushort            height  /**< */,
                   uint              plane_mask  /**< */,
                   ubyte             format  /**< */,
                   xcb_shm_seg_t     shmseg  /**< */,
                   uint              offset  /**< */);


/*****************************************************************************
 **
 ** xcb_shm_get_image_cookie_t xcb_shm_get_image_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_drawable_t    drawable
 ** @param short             x
 ** @param short             y
 ** @param ushort            width
 ** @param ushort            height
 ** @param uint              plane_mask
 ** @param ubyte             format
 ** @param xcb_shm_seg_t     shmseg
 ** @param uint              offset
 ** @returns xcb_shm_get_image_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_shm_get_image_cookie_t
xcb_shm_get_image_unchecked (xcb_connection_t *c  /**< */,
                             xcb_drawable_t    drawable  /**< */,
                             short             x  /**< */,
                             short             y  /**< */,
                             ushort            width  /**< */,
                             ushort            height  /**< */,
                             uint              plane_mask  /**< */,
                             ubyte             format  /**< */,
                             xcb_shm_seg_t     shmseg  /**< */,
                             uint              offset  /**< */);


/*****************************************************************************
 **
 ** xcb_shm_get_image_reply_t * xcb_shm_get_image_reply
 **
 ** @param xcb_connection_t            *c
 ** @param xcb_shm_get_image_cookie_t   cookie
 ** @param xcb_generic_error_t        **e
 ** @returns xcb_shm_get_image_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_shm_get_image_reply_t *
xcb_shm_get_image_reply (xcb_connection_t            *c  /**< */,
                         xcb_shm_get_image_cookie_t   cookie  /**< */,
                         xcb_generic_error_t        **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_shm_create_pixmap_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_pixmap_t      pid
 ** @param xcb_drawable_t    drawable
 ** @param ushort            width
 ** @param ushort            height
 ** @param ubyte             depth
 ** @param xcb_shm_seg_t     shmseg
 ** @param uint              offset
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_shm_create_pixmap_checked (xcb_connection_t *c  /**< */,
                               xcb_pixmap_t      pid  /**< */,
                               xcb_drawable_t    drawable  /**< */,
                               ushort            width  /**< */,
                               ushort            height  /**< */,
                               ubyte             depth  /**< */,
                               xcb_shm_seg_t     shmseg  /**< */,
                               uint              offset  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_shm_create_pixmap
 **
 ** @param xcb_connection_t *c
 ** @param xcb_pixmap_t      pid
 ** @param xcb_drawable_t    drawable
 ** @param ushort            width
 ** @param ushort            height
 ** @param ubyte             depth
 ** @param xcb_shm_seg_t     shmseg
 ** @param uint              offset
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_shm_create_pixmap (xcb_connection_t *c  /**< */,
                       xcb_pixmap_t      pid  /**< */,
                       xcb_drawable_t    drawable  /**< */,
                       ushort            width  /**< */,
                       ushort            height  /**< */,
                       ubyte             depth  /**< */,
                       xcb_shm_seg_t     shmseg  /**< */,
                       uint              offset  /**< */);



/**
 * @}
 */
