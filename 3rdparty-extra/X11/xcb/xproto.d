/*
 * This file generated automatically from xproto.xml by c-client.xsl using XSLT.
 * Edit at your peril.
 */

/**
 * @defgroup XCB__API XCB  API
 * @brief  XCB Protocol Implementation.
 * @{
 **/


module std.c.linux.X11.xcb.xproto;
version(USE_XCB):

import std.c.linux.X11.xcb.xcb;

/**
 * @brief xcb_char2b_t
 **/
struct xcb_char2b_t {
    ubyte byte1; /**<  */
    ubyte byte2; /**<  */
} ;

/**
 * @brief xcb_char2b_iterator_t
 **/
struct xcb_char2b_iterator_t {
    xcb_char2b_t *data; /**<  */
    int           rem; /**<  */
    int           index; /**<  */
} ;

alias uint xcb_window_t;

/**
 * @brief xcb_window_iterator_t
 **/
struct xcb_window_iterator_t {
    xcb_window_t *data; /**<  */
    int           rem; /**<  */
    int           index; /**<  */
} ;

alias uint xcb_pixmap_t;

/**
 * @brief xcb_pixmap_iterator_t
 **/
struct xcb_pixmap_iterator_t {
    xcb_pixmap_t *data; /**<  */
    int           rem; /**<  */
    int           index; /**<  */
} ;

alias uint xcb_cursor_t;

/**
 * @brief xcb_cursor_iterator_t
 **/
struct xcb_cursor_iterator_t {
    xcb_cursor_t *data; /**<  */
    int           rem; /**<  */
    int           index; /**<  */
} ;

alias uint xcb_font_t;

/**
 * @brief xcb_font_iterator_t
 **/
struct xcb_font_iterator_t {
    xcb_font_t *data; /**<  */
    int         rem; /**<  */
    int         index; /**<  */
} ;

alias uint xcb_gcontext_t;

/**
 * @brief xcb_gcontext_iterator_t
 **/
struct xcb_gcontext_iterator_t {
    xcb_gcontext_t *data; /**<  */
    int             rem; /**<  */
    int             index; /**<  */
} ;

alias uint xcb_colormap_t;

/**
 * @brief xcb_colormap_iterator_t
 **/
struct xcb_colormap_iterator_t {
    xcb_colormap_t *data; /**<  */
    int             rem; /**<  */
    int             index; /**<  */
} ;

alias uint xcb_atom_t;

enum : uint {
    XCB_ATOM_NONE = 0,
    XCB_ATOM_ANY = 0,
    XCB_ATOM_PRIMARY,
    XCB_ATOM_SECONDARY,
    XCB_ATOM_ARC,
    XCB_ATOM_ATOM,
    XCB_ATOM_BITMAP,
    XCB_ATOM_CARDINAL,
    XCB_ATOM_COLORMAP,
    XCB_ATOM_CURSOR,
    XCB_ATOM_CUT_BUFFER0,
    XCB_ATOM_CUT_BUFFER1,
    XCB_ATOM_CUT_BUFFER2,
    XCB_ATOM_CUT_BUFFER3,
    XCB_ATOM_CUT_BUFFER4,
    XCB_ATOM_CUT_BUFFER5,
    XCB_ATOM_CUT_BUFFER6,
    XCB_ATOM_CUT_BUFFER7,
    XCB_ATOM_DRAWABLE,
    XCB_ATOM_FONT,
    XCB_ATOM_INTEGER,
    XCB_ATOM_PIXMAP,
    XCB_ATOM_POINT,
    XCB_ATOM_RECTANGLE,
    XCB_ATOM_RESOURCE_MANAGER,
    XCB_ATOM_RGB_COLOR_MAP,
    XCB_ATOM_RGB_BEST_MAP,
    XCB_ATOM_RGB_BLUE_MAP,
    XCB_ATOM_RGB_DEFAULT_MAP,
    XCB_ATOM_RGB_GRAY_MAP,
    XCB_ATOM_RGB_GREEN_MAP,
    XCB_ATOM_RGB_RED_MAP,
    XCB_ATOM_STRING,
    XCB_ATOM_VISUALID,
    XCB_ATOM_WINDOW,
    XCB_ATOM_WM_COMMAND,
    XCB_ATOM_WM_HINTS,
    XCB_ATOM_WM_CLIENT_MACHINE,
    XCB_ATOM_WM_ICON_NAME,
    XCB_ATOM_WM_ICON_SIZE,
    XCB_ATOM_WM_NAME,
    XCB_ATOM_WM_NORMAL_HINTS,
    XCB_ATOM_WM_SIZE_HINTS,
    XCB_ATOM_WM_ZOOM_HINTS,
    XCB_ATOM_MIN_SPACE,
    XCB_ATOM_NORM_SPACE,
    XCB_ATOM_MAX_SPACE,
    XCB_ATOM_END_SPACE,
    XCB_ATOM_SUPERSCRIPT_X,
    XCB_ATOM_SUPERSCRIPT_Y,
    XCB_ATOM_SUBSCRIPT_X,
    XCB_ATOM_SUBSCRIPT_Y,
    XCB_ATOM_UNDERLINE_POSITION,
    XCB_ATOM_UNDERLINE_THICKNESS,
    XCB_ATOM_STRIKEOUT_ASCENT,
    XCB_ATOM_STRIKEOUT_DESCENT,
    XCB_ATOM_ITALIC_ANGLE,
    XCB_ATOM_X_HEIGHT,
    XCB_ATOM_QUAD_WIDTH,
    XCB_ATOM_WEIGHT,
    XCB_ATOM_POINT_SIZE,
    XCB_ATOM_RESOLUTION,
    XCB_ATOM_COPYRIGHT,
    XCB_ATOM_NOTICE,
    XCB_ATOM_FONT_NAME,
    XCB_ATOM_FAMILY_NAME,
    XCB_ATOM_FULL_NAME,
    XCB_ATOM_CAP_HEIGHT,
    XCB_ATOM_WM_CLASS,
    XCB_ATOM_WM_TRANSIENT_FOR
};

/**
 * @brief xcb_atom_iterator_t
 **/
struct xcb_atom_iterator_t {
    xcb_atom_t *data; /**<  */
    int         rem; /**<  */
    int         index; /**<  */
} ;

alias uint xcb_drawable_t;

/**
 * @brief xcb_drawable_iterator_t
 **/
struct xcb_drawable_iterator_t {
    xcb_drawable_t *data; /**<  */
    int             rem; /**<  */
    int             index; /**<  */
} ;

alias uint xcb_fontable_t;

/**
 * @brief xcb_fontable_iterator_t
 **/
struct xcb_fontable_iterator_t {
    xcb_fontable_t *data; /**<  */
    int             rem; /**<  */
    int             index; /**<  */
} ;

alias uint xcb_visualid_t;

/**
 * @brief xcb_visualid_iterator_t
 **/
struct xcb_visualid_iterator_t {
    xcb_visualid_t *data; /**<  */
    int             rem; /**<  */
    int             index; /**<  */
} ;

alias uint xcb_timestamp_t;

/**
 * @brief xcb_timestamp_iterator_t
 **/
struct xcb_timestamp_iterator_t {
    xcb_timestamp_t *data; /**<  */
    int              rem; /**<  */
    int              index; /**<  */
} ;

alias uint xcb_keysym_t;

/**
 * @brief xcb_keysym_iterator_t
 **/
struct xcb_keysym_iterator_t {
    xcb_keysym_t *data; /**<  */
    int           rem; /**<  */
    int           index; /**<  */
} ;

alias ubyte xcb_keycode_t;

/**
 * @brief xcb_keycode_iterator_t
 **/
struct xcb_keycode_iterator_t {
    xcb_keycode_t *data; /**<  */
    int            rem; /**<  */
    int            index; /**<  */
} ;

alias ubyte xcb_button_t;

/**
 * @brief xcb_button_iterator_t
 **/
struct xcb_button_iterator_t {
    xcb_button_t *data; /**<  */
    int           rem; /**<  */
    int           index; /**<  */
} ;

/**
 * @brief xcb_point_t
 **/
struct xcb_point_t {
    short x; /**<  */
    short y; /**<  */
} ;

/**
 * @brief xcb_point_iterator_t
 **/
struct xcb_point_iterator_t {
    xcb_point_t *data; /**<  */
    int          rem; /**<  */
    int          index; /**<  */
} ;

/**
 * @brief xcb_rectangle_t
 **/
struct xcb_rectangle_t {
    short  x; /**<  */
    short  y; /**<  */
    ushort width; /**<  */
    ushort height; /**<  */
} ;

/**
 * @brief xcb_rectangle_iterator_t
 **/
struct xcb_rectangle_iterator_t {
    xcb_rectangle_t *data; /**<  */
    int              rem; /**<  */
    int              index; /**<  */
} ;

/**
 * @brief xcb_arc_t
 **/
struct xcb_arc_t {
    short  x; /**<  */
    short  y; /**<  */
    ushort width; /**<  */
    ushort height; /**<  */
    short  angle1; /**<  */
    short  angle2; /**<  */
} ;

/**
 * @brief xcb_arc_iterator_t
 **/
struct xcb_arc_iterator_t {
    xcb_arc_t *data; /**<  */
    int        rem; /**<  */
    int        index; /**<  */
} ;

/**
 * @brief xcb_format_t
 **/
struct xcb_format_t {
    ubyte depth; /**<  */
    ubyte bits_per_pixel; /**<  */
    ubyte scanline_pad; /**<  */
    ubyte pad0[5]; /**<  */
} ;

/**
 * @brief xcb_format_iterator_t
 **/
struct xcb_format_iterator_t {
    xcb_format_t *data; /**<  */
    int           rem; /**<  */
    int           index; /**<  */
} ;

enum :int{
    XCB_VISUAL_CLASS_STATIC_GRAY = 0,
    XCB_VISUAL_CLASS_GRAY_SCALE = 1,
    XCB_VISUAL_CLASS_STATIC_COLOR = 2,
    XCB_VISUAL_CLASS_PSEUDO_COLOR = 3,
    XCB_VISUAL_CLASS_TRUE_COLOR = 4,
    XCB_VISUAL_CLASS_DIRECT_COLOR = 5
};

/**
 * @brief xcb_visualtype_t
 **/
struct xcb_visualtype_t {
    xcb_visualid_t visual_id; /**<  */
    ubyte          _class; /**<  */
    ubyte          bits_per_rgb_value; /**<  */
    ushort         colormap_entries; /**<  */
    uint           red_mask; /**<  */
    uint           green_mask; /**<  */
    uint           blue_mask; /**<  */
    ubyte          pad0[4]; /**<  */
} ;

/**
 * @brief xcb_visualtype_iterator_t
 **/
struct xcb_visualtype_iterator_t {
    xcb_visualtype_t *data; /**<  */
    int               rem; /**<  */
    int               index; /**<  */
} ;

/**
 * @brief xcb_depth_t
 **/
struct xcb_depth_t {
    ubyte  depth; /**<  */
    ubyte  pad0; /**<  */
    ushort visuals_len; /**<  */
    ubyte  pad1[4]; /**<  */
} ;

/**
 * @brief xcb_depth_iterator_t
 **/
struct xcb_depth_iterator_t {
    xcb_depth_t *data; /**<  */
    int          rem; /**<  */
    int          index; /**<  */
} ;

/**
 * @brief xcb_screen_t
 **/
struct xcb_screen_t {
    xcb_window_t   root; /**<  */
    xcb_colormap_t default_colormap; /**<  */
    uint           white_pixel; /**<  */
    uint           black_pixel; /**<  */
    uint           current_input_masks; /**<  */
    ushort         width_in_pixels; /**<  */
    ushort         height_in_pixels; /**<  */
    ushort         width_in_millimeters; /**<  */
    ushort         height_in_millimeters; /**<  */
    ushort         min_installed_maps; /**<  */
    ushort         max_installed_maps; /**<  */
    xcb_visualid_t root_visual; /**<  */
    ubyte          backing_stores; /**<  */
    bool           save_unders; /**<  */
    ubyte          root_depth; /**<  */
    ubyte          allowed_depths_len; /**<  */
} ;

/**
 * @brief xcb_screen_iterator_t
 **/
struct xcb_screen_iterator_t {
    xcb_screen_t *data; /**<  */
    int           rem; /**<  */
    int           index; /**<  */
} ;

/**
 * @brief xcb_setup_request_t
 **/
struct xcb_setup_request_t {
    ubyte  byte_order; /**<  */
    ubyte  pad0; /**<  */
    ushort protocol_major_version; /**<  */
    ushort protocol_minor_version; /**<  */
    ushort authorization_protocol_name_len; /**<  */
    ushort authorization_protocol_data_len; /**<  */
} ;

/**
 * @brief xcb_setup_request_iterator_t
 **/
struct xcb_setup_request_iterator_t {
    xcb_setup_request_t *data; /**<  */
    int                  rem; /**<  */
    int                  index; /**<  */
} ;

/**
 * @brief xcb_setup_failed_t
 **/
struct xcb_setup_failed_t {
    ubyte  status; /**<  */
    ubyte  reason_len; /**<  */
    ushort protocol_major_version; /**<  */
    ushort protocol_minor_version; /**<  */
    ushort length; /**<  */
} ;

/**
 * @brief xcb_setup_failed_iterator_t
 **/
struct xcb_setup_failed_iterator_t {
    xcb_setup_failed_t *data; /**<  */
    int                 rem; /**<  */
    int                 index; /**<  */
} ;

/**
 * @brief xcb_setup_authenticate_t
 **/
struct xcb_setup_authenticate_t {
    ubyte  status; /**<  */
    ubyte  pad0[5]; /**<  */
    ushort length; /**<  */
} ;

/**
 * @brief xcb_setup_authenticate_iterator_t
 **/
struct xcb_setup_authenticate_iterator_t {
    xcb_setup_authenticate_t *data; /**<  */
    int                       rem; /**<  */
    int                       index; /**<  */
} ;

alias xcb_image_order_t = int;
enum :int{
    XCB_IMAGE_ORDER_LSB_FIRST = 0,
    XCB_IMAGE_ORDER_MSB_FIRST = 1
};

/**
 * @brief xcb_setup_t
 **/
struct xcb_setup_t {
    ubyte         status; /**<  */
    ubyte         pad0; /**<  */
    ushort        protocol_major_version; /**<  */
    ushort        protocol_minor_version; /**<  */
    ushort        length; /**<  */
    uint          release_number; /**<  */
    uint          resource_id_base; /**<  */
    uint          resource_id_mask; /**<  */
    uint          motion_buffer_size; /**<  */
    ushort        vendor_len; /**<  */
    ushort        maximum_request_length; /**<  */
    ubyte         roots_len; /**<  */
    ubyte         pixmap_formats_len; /**<  */
    ubyte         image_byte_order; /**<  */
    ubyte         bitmap_format_bit_order; /**<  */
    ubyte         bitmap_format_scanline_unit; /**<  */
    ubyte         bitmap_format_scanline_pad; /**<  */
    xcb_keycode_t min_keycode; /**<  */
    xcb_keycode_t max_keycode; /**<  */
    ubyte         pad1[4]; /**<  */
} ;

/**
 * @brief xcb_setup_iterator_t
 **/
struct xcb_setup_iterator_t {
    xcb_setup_t *data; /**<  */
    int          rem; /**<  */
    int          index; /**<  */
} ;

enum :int{
    XCB_MOD_MASK_SHIFT = (1 << 0),
    XCB_MOD_MASK_LOCK = (1 << 1),
    XCB_MOD_MASK_CONTROL = (1 << 2),
    XCB_MOD_MASK_1 = (1 << 3),
    XCB_MOD_MASK_2 = (1 << 4),
    XCB_MOD_MASK_3 = (1 << 5),
    XCB_MOD_MASK_4 = (1 << 6),
    XCB_MOD_MASK_5 = (1 << 7)
};

/** Opcode for xcb_key_press. */
const uint XCB_KEY_PRESS = 2;

/**
 * @brief xcb_key_press_event_t
 **/
struct xcb_key_press_event_t {
    ubyte           response_type; /**<  */
    xcb_keycode_t   detail; /**<  */
    ushort          sequence; /**<  */
    xcb_timestamp_t time; /**<  */
    xcb_window_t    root; /**<  */
    xcb_window_t    event; /**<  */
    xcb_window_t    child; /**<  */
    short           root_x; /**<  */
    short           root_y; /**<  */
    short           event_x; /**<  */
    short           event_y; /**<  */
    ushort          state; /**<  */
    bool            same_screen; /**<  */
} ;

/** Opcode for xcb_key_release. */
const uint XCB_KEY_RELEASE = 3;

alias xcb_key_press_event_t xcb_key_release_event_t;

enum :int{
    XCB_BUTTON_MASK_1 = (1 << 8),
    XCB_BUTTON_MASK_2 = (1 << 9),
    XCB_BUTTON_MASK_3 = (1 << 10),
    XCB_BUTTON_MASK_4 = (1 << 11),
    XCB_BUTTON_MASK_5 = (1 << 12),
    XCB_BUTTON_MASK_ANY = (1 << 15)
};

/** Opcode for xcb_button_press. */
const uint XCB_BUTTON_PRESS = 4;

/**
 * @brief xcb_button_press_event_t
 **/
struct xcb_button_press_event_t {
    ubyte           response_type; /**<  */
    xcb_button_t    detail; /**<  */
    ushort          sequence; /**<  */
    xcb_timestamp_t time; /**<  */
    xcb_window_t    root; /**<  */
    xcb_window_t    event; /**<  */
    xcb_window_t    child; /**<  */
    short           root_x; /**<  */
    short           root_y; /**<  */
    short           event_x; /**<  */
    short           event_y; /**<  */
    ushort          state; /**<  */
    bool            same_screen; /**<  */
} ;

/** Opcode for xcb_button_release. */
const uint XCB_BUTTON_RELEASE = 5;

alias xcb_button_press_event_t xcb_button_release_event_t;

enum :int{
    XCB_MOTION_NORMAL = 0,
    XCB_MOTION_HINT = 1
};

/** Opcode for xcb_motion_notify. */
const uint XCB_MOTION_NOTIFY = 6;

/**
 * @brief xcb_motion_notify_event_t
 **/
struct xcb_motion_notify_event_t {
    ubyte           response_type; /**<  */
    ubyte           detail; /**<  */
    ushort          sequence; /**<  */
    xcb_timestamp_t time; /**<  */
    xcb_window_t    root; /**<  */
    xcb_window_t    event; /**<  */
    xcb_window_t    child; /**<  */
    short           root_x; /**<  */
    short           root_y; /**<  */
    short           event_x; /**<  */
    short           event_y; /**<  */
    ushort          state; /**<  */
    bool            same_screen; /**<  */
} ;

enum :int{
    XCB_NOTIFY_DETAIL_ANCESTOR = 0,
    XCB_NOTIFY_DETAIL_VIRTUAL = 1,
    XCB_NOTIFY_DETAIL_INFERIOR = 2,
    XCB_NOTIFY_DETAIL_NONLINEAR = 3,
    XCB_NOTIFY_DETAIL_NONLINEAR_VIRTUAL = 4,
    XCB_NOTIFY_DETAIL_POINTER = 5,
    XCB_NOTIFY_DETAIL_POINTER_ROOT = 6,
    XCB_NOTIFY_DETAIL_NONE = 7
};

enum :int{
    XCB_NOTIFY_MODE_NORMAL = 0,
    XCB_NOTIFY_MODE_GRAB = 1,
    XCB_NOTIFY_MODE_UNGRAB = 2,
    XCB_NOTIFY_MODE_WHILE_GRABBED = 3
};

/** Opcode for xcb_enter_notify. */
const uint XCB_ENTER_NOTIFY = 7;

/**
 * @brief xcb_enter_notify_event_t
 **/
struct xcb_enter_notify_event_t {
    ubyte           response_type; /**<  */
    ubyte           detail; /**<  */
    ushort          sequence; /**<  */
    xcb_timestamp_t time; /**<  */
    xcb_window_t    root; /**<  */
    xcb_window_t    event; /**<  */
    xcb_window_t    child; /**<  */
    short           root_x; /**<  */
    short           root_y; /**<  */
    short           event_x; /**<  */
    short           event_y; /**<  */
    ushort          state; /**<  */
    ubyte           mode; /**<  */
    ubyte           same_screen_focus; /**<  */
} ;

/** Opcode for xcb_leave_notify. */
const uint XCB_LEAVE_NOTIFY = 8;

alias xcb_enter_notify_event_t xcb_leave_notify_event_t;

/** Opcode for xcb_focus_in. */
const uint XCB_FOCUS_IN = 9;

/**
 * @brief xcb_focus_in_event_t
 **/
struct xcb_focus_in_event_t {
    ubyte        response_type; /**<  */
    ubyte        detail; /**<  */
    ushort       sequence; /**<  */
    xcb_window_t event; /**<  */
    ubyte        mode; /**<  */
} ;

/** Opcode for xcb_focus_out. */
const uint XCB_FOCUS_OUT = 10;

alias xcb_focus_in_event_t xcb_focus_out_event_t;

/** Opcode for xcb_keymap_notify. */
const uint XCB_KEYMAP_NOTIFY = 11;

/**
 * @brief xcb_keymap_notify_event_t
 **/
struct xcb_keymap_notify_event_t {
    ubyte response_type; /**<  */
    ubyte keys[31]; /**<  */
} ;

/** Opcode for xcb_expose. */
const uint XCB_EXPOSE = 12;

/**
 * @brief xcb_expose_event_t
 **/
struct xcb_expose_event_t {
    ubyte        response_type; /**<  */
    ubyte        pad0; /**<  */
    ushort       sequence; /**<  */
    xcb_window_t window; /**<  */
    ushort       x; /**<  */
    ushort       y; /**<  */
    ushort       width; /**<  */
    ushort       height; /**<  */
    ushort       count; /**<  */
} ;

/** Opcode for xcb_graphics_exposure. */
const uint XCB_GRAPHICS_EXPOSURE = 13;

/**
 * @brief xcb_graphics_exposure_event_t
 **/
struct xcb_graphics_exposure_event_t {
    ubyte          response_type; /**<  */
    ubyte          pad0; /**<  */
    ushort         sequence; /**<  */
    xcb_drawable_t drawable; /**<  */
    ushort         x; /**<  */
    ushort         y; /**<  */
    ushort         width; /**<  */
    ushort         height; /**<  */
    ushort         minor_opcode; /**<  */
    ushort         count; /**<  */
    ubyte          major_opcode; /**<  */
} ;

/** Opcode for xcb_no_exposure. */
const uint XCB_NO_EXPOSURE = 14;

/**
 * @brief xcb_no_exposure_event_t
 **/
struct xcb_no_exposure_event_t {
    ubyte          response_type; /**<  */
    ubyte          pad0; /**<  */
    ushort         sequence; /**<  */
    xcb_drawable_t drawable; /**<  */
    ushort         minor_opcode; /**<  */
    ubyte          major_opcode; /**<  */
} ;

enum :int{
    XCB_VISIBILITY_UNOBSCURED = 0,
    XCB_VISIBILITY_PARTIALLY_OBSCURED = 1,
    XCB_VISIBILITY_FULLY_OBSCURED = 2
};

/** Opcode for xcb_visibility_notify. */
const uint XCB_VISIBILITY_NOTIFY = 15;

/**
 * @brief xcb_visibility_notify_event_t
 **/
struct xcb_visibility_notify_event_t {
    ubyte        response_type; /**<  */
    ubyte        pad0; /**<  */
    ushort       sequence; /**<  */
    xcb_window_t window; /**<  */
    ubyte        state; /**<  */
} ;

/** Opcode for xcb_create_notify. */
const uint XCB_CREATE_NOTIFY = 16;

/**
 * @brief xcb_create_notify_event_t
 **/
struct xcb_create_notify_event_t {
    ubyte        response_type; /**<  */
    ubyte        pad0; /**<  */
    ushort       sequence; /**<  */
    xcb_window_t parent; /**<  */
    xcb_window_t window; /**<  */
    short        x; /**<  */
    short        y; /**<  */
    ushort       width; /**<  */
    ushort       height; /**<  */
    ushort       border_width; /**<  */
    bool         override_redirect; /**<  */
} ;

/** Opcode for xcb_destroy_notify. */
const uint XCB_DESTROY_NOTIFY = 17;

/**
 * @brief xcb_destroy_notify_event_t
 **/
struct xcb_destroy_notify_event_t {
    ubyte        response_type; /**<  */
    ubyte        pad0; /**<  */
    ushort       sequence; /**<  */
    xcb_window_t event; /**<  */
    xcb_window_t window; /**<  */
} ;

/** Opcode for xcb_unmap_notify. */
const uint XCB_UNMAP_NOTIFY = 18;

/**
 * @brief xcb_unmap_notify_event_t
 **/
struct xcb_unmap_notify_event_t {
    ubyte        response_type; /**<  */
    ubyte        pad0; /**<  */
    ushort       sequence; /**<  */
    xcb_window_t event; /**<  */
    xcb_window_t window; /**<  */
    bool         from_configure; /**<  */
} ;

/** Opcode for xcb_map_notify. */
const uint XCB_MAP_NOTIFY = 19;

/**
 * @brief xcb_map_notify_event_t
 **/
struct xcb_map_notify_event_t {
    ubyte        response_type; /**<  */
    ubyte        pad0; /**<  */
    ushort       sequence; /**<  */
    xcb_window_t event; /**<  */
    xcb_window_t window; /**<  */
    bool         override_redirect; /**<  */
} ;

/** Opcode for xcb_map_request. */
const uint XCB_MAP_REQUEST = 20;

/**
 * @brief xcb_map_request_event_t
 **/
struct xcb_map_request_event_t {
    ubyte        response_type; /**<  */
    ubyte        pad0; /**<  */
    ushort       sequence; /**<  */
    xcb_window_t parent; /**<  */
    xcb_window_t window; /**<  */
} ;

/** Opcode for xcb_reparent_notify. */
const uint XCB_REPARENT_NOTIFY = 21;

/**
 * @brief xcb_reparent_notify_event_t
 **/
struct xcb_reparent_notify_event_t {
    ubyte        response_type; /**<  */
    ubyte        pad0; /**<  */
    ushort       sequence; /**<  */
    xcb_window_t event; /**<  */
    xcb_window_t window; /**<  */
    xcb_window_t parent; /**<  */
    short        x; /**<  */
    short        y; /**<  */
    bool         override_redirect; /**<  */
} ;

/** Opcode for xcb_configure_notify. */
const uint XCB_CONFIGURE_NOTIFY = 22;

/**
 * @brief xcb_configure_notify_event_t
 **/
struct xcb_configure_notify_event_t {
    ubyte        response_type; /**<  */
    ubyte        pad0; /**<  */
    ushort       sequence; /**<  */
    xcb_window_t event; /**<  */
    xcb_window_t window; /**<  */
    xcb_window_t above_sibling; /**<  */
    short        x; /**<  */
    short        y; /**<  */
    ushort       width; /**<  */
    ushort       height; /**<  */
    ushort       border_width; /**<  */
    bool         override_redirect; /**<  */
} ;

/** Opcode for xcb_configure_request. */
const uint XCB_CONFIGURE_REQUEST = 23;

/**
 * @brief xcb_configure_request_event_t
 **/
struct xcb_configure_request_event_t {
    ubyte        response_type; /**<  */
    ubyte        stack_mode; /**<  */
    ushort       sequence; /**<  */
    xcb_window_t parent; /**<  */
    xcb_window_t window; /**<  */
    xcb_window_t sibling; /**<  */
    short        x; /**<  */
    short        y; /**<  */
    ushort       width; /**<  */
    ushort       height; /**<  */
    ushort       border_width; /**<  */
    ushort       value_mask; /**<  */
} ;

/** Opcode for xcb_gravity_notify. */
const uint XCB_GRAVITY_NOTIFY = 24;

/**
 * @brief xcb_gravity_notify_event_t
 **/
struct xcb_gravity_notify_event_t {
    ubyte        response_type; /**<  */
    ubyte        pad0; /**<  */
    ushort       sequence; /**<  */
    xcb_window_t event; /**<  */
    xcb_window_t window; /**<  */
    short        x; /**<  */
    short        y; /**<  */
} ;

/** Opcode for xcb_resize_request. */
const uint XCB_RESIZE_REQUEST = 25;

/**
 * @brief xcb_resize_request_event_t
 **/
struct xcb_resize_request_event_t {
    ubyte        response_type; /**<  */
    ubyte        pad0; /**<  */
    ushort       sequence; /**<  */
    xcb_window_t window; /**<  */
    ushort       width; /**<  */
    ushort       height; /**<  */
} ;

enum :int{
    XCB_PLACE_ON_TOP = 0,
    XCB_PLACE_ON_BOTTOM = 1
};

/** Opcode for xcb_circulate_notify. */
const uint XCB_CIRCULATE_NOTIFY = 26;

/**
 * @brief xcb_circulate_notify_event_t
 **/
struct xcb_circulate_notify_event_t {
    ubyte        response_type; /**<  */
    ubyte        pad0; /**<  */
    ushort       sequence; /**<  */
    xcb_window_t event; /**<  */
    xcb_window_t window; /**<  */
    ubyte        pad1[4]; /**<  */
    ubyte        place; /**<  */
} ;

/** Opcode for xcb_circulate_request. */
const uint XCB_CIRCULATE_REQUEST = 27;

alias xcb_circulate_notify_event_t xcb_circulate_request_event_t;

enum :int{
    XCB_PROPERTY_NEW_VALUE = 0,
    XCB_PROPERTY_DELETE = 1
};

/** Opcode for xcb_property_notify. */
const uint XCB_PROPERTY_NOTIFY = 28;

/**
 * @brief xcb_property_notify_event_t
 **/
struct xcb_property_notify_event_t {
    ubyte           response_type; /**<  */
    ubyte           pad0; /**<  */
    ushort          sequence; /**<  */
    xcb_window_t    window; /**<  */
    xcb_atom_t      atom; /**<  */
    xcb_timestamp_t time; /**<  */
    ubyte           state; /**<  */
} ;

/** Opcode for xcb_selection_clear. */
const uint XCB_SELECTION_CLEAR = 29;

/**
 * @brief xcb_selection_clear_event_t
 **/
struct xcb_selection_clear_event_t {
    ubyte           response_type; /**<  */
    ubyte           pad0; /**<  */
    ushort          sequence; /**<  */
    xcb_timestamp_t time; /**<  */
    xcb_window_t    owner; /**<  */
    xcb_atom_t      selection; /**<  */
} ;

/** Opcode for xcb_selection_request. */
const uint XCB_SELECTION_REQUEST = 30;

/**
 * @brief xcb_selection_request_event_t
 **/
struct xcb_selection_request_event_t {
    ubyte           response_type; /**<  */
    ubyte           pad0; /**<  */
    ushort          sequence; /**<  */
    xcb_timestamp_t time; /**<  */
    xcb_window_t    owner; /**<  */
    xcb_window_t    requestor; /**<  */
    xcb_atom_t      selection; /**<  */
    xcb_atom_t      target; /**<  */
    xcb_atom_t      property; /**<  */
} ;

/** Opcode for xcb_selection_notify. */
const uint XCB_SELECTION_NOTIFY = 31;

/**
 * @brief xcb_selection_notify_event_t
 **/
struct xcb_selection_notify_event_t {
    ubyte           response_type; /**<  */
    ubyte           pad0; /**<  */
    ushort          sequence; /**<  */
    xcb_timestamp_t time; /**<  */
    xcb_window_t    requestor; /**<  */
    xcb_atom_t      selection; /**<  */
    xcb_atom_t      target; /**<  */
    xcb_atom_t      property; /**<  */
} ;

enum :int{
    XCB_COLORMAP_STATE_UNINSTALLED = 0,
    XCB_COLORMAP_STATE_INSTALLED = 1
};

/** Opcode for xcb_colormap_notify. */
const uint XCB_COLORMAP_NOTIFY = 32;

/**
 * @brief xcb_colormap_notify_event_t
 **/
struct xcb_colormap_notify_event_t {
    ubyte          response_type; /**<  */
    ubyte          pad0; /**<  */
    ushort         sequence; /**<  */
    xcb_window_t   window; /**<  */
    xcb_colormap_t colormap; /**<  */
    bool           _new; /**<  */
    ubyte          state; /**<  */
} ;

/**
 * @brief xcb_client_message_data_t
 **/
union xcb_client_message_data_t {
    ubyte data8[20]; /**<  */
    ushort data16[10]; /**<  */
    uint data32[5]; /**<  */
} ;

/**
 * @brief xcb_client_message_data_iterator_t
 **/
struct xcb_client_message_data_iterator_t {
    xcb_client_message_data_t *data; /**<  */
    int                        rem; /**<  */
    int                        index; /**<  */
} ;

/** Opcode for xcb_client_message. */
const uint XCB_CLIENT_MESSAGE = 33;

/**
 * @brief xcb_client_message_event_t
 **/
struct xcb_client_message_event_t {
    ubyte                     response_type; /**<  */
    ubyte                     format; /**<  */
    ushort                    sequence; /**<  */
    xcb_window_t              window; /**<  */
    xcb_atom_t                type; /**<  */
    xcb_client_message_data_t data; /**<  */
} ;

enum :int{
    XCB_MAPPING_MODIFIER = 0,
    XCB_MAPPING_KEYBOARD = 1,
    XCB_MAPPING_POINTER = 2
};

/** Opcode for xcb_mapping_notify. */
const uint XCB_MAPPING_NOTIFY = 34;

/**
 * @brief xcb_mapping_notify_event_t
 **/
struct xcb_mapping_notify_event_t {
    ubyte         response_type; /**<  */
    ubyte         pad0; /**<  */
    ushort        sequence; /**<  */
    ubyte         request; /**<  */
    xcb_keycode_t first_keycode; /**<  */
    ubyte         count; /**<  */
} ;

/** Opcode for xcb_request. */
const uint XCB_REQUEST = 1;

/**
 * @brief xcb_request_error_t
 **/
struct xcb_request_error_t {
    ubyte  response_type; /**<  */
    ubyte  error_code; /**<  */
    ushort sequence; /**<  */
    uint   bad_value; /**<  */
    ushort minor_opcode; /**<  */
    ubyte  major_opcode; /**<  */
} ;

/** Opcode for xcb_value. */
const uint XCB_VALUE = 2;

/**
 * @brief xcb_value_error_t
 **/
struct xcb_value_error_t {
    ubyte  response_type; /**<  */
    ubyte  error_code; /**<  */
    ushort sequence; /**<  */
    uint   bad_value; /**<  */
    ushort minor_opcode; /**<  */
    ubyte  major_opcode; /**<  */
} ;

/** Opcode for xcb_window. */
const uint XCB_WINDOW = 3;

alias xcb_value_error_t xcb_window_error_t;

/** Opcode for xcb_pixmap. */
const uint XCB_PIXMAP = 4;

alias xcb_value_error_t xcb_pixmap_error_t;

/** Opcode for xcb_atom. */
const uint XCB_ATOM = 5;

alias xcb_value_error_t xcb_atom_error_t;

/** Opcode for xcb_cursor. */
const uint XCB_CURSOR = 6;

alias xcb_value_error_t xcb_cursor_error_t;

/** Opcode for xcb_font. */
const uint XCB_FONT = 7;

alias xcb_value_error_t xcb_font_error_t;

/** Opcode for xcb_match. */
const uint XCB_MATCH = 8;

alias xcb_request_error_t xcb_match_error_t;

/** Opcode for xcb_drawable. */
const uint XCB_DRAWABLE = 9;

alias xcb_value_error_t xcb_drawable_error_t;

/** Opcode for xcb_access. */
const uint XCB_ACCESS = 10;

alias xcb_request_error_t xcb_access_error_t;

/** Opcode for xcb_alloc. */
const uint XCB_ALLOC = 11;

alias xcb_request_error_t xcb_alloc_error_t;

/** Opcode for xcb_colormap. */
const uint XCB_COLORMAP = 12;

alias xcb_value_error_t xcb_colormap_error_t;

/** Opcode for xcb_g_context. */
const uint XCB_G_CONTEXT = 13;

alias xcb_value_error_t xcb_g_context_error_t;

/** Opcode for xcb_id_choice. */
const uint XCB_ID_CHOICE = 14;

alias xcb_value_error_t xcb_id_choice_error_t;

/** Opcode for xcb_name. */
const uint XCB_NAME = 15;

alias xcb_request_error_t xcb_name_error_t;

/** Opcode for xcb_length. */
const uint XCB_LENGTH = 16;

alias xcb_request_error_t xcb_length_error_t;

/** Opcode for xcb_implementation. */
const uint XCB_IMPLEMENTATION = 17;

alias xcb_request_error_t xcb_implementation_error_t;

enum :int{
    XCB_WINDOW_CLASS_COPY_FROM_PARENT = 0,
    XCB_WINDOW_CLASS_INPUT_OUTPUT = 1,
    XCB_WINDOW_CLASS_INPUT_ONLY = 2
};

enum :int{
    XCB_CW_BACK_PIXMAP = (1 << 0),
    XCB_CW_BACK_PIXEL = (1 << 1),
    XCB_CW_BORDER_PIXMAP = (1 << 2),
    XCB_CW_BORDER_PIXEL = (1 << 3),
    XCB_CW_BIT_GRAVITY = (1 << 4),
    XCB_CW_WIN_GRAVITY = (1 << 5),
    XCB_CW_BACKING_STORE = (1 << 6),
    XCB_CW_BACKING_PLANES = (1 << 7),
    XCB_CW_BACKING_PIXEL = (1 << 8),
    XCB_CW_OVERRIDE_REDIRECT = (1 << 9),
    XCB_CW_SAVE_UNDER = (1 << 10),
    XCB_CW_EVENT_MASK = (1 << 11),
    XCB_CW_DONT_PROPAGATE = (1 << 12),
    XCB_CW_COLORMAP = (1 << 13),
    XCB_CW_CURSOR = (1 << 14)
};

enum :int{
    XCB_BACK_PIXMAP_NONE = 0,
    XCB_BACK_PIXMAP_PARENT_RELATIVE = 1
};

enum :int{
    XCB_GRAVITY_BIT_FORGET = 0,
    XCB_GRAVITY_WIN_UNMAP = 0,
    XCB_GRAVITY_NORTH_WEST = 1,
    XCB_GRAVITY_NORTH = 2,
    XCB_GRAVITY_NORTH_EAST = 3,
    XCB_GRAVITY_WEST = 4,
    XCB_GRAVITY_CENTER = 5,
    XCB_GRAVITY_EAST = 6,
    XCB_GRAVITY_SOUTH_WEST = 7,
    XCB_GRAVITY_SOUTH = 8,
    XCB_GRAVITY_SOUTH_EAST = 9,
    XCB_GRAVITY_STATIC = 10
};

enum :int{
    XCB_BACKING_STORE_NOT_USEFUL = 0,
    XCB_BACKING_STORE_WHEN_MAPPED = 1,
    XCB_BACKING_STORE_ALWAYS = 2
};

enum :int{
    XCB_EVENT_MASK_NO_EVENT = 0,
    XCB_EVENT_MASK_KEY_PRESS = (1 << 0),
    XCB_EVENT_MASK_KEY_RELEASE = (1 << 1),
    XCB_EVENT_MASK_BUTTON_PRESS = (1 << 2),
    XCB_EVENT_MASK_BUTTON_RELEASE = (1 << 3),
    XCB_EVENT_MASK_ENTER_WINDOW = (1 << 4),
    XCB_EVENT_MASK_LEAVE_WINDOW = (1 << 5),
    XCB_EVENT_MASK_POINTER_MOTION = (1 << 6),
    XCB_EVENT_MASK_POINTER_MOTION_HINT = (1 << 7),
    XCB_EVENT_MASK_BUTTON_1_MOTION = (1 << 8),
    XCB_EVENT_MASK_BUTTON_2_MOTION = (1 << 9),
    XCB_EVENT_MASK_BUTTON_3_MOTION = (1 << 10),
    XCB_EVENT_MASK_BUTTON_4_MOTION = (1 << 11),
    XCB_EVENT_MASK_BUTTON_5_MOTION = (1 << 12),
    XCB_EVENT_MASK_BUTTON_MOTION = (1 << 13),
    XCB_EVENT_MASK_KEYMAP_STATE = (1 << 14),
    XCB_EVENT_MASK_EXPOSURE = (1 << 15),
    XCB_EVENT_MASK_VISIBILITY_CHANGE = (1 << 16),
    XCB_EVENT_MASK_STRUCTURE_NOTIFY = (1 << 17),
    XCB_EVENT_MASK_RESIZE_REDIRECT = (1 << 18),
    XCB_EVENT_MASK_SUBSTRUCTURE_NOTIFY = (1 << 19),
    XCB_EVENT_MASK_SUBSTRUCTURE_REDIRECT = (1 << 20),
    XCB_EVENT_MASK_FOCUS_CHANGE = (1 << 21),
    XCB_EVENT_MASK_PROPERTY_CHANGE = (1 << 22),
    XCB_EVENT_MASK_COLOR_MAP_CHANGE = (1 << 23),
    XCB_EVENT_MASK_OWNER_GRAB_BUTTON = (1 << 24)
};

/** Opcode for xcb_create_window. */
const uint XCB_CREATE_WINDOW = 1;

/**
 * @brief xcb_create_window_request_t
 **/
struct xcb_create_window_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          depth; /**<  */
    ushort         length; /**<  */
    xcb_window_t   wid; /**<  */
    xcb_window_t   parent; /**<  */
    short          x; /**<  */
    short          y; /**<  */
    ushort         width; /**<  */
    ushort         height; /**<  */
    ushort         border_width; /**<  */
    ushort         _class; /**<  */
    xcb_visualid_t visual; /**<  */
    uint           value_mask; /**<  */
} ;

/** Opcode for xcb_change_window_attributes. */
const uint XCB_CHANGE_WINDOW_ATTRIBUTES = 2;

/**
 * @brief xcb_change_window_attributes_request_t
 **/
struct xcb_change_window_attributes_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        pad0; /**<  */
    ushort       length; /**<  */
    xcb_window_t window; /**<  */
    uint         value_mask; /**<  */
} ;

enum :int{
    XCB_MAP_STATE_UNMAPPED = 0,
    XCB_MAP_STATE_UNVIEWABLE = 1,
    XCB_MAP_STATE_VIEWABLE = 2
};

/**
 * @brief xcb_get_window_attributes_cookie_t
 **/
struct xcb_get_window_attributes_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_get_window_attributes. */
const uint XCB_GET_WINDOW_ATTRIBUTES = 3;

/**
 * @brief xcb_get_window_attributes_request_t
 **/
struct xcb_get_window_attributes_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        pad0; /**<  */
    ushort       length; /**<  */
    xcb_window_t window; /**<  */
} ;

/**
 * @brief xcb_get_window_attributes_reply_t
 **/
struct xcb_get_window_attributes_reply_t {
    ubyte          response_type; /**<  */
    ubyte          backing_store; /**<  */
    ushort         sequence; /**<  */
    uint           length; /**<  */
    xcb_visualid_t visual; /**<  */
    ushort         _class; /**<  */
    ubyte          bit_gravity; /**<  */
    ubyte          win_gravity; /**<  */
    uint           backing_planes; /**<  */
    uint           backing_pixel; /**<  */
    bool           save_under; /**<  */
    bool           map_is_installed; /**<  */
    ubyte          map_state; /**<  */
    bool           override_redirect; /**<  */
    xcb_colormap_t colormap; /**<  */
    uint           all_event_masks; /**<  */
    uint           your_event_mask; /**<  */
    ushort         do_not_propagate_mask; /**<  */
} ;

/** Opcode for xcb_destroy_window. */
const uint XCB_DESTROY_WINDOW = 4;

/**
 * @brief xcb_destroy_window_request_t
 **/
struct xcb_destroy_window_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        pad0; /**<  */
    ushort       length; /**<  */
    xcb_window_t window; /**<  */
} ;

/** Opcode for xcb_destroy_subwindows. */
const uint XCB_DESTROY_SUBWINDOWS = 5;

/**
 * @brief xcb_destroy_subwindows_request_t
 **/
struct xcb_destroy_subwindows_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        pad0; /**<  */
    ushort       length; /**<  */
    xcb_window_t window; /**<  */
} ;

enum :int{
    XCB_SET_MODE_INSERT = 0,
    XCB_SET_MODE_DELETE = 1
};

/** Opcode for xcb_change_save_set. */
const uint XCB_CHANGE_SAVE_SET = 6;

/**
 * @brief xcb_change_save_set_request_t
 **/
struct xcb_change_save_set_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        mode; /**<  */
    ushort       length; /**<  */
    xcb_window_t window; /**<  */
} ;

/** Opcode for xcb_reparent_window. */
const uint XCB_REPARENT_WINDOW = 7;

/**
 * @brief xcb_reparent_window_request_t
 **/
struct xcb_reparent_window_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        pad0; /**<  */
    ushort       length; /**<  */
    xcb_window_t window; /**<  */
    xcb_window_t parent; /**<  */
    short        x; /**<  */
    short        y; /**<  */
} ;

/** Opcode for xcb_map_window. */
const uint XCB_MAP_WINDOW = 8;

/**
 * @brief xcb_map_window_request_t
 **/
struct xcb_map_window_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        pad0; /**<  */
    ushort       length; /**<  */
    xcb_window_t window; /**<  */
} ;

/** Opcode for xcb_map_subwindows. */
const uint XCB_MAP_SUBWINDOWS = 9;

/**
 * @brief xcb_map_subwindows_request_t
 **/
struct xcb_map_subwindows_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        pad0; /**<  */
    ushort       length; /**<  */
    xcb_window_t window; /**<  */
} ;

/** Opcode for xcb_unmap_window. */
const uint XCB_UNMAP_WINDOW = 10;

/**
 * @brief xcb_unmap_window_request_t
 **/
struct xcb_unmap_window_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        pad0; /**<  */
    ushort       length; /**<  */
    xcb_window_t window; /**<  */
} ;

/** Opcode for xcb_unmap_subwindows. */
const uint XCB_UNMAP_SUBWINDOWS = 11;

/**
 * @brief xcb_unmap_subwindows_request_t
 **/
struct xcb_unmap_subwindows_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        pad0; /**<  */
    ushort       length; /**<  */
    xcb_window_t window; /**<  */
} ;

enum :int{
    XCB_CONFIG_WINDOW_X = (1 << 0),
    XCB_CONFIG_WINDOW_Y = (1 << 1),
    XCB_CONFIG_WINDOW_WIDTH = (1 << 2),
    XCB_CONFIG_WINDOW_HEIGHT = (1 << 3),
    XCB_CONFIG_WINDOW_BORDER_WIDTH = (1 << 4),
    XCB_CONFIG_WINDOW_SIBLING = (1 << 5),
    XCB_CONFIG_WINDOW_STACK_MODE = (1 << 6)
};

enum :int{
    XCB_STACK_MODE_ABOVE = 0,
    XCB_STACK_MODE_BELOW = 1,
    XCB_STACK_MODE_TOP_IF = 2,
    XCB_STACK_MODE_BOTTOM_IF = 3,
    XCB_STACK_MODE_OPPOSITE = 4
};

/** Opcode for xcb_configure_window. */
const uint XCB_CONFIGURE_WINDOW = 12;

/**
 * @brief xcb_configure_window_request_t
 **/
struct xcb_configure_window_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        pad0; /**<  */
    ushort       length; /**<  */
    xcb_window_t window; /**<  */
    ushort       value_mask; /**<  */
} ;

enum :int{
    XCB_CIRCULATE_RAISE_LOWEST = 0,
    XCB_CIRCULATE_LOWER_HIGHEST = 1
};

/** Opcode for xcb_circulate_window. */
const uint XCB_CIRCULATE_WINDOW = 13;

/**
 * @brief xcb_circulate_window_request_t
 **/
struct xcb_circulate_window_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        direction; /**<  */
    ushort       length; /**<  */
    xcb_window_t window; /**<  */
} ;

/**
 * @brief xcb_get_geometry_cookie_t
 **/
struct xcb_get_geometry_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_get_geometry. */
const uint XCB_GET_GEOMETRY = 14;

/**
 * @brief xcb_get_geometry_request_t
 **/
struct xcb_get_geometry_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          pad0; /**<  */
    ushort         length; /**<  */
    xcb_drawable_t drawable; /**<  */
} ;

/**
 * @brief xcb_get_geometry_reply_t
 **/
struct xcb_get_geometry_reply_t {
    ubyte        response_type; /**<  */
    ubyte        depth; /**<  */
    ushort       sequence; /**<  */
    uint         length; /**<  */
    xcb_window_t root; /**<  */
    short        x; /**<  */
    short        y; /**<  */
    ushort       width; /**<  */
    ushort       height; /**<  */
    ushort       border_width; /**<  */
} ;

/**
 * @brief xcb_query_tree_cookie_t
 **/
struct xcb_query_tree_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_query_tree. */
const uint XCB_QUERY_TREE = 15;

/**
 * @brief xcb_query_tree_request_t
 **/
struct xcb_query_tree_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        pad0; /**<  */
    ushort       length; /**<  */
    xcb_window_t window; /**<  */
} ;

/**
 * @brief xcb_query_tree_reply_t
 **/
struct xcb_query_tree_reply_t {
    ubyte        response_type; /**<  */
    ubyte        pad0; /**<  */
    ushort       sequence; /**<  */
    uint         length; /**<  */
    xcb_window_t root; /**<  */
    xcb_window_t parent; /**<  */
    ushort       children_len; /**<  */
    ubyte        pad1[14]; /**<  */
} ;

/**
 * @brief xcb_intern_atom_cookie_t
 **/
struct xcb_intern_atom_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_intern_atom. */
const uint XCB_INTERN_ATOM = 16;

/**
 * @brief xcb_intern_atom_request_t
 **/
struct xcb_intern_atom_request_t {
    ubyte  major_opcode; /**<  */
    bool   only_if_exists; /**<  */
    ushort length; /**<  */
    ushort name_len; /**<  */
    ubyte  pad0[2]; /**<  */
} ;

/**
 * @brief xcb_intern_atom_reply_t
 **/
struct xcb_intern_atom_reply_t {
    ubyte      response_type; /**<  */
    ubyte      pad0; /**<  */
    ushort     sequence; /**<  */
    uint       length; /**<  */
    xcb_atom_t atom; /**<  */
} ;

/**
 * @brief xcb_get_atom_name_cookie_t
 **/
struct xcb_get_atom_name_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_get_atom_name. */
const uint XCB_GET_ATOM_NAME = 17;

/**
 * @brief xcb_get_atom_name_request_t
 **/
struct xcb_get_atom_name_request_t {
    ubyte      major_opcode; /**<  */
    ubyte      pad0; /**<  */
    ushort     length; /**<  */
    xcb_atom_t atom; /**<  */
} ;

/**
 * @brief xcb_get_atom_name_reply_t
 **/
struct xcb_get_atom_name_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ushort name_len; /**<  */
    ubyte  pad1[22]; /**<  */
} ;

enum :int{
    XCB_PROP_MODE_REPLACE = 0,
    XCB_PROP_MODE_PREPEND = 1,
    XCB_PROP_MODE_APPEND = 2
};

/** Opcode for xcb_change_property. */
const uint XCB_CHANGE_PROPERTY = 18;

/**
 * @brief xcb_change_property_request_t
 **/
struct xcb_change_property_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        mode; /**<  */
    ushort       length; /**<  */
    xcb_window_t window; /**<  */
    xcb_atom_t   property; /**<  */
    xcb_atom_t   type; /**<  */
    ubyte        format; /**<  */
    ubyte        pad0[3]; /**<  */
    uint         data_len; /**<  */
} ;

/** Opcode for xcb_delete_property. */
const uint XCB_DELETE_PROPERTY = 19;

/**
 * @brief xcb_delete_property_request_t
 **/
struct xcb_delete_property_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        pad0; /**<  */
    ushort       length; /**<  */
    xcb_window_t window; /**<  */
    xcb_atom_t   property; /**<  */
} ;

enum :int{
    XCB_GET_PROPERTY_TYPE_ANY = 0
};

/**
 * @brief xcb_get_property_cookie_t
 **/
struct xcb_get_property_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_get_property. */
const uint XCB_GET_PROPERTY = 20;

/**
 * @brief xcb_get_property_request_t
 **/
struct xcb_get_property_request_t {
    ubyte        major_opcode; /**<  */
    bool         _delete; /**<  */
    ushort       length; /**<  */
    xcb_window_t window; /**<  */
    xcb_atom_t   property; /**<  */
    xcb_atom_t   type; /**<  */
    uint         long_offset; /**<  */
    uint         long_length; /**<  */
} ;

/**
 * @brief xcb_get_property_reply_t
 **/
struct xcb_get_property_reply_t {
    ubyte      response_type; /**<  */
    ubyte      format; /**<  */
    ushort     sequence; /**<  */
    uint       length; /**<  */
    xcb_atom_t type; /**<  */
    uint       bytes_after; /**<  */
    uint       value_len; /**<  */
    ubyte      pad0[12]; /**<  */
} ;

/**
 * @brief xcb_list_properties_cookie_t
 **/
struct xcb_list_properties_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_list_properties. */
const uint XCB_LIST_PROPERTIES = 21;

/**
 * @brief xcb_list_properties_request_t
 **/
struct xcb_list_properties_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        pad0; /**<  */
    ushort       length; /**<  */
    xcb_window_t window; /**<  */
} ;

/**
 * @brief xcb_list_properties_reply_t
 **/
struct xcb_list_properties_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ushort atoms_len; /**<  */
    ubyte  pad1[22]; /**<  */
} ;

/** Opcode for xcb_set_selection_owner. */
const uint XCB_SET_SELECTION_OWNER = 22;

/**
 * @brief xcb_set_selection_owner_request_t
 **/
struct xcb_set_selection_owner_request_t {
    ubyte           major_opcode; /**<  */
    ubyte           pad0; /**<  */
    ushort          length; /**<  */
    xcb_window_t    owner; /**<  */
    xcb_atom_t      selection; /**<  */
    xcb_timestamp_t time; /**<  */
} ;

/**
 * @brief xcb_get_selection_owner_cookie_t
 **/
struct xcb_get_selection_owner_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_get_selection_owner. */
const uint XCB_GET_SELECTION_OWNER = 23;

/**
 * @brief xcb_get_selection_owner_request_t
 **/
struct xcb_get_selection_owner_request_t {
    ubyte      major_opcode; /**<  */
    ubyte      pad0; /**<  */
    ushort     length; /**<  */
    xcb_atom_t selection; /**<  */
} ;

/**
 * @brief xcb_get_selection_owner_reply_t
 **/
struct xcb_get_selection_owner_reply_t {
    ubyte        response_type; /**<  */
    ubyte        pad0; /**<  */
    ushort       sequence; /**<  */
    uint         length; /**<  */
    xcb_window_t owner; /**<  */
} ;

/** Opcode for xcb_convert_selection. */
const uint XCB_CONVERT_SELECTION = 24;

/**
 * @brief xcb_convert_selection_request_t
 **/
struct xcb_convert_selection_request_t {
    ubyte           major_opcode; /**<  */
    ubyte           pad0; /**<  */
    ushort          length; /**<  */
    xcb_window_t    requestor; /**<  */
    xcb_atom_t      selection; /**<  */
    xcb_atom_t      target; /**<  */
    xcb_atom_t      property; /**<  */
    xcb_timestamp_t time; /**<  */
} ;

enum :int{
    XCB_SEND_EVENT_DEST_POINTER_WINDOW = 0,
    XCB_SEND_EVENT_DEST_ITEM_FOCUS = 1
};

/** Opcode for xcb_send_event. */
const uint XCB_SEND_EVENT = 25;

/**
 * @brief xcb_send_event_request_t
 **/
struct xcb_send_event_request_t {
    ubyte        major_opcode; /**<  */
    bool         propagate; /**<  */
    ushort       length; /**<  */
    xcb_window_t destination; /**<  */
    uint         event_mask; /**<  */
} ;

enum :int{
    XCB_GRAB_MODE_SYNC = 0,
    XCB_GRAB_MODE_ASYNC = 1
};

enum :int{
    XCB_GRAB_STATUS_SUCCESS = 0,
    XCB_GRAB_STATUS_ALREADY_GRABBED = 1,
    XCB_GRAB_STATUS_INVALID_TIME = 2,
    XCB_GRAB_STATUS_NOT_VIEWABLE = 3,
    XCB_GRAB_STATUS_FROZEN = 4
};

/**
 * @brief xcb_grab_pointer_cookie_t
 **/
struct xcb_grab_pointer_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_grab_pointer. */
const uint XCB_GRAB_POINTER = 26;

/**
 * @brief xcb_grab_pointer_request_t
 **/
struct xcb_grab_pointer_request_t {
    ubyte           major_opcode; /**<  */
    bool            owner_events; /**<  */
    ushort          length; /**<  */
    xcb_window_t    grab_window; /**<  */
    ushort          event_mask; /**<  */
    ubyte           pointer_mode; /**<  */
    ubyte           keyboard_mode; /**<  */
    xcb_window_t    confine_to; /**<  */
    xcb_cursor_t    cursor; /**<  */
    xcb_timestamp_t time; /**<  */
} ;

/**
 * @brief xcb_grab_pointer_reply_t
 **/
struct xcb_grab_pointer_reply_t {
    ubyte  response_type; /**<  */
    ubyte  status; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
} ;

/** Opcode for xcb_ungrab_pointer. */
const uint XCB_UNGRAB_POINTER = 27;

/**
 * @brief xcb_ungrab_pointer_request_t
 **/
struct xcb_ungrab_pointer_request_t {
    ubyte           major_opcode; /**<  */
    ubyte           pad0; /**<  */
    ushort          length; /**<  */
    xcb_timestamp_t time; /**<  */
} ;

enum :int{
    XCB_BUTTON_INDEX_ANY = 0,
    XCB_BUTTON_INDEX_1 = 1,
    XCB_BUTTON_INDEX_2 = 2,
    XCB_BUTTON_INDEX_3 = 3,
    XCB_BUTTON_INDEX_4 = 4,
    XCB_BUTTON_INDEX_5 = 5
};

/** Opcode for xcb_grab_button. */
const uint XCB_GRAB_BUTTON = 28;

/**
 * @brief xcb_grab_button_request_t
 **/
struct xcb_grab_button_request_t {
    ubyte        major_opcode; /**<  */
    bool         owner_events; /**<  */
    ushort       length; /**<  */
    xcb_window_t grab_window; /**<  */
    ushort       event_mask; /**<  */
    ubyte        pointer_mode; /**<  */
    ubyte        keyboard_mode; /**<  */
    xcb_window_t confine_to; /**<  */
    xcb_cursor_t cursor; /**<  */
    ubyte        button; /**<  */
    ubyte        pad0; /**<  */
    ushort       modifiers; /**<  */
} ;

/** Opcode for xcb_ungrab_button. */
const uint XCB_UNGRAB_BUTTON = 29;

/**
 * @brief xcb_ungrab_button_request_t
 **/
struct xcb_ungrab_button_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        button; /**<  */
    ushort       length; /**<  */
    xcb_window_t grab_window; /**<  */
    ushort       modifiers; /**<  */
    ubyte        pad0[2]; /**<  */
} ;

/** Opcode for xcb_change_active_pointer_grab. */
const uint XCB_CHANGE_ACTIVE_POINTER_GRAB = 30;

/**
 * @brief xcb_change_active_pointer_grab_request_t
 **/
struct xcb_change_active_pointer_grab_request_t {
    ubyte           major_opcode; /**<  */
    ubyte           pad0; /**<  */
    ushort          length; /**<  */
    xcb_cursor_t    cursor; /**<  */
    xcb_timestamp_t time; /**<  */
    ushort          event_mask; /**<  */
} ;

/**
 * @brief xcb_grab_keyboard_cookie_t
 **/
struct xcb_grab_keyboard_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_grab_keyboard. */
const uint XCB_GRAB_KEYBOARD = 31;

/**
 * @brief xcb_grab_keyboard_request_t
 **/
struct xcb_grab_keyboard_request_t {
    ubyte           major_opcode; /**<  */
    bool            owner_events; /**<  */
    ushort          length; /**<  */
    xcb_window_t    grab_window; /**<  */
    xcb_timestamp_t time; /**<  */
    ubyte           pointer_mode; /**<  */
    ubyte           keyboard_mode; /**<  */
} ;

/**
 * @brief xcb_grab_keyboard_reply_t
 **/
struct xcb_grab_keyboard_reply_t {
    ubyte  response_type; /**<  */
    ubyte  status; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
} ;

/** Opcode for xcb_ungrab_keyboard. */
const uint XCB_UNGRAB_KEYBOARD = 32;

/**
 * @brief xcb_ungrab_keyboard_request_t
 **/
struct xcb_ungrab_keyboard_request_t {
    ubyte           major_opcode; /**<  */
    ubyte           pad0; /**<  */
    ushort          length; /**<  */
    xcb_timestamp_t time; /**<  */
} ;

enum :int{
    XCB_GRAB_ANY = 0
};

/** Opcode for xcb_grab_key. */
const uint XCB_GRAB_KEY = 33;

/**
 * @brief xcb_grab_key_request_t
 **/
struct xcb_grab_key_request_t {
    ubyte         major_opcode; /**<  */
    bool          owner_events; /**<  */
    ushort        length; /**<  */
    xcb_window_t  grab_window; /**<  */
    ushort        modifiers; /**<  */
    xcb_keycode_t key; /**<  */
    ubyte         pointer_mode; /**<  */
    ubyte         keyboard_mode; /**<  */
} ;

/** Opcode for xcb_ungrab_key. */
const uint XCB_UNGRAB_KEY = 34;

/**
 * @brief xcb_ungrab_key_request_t
 **/
struct xcb_ungrab_key_request_t {
    ubyte         major_opcode; /**<  */
    xcb_keycode_t key; /**<  */
    ushort        length; /**<  */
    xcb_window_t  grab_window; /**<  */
    ushort        modifiers; /**<  */
} ;

enum :int{
    XCB_ALLOW_ASYNC_POINTER = 0,
    XCB_ALLOW_SYNC_POINTER = 1,
    XCB_ALLOW_REPLAY_POINTER = 2,
    XCB_ALLOW_ASYNC_KEYBOARD = 3,
    XCB_ALLOW_SYNC_KEYBOARD = 4,
    XCB_ALLOW_REPLAY_KEYBOARD = 5,
    XCB_ALLOW_ASYNC_BOTH = 6,
    XCB_ALLOW_SYNC_BOTH = 7
};

/** Opcode for xcb_allow_events. */
const uint XCB_ALLOW_EVENTS = 35;

/**
 * @brief xcb_allow_events_request_t
 **/
struct xcb_allow_events_request_t {
    ubyte           major_opcode; /**<  */
    ubyte           mode; /**<  */
    ushort          length; /**<  */
    xcb_timestamp_t time; /**<  */
} ;

/** Opcode for xcb_grab_server. */
const uint XCB_GRAB_SERVER = 36;

/**
 * @brief xcb_grab_server_request_t
 **/
struct xcb_grab_server_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  pad0; /**<  */
    ushort length; /**<  */
} ;

/** Opcode for xcb_ungrab_server. */
const uint XCB_UNGRAB_SERVER = 37;

/**
 * @brief xcb_ungrab_server_request_t
 **/
struct xcb_ungrab_server_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  pad0; /**<  */
    ushort length; /**<  */
} ;

/**
 * @brief xcb_query_pointer_cookie_t
 **/
struct xcb_query_pointer_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_query_pointer. */
const uint XCB_QUERY_POINTER = 38;

/**
 * @brief xcb_query_pointer_request_t
 **/
struct xcb_query_pointer_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        pad0; /**<  */
    ushort       length; /**<  */
    xcb_window_t window; /**<  */
} ;

/**
 * @brief xcb_query_pointer_reply_t
 **/
struct xcb_query_pointer_reply_t {
    ubyte        response_type; /**<  */
    bool         same_screen; /**<  */
    ushort       sequence; /**<  */
    uint         length; /**<  */
    xcb_window_t root; /**<  */
    xcb_window_t child; /**<  */
    short        root_x; /**<  */
    short        root_y; /**<  */
    short        win_x; /**<  */
    short        win_y; /**<  */
    ushort       mask; /**<  */
} ;

/**
 * @brief xcb_timecoord_t
 **/
struct xcb_timecoord_t {
    xcb_timestamp_t time; /**<  */
    short           x; /**<  */
    short           y; /**<  */
} ;

/**
 * @brief xcb_timecoord_iterator_t
 **/
struct xcb_timecoord_iterator_t {
    xcb_timecoord_t *data; /**<  */
    int              rem; /**<  */
    int              index; /**<  */
} ;

/**
 * @brief xcb_get_motion_events_cookie_t
 **/
struct xcb_get_motion_events_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_get_motion_events. */
const uint XCB_GET_MOTION_EVENTS = 39;

/**
 * @brief xcb_get_motion_events_request_t
 **/
struct xcb_get_motion_events_request_t {
    ubyte           major_opcode; /**<  */
    ubyte           pad0; /**<  */
    ushort          length; /**<  */
    xcb_window_t    window; /**<  */
    xcb_timestamp_t start; /**<  */
    xcb_timestamp_t stop; /**<  */
} ;

/**
 * @brief xcb_get_motion_events_reply_t
 **/
struct xcb_get_motion_events_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    uint   events_len; /**<  */
    ubyte  pad1[20]; /**<  */
} ;

/**
 * @brief xcb_translate_coordinates_cookie_t
 **/
struct xcb_translate_coordinates_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_translate_coordinates. */
const uint XCB_TRANSLATE_COORDINATES = 40;

/**
 * @brief xcb_translate_coordinates_request_t
 **/
struct xcb_translate_coordinates_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        pad0; /**<  */
    ushort       length; /**<  */
    xcb_window_t src_window; /**<  */
    xcb_window_t dst_window; /**<  */
    short        src_x; /**<  */
    short        src_y; /**<  */
} ;

/**
 * @brief xcb_translate_coordinates_reply_t
 **/
struct xcb_translate_coordinates_reply_t {
    ubyte        response_type; /**<  */
    bool         same_screen; /**<  */
    ushort       sequence; /**<  */
    uint         length; /**<  */
    xcb_window_t child; /**<  */
    ushort       dst_x; /**<  */
    ushort       dst_y; /**<  */
} ;

/** Opcode for xcb_warp_pointer. */
const uint XCB_WARP_POINTER = 41;

/**
 * @brief xcb_warp_pointer_request_t
 **/
struct xcb_warp_pointer_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        pad0; /**<  */
    ushort       length; /**<  */
    xcb_window_t src_window; /**<  */
    xcb_window_t dst_window; /**<  */
    short        src_x; /**<  */
    short        src_y; /**<  */
    ushort       src_width; /**<  */
    ushort       src_height; /**<  */
    short        dst_x; /**<  */
    short        dst_y; /**<  */
} ;

enum :int{
    XCB_INPUT_FOCUS_NONE = 0,
    XCB_INPUT_FOCUS_POINTER_ROOT = 1,
    XCB_INPUT_FOCUS_PARENT = 2
};

/** Opcode for xcb_set_input_focus. */
const uint XCB_SET_INPUT_FOCUS = 42;

/**
 * @brief xcb_set_input_focus_request_t
 **/
struct xcb_set_input_focus_request_t {
    ubyte           major_opcode; /**<  */
    ubyte           revert_to; /**<  */
    ushort          length; /**<  */
    xcb_window_t    focus; /**<  */
    xcb_timestamp_t time; /**<  */
} ;

/**
 * @brief xcb_get_input_focus_cookie_t
 **/
struct xcb_get_input_focus_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_get_input_focus. */
const uint XCB_GET_INPUT_FOCUS = 43;

/**
 * @brief xcb_get_input_focus_request_t
 **/
struct xcb_get_input_focus_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  pad0; /**<  */
    ushort length; /**<  */
} ;

/**
 * @brief xcb_get_input_focus_reply_t
 **/
struct xcb_get_input_focus_reply_t {
    ubyte        response_type; /**<  */
    ubyte        revert_to; /**<  */
    ushort       sequence; /**<  */
    uint         length; /**<  */
    xcb_window_t focus; /**<  */
} ;

/**
 * @brief xcb_query_keymap_cookie_t
 **/
struct xcb_query_keymap_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_query_keymap. */
const uint XCB_QUERY_KEYMAP = 44;

/**
 * @brief xcb_query_keymap_request_t
 **/
struct xcb_query_keymap_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  pad0; /**<  */
    ushort length; /**<  */
} ;

/**
 * @brief xcb_query_keymap_reply_t
 **/
struct xcb_query_keymap_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ubyte  keys[32]; /**<  */
} ;

/** Opcode for xcb_open_font. */
const uint XCB_OPEN_FONT = 45;

/**
 * @brief xcb_open_font_request_t
 **/
struct xcb_open_font_request_t {
    ubyte      major_opcode; /**<  */
    ubyte      pad0; /**<  */
    ushort     length; /**<  */
    xcb_font_t fid; /**<  */
    ushort     name_len; /**<  */
} ;

/** Opcode for xcb_close_font. */
const uint XCB_CLOSE_FONT = 46;

/**
 * @brief xcb_close_font_request_t
 **/
struct xcb_close_font_request_t {
    ubyte      major_opcode; /**<  */
    ubyte      pad0; /**<  */
    ushort     length; /**<  */
    xcb_font_t font; /**<  */
} ;

enum :int{
    XCB_FONT_DRAW_LEFT_TO_RIGHT = 0,
    XCB_FONT_DRAW_RIGHT_TO_LEFT = 1
};

/**
 * @brief xcb_fontprop_t
 **/
struct xcb_fontprop_t {
    xcb_atom_t name; /**<  */
    uint       value; /**<  */
} ;

/**
 * @brief xcb_fontprop_iterator_t
 **/
struct xcb_fontprop_iterator_t {
    xcb_fontprop_t *data; /**<  */
    int             rem; /**<  */
    int             index; /**<  */
} ;

/**
 * @brief xcb_charinfo_t
 **/
struct xcb_charinfo_t {
    short  left_side_bearing; /**<  */
    short  right_side_bearing; /**<  */
    short  character_width; /**<  */
    short  ascent; /**<  */
    short  descent; /**<  */
    ushort attributes; /**<  */
} ;

/**
 * @brief xcb_charinfo_iterator_t
 **/
struct xcb_charinfo_iterator_t {
    xcb_charinfo_t *data; /**<  */
    int             rem; /**<  */
    int             index; /**<  */
} ;

/**
 * @brief xcb_query_font_cookie_t
 **/
struct xcb_query_font_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_query_font. */
const uint XCB_QUERY_FONT = 47;

/**
 * @brief xcb_query_font_request_t
 **/
struct xcb_query_font_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          pad0; /**<  */
    ushort         length; /**<  */
    xcb_fontable_t font; /**<  */
} ;

/**
 * @brief xcb_query_font_reply_t
 **/
struct xcb_query_font_reply_t {
    ubyte          response_type; /**<  */
    ubyte          pad0; /**<  */
    ushort         sequence; /**<  */
    uint           length; /**<  */
    xcb_charinfo_t min_bounds; /**<  */
    ubyte          pad1[4]; /**<  */
    xcb_charinfo_t max_bounds; /**<  */
    ubyte          pad2[4]; /**<  */
    ushort         min_char_or_byte2; /**<  */
    ushort         max_char_or_byte2; /**<  */
    ushort         default_char; /**<  */
    ushort         properties_len; /**<  */
    ubyte          draw_direction; /**<  */
    ubyte          min_byte1; /**<  */
    ubyte          max_byte1; /**<  */
    bool           all_chars_exist; /**<  */
    short          font_ascent; /**<  */
    short          font_descent; /**<  */
    uint           char_infos_len; /**<  */
} ;

/**
 * @brief xcb_query_text_extents_cookie_t
 **/
struct xcb_query_text_extents_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_query_text_extents. */
const uint XCB_QUERY_TEXT_EXTENTS = 48;

/**
 * @brief xcb_query_text_extents_request_t
 **/
struct xcb_query_text_extents_request_t {
    ubyte          major_opcode; /**<  */
    bool           odd_length; /**<  */
    ushort         length; /**<  */
    xcb_fontable_t font; /**<  */
} ;

/**
 * @brief xcb_query_text_extents_reply_t
 **/
struct xcb_query_text_extents_reply_t {
    ubyte  response_type; /**<  */
    ubyte  draw_direction; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    short  font_ascent; /**<  */
    short  font_descent; /**<  */
    short  overall_ascent; /**<  */
    short  overall_descent; /**<  */
    int    overall_width; /**<  */
    int    overall_left; /**<  */
    int    overall_right; /**<  */
} ;

/**
 * @brief xcb_str_t
 **/
struct xcb_str_t {
    ubyte name_len; /**<  */
} ;

/**
 * @brief xcb_str_iterator_t
 **/
struct xcb_str_iterator_t {
    xcb_str_t *data; /**<  */
    int        rem; /**<  */
    int        index; /**<  */
} ;

/**
 * @brief xcb_list_fonts_cookie_t
 **/
struct xcb_list_fonts_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_list_fonts. */
const uint XCB_LIST_FONTS = 49;

/**
 * @brief xcb_list_fonts_request_t
 **/
struct xcb_list_fonts_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  pad0; /**<  */
    ushort length; /**<  */
    ushort max_names; /**<  */
    ushort pattern_len; /**<  */
} ;

/**
 * @brief xcb_list_fonts_reply_t
 **/
struct xcb_list_fonts_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ushort names_len; /**<  */
    ubyte  pad1[22]; /**<  */
} ;

/**
 * @brief xcb_list_fonts_with_info_cookie_t
 **/
struct xcb_list_fonts_with_info_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_list_fonts_with_info. */
const uint XCB_LIST_FONTS_WITH_INFO = 50;

/**
 * @brief xcb_list_fonts_with_info_request_t
 **/
struct xcb_list_fonts_with_info_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  pad0; /**<  */
    ushort length; /**<  */
    ushort max_names; /**<  */
    ushort pattern_len; /**<  */
} ;

/**
 * @brief xcb_list_fonts_with_info_reply_t
 **/
struct xcb_list_fonts_with_info_reply_t {
    ubyte          response_type; /**<  */
    ubyte          name_len; /**<  */
    ushort         sequence; /**<  */
    uint           length; /**<  */
    xcb_charinfo_t min_bounds; /**<  */
    ubyte          pad0[4]; /**<  */
    xcb_charinfo_t max_bounds; /**<  */
    ubyte          pad1[4]; /**<  */
    ushort         min_char_or_byte2; /**<  */
    ushort         max_char_or_byte2; /**<  */
    ushort         default_char; /**<  */
    ushort         properties_len; /**<  */
    ubyte          draw_direction; /**<  */
    ubyte          min_byte1; /**<  */
    ubyte          max_byte1; /**<  */
    bool           all_chars_exist; /**<  */
    short          font_ascent; /**<  */
    short          font_descent; /**<  */
    uint           replies_hint; /**<  */
} ;

/** Opcode for xcb_set_font_path. */
const uint XCB_SET_FONT_PATH = 51;

/**
 * @brief xcb_set_font_path_request_t
 **/
struct xcb_set_font_path_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  pad0; /**<  */
    ushort length; /**<  */
    ushort font_qty; /**<  */
} ;

/**
 * @brief xcb_get_font_path_cookie_t
 **/
struct xcb_get_font_path_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_get_font_path. */
const uint XCB_GET_FONT_PATH = 52;

/**
 * @brief xcb_get_font_path_request_t
 **/
struct xcb_get_font_path_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  pad0; /**<  */
    ushort length; /**<  */
} ;

/**
 * @brief xcb_get_font_path_reply_t
 **/
struct xcb_get_font_path_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ushort path_len; /**<  */
    ubyte  pad1[22]; /**<  */
} ;

/** Opcode for xcb_create_pixmap. */
const uint XCB_CREATE_PIXMAP = 53;

/**
 * @brief xcb_create_pixmap_request_t
 **/
struct xcb_create_pixmap_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          depth; /**<  */
    ushort         length; /**<  */
    xcb_pixmap_t   pid; /**<  */
    xcb_drawable_t drawable; /**<  */
    ushort         width; /**<  */
    ushort         height; /**<  */
} ;

/** Opcode for xcb_free_pixmap. */
const uint XCB_FREE_PIXMAP = 54;

/**
 * @brief xcb_free_pixmap_request_t
 **/
struct xcb_free_pixmap_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        pad0; /**<  */
    ushort       length; /**<  */
    xcb_pixmap_t pixmap; /**<  */
} ;

enum :int{
    XCB_GC_FUNCTION = (1 << 0),
    XCB_GC_PLANE_MASK = (1 << 1),
    XCB_GC_FOREGROUND = (1 << 2),
    XCB_GC_BACKGROUND = (1 << 3),
    XCB_GC_LINE_WIDTH = (1 << 4),
    XCB_GC_LINE_STYLE = (1 << 5),
    XCB_GC_CAP_STYLE = (1 << 6),
    XCB_GC_JOIN_STYLE = (1 << 7),
    XCB_GC_FILL_STYLE = (1 << 8),
    XCB_GC_FILL_RULE = (1 << 9),
    XCB_GC_TILE = (1 << 10),
    XCB_GC_STIPPLE = (1 << 11),
    XCB_GC_TILE_STIPPLE_ORIGIN_X = (1 << 12),
    XCB_GC_TILE_STIPPLE_ORIGIN_Y = (1 << 13),
    XCB_GC_FONT = (1 << 14),
    XCB_GC_SUBWINDOW_MODE = (1 << 15),
    XCB_GC_GRAPHICS_EXPOSURES = (1 << 16),
    XCB_GC_CLIP_ORIGIN_X = (1 << 17),
    XCB_GC_CLIP_ORIGIN_Y = (1 << 18),
    XCB_GC_CLIP_MASK = (1 << 19),
    XCB_GC_DASH_OFFSET = (1 << 20),
    XCB_GC_DASH_LIST = (1 << 21),
    XCB_GC_ARC_MODE = (1 << 22)
};

enum :int{
    XCB_GX_CLEAR = 0x0,
    XCB_GX_AND = 0x1,
    XCB_GX_AND_REVERSE = 0x2,
    XCB_GX_COPY = 0x3,
    XCB_GX_AND_INVERTED = 0x4,
    XCB_GX_NOOP = 0x5,
    XCB_GX_XOR = 0x6,
    XCB_GX_OR = 0x7,
    XCB_GX_NOR = 0x8,
    XCB_GX_EQUIV = 0x9,
    XCB_GX_INVERT = 0xa,
    XCB_GX_OR_REVERSE = 0xb,
    XCB_GX_COPY_INVERTED = 0xc,
    XCB_GX_OR_INVERTED = 0xd,
    XCB_GX_NAND = 0xe,
    XCB_GX_SET = 0xf
};

enum :int{
    XCB_LINE_STYLE_SOLID = 0,
    XCB_LINE_STYLE_ON_OFF_DASH = 1,
    XCB_LINE_STYLE_DOUBLE_DASH = 2
};

enum :int{
    XCB_CAP_STYLE_NOT_LAST = 0,
    XCB_CAP_STYLE_BUTT = 1,
    XCB_CAP_STYLE_ROUND = 2,
    XCB_CAP_STYLE_PROJECTING = 3
};

enum :int{
    XCB_JOIN_STYLE_MITRE = 0,
    XCB_JOIN_STYLE_ROUND = 1,
    XCB_JOIN_STYLE_BEVEL = 2
};

enum :int{
    XCB_FILL_STYLE_SOLID = 0,
    XCB_FILL_STYLE_TILED = 1,
    XCB_FILL_STYLE_STIPPLED = 2,
    XCB_FILL_STYLE_OPAQUE_STIPPLED = 3
};

enum :int{
    XCB_FILL_RULE_EVEN_ODD = 0,
    XCB_FILL_RULE_WINDING = 1
};

enum :int{
    XCB_SUBWINDOW_MODE_CLIP_BY_CHILDREN = 0,
    XCB_SUBWINDOW_MODE_INCLUDE_INFERIORS = 1
};

enum :int{
    XCB_ARC_MODE_CHORD = 0,
    XCB_ARC_MODE_PIE_SLICE = 1
};

/** Opcode for xcb_create_gc. */
const uint XCB_CREATE_GC = 55;

/**
 * @brief xcb_create_gc_request_t
 **/
struct xcb_create_gc_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          pad0; /**<  */
    ushort         length; /**<  */
    xcb_gcontext_t cid; /**<  */
    xcb_drawable_t drawable; /**<  */
    uint           value_mask; /**<  */
} ;

/** Opcode for xcb_change_gc. */
const uint XCB_CHANGE_GC = 56;

/**
 * @brief xcb_change_gc_request_t
 **/
struct xcb_change_gc_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          pad0; /**<  */
    ushort         length; /**<  */
    xcb_gcontext_t gc; /**<  */
    uint           value_mask; /**<  */
} ;

/** Opcode for xcb_copy_gc. */
const uint XCB_COPY_GC = 57;

/**
 * @brief xcb_copy_gc_request_t
 **/
struct xcb_copy_gc_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          pad0; /**<  */
    ushort         length; /**<  */
    xcb_gcontext_t src_gc; /**<  */
    xcb_gcontext_t dst_gc; /**<  */
    uint           value_mask; /**<  */
} ;

/** Opcode for xcb_set_dashes. */
const uint XCB_SET_DASHES = 58;

/**
 * @brief xcb_set_dashes_request_t
 **/
struct xcb_set_dashes_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          pad0; /**<  */
    ushort         length; /**<  */
    xcb_gcontext_t gc; /**<  */
    ushort         dash_offset; /**<  */
    ushort         dashes_len; /**<  */
} ;

enum :int{
    XCB_CLIP_ORDERING_UNSORTED = 0,
    XCB_CLIP_ORDERING_Y_SORTED = 1,
    XCB_CLIP_ORDERING_YX_SORTED = 2,
    XCB_CLIP_ORDERING_YX_BANDED = 3
};

/** Opcode for xcb_set_clip_rectangles. */
const uint XCB_SET_CLIP_RECTANGLES = 59;

/**
 * @brief xcb_set_clip_rectangles_request_t
 **/
struct xcb_set_clip_rectangles_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          ordering; /**<  */
    ushort         length; /**<  */
    xcb_gcontext_t gc; /**<  */
    short          clip_x_origin; /**<  */
    short          clip_y_origin; /**<  */
} ;

/** Opcode for xcb_free_gc. */
const uint XCB_FREE_GC = 60;

/**
 * @brief xcb_free_gc_request_t
 **/
struct xcb_free_gc_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          pad0; /**<  */
    ushort         length; /**<  */
    xcb_gcontext_t gc; /**<  */
} ;

/** Opcode for xcb_clear_area. */
const uint XCB_CLEAR_AREA = 61;

/**
 * @brief xcb_clear_area_request_t
 **/
struct xcb_clear_area_request_t {
    ubyte        major_opcode; /**<  */
    bool         exposures; /**<  */
    ushort       length; /**<  */
    xcb_window_t window; /**<  */
    short        x; /**<  */
    short        y; /**<  */
    ushort       width; /**<  */
    ushort       height; /**<  */
} ;

/** Opcode for xcb_copy_area. */
const uint XCB_COPY_AREA = 62;

/**
 * @brief xcb_copy_area_request_t
 **/
struct xcb_copy_area_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          pad0; /**<  */
    ushort         length; /**<  */
    xcb_drawable_t src_drawable; /**<  */
    xcb_drawable_t dst_drawable; /**<  */
    xcb_gcontext_t gc; /**<  */
    short          src_x; /**<  */
    short          src_y; /**<  */
    short          dst_x; /**<  */
    short          dst_y; /**<  */
    ushort         width; /**<  */
    ushort         height; /**<  */
} ;

/** Opcode for xcb_copy_plane. */
const uint XCB_COPY_PLANE = 63;

/**
 * @brief xcb_copy_plane_request_t
 **/
struct xcb_copy_plane_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          pad0; /**<  */
    ushort         length; /**<  */
    xcb_drawable_t src_drawable; /**<  */
    xcb_drawable_t dst_drawable; /**<  */
    xcb_gcontext_t gc; /**<  */
    short          src_x; /**<  */
    short          src_y; /**<  */
    short          dst_x; /**<  */
    short          dst_y; /**<  */
    ushort         width; /**<  */
    ushort         height; /**<  */
    uint           bit_plane; /**<  */
} ;

enum :int{
    XCB_COORD_MODE_ORIGIN = 0,
    XCB_COORD_MODE_PREVIOUS = 1
};

/** Opcode for xcb_poly_point. */
const uint XCB_POLY_POINT = 64;

/**
 * @brief xcb_poly_point_request_t
 **/
struct xcb_poly_point_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          coordinate_mode; /**<  */
    ushort         length; /**<  */
    xcb_drawable_t drawable; /**<  */
    xcb_gcontext_t gc; /**<  */
} ;

/** Opcode for xcb_poly_line. */
const uint XCB_POLY_LINE = 65;

/**
 * @brief xcb_poly_line_request_t
 **/
struct xcb_poly_line_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          coordinate_mode; /**<  */
    ushort         length; /**<  */
    xcb_drawable_t drawable; /**<  */
    xcb_gcontext_t gc; /**<  */
} ;

/**
 * @brief xcb_segment_t
 **/
struct xcb_segment_t {
    short x1; /**<  */
    short y1; /**<  */
    short x2; /**<  */
    short y2; /**<  */
} ;

/**
 * @brief xcb_segment_iterator_t
 **/
struct xcb_segment_iterator_t {
    xcb_segment_t *data; /**<  */
    int            rem; /**<  */
    int            index; /**<  */
} ;

/** Opcode for xcb_poly_segment. */
const uint XCB_POLY_SEGMENT = 66;

/**
 * @brief xcb_poly_segment_request_t
 **/
struct xcb_poly_segment_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          pad0; /**<  */
    ushort         length; /**<  */
    xcb_drawable_t drawable; /**<  */
    xcb_gcontext_t gc; /**<  */
} ;

/** Opcode for xcb_poly_rectangle. */
const uint XCB_POLY_RECTANGLE = 67;

/**
 * @brief xcb_poly_rectangle_request_t
 **/
struct xcb_poly_rectangle_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          pad0; /**<  */
    ushort         length; /**<  */
    xcb_drawable_t drawable; /**<  */
    xcb_gcontext_t gc; /**<  */
} ;

/** Opcode for xcb_poly_arc. */
const uint XCB_POLY_ARC = 68;

/**
 * @brief xcb_poly_arc_request_t
 **/
struct xcb_poly_arc_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          pad0; /**<  */
    ushort         length; /**<  */
    xcb_drawable_t drawable; /**<  */
    xcb_gcontext_t gc; /**<  */
} ;

enum :int{
    XCB_POLY_SHAPE_COMPLEX = 0,
    XCB_POLY_SHAPE_NONCONVEX = 1,
    XCB_POLY_SHAPE_CONVEX = 2
};

/** Opcode for xcb_fill_poly. */
const uint XCB_FILL_POLY = 69;

/**
 * @brief xcb_fill_poly_request_t
 **/
struct xcb_fill_poly_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          pad0; /**<  */
    ushort         length; /**<  */
    xcb_drawable_t drawable; /**<  */
    xcb_gcontext_t gc; /**<  */
    ubyte          shape; /**<  */
    ubyte          coordinate_mode; /**<  */
} ;

/** Opcode for xcb_poly_fill_rectangle. */
const uint XCB_POLY_FILL_RECTANGLE = 70;

/**
 * @brief xcb_poly_fill_rectangle_request_t
 **/
struct xcb_poly_fill_rectangle_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          pad0; /**<  */
    ushort         length; /**<  */
    xcb_drawable_t drawable; /**<  */
    xcb_gcontext_t gc; /**<  */
} ;

/** Opcode for xcb_poly_fill_arc. */
const uint XCB_POLY_FILL_ARC = 71;

/**
 * @brief xcb_poly_fill_arc_request_t
 **/
struct xcb_poly_fill_arc_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          pad0; /**<  */
    ushort         length; /**<  */
    xcb_drawable_t drawable; /**<  */
    xcb_gcontext_t gc; /**<  */
} ;

alias xcb_image_format_t = int;
enum :int{
    XCB_IMAGE_FORMAT_XY_BITMAP = 0,
    XCB_IMAGE_FORMAT_XY_PIXMAP = 1,
    XCB_IMAGE_FORMAT_Z_PIXMAP = 2
};

/** Opcode for xcb_put_image. */
const uint XCB_PUT_IMAGE = 72;

/**
 * @brief xcb_put_image_request_t
 **/
struct xcb_put_image_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          format; /**<  */
    ushort         length; /**<  */
    xcb_drawable_t drawable; /**<  */
    xcb_gcontext_t gc; /**<  */
    ushort         width; /**<  */
    ushort         height; /**<  */
    short          dst_x; /**<  */
    short          dst_y; /**<  */
    ubyte          left_pad; /**<  */
    ubyte          depth; /**<  */
} ;

/**
 * @brief xcb_get_image_cookie_t
 **/
struct xcb_get_image_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_get_image. */
const uint XCB_GET_IMAGE = 73;

/**
 * @brief xcb_get_image_request_t
 **/
struct xcb_get_image_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          format; /**<  */
    ushort         length; /**<  */
    xcb_drawable_t drawable; /**<  */
    short          x; /**<  */
    short          y; /**<  */
    ushort         width; /**<  */
    ushort         height; /**<  */
    uint           plane_mask; /**<  */
} ;

/**
 * @brief xcb_get_image_reply_t
 **/
struct xcb_get_image_reply_t {
    ubyte          response_type; /**<  */
    ubyte          depth; /**<  */
    ushort         sequence; /**<  */
    uint           length; /**<  */
    xcb_visualid_t visual; /**<  */
    ubyte          pad0[20]; /**<  */
} ;

/** Opcode for xcb_poly_text_8. */
const uint XCB_POLY_TEXT_8 = 74;

/**
 * @brief xcb_poly_text_8_request_t
 **/
struct xcb_poly_text_8_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          pad0; /**<  */
    ushort         length; /**<  */
    xcb_drawable_t drawable; /**<  */
    xcb_gcontext_t gc; /**<  */
    short          x; /**<  */
    short          y; /**<  */
} ;

/** Opcode for xcb_poly_text_16. */
const uint XCB_POLY_TEXT_16 = 75;

/**
 * @brief xcb_poly_text_16_request_t
 **/
struct xcb_poly_text_16_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          pad0; /**<  */
    ushort         length; /**<  */
    xcb_drawable_t drawable; /**<  */
    xcb_gcontext_t gc; /**<  */
    short          x; /**<  */
    short          y; /**<  */
} ;

/** Opcode for xcb_image_text_8. */
const uint XCB_IMAGE_TEXT_8 = 76;

/**
 * @brief xcb_image_text_8_request_t
 **/
struct xcb_image_text_8_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          string_len; /**<  */
    ushort         length; /**<  */
    xcb_drawable_t drawable; /**<  */
    xcb_gcontext_t gc; /**<  */
    short          x; /**<  */
    short          y; /**<  */
} ;

/** Opcode for xcb_image_text_16. */
const uint XCB_IMAGE_TEXT_16 = 77;

/**
 * @brief xcb_image_text_16_request_t
 **/
struct xcb_image_text_16_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          string_len; /**<  */
    ushort         length; /**<  */
    xcb_drawable_t drawable; /**<  */
    xcb_gcontext_t gc; /**<  */
    short          x; /**<  */
    short          y; /**<  */
} ;

enum :int{
    XCB_COLORMAP_ALLOC_NONE = 0,
    XCB_COLORMAP_ALLOC_ALL = 1
};

/** Opcode for xcb_create_colormap. */
const uint XCB_CREATE_COLORMAP = 78;

/**
 * @brief xcb_create_colormap_request_t
 **/
struct xcb_create_colormap_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          alloc; /**<  */
    ushort         length; /**<  */
    xcb_colormap_t mid; /**<  */
    xcb_window_t   window; /**<  */
    xcb_visualid_t visual; /**<  */
} ;

/** Opcode for xcb_free_colormap. */
const uint XCB_FREE_COLORMAP = 79;

/**
 * @brief xcb_free_colormap_request_t
 **/
struct xcb_free_colormap_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          pad0; /**<  */
    ushort         length; /**<  */
    xcb_colormap_t cmap; /**<  */
} ;

/** Opcode for xcb_copy_colormap_and_free. */
const uint XCB_COPY_COLORMAP_AND_FREE = 80;

/**
 * @brief xcb_copy_colormap_and_free_request_t
 **/
struct xcb_copy_colormap_and_free_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          pad0; /**<  */
    ushort         length; /**<  */
    xcb_colormap_t mid; /**<  */
    xcb_colormap_t src_cmap; /**<  */
} ;

/** Opcode for xcb_install_colormap. */
const uint XCB_INSTALL_COLORMAP = 81;

/**
 * @brief xcb_install_colormap_request_t
 **/
struct xcb_install_colormap_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          pad0; /**<  */
    ushort         length; /**<  */
    xcb_colormap_t cmap; /**<  */
} ;

/** Opcode for xcb_uninstall_colormap. */
const uint XCB_UNINSTALL_COLORMAP = 82;

/**
 * @brief xcb_uninstall_colormap_request_t
 **/
struct xcb_uninstall_colormap_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          pad0; /**<  */
    ushort         length; /**<  */
    xcb_colormap_t cmap; /**<  */
} ;

/**
 * @brief xcb_list_installed_colormaps_cookie_t
 **/
struct xcb_list_installed_colormaps_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_list_installed_colormaps. */
const uint XCB_LIST_INSTALLED_COLORMAPS = 83;

/**
 * @brief xcb_list_installed_colormaps_request_t
 **/
struct xcb_list_installed_colormaps_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        pad0; /**<  */
    ushort       length; /**<  */
    xcb_window_t window; /**<  */
} ;

/**
 * @brief xcb_list_installed_colormaps_reply_t
 **/
struct xcb_list_installed_colormaps_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ushort cmaps_len; /**<  */
    ubyte  pad1[22]; /**<  */
} ;

/**
 * @brief xcb_alloc_color_cookie_t
 **/
struct xcb_alloc_color_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_alloc_color. */
const uint XCB_ALLOC_COLOR = 84;

/**
 * @brief xcb_alloc_color_request_t
 **/
struct xcb_alloc_color_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          pad0; /**<  */
    ushort         length; /**<  */
    xcb_colormap_t cmap; /**<  */
    ushort         red; /**<  */
    ushort         green; /**<  */
    ushort         blue; /**<  */
} ;

/**
 * @brief xcb_alloc_color_reply_t
 **/
struct xcb_alloc_color_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ushort red; /**<  */
    ushort green; /**<  */
    ushort blue; /**<  */
    ubyte  pad1[2]; /**<  */
    uint   pixel; /**<  */
} ;

/**
 * @brief xcb_alloc_named_color_cookie_t
 **/
struct xcb_alloc_named_color_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_alloc_named_color. */
const uint XCB_ALLOC_NAMED_COLOR = 85;

/**
 * @brief xcb_alloc_named_color_request_t
 **/
struct xcb_alloc_named_color_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          pad0; /**<  */
    ushort         length; /**<  */
    xcb_colormap_t cmap; /**<  */
    ushort         name_len; /**<  */
} ;

/**
 * @brief xcb_alloc_named_color_reply_t
 **/
struct xcb_alloc_named_color_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    uint   pixel; /**<  */
    ushort exact_red; /**<  */
    ushort exact_green; /**<  */
    ushort exact_blue; /**<  */
    ushort visual_red; /**<  */
    ushort visual_green; /**<  */
    ushort visual_blue; /**<  */
} ;

/**
 * @brief xcb_alloc_color_cells_cookie_t
 **/
struct xcb_alloc_color_cells_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_alloc_color_cells. */
const uint XCB_ALLOC_COLOR_CELLS = 86;

/**
 * @brief xcb_alloc_color_cells_request_t
 **/
struct xcb_alloc_color_cells_request_t {
    ubyte          major_opcode; /**<  */
    bool           contiguous; /**<  */
    ushort         length; /**<  */
    xcb_colormap_t cmap; /**<  */
    ushort         colors; /**<  */
    ushort         planes; /**<  */
} ;

/**
 * @brief xcb_alloc_color_cells_reply_t
 **/
struct xcb_alloc_color_cells_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ushort pixels_len; /**<  */
    ushort masks_len; /**<  */
    ubyte  pad1[20]; /**<  */
} ;

/**
 * @brief xcb_alloc_color_planes_cookie_t
 **/
struct xcb_alloc_color_planes_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_alloc_color_planes. */
const uint XCB_ALLOC_COLOR_PLANES = 87;

/**
 * @brief xcb_alloc_color_planes_request_t
 **/
struct xcb_alloc_color_planes_request_t {
    ubyte          major_opcode; /**<  */
    bool           contiguous; /**<  */
    ushort         length; /**<  */
    xcb_colormap_t cmap; /**<  */
    ushort         colors; /**<  */
    ushort         reds; /**<  */
    ushort         greens; /**<  */
    ushort         blues; /**<  */
} ;

/**
 * @brief xcb_alloc_color_planes_reply_t
 **/
struct xcb_alloc_color_planes_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ushort pixels_len; /**<  */
    ubyte  pad1[2]; /**<  */
    uint   red_mask; /**<  */
    uint   green_mask; /**<  */
    uint   blue_mask; /**<  */
    ubyte  pad2[8]; /**<  */
} ;

/** Opcode for xcb_free_colors. */
const uint XCB_FREE_COLORS = 88;

/**
 * @brief xcb_free_colors_request_t
 **/
struct xcb_free_colors_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          pad0; /**<  */
    ushort         length; /**<  */
    xcb_colormap_t cmap; /**<  */
    uint           plane_mask; /**<  */
} ;

enum :int{
    XCB_COLOR_FLAG_RED = (1 << 0),
    XCB_COLOR_FLAG_GREEN = (1 << 1),
    XCB_COLOR_FLAG_BLUE = (1 << 2)
};

/**
 * @brief xcb_coloritem_t
 **/
struct xcb_coloritem_t {
    uint   pixel; /**<  */
    ushort red; /**<  */
    ushort green; /**<  */
    ushort blue; /**<  */
    ubyte  flags; /**<  */
    ubyte  pad0; /**<  */
} ;

/**
 * @brief xcb_coloritem_iterator_t
 **/
struct xcb_coloritem_iterator_t {
    xcb_coloritem_t *data; /**<  */
    int              rem; /**<  */
    int              index; /**<  */
} ;

/** Opcode for xcb_store_colors. */
const uint XCB_STORE_COLORS = 89;

/**
 * @brief xcb_store_colors_request_t
 **/
struct xcb_store_colors_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          pad0; /**<  */
    ushort         length; /**<  */
    xcb_colormap_t cmap; /**<  */
} ;

/** Opcode for xcb_store_named_color. */
const uint XCB_STORE_NAMED_COLOR = 90;

/**
 * @brief xcb_store_named_color_request_t
 **/
struct xcb_store_named_color_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          flags; /**<  */
    ushort         length; /**<  */
    xcb_colormap_t cmap; /**<  */
    uint           pixel; /**<  */
    ushort         name_len; /**<  */
} ;

/**
 * @brief xcb_rgb_t
 **/
struct xcb_rgb_t {
    ushort red; /**<  */
    ushort green; /**<  */
    ushort blue; /**<  */
    ubyte  pad0[2]; /**<  */
} ;

/**
 * @brief xcb_rgb_iterator_t
 **/
struct xcb_rgb_iterator_t {
    xcb_rgb_t *data; /**<  */
    int        rem; /**<  */
    int        index; /**<  */
} ;

/**
 * @brief xcb_query_colors_cookie_t
 **/
struct xcb_query_colors_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_query_colors. */
const uint XCB_QUERY_COLORS = 91;

/**
 * @brief xcb_query_colors_request_t
 **/
struct xcb_query_colors_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          pad0; /**<  */
    ushort         length; /**<  */
    xcb_colormap_t cmap; /**<  */
} ;

/**
 * @brief xcb_query_colors_reply_t
 **/
struct xcb_query_colors_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ushort colors_len; /**<  */
    ubyte  pad1[22]; /**<  */
} ;

/**
 * @brief xcb_lookup_color_cookie_t
 **/
struct xcb_lookup_color_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_lookup_color. */
const uint XCB_LOOKUP_COLOR = 92;

/**
 * @brief xcb_lookup_color_request_t
 **/
struct xcb_lookup_color_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          pad0; /**<  */
    ushort         length; /**<  */
    xcb_colormap_t cmap; /**<  */
    ushort         name_len; /**<  */
} ;

/**
 * @brief xcb_lookup_color_reply_t
 **/
struct xcb_lookup_color_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ushort exact_red; /**<  */
    ushort exact_green; /**<  */
    ushort exact_blue; /**<  */
    ushort visual_red; /**<  */
    ushort visual_green; /**<  */
    ushort visual_blue; /**<  */
} ;

/** Opcode for xcb_create_cursor. */
const uint XCB_CREATE_CURSOR = 93;

/**
 * @brief xcb_create_cursor_request_t
 **/
struct xcb_create_cursor_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        pad0; /**<  */
    ushort       length; /**<  */
    xcb_cursor_t cid; /**<  */
    xcb_pixmap_t source; /**<  */
    xcb_pixmap_t mask; /**<  */
    ushort       fore_red; /**<  */
    ushort       fore_green; /**<  */
    ushort       fore_blue; /**<  */
    ushort       back_red; /**<  */
    ushort       back_green; /**<  */
    ushort       back_blue; /**<  */
    ushort       x; /**<  */
    ushort       y; /**<  */
} ;

/** Opcode for xcb_create_glyph_cursor. */
const uint XCB_CREATE_GLYPH_CURSOR = 94;

/**
 * @brief xcb_create_glyph_cursor_request_t
 **/
struct xcb_create_glyph_cursor_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        pad0; /**<  */
    ushort       length; /**<  */
    xcb_cursor_t cid; /**<  */
    xcb_font_t   source_font; /**<  */
    xcb_font_t   mask_font; /**<  */
    ushort       source_char; /**<  */
    ushort       mask_char; /**<  */
    ushort       fore_red; /**<  */
    ushort       fore_green; /**<  */
    ushort       fore_blue; /**<  */
    ushort       back_red; /**<  */
    ushort       back_green; /**<  */
    ushort       back_blue; /**<  */
} ;

/** Opcode for xcb_free_cursor. */
const uint XCB_FREE_CURSOR = 95;

/**
 * @brief xcb_free_cursor_request_t
 **/
struct xcb_free_cursor_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        pad0; /**<  */
    ushort       length; /**<  */
    xcb_cursor_t cursor; /**<  */
} ;

/** Opcode for xcb_recolor_cursor. */
const uint XCB_RECOLOR_CURSOR = 96;

/**
 * @brief xcb_recolor_cursor_request_t
 **/
struct xcb_recolor_cursor_request_t {
    ubyte        major_opcode; /**<  */
    ubyte        pad0; /**<  */
    ushort       length; /**<  */
    xcb_cursor_t cursor; /**<  */
    ushort       fore_red; /**<  */
    ushort       fore_green; /**<  */
    ushort       fore_blue; /**<  */
    ushort       back_red; /**<  */
    ushort       back_green; /**<  */
    ushort       back_blue; /**<  */
} ;

enum :int{
    XCB_QUERY_SHAPE_OF_LARGEST_CURSOR = 0,
    XCB_QUERY_SHAPE_OF_FASTEST_TILE = 1,
    XCB_QUERY_SHAPE_OF_FASTEST_STIPPLE = 2
};

/**
 * @brief xcb_query_best_size_cookie_t
 **/
struct xcb_query_best_size_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_query_best_size. */
const uint XCB_QUERY_BEST_SIZE = 97;

/**
 * @brief xcb_query_best_size_request_t
 **/
struct xcb_query_best_size_request_t {
    ubyte          major_opcode; /**<  */
    ubyte          _class; /**<  */
    ushort         length; /**<  */
    xcb_drawable_t drawable; /**<  */
    ushort         width; /**<  */
    ushort         height; /**<  */
} ;

/**
 * @brief xcb_query_best_size_reply_t
 **/
struct xcb_query_best_size_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ushort width; /**<  */
    ushort height; /**<  */
} ;

/**
 * @brief xcb_query_extension_cookie_t
 **/
struct xcb_query_extension_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_query_extension. */
const uint XCB_QUERY_EXTENSION = 98;

/**
 * @brief xcb_query_extension_request_t
 **/
struct xcb_query_extension_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  pad0; /**<  */
    ushort length; /**<  */
    ushort name_len; /**<  */
} ;

/**
 * @brief xcb_query_extension_reply_t
 **/
struct xcb_query_extension_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    bool   present; /**<  */
    ubyte  major_opcode; /**<  */
    ubyte  first_event; /**<  */
    ubyte  first_error; /**<  */
} ;

/**
 * @brief xcb_list_extensions_cookie_t
 **/
struct xcb_list_extensions_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_list_extensions. */
const uint XCB_LIST_EXTENSIONS = 99;

/**
 * @brief xcb_list_extensions_request_t
 **/
struct xcb_list_extensions_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  pad0; /**<  */
    ushort length; /**<  */
} ;

/**
 * @brief xcb_list_extensions_reply_t
 **/
struct xcb_list_extensions_reply_t {
    ubyte  response_type; /**<  */
    ubyte  names_len; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ubyte  pad0[24]; /**<  */
} ;

/** Opcode for xcb_change_keyboard_mapping. */
const uint XCB_CHANGE_KEYBOARD_MAPPING = 100;

/**
 * @brief xcb_change_keyboard_mapping_request_t
 **/
struct xcb_change_keyboard_mapping_request_t {
    ubyte         major_opcode; /**<  */
    ubyte         keycode_count; /**<  */
    ushort        length; /**<  */
    xcb_keycode_t first_keycode; /**<  */
    ubyte         keysyms_per_keycode; /**<  */
} ;

/**
 * @brief xcb_get_keyboard_mapping_cookie_t
 **/
struct xcb_get_keyboard_mapping_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_get_keyboard_mapping. */
const uint XCB_GET_KEYBOARD_MAPPING = 101;

/**
 * @brief xcb_get_keyboard_mapping_request_t
 **/
struct xcb_get_keyboard_mapping_request_t {
    ubyte         major_opcode; /**<  */
    ubyte         pad0; /**<  */
    ushort        length; /**<  */
    xcb_keycode_t first_keycode; /**<  */
    ubyte         count; /**<  */
} ;

/**
 * @brief xcb_get_keyboard_mapping_reply_t
 **/
struct xcb_get_keyboard_mapping_reply_t {
    ubyte  response_type; /**<  */
    ubyte  keysyms_per_keycode; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ubyte  pad0[24]; /**<  */
} ;

enum :int{
    XCB_KB_KEY_CLICK_PERCENT = (1 << 0),
    XCB_KB_BELL_PERCENT = (1 << 1),
    XCB_KB_BELL_PITCH = (1 << 2),
    XCB_KB_BELL_DURATION = (1 << 3),
    XCB_KB_LED = (1 << 4),
    XCB_KB_LED_MODE = (1 << 5),
    XCB_KB_KEY = (1 << 6),
    XCB_KB_AUTO_REPEAT_MODE = (1 << 7)
};

enum :int{
    XCB_LED_MODE_OFF = 0,
    XCB_LED_MODE_ON = 1
};

enum :int{
    XCB_AUTO_REPEAT_MODE_OFF = 0,
    XCB_AUTO_REPEAT_MODE_ON = 1,
    XCB_AUTO_REPEAT_MODE_DEFAULT = 2
};

/** Opcode for xcb_change_keyboard_control. */
const uint XCB_CHANGE_KEYBOARD_CONTROL = 102;

/**
 * @brief xcb_change_keyboard_control_request_t
 **/
struct xcb_change_keyboard_control_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  pad0; /**<  */
    ushort length; /**<  */
    uint   value_mask; /**<  */
} ;

/**
 * @brief xcb_get_keyboard_control_cookie_t
 **/
struct xcb_get_keyboard_control_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_get_keyboard_control. */
const uint XCB_GET_KEYBOARD_CONTROL = 103;

/**
 * @brief xcb_get_keyboard_control_request_t
 **/
struct xcb_get_keyboard_control_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  pad0; /**<  */
    ushort length; /**<  */
} ;

/**
 * @brief xcb_get_keyboard_control_reply_t
 **/
struct xcb_get_keyboard_control_reply_t {
    ubyte  response_type; /**<  */
    ubyte  global_auto_repeat; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    uint   led_mask; /**<  */
    ubyte  key_click_percent; /**<  */
    ubyte  bell_percent; /**<  */
    ushort bell_pitch; /**<  */
    ushort bell_duration; /**<  */
    ubyte  pad0[2]; /**<  */
    ubyte  auto_repeats[32]; /**<  */
} ;

/** Opcode for xcb_bell. */
const uint XCB_BELL = 104;

/**
 * @brief xcb_bell_request_t
 **/
struct xcb_bell_request_t {
    ubyte  major_opcode; /**<  */
    byte   percent; /**<  */
    ushort length; /**<  */
} ;

/** Opcode for xcb_change_pointer_control. */
const uint XCB_CHANGE_POINTER_CONTROL = 105;

/**
 * @brief xcb_change_pointer_control_request_t
 **/
struct xcb_change_pointer_control_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  pad0; /**<  */
    ushort length; /**<  */
    short  acceleration_numerator; /**<  */
    short  acceleration_denominator; /**<  */
    short  threshold; /**<  */
    bool   do_acceleration; /**<  */
    bool   do_threshold; /**<  */
} ;

/**
 * @brief xcb_get_pointer_control_cookie_t
 **/
struct xcb_get_pointer_control_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_get_pointer_control. */
const uint XCB_GET_POINTER_CONTROL = 106;

/**
 * @brief xcb_get_pointer_control_request_t
 **/
struct xcb_get_pointer_control_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  pad0; /**<  */
    ushort length; /**<  */
} ;

/**
 * @brief xcb_get_pointer_control_reply_t
 **/
struct xcb_get_pointer_control_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ushort acceleration_numerator; /**<  */
    ushort acceleration_denominator; /**<  */
    ushort threshold; /**<  */
} ;

enum :int{
    XCB_BLANKING_NOT_PREFERRED = 0,
    XCB_BLANKING_PREFERRED = 1,
    XCB_BLANKING_DEFAULT = 2
};

enum :int{
    XCB_EXPOSURES_NOT_ALLOWED = 0,
    XCB_EXPOSURES_ALLOWED = 1,
    XCB_EXPOSURES_DEFAULT = 2
};

/** Opcode for xcb_set_screen_saver. */
const uint XCB_SET_SCREEN_SAVER = 107;

/**
 * @brief xcb_set_screen_saver_request_t
 **/
struct xcb_set_screen_saver_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  pad0; /**<  */
    ushort length; /**<  */
    short  timeout; /**<  */
    short  interval; /**<  */
    ubyte  prefer_blanking; /**<  */
    ubyte  allow_exposures; /**<  */
} ;

/**
 * @brief xcb_get_screen_saver_cookie_t
 **/
struct xcb_get_screen_saver_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_get_screen_saver. */
const uint XCB_GET_SCREEN_SAVER = 108;

/**
 * @brief xcb_get_screen_saver_request_t
 **/
struct xcb_get_screen_saver_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  pad0; /**<  */
    ushort length; /**<  */
} ;

/**
 * @brief xcb_get_screen_saver_reply_t
 **/
struct xcb_get_screen_saver_reply_t {
    ubyte  response_type; /**<  */
    ubyte  pad0; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ushort timeout; /**<  */
    ushort interval; /**<  */
    ubyte  prefer_blanking; /**<  */
    ubyte  allow_exposures; /**<  */
} ;

enum :int{
    XCB_HOST_MODE_INSERT = 0,
    XCB_HOST_MODE_DELETE = 1
};

enum :int{
    XCB_FAMILY_INTERNET = 0,
    XCB_FAMILY_DECNET = 1,
    XCB_FAMILY_CHAOS = 2,
    XCB_FAMILY_SERVER_INTERPRETED = 5,
    XCB_FAMILY_INTERNET_6 = 6
};

/** Opcode for xcb_change_hosts. */
const uint XCB_CHANGE_HOSTS = 109;

/**
 * @brief xcb_change_hosts_request_t
 **/
struct xcb_change_hosts_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  mode; /**<  */
    ushort length; /**<  */
    ubyte  family; /**<  */
    ubyte  pad0; /**<  */
    ushort address_len; /**<  */
} ;

/**
 * @brief xcb_host_t
 **/
struct xcb_host_t {
    ubyte  family; /**<  */
    ubyte  pad0; /**<  */
    ushort address_len; /**<  */
} ;

/**
 * @brief xcb_host_iterator_t
 **/
struct xcb_host_iterator_t {
    xcb_host_t *data; /**<  */
    int         rem; /**<  */
    int         index; /**<  */
} ;

/**
 * @brief xcb_list_hosts_cookie_t
 **/
struct xcb_list_hosts_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_list_hosts. */
const uint XCB_LIST_HOSTS = 110;

/**
 * @brief xcb_list_hosts_request_t
 **/
struct xcb_list_hosts_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  pad0; /**<  */
    ushort length; /**<  */
} ;

/**
 * @brief xcb_list_hosts_reply_t
 **/
struct xcb_list_hosts_reply_t {
    ubyte  response_type; /**<  */
    ubyte  mode; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ushort hosts_len; /**<  */
    ubyte  pad0[22]; /**<  */
} ;

enum :int{
    XCB_ACCESS_CONTROL_DISABLE = 0,
    XCB_ACCESS_CONTROL_ENABLE = 1
};

/** Opcode for xcb_set_access_control. */
const uint XCB_SET_ACCESS_CONTROL = 111;

/**
 * @brief xcb_set_access_control_request_t
 **/
struct xcb_set_access_control_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  mode; /**<  */
    ushort length; /**<  */
} ;

enum :int{
    XCB_CLOSE_DOWN_DESTROY_ALL = 0,
    XCB_CLOSE_DOWN_RETAIN_PERMANENT = 1,
    XCB_CLOSE_DOWN_RETAIN_TEMPORARY = 2
};

/** Opcode for xcb_set_close_down_mode. */
const uint XCB_SET_CLOSE_DOWN_MODE = 112;

/**
 * @brief xcb_set_close_down_mode_request_t
 **/
struct xcb_set_close_down_mode_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  mode; /**<  */
    ushort length; /**<  */
} ;

enum :int{
    XCB_KILL_ALL_TEMPORARY = 0
};

/** Opcode for xcb_kill_client. */
const uint XCB_KILL_CLIENT = 113;

/**
 * @brief xcb_kill_client_request_t
 **/
struct xcb_kill_client_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  pad0; /**<  */
    ushort length; /**<  */
    uint   resource; /**<  */
} ;

/** Opcode for xcb_rotate_properties. */
const uint XCB_ROTATE_PROPERTIES = 114;

/**
 * @brief xcb_rotate_properties_request_t
 **/
struct xcb_rotate_properties_request_t {
    ubyte        major_opcode; /**<  */
    xcb_window_t window; /**<  */
    ushort       length; /**<  */
    ushort       atoms_len; /**<  */
    short        delta; /**<  */
} ;

enum :int{
    XCB_SCREEN_SAVER_RESET = 0,
    XCB_SCREEN_SAVER_ACTIVE = 1
};

/** Opcode for xcb_force_screen_saver. */
const uint XCB_FORCE_SCREEN_SAVER = 115;

/**
 * @brief xcb_force_screen_saver_request_t
 **/
struct xcb_force_screen_saver_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  mode; /**<  */
    ushort length; /**<  */
} ;

enum :int{
    XCB_MAPPING_STATUS_SUCCESS = 0,
    XCB_MAPPING_STATUS_BUSY = 1,
    XCB_MAPPING_STATUS_FAILURE = 2
};

/**
 * @brief xcb_set_pointer_mapping_cookie_t
 **/
struct xcb_set_pointer_mapping_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_set_pointer_mapping. */
const uint XCB_SET_POINTER_MAPPING = 116;

/**
 * @brief xcb_set_pointer_mapping_request_t
 **/
struct xcb_set_pointer_mapping_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  map_len; /**<  */
    ushort length; /**<  */
} ;

/**
 * @brief xcb_set_pointer_mapping_reply_t
 **/
struct xcb_set_pointer_mapping_reply_t {
    ubyte  response_type; /**<  */
    ubyte  status; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
} ;

/**
 * @brief xcb_get_pointer_mapping_cookie_t
 **/
struct xcb_get_pointer_mapping_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_get_pointer_mapping. */
const uint XCB_GET_POINTER_MAPPING = 117;

/**
 * @brief xcb_get_pointer_mapping_request_t
 **/
struct xcb_get_pointer_mapping_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  pad0; /**<  */
    ushort length; /**<  */
} ;

/**
 * @brief xcb_get_pointer_mapping_reply_t
 **/
struct xcb_get_pointer_mapping_reply_t {
    ubyte  response_type; /**<  */
    ubyte  map_len; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ubyte  pad0[24]; /**<  */
} ;

enum :int{
    XCB_MAP_INDEX_SHIFT = 0,
    XCB_MAP_INDEX_LOCK = 1,
    XCB_MAP_INDEX_CONTROL = 2,
    XCB_MAP_INDEX_1 = 3,
    XCB_MAP_INDEX_2 = 4,
    XCB_MAP_INDEX_3 = 5,
    XCB_MAP_INDEX_4 = 6,
    XCB_MAP_INDEX_5 = 7
};

/**
 * @brief xcb_set_modifier_mapping_cookie_t
 **/
struct xcb_set_modifier_mapping_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_set_modifier_mapping. */
const uint XCB_SET_MODIFIER_MAPPING = 118;

/**
 * @brief xcb_set_modifier_mapping_request_t
 **/
struct xcb_set_modifier_mapping_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  keycodes_per_modifier; /**<  */
    ushort length; /**<  */
} ;

/**
 * @brief xcb_set_modifier_mapping_reply_t
 **/
struct xcb_set_modifier_mapping_reply_t {
    ubyte  response_type; /**<  */
    ubyte  status; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
} ;

/**
 * @brief xcb_get_modifier_mapping_cookie_t
 **/
struct xcb_get_modifier_mapping_cookie_t {
    uint sequence; /**<  */
} ;

/** Opcode for xcb_get_modifier_mapping. */
const uint XCB_GET_MODIFIER_MAPPING = 119;

/**
 * @brief xcb_get_modifier_mapping_request_t
 **/
struct xcb_get_modifier_mapping_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  pad0; /**<  */
    ushort length; /**<  */
} ;

/**
 * @brief xcb_get_modifier_mapping_reply_t
 **/
struct xcb_get_modifier_mapping_reply_t {
    ubyte  response_type; /**<  */
    ubyte  keycodes_per_modifier; /**<  */
    ushort sequence; /**<  */
    uint   length; /**<  */
    ubyte  pad0[24]; /**<  */
} ;

/** Opcode for xcb_no_operation. */
const uint XCB_NO_OPERATION = 127;

/**
 * @brief xcb_no_operation_request_t
 **/
struct xcb_no_operation_request_t {
    ubyte  major_opcode; /**<  */
    ubyte  pad0; /**<  */
    ushort length; /**<  */
} ;


/*****************************************************************************
 **
 ** void xcb_char2b_next
 **
 ** @param xcb_char2b_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_char2b_next (xcb_char2b_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_char2b_end
 **
 ** @param xcb_char2b_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_char2b_end (xcb_char2b_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_window_next
 **
 ** @param xcb_window_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_window_next (xcb_window_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_window_end
 **
 ** @param xcb_window_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_window_end (xcb_window_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_pixmap_next
 **
 ** @param xcb_pixmap_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_pixmap_next (xcb_pixmap_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_pixmap_end
 **
 ** @param xcb_pixmap_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_pixmap_end (xcb_pixmap_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_cursor_next
 **
 ** @param xcb_cursor_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_cursor_next (xcb_cursor_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_cursor_end
 **
 ** @param xcb_cursor_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_cursor_end (xcb_cursor_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_font_next
 **
 ** @param xcb_font_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_font_next (xcb_font_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_font_end
 **
 ** @param xcb_font_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_font_end (xcb_font_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_gcontext_next
 **
 ** @param xcb_gcontext_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_gcontext_next (xcb_gcontext_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_gcontext_end
 **
 ** @param xcb_gcontext_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_gcontext_end (xcb_gcontext_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_colormap_next
 **
 ** @param xcb_colormap_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_colormap_next (xcb_colormap_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_colormap_end
 **
 ** @param xcb_colormap_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_colormap_end (xcb_colormap_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_atom_next
 **
 ** @param xcb_atom_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_atom_next (xcb_atom_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_atom_end
 **
 ** @param xcb_atom_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_atom_end (xcb_atom_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_drawable_next
 **
 ** @param xcb_drawable_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_drawable_next (xcb_drawable_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_drawable_end
 **
 ** @param xcb_drawable_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_drawable_end (xcb_drawable_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_fontable_next
 **
 ** @param xcb_fontable_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_fontable_next (xcb_fontable_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_fontable_end
 **
 ** @param xcb_fontable_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_fontable_end (xcb_fontable_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_visualid_next
 **
 ** @param xcb_visualid_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_visualid_next (xcb_visualid_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_visualid_end
 **
 ** @param xcb_visualid_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_visualid_end (xcb_visualid_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_timestamp_next
 **
 ** @param xcb_timestamp_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_timestamp_next (xcb_timestamp_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_timestamp_end
 **
 ** @param xcb_timestamp_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_timestamp_end (xcb_timestamp_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_keysym_next
 **
 ** @param xcb_keysym_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_keysym_next (xcb_keysym_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_keysym_end
 **
 ** @param xcb_keysym_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_keysym_end (xcb_keysym_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_keycode_next
 **
 ** @param xcb_keycode_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_keycode_next (xcb_keycode_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_keycode_end
 **
 ** @param xcb_keycode_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_keycode_end (xcb_keycode_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_button_next
 **
 ** @param xcb_button_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_button_next (xcb_button_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_button_end
 **
 ** @param xcb_button_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_button_end (xcb_button_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_point_next
 **
 ** @param xcb_point_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_point_next (xcb_point_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_point_end
 **
 ** @param xcb_point_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_point_end (xcb_point_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_rectangle_next
 **
 ** @param xcb_rectangle_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_rectangle_next (xcb_rectangle_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_rectangle_end
 **
 ** @param xcb_rectangle_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_rectangle_end (xcb_rectangle_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_arc_next
 **
 ** @param xcb_arc_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_arc_next (xcb_arc_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_arc_end
 **
 ** @param xcb_arc_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_arc_end (xcb_arc_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_format_next
 **
 ** @param xcb_format_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_format_next (xcb_format_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_format_end
 **
 ** @param xcb_format_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_format_end (xcb_format_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_visualtype_next
 **
 ** @param xcb_visualtype_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_visualtype_next (xcb_visualtype_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_visualtype_end
 **
 ** @param xcb_visualtype_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_visualtype_end (xcb_visualtype_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** xcb_visualtype_t * xcb_depth_visuals
 **
 ** @param /+const+/ xcb_depth_t *R
 ** @returns xcb_visualtype_t *
 **
 *****************************************************************************/

extern(C) xcb_visualtype_t *
xcb_depth_visuals (/+const+/ xcb_depth_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_depth_visuals_length
 **
 ** @param /+const+/ xcb_depth_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_depth_visuals_length (/+const+/ xcb_depth_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_visualtype_iterator_t xcb_depth_visuals_iterator
 **
 ** @param /+const+/ xcb_depth_t *R
 ** @returns xcb_visualtype_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_visualtype_iterator_t
xcb_depth_visuals_iterator (/+const+/ xcb_depth_t *R  /**< */);


/*****************************************************************************
 **
 ** void xcb_depth_next
 **
 ** @param xcb_depth_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_depth_next (xcb_depth_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_depth_end
 **
 ** @param xcb_depth_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_depth_end (xcb_depth_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** int xcb_screen_allowed_depths_length
 **
 ** @param /+const+/ xcb_screen_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_screen_allowed_depths_length (/+const+/ xcb_screen_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_depth_iterator_t xcb_screen_allowed_depths_iterator
 **
 ** @param /+const+/ xcb_screen_t *R
 ** @returns xcb_depth_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_depth_iterator_t
xcb_screen_allowed_depths_iterator (/+const+/ xcb_screen_t *R  /**< */);


/*****************************************************************************
 **
 ** void xcb_screen_next
 **
 ** @param xcb_screen_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_screen_next (xcb_screen_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_screen_end
 **
 ** @param xcb_screen_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_screen_end (xcb_screen_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** char * xcb_setup_request_authorization_protocol_name
 **
 ** @param /+const+/ xcb_setup_request_t *R
 ** @returns char *
 **
 *****************************************************************************/

extern(C) char *
xcb_setup_request_authorization_protocol_name (/+const+/ xcb_setup_request_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_setup_request_authorization_protocol_name_length
 **
 ** @param /+const+/ xcb_setup_request_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_setup_request_authorization_protocol_name_length (/+const+/ xcb_setup_request_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_setup_request_authorization_protocol_name_end
 **
 ** @param /+const+/ xcb_setup_request_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_setup_request_authorization_protocol_name_end (/+const+/ xcb_setup_request_t *R  /**< */);


/*****************************************************************************
 **
 ** char * xcb_setup_request_authorization_protocol_data
 **
 ** @param /+const+/ xcb_setup_request_t *R
 ** @returns char *
 **
 *****************************************************************************/

extern(C) char *
xcb_setup_request_authorization_protocol_data (/+const+/ xcb_setup_request_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_setup_request_authorization_protocol_data_length
 **
 ** @param /+const+/ xcb_setup_request_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_setup_request_authorization_protocol_data_length (/+const+/ xcb_setup_request_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_setup_request_authorization_protocol_data_end
 **
 ** @param /+const+/ xcb_setup_request_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_setup_request_authorization_protocol_data_end (/+const+/ xcb_setup_request_t *R  /**< */);


/*****************************************************************************
 **
 ** void xcb_setup_request_next
 **
 ** @param xcb_setup_request_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_setup_request_next (xcb_setup_request_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_setup_request_end
 **
 ** @param xcb_setup_request_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_setup_request_end (xcb_setup_request_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** char * xcb_setup_failed_reason
 **
 ** @param /+const+/ xcb_setup_failed_t *R
 ** @returns char *
 **
 *****************************************************************************/

extern(C) char *
xcb_setup_failed_reason (/+const+/ xcb_setup_failed_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_setup_failed_reason_length
 **
 ** @param /+const+/ xcb_setup_failed_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_setup_failed_reason_length (/+const+/ xcb_setup_failed_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_setup_failed_reason_end
 **
 ** @param /+const+/ xcb_setup_failed_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_setup_failed_reason_end (/+const+/ xcb_setup_failed_t *R  /**< */);


/*****************************************************************************
 **
 ** void xcb_setup_failed_next
 **
 ** @param xcb_setup_failed_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_setup_failed_next (xcb_setup_failed_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_setup_failed_end
 **
 ** @param xcb_setup_failed_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_setup_failed_end (xcb_setup_failed_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** char * xcb_setup_authenticate_reason
 **
 ** @param /+const+/ xcb_setup_authenticate_t *R
 ** @returns char *
 **
 *****************************************************************************/

extern(C) char *
xcb_setup_authenticate_reason (/+const+/ xcb_setup_authenticate_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_setup_authenticate_reason_length
 **
 ** @param /+const+/ xcb_setup_authenticate_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_setup_authenticate_reason_length (/+const+/ xcb_setup_authenticate_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_setup_authenticate_reason_end
 **
 ** @param /+const+/ xcb_setup_authenticate_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_setup_authenticate_reason_end (/+const+/ xcb_setup_authenticate_t *R  /**< */);


/*****************************************************************************
 **
 ** void xcb_setup_authenticate_next
 **
 ** @param xcb_setup_authenticate_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_setup_authenticate_next (xcb_setup_authenticate_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_setup_authenticate_end
 **
 ** @param xcb_setup_authenticate_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_setup_authenticate_end (xcb_setup_authenticate_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** char * xcb_setup_vendor
 **
 ** @param /+const+/ xcb_setup_t *R
 ** @returns char *
 **
 *****************************************************************************/

extern(C) char *
xcb_setup_vendor (/+const+/ xcb_setup_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_setup_vendor_length
 **
 ** @param /+const+/ xcb_setup_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_setup_vendor_length (/+const+/ xcb_setup_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_setup_vendor_end
 **
 ** @param /+const+/ xcb_setup_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_setup_vendor_end (/+const+/ xcb_setup_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_format_t * xcb_setup_pixmap_formats
 **
 ** @param /+const+/ xcb_setup_t *R
 ** @returns xcb_format_t *
 **
 *****************************************************************************/

extern(C) xcb_format_t *
xcb_setup_pixmap_formats (/+const+/ xcb_setup_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_setup_pixmap_formats_length
 **
 ** @param /+const+/ xcb_setup_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_setup_pixmap_formats_length (/+const+/ xcb_setup_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_format_iterator_t xcb_setup_pixmap_formats_iterator
 **
 ** @param /+const+/ xcb_setup_t *R
 ** @returns xcb_format_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_format_iterator_t
xcb_setup_pixmap_formats_iterator (/+const+/ xcb_setup_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_setup_roots_length
 **
 ** @param /+const+/ xcb_setup_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_setup_roots_length (/+const+/ xcb_setup_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_screen_iterator_t xcb_setup_roots_iterator
 **
 ** @param /+const+/ xcb_setup_t *R
 ** @returns xcb_screen_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_screen_iterator_t
xcb_setup_roots_iterator (/+const+/ xcb_setup_t *R  /**< */);


/*****************************************************************************
 **
 ** void xcb_setup_next
 **
 ** @param xcb_setup_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_setup_next (xcb_setup_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_setup_end
 **
 ** @param xcb_setup_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_setup_end (xcb_setup_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_client_message_data_next
 **
 ** @param xcb_client_message_data_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_client_message_data_next (xcb_client_message_data_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_client_message_data_end
 **
 ** @param xcb_client_message_data_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_client_message_data_end (xcb_client_message_data_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_create_window_checked
 **
 ** @param xcb_connection_t *c
 ** @param ubyte             depth
 ** @param xcb_window_t      wid
 ** @param xcb_window_t      parent
 ** @param short             x
 ** @param short             y
 ** @param ushort            width
 ** @param ushort            height
 ** @param ushort            border_width
 ** @param ushort            _class
 ** @param xcb_visualid_t    visual
 ** @param uint              value_mask
 ** @param /+const+/ uint   *value_list
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_create_window_checked (xcb_connection_t *c  /**< */,
                           ubyte             depth  /**< */,
                           xcb_window_t      wid  /**< */,
                           xcb_window_t      parent  /**< */,
                           short             x  /**< */,
                           short             y  /**< */,
                           ushort            width  /**< */,
                           ushort            height  /**< */,
                           ushort            border_width  /**< */,
                           ushort            _class  /**< */,
                           xcb_visualid_t    visual  /**< */,
                           uint              value_mask  /**< */,
                           /+const+/ uint   *value_list  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_create_window
 **
 ** @param xcb_connection_t *c
 ** @param ubyte             depth
 ** @param xcb_window_t      wid
 ** @param xcb_window_t      parent
 ** @param short             x
 ** @param short             y
 ** @param ushort            width
 ** @param ushort            height
 ** @param ushort            border_width
 ** @param ushort            _class
 ** @param xcb_visualid_t    visual
 ** @param uint              value_mask
 ** @param /+const+/ uint   *value_list
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_create_window (xcb_connection_t *c  /**< */,
                   ubyte             depth  /**< */,
                   xcb_window_t      wid  /**< */,
                   xcb_window_t      parent  /**< */,
                   short             x  /**< */,
                   short             y  /**< */,
                   ushort            width  /**< */,
                   ushort            height  /**< */,
                   ushort            border_width  /**< */,
                   ushort            _class  /**< */,
                   xcb_visualid_t    visual  /**< */,
                   uint              value_mask  /**< */,
                   /+const+/ uint   *value_list  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_change_window_attributes_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @param uint              value_mask
 ** @param /+const+/ uint   *value_list
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_change_window_attributes_checked (xcb_connection_t *c  /**< */,
                                      xcb_window_t      window  /**< */,
                                      uint              value_mask  /**< */,
                                      /+const+/ uint   *value_list  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_change_window_attributes
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @param uint              value_mask
 ** @param /+const+/ uint   *value_list
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_change_window_attributes (xcb_connection_t *c  /**< */,
                              xcb_window_t      window  /**< */,
                              uint              value_mask  /**< */,
                              /+const+/ uint   *value_list  /**< */);


/*****************************************************************************
 **
 ** xcb_get_window_attributes_cookie_t xcb_get_window_attributes
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @returns xcb_get_window_attributes_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_get_window_attributes_cookie_t
xcb_get_window_attributes (xcb_connection_t *c  /**< */,
                           xcb_window_t      window  /**< */);


/*****************************************************************************
 **
 ** xcb_get_window_attributes_cookie_t xcb_get_window_attributes_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @returns xcb_get_window_attributes_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_get_window_attributes_cookie_t
xcb_get_window_attributes_unchecked (xcb_connection_t *c  /**< */,
                                     xcb_window_t      window  /**< */);


/*****************************************************************************
 **
 ** xcb_get_window_attributes_reply_t * xcb_get_window_attributes_reply
 **
 ** @param xcb_connection_t                    *c
 ** @param xcb_get_window_attributes_cookie_t   cookie
 ** @param xcb_generic_error_t                **e
 ** @returns xcb_get_window_attributes_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_get_window_attributes_reply_t *
xcb_get_window_attributes_reply (xcb_connection_t                    *c  /**< */,
                                 xcb_get_window_attributes_cookie_t   cookie  /**< */,
                                 xcb_generic_error_t                **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_destroy_window_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_destroy_window_checked (xcb_connection_t *c  /**< */,
                            xcb_window_t      window  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_destroy_window
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_destroy_window (xcb_connection_t *c  /**< */,
                    xcb_window_t      window  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_destroy_subwindows_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_destroy_subwindows_checked (xcb_connection_t *c  /**< */,
                                xcb_window_t      window  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_destroy_subwindows
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_destroy_subwindows (xcb_connection_t *c  /**< */,
                        xcb_window_t      window  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_change_save_set_checked
 **
 ** @param xcb_connection_t *c
 ** @param ubyte             mode
 ** @param xcb_window_t      window
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_change_save_set_checked (xcb_connection_t *c  /**< */,
                             ubyte             mode  /**< */,
                             xcb_window_t      window  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_change_save_set
 **
 ** @param xcb_connection_t *c
 ** @param ubyte             mode
 ** @param xcb_window_t      window
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_change_save_set (xcb_connection_t *c  /**< */,
                     ubyte             mode  /**< */,
                     xcb_window_t      window  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_reparent_window_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @param xcb_window_t      parent
 ** @param short             x
 ** @param short             y
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_reparent_window_checked (xcb_connection_t *c  /**< */,
                             xcb_window_t      window  /**< */,
                             xcb_window_t      parent  /**< */,
                             short             x  /**< */,
                             short             y  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_reparent_window
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @param xcb_window_t      parent
 ** @param short             x
 ** @param short             y
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_reparent_window (xcb_connection_t *c  /**< */,
                     xcb_window_t      window  /**< */,
                     xcb_window_t      parent  /**< */,
                     short             x  /**< */,
                     short             y  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_map_window_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_map_window_checked (xcb_connection_t *c  /**< */,
                        xcb_window_t      window  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_map_window
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_map_window (xcb_connection_t *c  /**< */,
                xcb_window_t      window  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_map_subwindows_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_map_subwindows_checked (xcb_connection_t *c  /**< */,
                            xcb_window_t      window  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_map_subwindows
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_map_subwindows (xcb_connection_t *c  /**< */,
                    xcb_window_t      window  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_unmap_window_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_unmap_window_checked (xcb_connection_t *c  /**< */,
                          xcb_window_t      window  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_unmap_window
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_unmap_window (xcb_connection_t *c  /**< */,
                  xcb_window_t      window  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_unmap_subwindows_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_unmap_subwindows_checked (xcb_connection_t *c  /**< */,
                              xcb_window_t      window  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_unmap_subwindows
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_unmap_subwindows (xcb_connection_t *c  /**< */,
                      xcb_window_t      window  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_configure_window_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @param ushort            value_mask
 ** @param /+const+/ uint   *value_list
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_configure_window_checked (xcb_connection_t *c  /**< */,
                              xcb_window_t      window  /**< */,
                              ushort            value_mask  /**< */,
                              /+const+/ uint   *value_list  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_configure_window
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @param ushort            value_mask
 ** @param /+const+/ uint   *value_list
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_configure_window (xcb_connection_t *c  /**< */,
                      xcb_window_t      window  /**< */,
                      ushort            value_mask  /**< */,
                      /+const+/ uint   *value_list  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_circulate_window_checked
 **
 ** @param xcb_connection_t *c
 ** @param ubyte             direction
 ** @param xcb_window_t      window
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_circulate_window_checked (xcb_connection_t *c  /**< */,
                              ubyte             direction  /**< */,
                              xcb_window_t      window  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_circulate_window
 **
 ** @param xcb_connection_t *c
 ** @param ubyte             direction
 ** @param xcb_window_t      window
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_circulate_window (xcb_connection_t *c  /**< */,
                      ubyte             direction  /**< */,
                      xcb_window_t      window  /**< */);


/*****************************************************************************
 **
 ** xcb_get_geometry_cookie_t xcb_get_geometry
 **
 ** @param xcb_connection_t *c
 ** @param xcb_drawable_t    drawable
 ** @returns xcb_get_geometry_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_get_geometry_cookie_t
xcb_get_geometry (xcb_connection_t *c  /**< */,
                  xcb_drawable_t    drawable  /**< */);


/*****************************************************************************
 **
 ** xcb_get_geometry_cookie_t xcb_get_geometry_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_drawable_t    drawable
 ** @returns xcb_get_geometry_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_get_geometry_cookie_t
xcb_get_geometry_unchecked (xcb_connection_t *c  /**< */,
                            xcb_drawable_t    drawable  /**< */);


/*****************************************************************************
 **
 ** xcb_get_geometry_reply_t * xcb_get_geometry_reply
 **
 ** @param xcb_connection_t           *c
 ** @param xcb_get_geometry_cookie_t   cookie
 ** @param xcb_generic_error_t       **e
 ** @returns xcb_get_geometry_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_get_geometry_reply_t *
xcb_get_geometry_reply (xcb_connection_t           *c  /**< */,
                        xcb_get_geometry_cookie_t   cookie  /**< */,
                        xcb_generic_error_t       **e  /**< */);


/*****************************************************************************
 **
 ** xcb_query_tree_cookie_t xcb_query_tree
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @returns xcb_query_tree_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_query_tree_cookie_t
xcb_query_tree (xcb_connection_t *c  /**< */,
                xcb_window_t      window  /**< */);


/*****************************************************************************
 **
 ** xcb_query_tree_cookie_t xcb_query_tree_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @returns xcb_query_tree_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_query_tree_cookie_t
xcb_query_tree_unchecked (xcb_connection_t *c  /**< */,
                          xcb_window_t      window  /**< */);


/*****************************************************************************
 **
 ** xcb_window_t * xcb_query_tree_children
 **
 ** @param /+const+/ xcb_query_tree_reply_t *R
 ** @returns xcb_window_t *
 **
 *****************************************************************************/

extern(C) xcb_window_t *
xcb_query_tree_children (/+const+/ xcb_query_tree_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_query_tree_children_length
 **
 ** @param /+const+/ xcb_query_tree_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_query_tree_children_length (/+const+/ xcb_query_tree_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_window_iterator_t xcb_query_tree_children_iterator
 **
 ** @param /+const+/ xcb_query_tree_reply_t *R
 ** @returns xcb_window_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_window_iterator_t
xcb_query_tree_children_iterator (/+const+/ xcb_query_tree_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_query_tree_reply_t * xcb_query_tree_reply
 **
 ** @param xcb_connection_t         *c
 ** @param xcb_query_tree_cookie_t   cookie
 ** @param xcb_generic_error_t     **e
 ** @returns xcb_query_tree_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_query_tree_reply_t *
xcb_query_tree_reply (xcb_connection_t         *c  /**< */,
                      xcb_query_tree_cookie_t   cookie  /**< */,
                      xcb_generic_error_t     **e  /**< */);


/*****************************************************************************
 **
 ** xcb_intern_atom_cookie_t xcb_intern_atom
 **
 ** @param xcb_connection_t *c
 ** @param bool              only_if_exists
 ** @param ushort            name_len
 ** @param /+const+/ char   *name
 ** @returns xcb_intern_atom_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_intern_atom_cookie_t
xcb_intern_atom (xcb_connection_t *c  /**< */,
                 bool              only_if_exists  /**< */,
                 ushort            name_len  /**< */,
                 /+const+/ char   *name  /**< */);


/*****************************************************************************
 **
 ** xcb_intern_atom_cookie_t xcb_intern_atom_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param bool              only_if_exists
 ** @param ushort            name_len
 ** @param /+const+/ char   *name
 ** @returns xcb_intern_atom_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_intern_atom_cookie_t
xcb_intern_atom_unchecked (xcb_connection_t *c  /**< */,
                           bool              only_if_exists  /**< */,
                           ushort            name_len  /**< */,
                           /+const+/ char   *name  /**< */);


/*****************************************************************************
 **
 ** xcb_intern_atom_reply_t * xcb_intern_atom_reply
 **
 ** @param xcb_connection_t          *c
 ** @param xcb_intern_atom_cookie_t   cookie
 ** @param xcb_generic_error_t      **e
 ** @returns xcb_intern_atom_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_intern_atom_reply_t *
xcb_intern_atom_reply (xcb_connection_t          *c  /**< */,
                       xcb_intern_atom_cookie_t   cookie  /**< */,
                       xcb_generic_error_t      **e  /**< */);


/*****************************************************************************
 **
 ** xcb_get_atom_name_cookie_t xcb_get_atom_name
 **
 ** @param xcb_connection_t *c
 ** @param xcb_atom_t        atom
 ** @returns xcb_get_atom_name_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_get_atom_name_cookie_t
xcb_get_atom_name (xcb_connection_t *c  /**< */,
                   xcb_atom_t        atom  /**< */);


/*****************************************************************************
 **
 ** xcb_get_atom_name_cookie_t xcb_get_atom_name_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_atom_t        atom
 ** @returns xcb_get_atom_name_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_get_atom_name_cookie_t
xcb_get_atom_name_unchecked (xcb_connection_t *c  /**< */,
                             xcb_atom_t        atom  /**< */);


/*****************************************************************************
 **
 ** ubyte * xcb_get_atom_name_name
 **
 ** @param /+const+/ xcb_get_atom_name_reply_t *R
 ** @returns ubyte *
 **
 *****************************************************************************/

extern(C) ubyte *
xcb_get_atom_name_name (/+const+/ xcb_get_atom_name_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_get_atom_name_name_length
 **
 ** @param /+const+/ xcb_get_atom_name_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_get_atom_name_name_length (/+const+/ xcb_get_atom_name_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_get_atom_name_name_end
 **
 ** @param /+const+/ xcb_get_atom_name_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_get_atom_name_name_end (/+const+/ xcb_get_atom_name_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_get_atom_name_reply_t * xcb_get_atom_name_reply
 **
 ** @param xcb_connection_t            *c
 ** @param xcb_get_atom_name_cookie_t   cookie
 ** @param xcb_generic_error_t        **e
 ** @returns xcb_get_atom_name_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_get_atom_name_reply_t *
xcb_get_atom_name_reply (xcb_connection_t            *c  /**< */,
                         xcb_get_atom_name_cookie_t   cookie  /**< */,
                         xcb_generic_error_t        **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_change_property_checked
 **
 ** @param xcb_connection_t *c
 ** @param ubyte             mode
 ** @param xcb_window_t      window
 ** @param xcb_atom_t        property
 ** @param xcb_atom_t        type
 ** @param ubyte             format
 ** @param uint              data_len
 ** @param /+const+/ void   *data
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_change_property_checked (xcb_connection_t *c  /**< */,
                             ubyte             mode  /**< */,
                             xcb_window_t      window  /**< */,
                             xcb_atom_t        property  /**< */,
                             xcb_atom_t        type  /**< */,
                             ubyte             format  /**< */,
                             uint              data_len  /**< */,
                             /+const+/ void   *data  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_change_property
 **
 ** @param xcb_connection_t *c
 ** @param ubyte             mode
 ** @param xcb_window_t      window
 ** @param xcb_atom_t        property
 ** @param xcb_atom_t        type
 ** @param ubyte             format
 ** @param uint              data_len
 ** @param /+const+/ void   *data
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_change_property (xcb_connection_t *c  /**< */,
                     ubyte             mode  /**< */,
                     xcb_window_t      window  /**< */,
                     xcb_atom_t        property  /**< */,
                     xcb_atom_t        type  /**< */,
                     ubyte             format  /**< */,
                     uint              data_len  /**< */,
                     /+const+/ void   *data  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_delete_property_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @param xcb_atom_t        property
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_delete_property_checked (xcb_connection_t *c  /**< */,
                             xcb_window_t      window  /**< */,
                             xcb_atom_t        property  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_delete_property
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @param xcb_atom_t        property
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_delete_property (xcb_connection_t *c  /**< */,
                     xcb_window_t      window  /**< */,
                     xcb_atom_t        property  /**< */);


/*****************************************************************************
 **
 ** xcb_get_property_cookie_t xcb_get_property
 **
 ** @param xcb_connection_t *c
 ** @param bool              _delete
 ** @param xcb_window_t      window
 ** @param xcb_atom_t        property
 ** @param xcb_atom_t        type
 ** @param uint              long_offset
 ** @param uint              long_length
 ** @returns xcb_get_property_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_get_property_cookie_t
xcb_get_property (xcb_connection_t *c  /**< */,
                  bool              _delete  /**< */,
                  xcb_window_t      window  /**< */,
                  xcb_atom_t        property  /**< */,
                  xcb_atom_t        type  /**< */,
                  uint              long_offset  /**< */,
                  uint              long_length  /**< */);


/*****************************************************************************
 **
 ** xcb_get_property_cookie_t xcb_get_property_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param bool              _delete
 ** @param xcb_window_t      window
 ** @param xcb_atom_t        property
 ** @param xcb_atom_t        type
 ** @param uint              long_offset
 ** @param uint              long_length
 ** @returns xcb_get_property_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_get_property_cookie_t
xcb_get_property_unchecked (xcb_connection_t *c  /**< */,
                            bool              _delete  /**< */,
                            xcb_window_t      window  /**< */,
                            xcb_atom_t        property  /**< */,
                            xcb_atom_t        type  /**< */,
                            uint              long_offset  /**< */,
                            uint              long_length  /**< */);


/*****************************************************************************
 **
 ** void * xcb_get_property_value
 **
 ** @param /+const+/ xcb_get_property_reply_t *R
 ** @returns void *
 **
 *****************************************************************************/

extern(C) void *
xcb_get_property_value (/+const+/ xcb_get_property_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_get_property_value_length
 **
 ** @param /+const+/ xcb_get_property_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_get_property_value_length (/+const+/ xcb_get_property_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_get_property_value_end
 **
 ** @param /+const+/ xcb_get_property_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_get_property_value_end (/+const+/ xcb_get_property_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_get_property_reply_t * xcb_get_property_reply
 **
 ** @param xcb_connection_t           *c
 ** @param xcb_get_property_cookie_t   cookie
 ** @param xcb_generic_error_t       **e
 ** @returns xcb_get_property_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_get_property_reply_t *
xcb_get_property_reply (xcb_connection_t           *c  /**< */,
                        xcb_get_property_cookie_t   cookie  /**< */,
                        xcb_generic_error_t       **e  /**< */);


/*****************************************************************************
 **
 ** xcb_list_properties_cookie_t xcb_list_properties
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @returns xcb_list_properties_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_list_properties_cookie_t
xcb_list_properties (xcb_connection_t *c  /**< */,
                     xcb_window_t      window  /**< */);


/*****************************************************************************
 **
 ** xcb_list_properties_cookie_t xcb_list_properties_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @returns xcb_list_properties_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_list_properties_cookie_t
xcb_list_properties_unchecked (xcb_connection_t *c  /**< */,
                               xcb_window_t      window  /**< */);


/*****************************************************************************
 **
 ** xcb_atom_t * xcb_list_properties_atoms
 **
 ** @param /+const+/ xcb_list_properties_reply_t *R
 ** @returns xcb_atom_t *
 **
 *****************************************************************************/

extern(C) xcb_atom_t *
xcb_list_properties_atoms (/+const+/ xcb_list_properties_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_list_properties_atoms_length
 **
 ** @param /+const+/ xcb_list_properties_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_list_properties_atoms_length (/+const+/ xcb_list_properties_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_atom_iterator_t xcb_list_properties_atoms_iterator
 **
 ** @param /+const+/ xcb_list_properties_reply_t *R
 ** @returns xcb_atom_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_atom_iterator_t
xcb_list_properties_atoms_iterator (/+const+/ xcb_list_properties_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_list_properties_reply_t * xcb_list_properties_reply
 **
 ** @param xcb_connection_t              *c
 ** @param xcb_list_properties_cookie_t   cookie
 ** @param xcb_generic_error_t          **e
 ** @returns xcb_list_properties_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_list_properties_reply_t *
xcb_list_properties_reply (xcb_connection_t              *c  /**< */,
                           xcb_list_properties_cookie_t   cookie  /**< */,
                           xcb_generic_error_t          **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_set_selection_owner_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      owner
 ** @param xcb_atom_t        selection
 ** @param xcb_timestamp_t   time
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_set_selection_owner_checked (xcb_connection_t *c  /**< */,
                                 xcb_window_t      owner  /**< */,
                                 xcb_atom_t        selection  /**< */,
                                 xcb_timestamp_t   time  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_set_selection_owner
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      owner
 ** @param xcb_atom_t        selection
 ** @param xcb_timestamp_t   time
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_set_selection_owner (xcb_connection_t *c  /**< */,
                         xcb_window_t      owner  /**< */,
                         xcb_atom_t        selection  /**< */,
                         xcb_timestamp_t   time  /**< */);


/*****************************************************************************
 **
 ** xcb_get_selection_owner_cookie_t xcb_get_selection_owner
 **
 ** @param xcb_connection_t *c
 ** @param xcb_atom_t        selection
 ** @returns xcb_get_selection_owner_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_get_selection_owner_cookie_t
xcb_get_selection_owner (xcb_connection_t *c  /**< */,
                         xcb_atom_t        selection  /**< */);


/*****************************************************************************
 **
 ** xcb_get_selection_owner_cookie_t xcb_get_selection_owner_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_atom_t        selection
 ** @returns xcb_get_selection_owner_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_get_selection_owner_cookie_t
xcb_get_selection_owner_unchecked (xcb_connection_t *c  /**< */,
                                   xcb_atom_t        selection  /**< */);


/*****************************************************************************
 **
 ** xcb_get_selection_owner_reply_t * xcb_get_selection_owner_reply
 **
 ** @param xcb_connection_t                  *c
 ** @param xcb_get_selection_owner_cookie_t   cookie
 ** @param xcb_generic_error_t              **e
 ** @returns xcb_get_selection_owner_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_get_selection_owner_reply_t *
xcb_get_selection_owner_reply (xcb_connection_t                  *c  /**< */,
                               xcb_get_selection_owner_cookie_t   cookie  /**< */,
                               xcb_generic_error_t              **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_convert_selection_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      requestor
 ** @param xcb_atom_t        selection
 ** @param xcb_atom_t        target
 ** @param xcb_atom_t        property
 ** @param xcb_timestamp_t   time
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_convert_selection_checked (xcb_connection_t *c  /**< */,
                               xcb_window_t      requestor  /**< */,
                               xcb_atom_t        selection  /**< */,
                               xcb_atom_t        target  /**< */,
                               xcb_atom_t        property  /**< */,
                               xcb_timestamp_t   time  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_convert_selection
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      requestor
 ** @param xcb_atom_t        selection
 ** @param xcb_atom_t        target
 ** @param xcb_atom_t        property
 ** @param xcb_timestamp_t   time
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_convert_selection (xcb_connection_t *c  /**< */,
                       xcb_window_t      requestor  /**< */,
                       xcb_atom_t        selection  /**< */,
                       xcb_atom_t        target  /**< */,
                       xcb_atom_t        property  /**< */,
                       xcb_timestamp_t   time  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_send_event_checked
 **
 ** @param xcb_connection_t *c
 ** @param bool              propagate
 ** @param xcb_window_t      destination
 ** @param uint              event_mask
 ** @param /+const+/ char   *event
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_send_event_checked (xcb_connection_t *c  /**< */,
                        bool              propagate  /**< */,
                        xcb_window_t      destination  /**< */,
                        uint              event_mask  /**< */,
                        /+const+/ char   *event  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_send_event
 **
 ** @param xcb_connection_t *c
 ** @param bool              propagate
 ** @param xcb_window_t      destination
 ** @param uint              event_mask
 ** @param /+const+/ char   *event
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_send_event (xcb_connection_t *c  /**< */,
                bool              propagate  /**< */,
                xcb_window_t      destination  /**< */,
                uint              event_mask  /**< */,
                /+const+/ char   *event  /**< */);


/*****************************************************************************
 **
 ** xcb_grab_pointer_cookie_t xcb_grab_pointer
 **
 ** @param xcb_connection_t *c
 ** @param bool              owner_events
 ** @param xcb_window_t      grab_window
 ** @param ushort            event_mask
 ** @param ubyte             pointer_mode
 ** @param ubyte             keyboard_mode
 ** @param xcb_window_t      confine_to
 ** @param xcb_cursor_t      cursor
 ** @param xcb_timestamp_t   time
 ** @returns xcb_grab_pointer_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_grab_pointer_cookie_t
xcb_grab_pointer (xcb_connection_t *c  /**< */,
                  bool              owner_events  /**< */,
                  xcb_window_t      grab_window  /**< */,
                  ushort            event_mask  /**< */,
                  ubyte             pointer_mode  /**< */,
                  ubyte             keyboard_mode  /**< */,
                  xcb_window_t      confine_to  /**< */,
                  xcb_cursor_t      cursor  /**< */,
                  xcb_timestamp_t   time  /**< */);


/*****************************************************************************
 **
 ** xcb_grab_pointer_cookie_t xcb_grab_pointer_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param bool              owner_events
 ** @param xcb_window_t      grab_window
 ** @param ushort            event_mask
 ** @param ubyte             pointer_mode
 ** @param ubyte             keyboard_mode
 ** @param xcb_window_t      confine_to
 ** @param xcb_cursor_t      cursor
 ** @param xcb_timestamp_t   time
 ** @returns xcb_grab_pointer_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_grab_pointer_cookie_t
xcb_grab_pointer_unchecked (xcb_connection_t *c  /**< */,
                            bool              owner_events  /**< */,
                            xcb_window_t      grab_window  /**< */,
                            ushort            event_mask  /**< */,
                            ubyte             pointer_mode  /**< */,
                            ubyte             keyboard_mode  /**< */,
                            xcb_window_t      confine_to  /**< */,
                            xcb_cursor_t      cursor  /**< */,
                            xcb_timestamp_t   time  /**< */);


/*****************************************************************************
 **
 ** xcb_grab_pointer_reply_t * xcb_grab_pointer_reply
 **
 ** @param xcb_connection_t           *c
 ** @param xcb_grab_pointer_cookie_t   cookie
 ** @param xcb_generic_error_t       **e
 ** @returns xcb_grab_pointer_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_grab_pointer_reply_t *
xcb_grab_pointer_reply (xcb_connection_t           *c  /**< */,
                        xcb_grab_pointer_cookie_t   cookie  /**< */,
                        xcb_generic_error_t       **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_ungrab_pointer_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_timestamp_t   time
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_ungrab_pointer_checked (xcb_connection_t *c  /**< */,
                            xcb_timestamp_t   time  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_ungrab_pointer
 **
 ** @param xcb_connection_t *c
 ** @param xcb_timestamp_t   time
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_ungrab_pointer (xcb_connection_t *c  /**< */,
                    xcb_timestamp_t   time  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_grab_button_checked
 **
 ** @param xcb_connection_t *c
 ** @param bool              owner_events
 ** @param xcb_window_t      grab_window
 ** @param ushort            event_mask
 ** @param ubyte             pointer_mode
 ** @param ubyte             keyboard_mode
 ** @param xcb_window_t      confine_to
 ** @param xcb_cursor_t      cursor
 ** @param ubyte             button
 ** @param ushort            modifiers
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_grab_button_checked (xcb_connection_t *c  /**< */,
                         bool              owner_events  /**< */,
                         xcb_window_t      grab_window  /**< */,
                         ushort            event_mask  /**< */,
                         ubyte             pointer_mode  /**< */,
                         ubyte             keyboard_mode  /**< */,
                         xcb_window_t      confine_to  /**< */,
                         xcb_cursor_t      cursor  /**< */,
                         ubyte             button  /**< */,
                         ushort            modifiers  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_grab_button
 **
 ** @param xcb_connection_t *c
 ** @param bool              owner_events
 ** @param xcb_window_t      grab_window
 ** @param ushort            event_mask
 ** @param ubyte             pointer_mode
 ** @param ubyte             keyboard_mode
 ** @param xcb_window_t      confine_to
 ** @param xcb_cursor_t      cursor
 ** @param ubyte             button
 ** @param ushort            modifiers
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_grab_button (xcb_connection_t *c  /**< */,
                 bool              owner_events  /**< */,
                 xcb_window_t      grab_window  /**< */,
                 ushort            event_mask  /**< */,
                 ubyte             pointer_mode  /**< */,
                 ubyte             keyboard_mode  /**< */,
                 xcb_window_t      confine_to  /**< */,
                 xcb_cursor_t      cursor  /**< */,
                 ubyte             button  /**< */,
                 ushort            modifiers  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_ungrab_button_checked
 **
 ** @param xcb_connection_t *c
 ** @param ubyte             button
 ** @param xcb_window_t      grab_window
 ** @param ushort            modifiers
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_ungrab_button_checked (xcb_connection_t *c  /**< */,
                           ubyte             button  /**< */,
                           xcb_window_t      grab_window  /**< */,
                           ushort            modifiers  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_ungrab_button
 **
 ** @param xcb_connection_t *c
 ** @param ubyte             button
 ** @param xcb_window_t      grab_window
 ** @param ushort            modifiers
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_ungrab_button (xcb_connection_t *c  /**< */,
                   ubyte             button  /**< */,
                   xcb_window_t      grab_window  /**< */,
                   ushort            modifiers  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_change_active_pointer_grab_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_cursor_t      cursor
 ** @param xcb_timestamp_t   time
 ** @param ushort            event_mask
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_change_active_pointer_grab_checked (xcb_connection_t *c  /**< */,
                                        xcb_cursor_t      cursor  /**< */,
                                        xcb_timestamp_t   time  /**< */,
                                        ushort            event_mask  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_change_active_pointer_grab
 **
 ** @param xcb_connection_t *c
 ** @param xcb_cursor_t      cursor
 ** @param xcb_timestamp_t   time
 ** @param ushort            event_mask
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_change_active_pointer_grab (xcb_connection_t *c  /**< */,
                                xcb_cursor_t      cursor  /**< */,
                                xcb_timestamp_t   time  /**< */,
                                ushort            event_mask  /**< */);


/*****************************************************************************
 **
 ** xcb_grab_keyboard_cookie_t xcb_grab_keyboard
 **
 ** @param xcb_connection_t *c
 ** @param bool              owner_events
 ** @param xcb_window_t      grab_window
 ** @param xcb_timestamp_t   time
 ** @param ubyte             pointer_mode
 ** @param ubyte             keyboard_mode
 ** @returns xcb_grab_keyboard_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_grab_keyboard_cookie_t
xcb_grab_keyboard (xcb_connection_t *c  /**< */,
                   bool              owner_events  /**< */,
                   xcb_window_t      grab_window  /**< */,
                   xcb_timestamp_t   time  /**< */,
                   ubyte             pointer_mode  /**< */,
                   ubyte             keyboard_mode  /**< */);


/*****************************************************************************
 **
 ** xcb_grab_keyboard_cookie_t xcb_grab_keyboard_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param bool              owner_events
 ** @param xcb_window_t      grab_window
 ** @param xcb_timestamp_t   time
 ** @param ubyte             pointer_mode
 ** @param ubyte             keyboard_mode
 ** @returns xcb_grab_keyboard_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_grab_keyboard_cookie_t
xcb_grab_keyboard_unchecked (xcb_connection_t *c  /**< */,
                             bool              owner_events  /**< */,
                             xcb_window_t      grab_window  /**< */,
                             xcb_timestamp_t   time  /**< */,
                             ubyte             pointer_mode  /**< */,
                             ubyte             keyboard_mode  /**< */);


/*****************************************************************************
 **
 ** xcb_grab_keyboard_reply_t * xcb_grab_keyboard_reply
 **
 ** @param xcb_connection_t            *c
 ** @param xcb_grab_keyboard_cookie_t   cookie
 ** @param xcb_generic_error_t        **e
 ** @returns xcb_grab_keyboard_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_grab_keyboard_reply_t *
xcb_grab_keyboard_reply (xcb_connection_t            *c  /**< */,
                         xcb_grab_keyboard_cookie_t   cookie  /**< */,
                         xcb_generic_error_t        **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_ungrab_keyboard_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_timestamp_t   time
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_ungrab_keyboard_checked (xcb_connection_t *c  /**< */,
                             xcb_timestamp_t   time  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_ungrab_keyboard
 **
 ** @param xcb_connection_t *c
 ** @param xcb_timestamp_t   time
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_ungrab_keyboard (xcb_connection_t *c  /**< */,
                     xcb_timestamp_t   time  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_grab_key_checked
 **
 ** @param xcb_connection_t *c
 ** @param bool              owner_events
 ** @param xcb_window_t      grab_window
 ** @param ushort            modifiers
 ** @param xcb_keycode_t     key
 ** @param ubyte             pointer_mode
 ** @param ubyte             keyboard_mode
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_grab_key_checked (xcb_connection_t *c  /**< */,
                      bool              owner_events  /**< */,
                      xcb_window_t      grab_window  /**< */,
                      ushort            modifiers  /**< */,
                      xcb_keycode_t     key  /**< */,
                      ubyte             pointer_mode  /**< */,
                      ubyte             keyboard_mode  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_grab_key
 **
 ** @param xcb_connection_t *c
 ** @param bool              owner_events
 ** @param xcb_window_t      grab_window
 ** @param ushort            modifiers
 ** @param xcb_keycode_t     key
 ** @param ubyte             pointer_mode
 ** @param ubyte             keyboard_mode
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_grab_key (xcb_connection_t *c  /**< */,
              bool              owner_events  /**< */,
              xcb_window_t      grab_window  /**< */,
              ushort            modifiers  /**< */,
              xcb_keycode_t     key  /**< */,
              ubyte             pointer_mode  /**< */,
              ubyte             keyboard_mode  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_ungrab_key_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_keycode_t     key
 ** @param xcb_window_t      grab_window
 ** @param ushort            modifiers
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_ungrab_key_checked (xcb_connection_t *c  /**< */,
                        xcb_keycode_t     key  /**< */,
                        xcb_window_t      grab_window  /**< */,
                        ushort            modifiers  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_ungrab_key
 **
 ** @param xcb_connection_t *c
 ** @param xcb_keycode_t     key
 ** @param xcb_window_t      grab_window
 ** @param ushort            modifiers
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_ungrab_key (xcb_connection_t *c  /**< */,
                xcb_keycode_t     key  /**< */,
                xcb_window_t      grab_window  /**< */,
                ushort            modifiers  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_allow_events_checked
 **
 ** @param xcb_connection_t *c
 ** @param ubyte             mode
 ** @param xcb_timestamp_t   time
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_allow_events_checked (xcb_connection_t *c  /**< */,
                          ubyte             mode  /**< */,
                          xcb_timestamp_t   time  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_allow_events
 **
 ** @param xcb_connection_t *c
 ** @param ubyte             mode
 ** @param xcb_timestamp_t   time
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_allow_events (xcb_connection_t *c  /**< */,
                  ubyte             mode  /**< */,
                  xcb_timestamp_t   time  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_grab_server_checked
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_grab_server_checked (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_grab_server
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_grab_server (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_ungrab_server_checked
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_ungrab_server_checked (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_ungrab_server
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_ungrab_server (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_query_pointer_cookie_t xcb_query_pointer
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @returns xcb_query_pointer_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_query_pointer_cookie_t
xcb_query_pointer (xcb_connection_t *c  /**< */,
                   xcb_window_t      window  /**< */);


/*****************************************************************************
 **
 ** xcb_query_pointer_cookie_t xcb_query_pointer_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @returns xcb_query_pointer_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_query_pointer_cookie_t
xcb_query_pointer_unchecked (xcb_connection_t *c  /**< */,
                             xcb_window_t      window  /**< */);


/*****************************************************************************
 **
 ** xcb_query_pointer_reply_t * xcb_query_pointer_reply
 **
 ** @param xcb_connection_t            *c
 ** @param xcb_query_pointer_cookie_t   cookie
 ** @param xcb_generic_error_t        **e
 ** @returns xcb_query_pointer_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_query_pointer_reply_t *
xcb_query_pointer_reply (xcb_connection_t            *c  /**< */,
                         xcb_query_pointer_cookie_t   cookie  /**< */,
                         xcb_generic_error_t        **e  /**< */);


/*****************************************************************************
 **
 ** void xcb_timecoord_next
 **
 ** @param xcb_timecoord_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_timecoord_next (xcb_timecoord_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_timecoord_end
 **
 ** @param xcb_timecoord_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_timecoord_end (xcb_timecoord_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** xcb_get_motion_events_cookie_t xcb_get_motion_events
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @param xcb_timestamp_t   start
 ** @param xcb_timestamp_t   stop
 ** @returns xcb_get_motion_events_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_get_motion_events_cookie_t
xcb_get_motion_events (xcb_connection_t *c  /**< */,
                       xcb_window_t      window  /**< */,
                       xcb_timestamp_t   start  /**< */,
                       xcb_timestamp_t   stop  /**< */);


/*****************************************************************************
 **
 ** xcb_get_motion_events_cookie_t xcb_get_motion_events_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @param xcb_timestamp_t   start
 ** @param xcb_timestamp_t   stop
 ** @returns xcb_get_motion_events_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_get_motion_events_cookie_t
xcb_get_motion_events_unchecked (xcb_connection_t *c  /**< */,
                                 xcb_window_t      window  /**< */,
                                 xcb_timestamp_t   start  /**< */,
                                 xcb_timestamp_t   stop  /**< */);


/*****************************************************************************
 **
 ** xcb_timecoord_t * xcb_get_motion_events_events
 **
 ** @param /+const+/ xcb_get_motion_events_reply_t *R
 ** @returns xcb_timecoord_t *
 **
 *****************************************************************************/

extern(C) xcb_timecoord_t *
xcb_get_motion_events_events (/+const+/ xcb_get_motion_events_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_get_motion_events_events_length
 **
 ** @param /+const+/ xcb_get_motion_events_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_get_motion_events_events_length (/+const+/ xcb_get_motion_events_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_timecoord_iterator_t xcb_get_motion_events_events_iterator
 **
 ** @param /+const+/ xcb_get_motion_events_reply_t *R
 ** @returns xcb_timecoord_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_timecoord_iterator_t
xcb_get_motion_events_events_iterator (/+const+/ xcb_get_motion_events_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_get_motion_events_reply_t * xcb_get_motion_events_reply
 **
 ** @param xcb_connection_t                *c
 ** @param xcb_get_motion_events_cookie_t   cookie
 ** @param xcb_generic_error_t            **e
 ** @returns xcb_get_motion_events_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_get_motion_events_reply_t *
xcb_get_motion_events_reply (xcb_connection_t                *c  /**< */,
                             xcb_get_motion_events_cookie_t   cookie  /**< */,
                             xcb_generic_error_t            **e  /**< */);


/*****************************************************************************
 **
 ** xcb_translate_coordinates_cookie_t xcb_translate_coordinates
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      src_window
 ** @param xcb_window_t      dst_window
 ** @param short             src_x
 ** @param short             src_y
 ** @returns xcb_translate_coordinates_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_translate_coordinates_cookie_t
xcb_translate_coordinates (xcb_connection_t *c  /**< */,
                           xcb_window_t      src_window  /**< */,
                           xcb_window_t      dst_window  /**< */,
                           short             src_x  /**< */,
                           short             src_y  /**< */);


/*****************************************************************************
 **
 ** xcb_translate_coordinates_cookie_t xcb_translate_coordinates_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      src_window
 ** @param xcb_window_t      dst_window
 ** @param short             src_x
 ** @param short             src_y
 ** @returns xcb_translate_coordinates_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_translate_coordinates_cookie_t
xcb_translate_coordinates_unchecked (xcb_connection_t *c  /**< */,
                                     xcb_window_t      src_window  /**< */,
                                     xcb_window_t      dst_window  /**< */,
                                     short             src_x  /**< */,
                                     short             src_y  /**< */);


/*****************************************************************************
 **
 ** xcb_translate_coordinates_reply_t * xcb_translate_coordinates_reply
 **
 ** @param xcb_connection_t                    *c
 ** @param xcb_translate_coordinates_cookie_t   cookie
 ** @param xcb_generic_error_t                **e
 ** @returns xcb_translate_coordinates_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_translate_coordinates_reply_t *
xcb_translate_coordinates_reply (xcb_connection_t                    *c  /**< */,
                                 xcb_translate_coordinates_cookie_t   cookie  /**< */,
                                 xcb_generic_error_t                **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_warp_pointer_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      src_window
 ** @param xcb_window_t      dst_window
 ** @param short             src_x
 ** @param short             src_y
 ** @param ushort            src_width
 ** @param ushort            src_height
 ** @param short             dst_x
 ** @param short             dst_y
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_warp_pointer_checked (xcb_connection_t *c  /**< */,
                          xcb_window_t      src_window  /**< */,
                          xcb_window_t      dst_window  /**< */,
                          short             src_x  /**< */,
                          short             src_y  /**< */,
                          ushort            src_width  /**< */,
                          ushort            src_height  /**< */,
                          short             dst_x  /**< */,
                          short             dst_y  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_warp_pointer
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      src_window
 ** @param xcb_window_t      dst_window
 ** @param short             src_x
 ** @param short             src_y
 ** @param ushort            src_width
 ** @param ushort            src_height
 ** @param short             dst_x
 ** @param short             dst_y
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_warp_pointer (xcb_connection_t *c  /**< */,
                  xcb_window_t      src_window  /**< */,
                  xcb_window_t      dst_window  /**< */,
                  short             src_x  /**< */,
                  short             src_y  /**< */,
                  ushort            src_width  /**< */,
                  ushort            src_height  /**< */,
                  short             dst_x  /**< */,
                  short             dst_y  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_set_input_focus_checked
 **
 ** @param xcb_connection_t *c
 ** @param ubyte             revert_to
 ** @param xcb_window_t      focus
 ** @param xcb_timestamp_t   time
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_set_input_focus_checked (xcb_connection_t *c  /**< */,
                             ubyte             revert_to  /**< */,
                             xcb_window_t      focus  /**< */,
                             xcb_timestamp_t   time  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_set_input_focus
 **
 ** @param xcb_connection_t *c
 ** @param ubyte             revert_to
 ** @param xcb_window_t      focus
 ** @param xcb_timestamp_t   time
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_set_input_focus (xcb_connection_t *c  /**< */,
                     ubyte             revert_to  /**< */,
                     xcb_window_t      focus  /**< */,
                     xcb_timestamp_t   time  /**< */);


/*****************************************************************************
 **
 ** xcb_get_input_focus_cookie_t xcb_get_input_focus
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_get_input_focus_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_get_input_focus_cookie_t
xcb_get_input_focus (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_get_input_focus_cookie_t xcb_get_input_focus_unchecked
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_get_input_focus_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_get_input_focus_cookie_t
xcb_get_input_focus_unchecked (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_get_input_focus_reply_t * xcb_get_input_focus_reply
 **
 ** @param xcb_connection_t              *c
 ** @param xcb_get_input_focus_cookie_t   cookie
 ** @param xcb_generic_error_t          **e
 ** @returns xcb_get_input_focus_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_get_input_focus_reply_t *
xcb_get_input_focus_reply (xcb_connection_t              *c  /**< */,
                           xcb_get_input_focus_cookie_t   cookie  /**< */,
                           xcb_generic_error_t          **e  /**< */);


/*****************************************************************************
 **
 ** xcb_query_keymap_cookie_t xcb_query_keymap
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_query_keymap_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_query_keymap_cookie_t
xcb_query_keymap (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_query_keymap_cookie_t xcb_query_keymap_unchecked
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_query_keymap_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_query_keymap_cookie_t
xcb_query_keymap_unchecked (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_query_keymap_reply_t * xcb_query_keymap_reply
 **
 ** @param xcb_connection_t           *c
 ** @param xcb_query_keymap_cookie_t   cookie
 ** @param xcb_generic_error_t       **e
 ** @returns xcb_query_keymap_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_query_keymap_reply_t *
xcb_query_keymap_reply (xcb_connection_t           *c  /**< */,
                        xcb_query_keymap_cookie_t   cookie  /**< */,
                        xcb_generic_error_t       **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_open_font_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_font_t        fid
 ** @param ushort            name_len
 ** @param /+const+/ char   *name
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_open_font_checked (xcb_connection_t *c  /**< */,
                       xcb_font_t        fid  /**< */,
                       ushort            name_len  /**< */,
                       /+const+/ char   *name  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_open_font
 **
 ** @param xcb_connection_t *c
 ** @param xcb_font_t        fid
 ** @param ushort            name_len
 ** @param /+const+/ char   *name
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_open_font (xcb_connection_t *c  /**< */,
               xcb_font_t        fid  /**< */,
               ushort            name_len  /**< */,
               /+const+/ char   *name  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_close_font_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_font_t        font
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_close_font_checked (xcb_connection_t *c  /**< */,
                        xcb_font_t        font  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_close_font
 **
 ** @param xcb_connection_t *c
 ** @param xcb_font_t        font
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_close_font (xcb_connection_t *c  /**< */,
                xcb_font_t        font  /**< */);


/*****************************************************************************
 **
 ** void xcb_fontprop_next
 **
 ** @param xcb_fontprop_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_fontprop_next (xcb_fontprop_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_fontprop_end
 **
 ** @param xcb_fontprop_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_fontprop_end (xcb_fontprop_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** void xcb_charinfo_next
 **
 ** @param xcb_charinfo_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_charinfo_next (xcb_charinfo_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_charinfo_end
 **
 ** @param xcb_charinfo_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_charinfo_end (xcb_charinfo_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** xcb_query_font_cookie_t xcb_query_font
 **
 ** @param xcb_connection_t *c
 ** @param xcb_fontable_t    font
 ** @returns xcb_query_font_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_query_font_cookie_t
xcb_query_font (xcb_connection_t *c  /**< */,
                xcb_fontable_t    font  /**< */);


/*****************************************************************************
 **
 ** xcb_query_font_cookie_t xcb_query_font_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_fontable_t    font
 ** @returns xcb_query_font_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_query_font_cookie_t
xcb_query_font_unchecked (xcb_connection_t *c  /**< */,
                          xcb_fontable_t    font  /**< */);


/*****************************************************************************
 **
 ** xcb_fontprop_t * xcb_query_font_properties
 **
 ** @param /+const+/ xcb_query_font_reply_t *R
 ** @returns xcb_fontprop_t *
 **
 *****************************************************************************/

extern(C) xcb_fontprop_t *
xcb_query_font_properties (/+const+/ xcb_query_font_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_query_font_properties_length
 **
 ** @param /+const+/ xcb_query_font_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_query_font_properties_length (/+const+/ xcb_query_font_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_fontprop_iterator_t xcb_query_font_properties_iterator
 **
 ** @param /+const+/ xcb_query_font_reply_t *R
 ** @returns xcb_fontprop_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_fontprop_iterator_t
xcb_query_font_properties_iterator (/+const+/ xcb_query_font_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_charinfo_t * xcb_query_font_char_infos
 **
 ** @param /+const+/ xcb_query_font_reply_t *R
 ** @returns xcb_charinfo_t *
 **
 *****************************************************************************/

extern(C) xcb_charinfo_t *
xcb_query_font_char_infos (/+const+/ xcb_query_font_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_query_font_char_infos_length
 **
 ** @param /+const+/ xcb_query_font_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_query_font_char_infos_length (/+const+/ xcb_query_font_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_charinfo_iterator_t xcb_query_font_char_infos_iterator
 **
 ** @param /+const+/ xcb_query_font_reply_t *R
 ** @returns xcb_charinfo_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_charinfo_iterator_t
xcb_query_font_char_infos_iterator (/+const+/ xcb_query_font_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_query_font_reply_t * xcb_query_font_reply
 **
 ** @param xcb_connection_t         *c
 ** @param xcb_query_font_cookie_t   cookie
 ** @param xcb_generic_error_t     **e
 ** @returns xcb_query_font_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_query_font_reply_t *
xcb_query_font_reply (xcb_connection_t         *c  /**< */,
                      xcb_query_font_cookie_t   cookie  /**< */,
                      xcb_generic_error_t     **e  /**< */);


/*****************************************************************************
 **
 ** xcb_query_text_extents_cookie_t xcb_query_text_extents
 **
 ** @param xcb_connection_t       *c
 ** @param xcb_fontable_t          font
 ** @param uint                    string_len
 ** @param /+const+/ xcb_char2b_t *string
 ** @returns xcb_query_text_extents_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_query_text_extents_cookie_t
xcb_query_text_extents (xcb_connection_t       *c  /**< */,
                        xcb_fontable_t          font  /**< */,
                        uint                    string_len  /**< */,
                        /+const+/ xcb_char2b_t *string  /**< */);


/*****************************************************************************
 **
 ** xcb_query_text_extents_cookie_t xcb_query_text_extents_unchecked
 **
 ** @param xcb_connection_t       *c
 ** @param xcb_fontable_t          font
 ** @param uint                    string_len
 ** @param /+const+/ xcb_char2b_t *string
 ** @returns xcb_query_text_extents_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_query_text_extents_cookie_t
xcb_query_text_extents_unchecked (xcb_connection_t       *c  /**< */,
                                  xcb_fontable_t          font  /**< */,
                                  uint                    string_len  /**< */,
                                  /+const+/ xcb_char2b_t *string  /**< */);


/*****************************************************************************
 **
 ** xcb_query_text_extents_reply_t * xcb_query_text_extents_reply
 **
 ** @param xcb_connection_t                 *c
 ** @param xcb_query_text_extents_cookie_t   cookie
 ** @param xcb_generic_error_t             **e
 ** @returns xcb_query_text_extents_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_query_text_extents_reply_t *
xcb_query_text_extents_reply (xcb_connection_t                 *c  /**< */,
                              xcb_query_text_extents_cookie_t   cookie  /**< */,
                              xcb_generic_error_t             **e  /**< */);


/*****************************************************************************
 **
 ** char * xcb_str_name
 **
 ** @param /+const+/ xcb_str_t *R
 ** @returns char *
 **
 *****************************************************************************/

extern(C) char *
xcb_str_name (/+const+/ xcb_str_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_str_name_length
 **
 ** @param /+const+/ xcb_str_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_str_name_length (/+const+/ xcb_str_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_str_name_end
 **
 ** @param /+const+/ xcb_str_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_str_name_end (/+const+/ xcb_str_t *R  /**< */);


/*****************************************************************************
 **
 ** void xcb_str_next
 **
 ** @param xcb_str_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_str_next (xcb_str_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_str_end
 **
 ** @param xcb_str_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_str_end (xcb_str_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** xcb_list_fonts_cookie_t xcb_list_fonts
 **
 ** @param xcb_connection_t *c
 ** @param ushort            max_names
 ** @param ushort            pattern_len
 ** @param /+const+/ char   *pattern
 ** @returns xcb_list_fonts_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_list_fonts_cookie_t
xcb_list_fonts (xcb_connection_t *c  /**< */,
                ushort            max_names  /**< */,
                ushort            pattern_len  /**< */,
                /+const+/ char   *pattern  /**< */);


/*****************************************************************************
 **
 ** xcb_list_fonts_cookie_t xcb_list_fonts_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param ushort            max_names
 ** @param ushort            pattern_len
 ** @param /+const+/ char   *pattern
 ** @returns xcb_list_fonts_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_list_fonts_cookie_t
xcb_list_fonts_unchecked (xcb_connection_t *c  /**< */,
                          ushort            max_names  /**< */,
                          ushort            pattern_len  /**< */,
                          /+const+/ char   *pattern  /**< */);


/*****************************************************************************
 **
 ** int xcb_list_fonts_names_length
 **
 ** @param /+const+/ xcb_list_fonts_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_list_fonts_names_length (/+const+/ xcb_list_fonts_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_str_iterator_t xcb_list_fonts_names_iterator
 **
 ** @param /+const+/ xcb_list_fonts_reply_t *R
 ** @returns xcb_str_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_str_iterator_t
xcb_list_fonts_names_iterator (/+const+/ xcb_list_fonts_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_list_fonts_reply_t * xcb_list_fonts_reply
 **
 ** @param xcb_connection_t         *c
 ** @param xcb_list_fonts_cookie_t   cookie
 ** @param xcb_generic_error_t     **e
 ** @returns xcb_list_fonts_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_list_fonts_reply_t *
xcb_list_fonts_reply (xcb_connection_t         *c  /**< */,
                      xcb_list_fonts_cookie_t   cookie  /**< */,
                      xcb_generic_error_t     **e  /**< */);


/*****************************************************************************
 **
 ** xcb_list_fonts_with_info_cookie_t xcb_list_fonts_with_info
 **
 ** @param xcb_connection_t *c
 ** @param ushort            max_names
 ** @param ushort            pattern_len
 ** @param /+const+/ char   *pattern
 ** @returns xcb_list_fonts_with_info_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_list_fonts_with_info_cookie_t
xcb_list_fonts_with_info (xcb_connection_t *c  /**< */,
                          ushort            max_names  /**< */,
                          ushort            pattern_len  /**< */,
                          /+const+/ char   *pattern  /**< */);


/*****************************************************************************
 **
 ** xcb_list_fonts_with_info_cookie_t xcb_list_fonts_with_info_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param ushort            max_names
 ** @param ushort            pattern_len
 ** @param /+const+/ char   *pattern
 ** @returns xcb_list_fonts_with_info_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_list_fonts_with_info_cookie_t
xcb_list_fonts_with_info_unchecked (xcb_connection_t *c  /**< */,
                                    ushort            max_names  /**< */,
                                    ushort            pattern_len  /**< */,
                                    /+const+/ char   *pattern  /**< */);


/*****************************************************************************
 **
 ** xcb_fontprop_t * xcb_list_fonts_with_info_properties
 **
 ** @param /+const+/ xcb_list_fonts_with_info_reply_t *R
 ** @returns xcb_fontprop_t *
 **
 *****************************************************************************/

extern(C) xcb_fontprop_t *
xcb_list_fonts_with_info_properties (/+const+/ xcb_list_fonts_with_info_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_list_fonts_with_info_properties_length
 **
 ** @param /+const+/ xcb_list_fonts_with_info_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_list_fonts_with_info_properties_length (/+const+/ xcb_list_fonts_with_info_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_fontprop_iterator_t xcb_list_fonts_with_info_properties_iterator
 **
 ** @param /+const+/ xcb_list_fonts_with_info_reply_t *R
 ** @returns xcb_fontprop_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_fontprop_iterator_t
xcb_list_fonts_with_info_properties_iterator (/+const+/ xcb_list_fonts_with_info_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** char * xcb_list_fonts_with_info_name
 **
 ** @param /+const+/ xcb_list_fonts_with_info_reply_t *R
 ** @returns char *
 **
 *****************************************************************************/

extern(C) char *
xcb_list_fonts_with_info_name (/+const+/ xcb_list_fonts_with_info_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_list_fonts_with_info_name_length
 **
 ** @param /+const+/ xcb_list_fonts_with_info_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_list_fonts_with_info_name_length (/+const+/ xcb_list_fonts_with_info_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_list_fonts_with_info_name_end
 **
 ** @param /+const+/ xcb_list_fonts_with_info_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_list_fonts_with_info_name_end (/+const+/ xcb_list_fonts_with_info_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_list_fonts_with_info_reply_t * xcb_list_fonts_with_info_reply
 **
 ** @param xcb_connection_t                   *c
 ** @param xcb_list_fonts_with_info_cookie_t   cookie
 ** @param xcb_generic_error_t               **e
 ** @returns xcb_list_fonts_with_info_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_list_fonts_with_info_reply_t *
xcb_list_fonts_with_info_reply (xcb_connection_t                   *c  /**< */,
                                xcb_list_fonts_with_info_cookie_t   cookie  /**< */,
                                xcb_generic_error_t               **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_set_font_path_checked
 **
 ** @param xcb_connection_t *c
 ** @param ushort            font_qty
 ** @param uint              path_len
 ** @param /+const+/ char   *path
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_set_font_path_checked (xcb_connection_t *c  /**< */,
                           ushort            font_qty  /**< */,
                           uint              path_len  /**< */,
                           /+const+/ char   *path  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_set_font_path
 **
 ** @param xcb_connection_t *c
 ** @param ushort            font_qty
 ** @param uint              path_len
 ** @param /+const+/ char   *path
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_set_font_path (xcb_connection_t *c  /**< */,
                   ushort            font_qty  /**< */,
                   uint              path_len  /**< */,
                   /+const+/ char   *path  /**< */);


/*****************************************************************************
 **
 ** xcb_get_font_path_cookie_t xcb_get_font_path
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_get_font_path_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_get_font_path_cookie_t
xcb_get_font_path (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_get_font_path_cookie_t xcb_get_font_path_unchecked
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_get_font_path_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_get_font_path_cookie_t
xcb_get_font_path_unchecked (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** int xcb_get_font_path_path_length
 **
 ** @param /+const+/ xcb_get_font_path_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_get_font_path_path_length (/+const+/ xcb_get_font_path_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_str_iterator_t xcb_get_font_path_path_iterator
 **
 ** @param /+const+/ xcb_get_font_path_reply_t *R
 ** @returns xcb_str_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_str_iterator_t
xcb_get_font_path_path_iterator (/+const+/ xcb_get_font_path_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_get_font_path_reply_t * xcb_get_font_path_reply
 **
 ** @param xcb_connection_t            *c
 ** @param xcb_get_font_path_cookie_t   cookie
 ** @param xcb_generic_error_t        **e
 ** @returns xcb_get_font_path_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_get_font_path_reply_t *
xcb_get_font_path_reply (xcb_connection_t            *c  /**< */,
                         xcb_get_font_path_cookie_t   cookie  /**< */,
                         xcb_generic_error_t        **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_create_pixmap_checked
 **
 ** @param xcb_connection_t *c
 ** @param ubyte             depth
 ** @param xcb_pixmap_t      pid
 ** @param xcb_drawable_t    drawable
 ** @param ushort            width
 ** @param ushort            height
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_create_pixmap_checked (xcb_connection_t *c  /**< */,
                           ubyte             depth  /**< */,
                           xcb_pixmap_t      pid  /**< */,
                           xcb_drawable_t    drawable  /**< */,
                           ushort            width  /**< */,
                           ushort            height  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_create_pixmap
 **
 ** @param xcb_connection_t *c
 ** @param ubyte             depth
 ** @param xcb_pixmap_t      pid
 ** @param xcb_drawable_t    drawable
 ** @param ushort            width
 ** @param ushort            height
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_create_pixmap (xcb_connection_t *c  /**< */,
                   ubyte             depth  /**< */,
                   xcb_pixmap_t      pid  /**< */,
                   xcb_drawable_t    drawable  /**< */,
                   ushort            width  /**< */,
                   ushort            height  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_free_pixmap_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_pixmap_t      pixmap
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_free_pixmap_checked (xcb_connection_t *c  /**< */,
                         xcb_pixmap_t      pixmap  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_free_pixmap
 **
 ** @param xcb_connection_t *c
 ** @param xcb_pixmap_t      pixmap
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_free_pixmap (xcb_connection_t *c  /**< */,
                 xcb_pixmap_t      pixmap  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_create_gc_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_gcontext_t    cid
 ** @param xcb_drawable_t    drawable
 ** @param uint              value_mask
 ** @param /+const+/ uint   *value_list
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_create_gc_checked (xcb_connection_t *c  /**< */,
                       xcb_gcontext_t    cid  /**< */,
                       xcb_drawable_t    drawable  /**< */,
                       uint              value_mask  /**< */,
                       /+const+/ uint   *value_list  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_create_gc
 **
 ** @param xcb_connection_t *c
 ** @param xcb_gcontext_t    cid
 ** @param xcb_drawable_t    drawable
 ** @param uint              value_mask
 ** @param /+const+/ uint   *value_list
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_create_gc (xcb_connection_t *c  /**< */,
               xcb_gcontext_t    cid  /**< */,
               xcb_drawable_t    drawable  /**< */,
               uint              value_mask  /**< */,
               /+const+/ uint   *value_list  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_change_gc_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_gcontext_t    gc
 ** @param uint              value_mask
 ** @param /+const+/ uint   *value_list
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_change_gc_checked (xcb_connection_t *c  /**< */,
                       xcb_gcontext_t    gc  /**< */,
                       uint              value_mask  /**< */,
                       /+const+/ uint   *value_list  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_change_gc
 **
 ** @param xcb_connection_t *c
 ** @param xcb_gcontext_t    gc
 ** @param uint              value_mask
 ** @param /+const+/ uint   *value_list
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_change_gc (xcb_connection_t *c  /**< */,
               xcb_gcontext_t    gc  /**< */,
               uint              value_mask  /**< */,
               /+const+/ uint   *value_list  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_copy_gc_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_gcontext_t    src_gc
 ** @param xcb_gcontext_t    dst_gc
 ** @param uint              value_mask
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_copy_gc_checked (xcb_connection_t *c  /**< */,
                     xcb_gcontext_t    src_gc  /**< */,
                     xcb_gcontext_t    dst_gc  /**< */,
                     uint              value_mask  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_copy_gc
 **
 ** @param xcb_connection_t *c
 ** @param xcb_gcontext_t    src_gc
 ** @param xcb_gcontext_t    dst_gc
 ** @param uint              value_mask
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_copy_gc (xcb_connection_t *c  /**< */,
             xcb_gcontext_t    src_gc  /**< */,
             xcb_gcontext_t    dst_gc  /**< */,
             uint              value_mask  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_set_dashes_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_gcontext_t    gc
 ** @param ushort            dash_offset
 ** @param ushort            dashes_len
 ** @param /+const+/ ubyte  *dashes
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_set_dashes_checked (xcb_connection_t *c  /**< */,
                        xcb_gcontext_t    gc  /**< */,
                        ushort            dash_offset  /**< */,
                        ushort            dashes_len  /**< */,
                        /+const+/ ubyte  *dashes  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_set_dashes
 **
 ** @param xcb_connection_t *c
 ** @param xcb_gcontext_t    gc
 ** @param ushort            dash_offset
 ** @param ushort            dashes_len
 ** @param /+const+/ ubyte  *dashes
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_set_dashes (xcb_connection_t *c  /**< */,
                xcb_gcontext_t    gc  /**< */,
                ushort            dash_offset  /**< */,
                ushort            dashes_len  /**< */,
                /+const+/ ubyte  *dashes  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_set_clip_rectangles_checked
 **
 ** @param xcb_connection_t          *c
 ** @param ubyte                      ordering
 ** @param xcb_gcontext_t             gc
 ** @param short                      clip_x_origin
 ** @param short                      clip_y_origin
 ** @param uint                       rectangles_len
 ** @param /+const+/ xcb_rectangle_t *rectangles
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_set_clip_rectangles_checked (xcb_connection_t          *c  /**< */,
                                 ubyte                      ordering  /**< */,
                                 xcb_gcontext_t             gc  /**< */,
                                 short                      clip_x_origin  /**< */,
                                 short                      clip_y_origin  /**< */,
                                 uint                       rectangles_len  /**< */,
                                 /+const+/ xcb_rectangle_t *rectangles  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_set_clip_rectangles
 **
 ** @param xcb_connection_t          *c
 ** @param ubyte                      ordering
 ** @param xcb_gcontext_t             gc
 ** @param short                      clip_x_origin
 ** @param short                      clip_y_origin
 ** @param uint                       rectangles_len
 ** @param /+const+/ xcb_rectangle_t *rectangles
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_set_clip_rectangles (xcb_connection_t          *c  /**< */,
                         ubyte                      ordering  /**< */,
                         xcb_gcontext_t             gc  /**< */,
                         short                      clip_x_origin  /**< */,
                         short                      clip_y_origin  /**< */,
                         uint                       rectangles_len  /**< */,
                         /+const+/ xcb_rectangle_t *rectangles  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_free_gc_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_gcontext_t    gc
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_free_gc_checked (xcb_connection_t *c  /**< */,
                     xcb_gcontext_t    gc  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_free_gc
 **
 ** @param xcb_connection_t *c
 ** @param xcb_gcontext_t    gc
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_free_gc (xcb_connection_t *c  /**< */,
             xcb_gcontext_t    gc  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_clear_area_checked
 **
 ** @param xcb_connection_t *c
 ** @param bool              exposures
 ** @param xcb_window_t      window
 ** @param short             x
 ** @param short             y
 ** @param ushort            width
 ** @param ushort            height
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_clear_area_checked (xcb_connection_t *c  /**< */,
                        bool              exposures  /**< */,
                        xcb_window_t      window  /**< */,
                        short             x  /**< */,
                        short             y  /**< */,
                        ushort            width  /**< */,
                        ushort            height  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_clear_area
 **
 ** @param xcb_connection_t *c
 ** @param bool              exposures
 ** @param xcb_window_t      window
 ** @param short             x
 ** @param short             y
 ** @param ushort            width
 ** @param ushort            height
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_clear_area (xcb_connection_t *c  /**< */,
                bool              exposures  /**< */,
                xcb_window_t      window  /**< */,
                short             x  /**< */,
                short             y  /**< */,
                ushort            width  /**< */,
                ushort            height  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_copy_area_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_drawable_t    src_drawable
 ** @param xcb_drawable_t    dst_drawable
 ** @param xcb_gcontext_t    gc
 ** @param short             src_x
 ** @param short             src_y
 ** @param short             dst_x
 ** @param short             dst_y
 ** @param ushort            width
 ** @param ushort            height
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_copy_area_checked (xcb_connection_t *c  /**< */,
                       xcb_drawable_t    src_drawable  /**< */,
                       xcb_drawable_t    dst_drawable  /**< */,
                       xcb_gcontext_t    gc  /**< */,
                       short             src_x  /**< */,
                       short             src_y  /**< */,
                       short             dst_x  /**< */,
                       short             dst_y  /**< */,
                       ushort            width  /**< */,
                       ushort            height  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_copy_area
 **
 ** @param xcb_connection_t *c
 ** @param xcb_drawable_t    src_drawable
 ** @param xcb_drawable_t    dst_drawable
 ** @param xcb_gcontext_t    gc
 ** @param short             src_x
 ** @param short             src_y
 ** @param short             dst_x
 ** @param short             dst_y
 ** @param ushort            width
 ** @param ushort            height
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_copy_area (xcb_connection_t *c  /**< */,
               xcb_drawable_t    src_drawable  /**< */,
               xcb_drawable_t    dst_drawable  /**< */,
               xcb_gcontext_t    gc  /**< */,
               short             src_x  /**< */,
               short             src_y  /**< */,
               short             dst_x  /**< */,
               short             dst_y  /**< */,
               ushort            width  /**< */,
               ushort            height  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_copy_plane_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_drawable_t    src_drawable
 ** @param xcb_drawable_t    dst_drawable
 ** @param xcb_gcontext_t    gc
 ** @param short             src_x
 ** @param short             src_y
 ** @param short             dst_x
 ** @param short             dst_y
 ** @param ushort            width
 ** @param ushort            height
 ** @param uint              bit_plane
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_copy_plane_checked (xcb_connection_t *c  /**< */,
                        xcb_drawable_t    src_drawable  /**< */,
                        xcb_drawable_t    dst_drawable  /**< */,
                        xcb_gcontext_t    gc  /**< */,
                        short             src_x  /**< */,
                        short             src_y  /**< */,
                        short             dst_x  /**< */,
                        short             dst_y  /**< */,
                        ushort            width  /**< */,
                        ushort            height  /**< */,
                        uint              bit_plane  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_copy_plane
 **
 ** @param xcb_connection_t *c
 ** @param xcb_drawable_t    src_drawable
 ** @param xcb_drawable_t    dst_drawable
 ** @param xcb_gcontext_t    gc
 ** @param short             src_x
 ** @param short             src_y
 ** @param short             dst_x
 ** @param short             dst_y
 ** @param ushort            width
 ** @param ushort            height
 ** @param uint              bit_plane
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_copy_plane (xcb_connection_t *c  /**< */,
                xcb_drawable_t    src_drawable  /**< */,
                xcb_drawable_t    dst_drawable  /**< */,
                xcb_gcontext_t    gc  /**< */,
                short             src_x  /**< */,
                short             src_y  /**< */,
                short             dst_x  /**< */,
                short             dst_y  /**< */,
                ushort            width  /**< */,
                ushort            height  /**< */,
                uint              bit_plane  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_poly_point_checked
 **
 ** @param xcb_connection_t      *c
 ** @param ubyte                  coordinate_mode
 ** @param xcb_drawable_t         drawable
 ** @param xcb_gcontext_t         gc
 ** @param uint                   points_len
 ** @param /+const+/ xcb_point_t *points
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_poly_point_checked (xcb_connection_t      *c  /**< */,
                        ubyte                  coordinate_mode  /**< */,
                        xcb_drawable_t         drawable  /**< */,
                        xcb_gcontext_t         gc  /**< */,
                        uint                   points_len  /**< */,
                        /+const+/ xcb_point_t *points  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_poly_point
 **
 ** @param xcb_connection_t      *c
 ** @param ubyte                  coordinate_mode
 ** @param xcb_drawable_t         drawable
 ** @param xcb_gcontext_t         gc
 ** @param uint                   points_len
 ** @param /+const+/ xcb_point_t *points
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_poly_point (xcb_connection_t      *c  /**< */,
                ubyte                  coordinate_mode  /**< */,
                xcb_drawable_t         drawable  /**< */,
                xcb_gcontext_t         gc  /**< */,
                uint                   points_len  /**< */,
                /+const+/ xcb_point_t *points  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_poly_line_checked
 **
 ** @param xcb_connection_t      *c
 ** @param ubyte                  coordinate_mode
 ** @param xcb_drawable_t         drawable
 ** @param xcb_gcontext_t         gc
 ** @param uint                   points_len
 ** @param /+const+/ xcb_point_t *points
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_poly_line_checked (xcb_connection_t      *c  /**< */,
                       ubyte                  coordinate_mode  /**< */,
                       xcb_drawable_t         drawable  /**< */,
                       xcb_gcontext_t         gc  /**< */,
                       uint                   points_len  /**< */,
                       /+const+/ xcb_point_t *points  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_poly_line
 **
 ** @param xcb_connection_t      *c
 ** @param ubyte                  coordinate_mode
 ** @param xcb_drawable_t         drawable
 ** @param xcb_gcontext_t         gc
 ** @param uint                   points_len
 ** @param /+const+/ xcb_point_t *points
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_poly_line (xcb_connection_t      *c  /**< */,
               ubyte                  coordinate_mode  /**< */,
               xcb_drawable_t         drawable  /**< */,
               xcb_gcontext_t         gc  /**< */,
               uint                   points_len  /**< */,
               /+const+/ xcb_point_t *points  /**< */);


/*****************************************************************************
 **
 ** void xcb_segment_next
 **
 ** @param xcb_segment_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_segment_next (xcb_segment_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_segment_end
 **
 ** @param xcb_segment_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_segment_end (xcb_segment_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_poly_segment_checked
 **
 ** @param xcb_connection_t        *c
 ** @param xcb_drawable_t           drawable
 ** @param xcb_gcontext_t           gc
 ** @param uint                     segments_len
 ** @param /+const+/ xcb_segment_t *segments
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_poly_segment_checked (xcb_connection_t        *c  /**< */,
                          xcb_drawable_t           drawable  /**< */,
                          xcb_gcontext_t           gc  /**< */,
                          uint                     segments_len  /**< */,
                          /+const+/ xcb_segment_t *segments  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_poly_segment
 **
 ** @param xcb_connection_t        *c
 ** @param xcb_drawable_t           drawable
 ** @param xcb_gcontext_t           gc
 ** @param uint                     segments_len
 ** @param /+const+/ xcb_segment_t *segments
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_poly_segment (xcb_connection_t        *c  /**< */,
                  xcb_drawable_t           drawable  /**< */,
                  xcb_gcontext_t           gc  /**< */,
                  uint                     segments_len  /**< */,
                  /+const+/ xcb_segment_t *segments  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_poly_rectangle_checked
 **
 ** @param xcb_connection_t          *c
 ** @param xcb_drawable_t             drawable
 ** @param xcb_gcontext_t             gc
 ** @param uint                       rectangles_len
 ** @param /+const+/ xcb_rectangle_t *rectangles
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_poly_rectangle_checked (xcb_connection_t          *c  /**< */,
                            xcb_drawable_t             drawable  /**< */,
                            xcb_gcontext_t             gc  /**< */,
                            uint                       rectangles_len  /**< */,
                            /+const+/ xcb_rectangle_t *rectangles  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_poly_rectangle
 **
 ** @param xcb_connection_t          *c
 ** @param xcb_drawable_t             drawable
 ** @param xcb_gcontext_t             gc
 ** @param uint                       rectangles_len
 ** @param /+const+/ xcb_rectangle_t *rectangles
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_poly_rectangle (xcb_connection_t          *c  /**< */,
                    xcb_drawable_t             drawable  /**< */,
                    xcb_gcontext_t             gc  /**< */,
                    uint                       rectangles_len  /**< */,
                    /+const+/ xcb_rectangle_t *rectangles  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_poly_arc_checked
 **
 ** @param xcb_connection_t    *c
 ** @param xcb_drawable_t       drawable
 ** @param xcb_gcontext_t       gc
 ** @param uint                 arcs_len
 ** @param /+const+/ xcb_arc_t *arcs
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_poly_arc_checked (xcb_connection_t    *c  /**< */,
                      xcb_drawable_t       drawable  /**< */,
                      xcb_gcontext_t       gc  /**< */,
                      uint                 arcs_len  /**< */,
                      /+const+/ xcb_arc_t *arcs  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_poly_arc
 **
 ** @param xcb_connection_t    *c
 ** @param xcb_drawable_t       drawable
 ** @param xcb_gcontext_t       gc
 ** @param uint                 arcs_len
 ** @param /+const+/ xcb_arc_t *arcs
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_poly_arc (xcb_connection_t    *c  /**< */,
              xcb_drawable_t       drawable  /**< */,
              xcb_gcontext_t       gc  /**< */,
              uint                 arcs_len  /**< */,
              /+const+/ xcb_arc_t *arcs  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_fill_poly_checked
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_drawable_t         drawable
 ** @param xcb_gcontext_t         gc
 ** @param ubyte                  shape
 ** @param ubyte                  coordinate_mode
 ** @param uint                   points_len
 ** @param /+const+/ xcb_point_t *points
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_fill_poly_checked (xcb_connection_t      *c  /**< */,
                       xcb_drawable_t         drawable  /**< */,
                       xcb_gcontext_t         gc  /**< */,
                       ubyte                  shape  /**< */,
                       ubyte                  coordinate_mode  /**< */,
                       uint                   points_len  /**< */,
                       /+const+/ xcb_point_t *points  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_fill_poly
 **
 ** @param xcb_connection_t      *c
 ** @param xcb_drawable_t         drawable
 ** @param xcb_gcontext_t         gc
 ** @param ubyte                  shape
 ** @param ubyte                  coordinate_mode
 ** @param uint                   points_len
 ** @param /+const+/ xcb_point_t *points
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_fill_poly (xcb_connection_t      *c  /**< */,
               xcb_drawable_t         drawable  /**< */,
               xcb_gcontext_t         gc  /**< */,
               ubyte                  shape  /**< */,
               ubyte                  coordinate_mode  /**< */,
               uint                   points_len  /**< */,
               /+const+/ xcb_point_t *points  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_poly_fill_rectangle_checked
 **
 ** @param xcb_connection_t          *c
 ** @param xcb_drawable_t             drawable
 ** @param xcb_gcontext_t             gc
 ** @param uint                       rectangles_len
 ** @param /+const+/ xcb_rectangle_t *rectangles
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_poly_fill_rectangle_checked (xcb_connection_t          *c  /**< */,
                                 xcb_drawable_t             drawable  /**< */,
                                 xcb_gcontext_t             gc  /**< */,
                                 uint                       rectangles_len  /**< */,
                                 /+const+/ xcb_rectangle_t *rectangles  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_poly_fill_rectangle
 **
 ** @param xcb_connection_t          *c
 ** @param xcb_drawable_t             drawable
 ** @param xcb_gcontext_t             gc
 ** @param uint                       rectangles_len
 ** @param /+const+/ xcb_rectangle_t *rectangles
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_poly_fill_rectangle (xcb_connection_t          *c  /**< */,
                         xcb_drawable_t             drawable  /**< */,
                         xcb_gcontext_t             gc  /**< */,
                         uint                       rectangles_len  /**< */,
                         /+const+/ xcb_rectangle_t *rectangles  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_poly_fill_arc_checked
 **
 ** @param xcb_connection_t    *c
 ** @param xcb_drawable_t       drawable
 ** @param xcb_gcontext_t       gc
 ** @param uint                 arcs_len
 ** @param /+const+/ xcb_arc_t *arcs
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_poly_fill_arc_checked (xcb_connection_t    *c  /**< */,
                           xcb_drawable_t       drawable  /**< */,
                           xcb_gcontext_t       gc  /**< */,
                           uint                 arcs_len  /**< */,
                           /+const+/ xcb_arc_t *arcs  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_poly_fill_arc
 **
 ** @param xcb_connection_t    *c
 ** @param xcb_drawable_t       drawable
 ** @param xcb_gcontext_t       gc
 ** @param uint                 arcs_len
 ** @param /+const+/ xcb_arc_t *arcs
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_poly_fill_arc (xcb_connection_t    *c  /**< */,
                   xcb_drawable_t       drawable  /**< */,
                   xcb_gcontext_t       gc  /**< */,
                   uint                 arcs_len  /**< */,
                   /+const+/ xcb_arc_t *arcs  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_put_image_checked
 **
 ** @param xcb_connection_t *c
 ** @param ubyte             format
 ** @param xcb_drawable_t    drawable
 ** @param xcb_gcontext_t    gc
 ** @param ushort            width
 ** @param ushort            height
 ** @param short             dst_x
 ** @param short             dst_y
 ** @param ubyte             left_pad
 ** @param ubyte             depth
 ** @param uint              data_len
 ** @param /+const+/ ubyte  *data
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_put_image_checked (xcb_connection_t *c  /**< */,
                       ubyte             format  /**< */,
                       xcb_drawable_t    drawable  /**< */,
                       xcb_gcontext_t    gc  /**< */,
                       ushort            width  /**< */,
                       ushort            height  /**< */,
                       short             dst_x  /**< */,
                       short             dst_y  /**< */,
                       ubyte             left_pad  /**< */,
                       ubyte             depth  /**< */,
                       uint              data_len  /**< */,
                       /+const+/ ubyte  *data  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_put_image
 **
 ** @param xcb_connection_t *c
 ** @param ubyte             format
 ** @param xcb_drawable_t    drawable
 ** @param xcb_gcontext_t    gc
 ** @param ushort            width
 ** @param ushort            height
 ** @param short             dst_x
 ** @param short             dst_y
 ** @param ubyte             left_pad
 ** @param ubyte             depth
 ** @param uint              data_len
 ** @param /+const+/ ubyte  *data
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_put_image (xcb_connection_t *c  /**< */,
               ubyte             format  /**< */,
               xcb_drawable_t    drawable  /**< */,
               xcb_gcontext_t    gc  /**< */,
               ushort            width  /**< */,
               ushort            height  /**< */,
               short             dst_x  /**< */,
               short             dst_y  /**< */,
               ubyte             left_pad  /**< */,
               ubyte             depth  /**< */,
               uint              data_len  /**< */,
               /+const+/ ubyte  *data  /**< */);


/*****************************************************************************
 **
 ** xcb_get_image_cookie_t xcb_get_image
 **
 ** @param xcb_connection_t *c
 ** @param ubyte             format
 ** @param xcb_drawable_t    drawable
 ** @param short             x
 ** @param short             y
 ** @param ushort            width
 ** @param ushort            height
 ** @param uint              plane_mask
 ** @returns xcb_get_image_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_get_image_cookie_t
xcb_get_image (xcb_connection_t *c  /**< */,
               ubyte             format  /**< */,
               xcb_drawable_t    drawable  /**< */,
               short             x  /**< */,
               short             y  /**< */,
               ushort            width  /**< */,
               ushort            height  /**< */,
               uint              plane_mask  /**< */);


/*****************************************************************************
 **
 ** xcb_get_image_cookie_t xcb_get_image_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param ubyte             format
 ** @param xcb_drawable_t    drawable
 ** @param short             x
 ** @param short             y
 ** @param ushort            width
 ** @param ushort            height
 ** @param uint              plane_mask
 ** @returns xcb_get_image_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_get_image_cookie_t
xcb_get_image_unchecked (xcb_connection_t *c  /**< */,
                         ubyte             format  /**< */,
                         xcb_drawable_t    drawable  /**< */,
                         short             x  /**< */,
                         short             y  /**< */,
                         ushort            width  /**< */,
                         ushort            height  /**< */,
                         uint              plane_mask  /**< */);


/*****************************************************************************
 **
 ** ubyte * xcb_get_image_data
 **
 ** @param /+const+/ xcb_get_image_reply_t *R
 ** @returns ubyte *
 **
 *****************************************************************************/

extern(C) ubyte *
xcb_get_image_data (/+const+/ xcb_get_image_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_get_image_data_length
 **
 ** @param /+const+/ xcb_get_image_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_get_image_data_length (/+const+/ xcb_get_image_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_get_image_data_end
 **
 ** @param /+const+/ xcb_get_image_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_get_image_data_end (/+const+/ xcb_get_image_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_get_image_reply_t * xcb_get_image_reply
 **
 ** @param xcb_connection_t        *c
 ** @param xcb_get_image_cookie_t   cookie
 ** @param xcb_generic_error_t    **e
 ** @returns xcb_get_image_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_get_image_reply_t *
xcb_get_image_reply (xcb_connection_t        *c  /**< */,
                     xcb_get_image_cookie_t   cookie  /**< */,
                     xcb_generic_error_t    **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_poly_text_8_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_drawable_t    drawable
 ** @param xcb_gcontext_t    gc
 ** @param short             x
 ** @param short             y
 ** @param uint              items_len
 ** @param /+const+/ ubyte  *items
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_poly_text_8_checked (xcb_connection_t *c  /**< */,
                         xcb_drawable_t    drawable  /**< */,
                         xcb_gcontext_t    gc  /**< */,
                         short             x  /**< */,
                         short             y  /**< */,
                         uint              items_len  /**< */,
                         /+const+/ ubyte  *items  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_poly_text_8
 **
 ** @param xcb_connection_t *c
 ** @param xcb_drawable_t    drawable
 ** @param xcb_gcontext_t    gc
 ** @param short             x
 ** @param short             y
 ** @param uint              items_len
 ** @param /+const+/ ubyte  *items
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_poly_text_8 (xcb_connection_t *c  /**< */,
                 xcb_drawable_t    drawable  /**< */,
                 xcb_gcontext_t    gc  /**< */,
                 short             x  /**< */,
                 short             y  /**< */,
                 uint              items_len  /**< */,
                 /+const+/ ubyte  *items  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_poly_text_16_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_drawable_t    drawable
 ** @param xcb_gcontext_t    gc
 ** @param short             x
 ** @param short             y
 ** @param uint              items_len
 ** @param /+const+/ ubyte  *items
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_poly_text_16_checked (xcb_connection_t *c  /**< */,
                          xcb_drawable_t    drawable  /**< */,
                          xcb_gcontext_t    gc  /**< */,
                          short             x  /**< */,
                          short             y  /**< */,
                          uint              items_len  /**< */,
                          /+const+/ ubyte  *items  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_poly_text_16
 **
 ** @param xcb_connection_t *c
 ** @param xcb_drawable_t    drawable
 ** @param xcb_gcontext_t    gc
 ** @param short             x
 ** @param short             y
 ** @param uint              items_len
 ** @param /+const+/ ubyte  *items
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_poly_text_16 (xcb_connection_t *c  /**< */,
                  xcb_drawable_t    drawable  /**< */,
                  xcb_gcontext_t    gc  /**< */,
                  short             x  /**< */,
                  short             y  /**< */,
                  uint              items_len  /**< */,
                  /+const+/ ubyte  *items  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_image_text_8_checked
 **
 ** @param xcb_connection_t *c
 ** @param ubyte             string_len
 ** @param xcb_drawable_t    drawable
 ** @param xcb_gcontext_t    gc
 ** @param short             x
 ** @param short             y
 ** @param /+const+/ char   *string
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_image_text_8_checked (xcb_connection_t *c  /**< */,
                          ubyte             string_len  /**< */,
                          xcb_drawable_t    drawable  /**< */,
                          xcb_gcontext_t    gc  /**< */,
                          short             x  /**< */,
                          short             y  /**< */,
                          /+const+/ char   *string  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_image_text_8
 **
 ** @param xcb_connection_t *c
 ** @param ubyte             string_len
 ** @param xcb_drawable_t    drawable
 ** @param xcb_gcontext_t    gc
 ** @param short             x
 ** @param short             y
 ** @param /+const+/ char   *string
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_image_text_8 (xcb_connection_t *c  /**< */,
                  ubyte             string_len  /**< */,
                  xcb_drawable_t    drawable  /**< */,
                  xcb_gcontext_t    gc  /**< */,
                  short             x  /**< */,
                  short             y  /**< */,
                  /+const+/ char   *string  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_image_text_16_checked
 **
 ** @param xcb_connection_t       *c
 ** @param ubyte                   string_len
 ** @param xcb_drawable_t          drawable
 ** @param xcb_gcontext_t          gc
 ** @param short                   x
 ** @param short                   y
 ** @param /+const+/ xcb_char2b_t *string
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_image_text_16_checked (xcb_connection_t       *c  /**< */,
                           ubyte                   string_len  /**< */,
                           xcb_drawable_t          drawable  /**< */,
                           xcb_gcontext_t          gc  /**< */,
                           short                   x  /**< */,
                           short                   y  /**< */,
                           /+const+/ xcb_char2b_t *string  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_image_text_16
 **
 ** @param xcb_connection_t       *c
 ** @param ubyte                   string_len
 ** @param xcb_drawable_t          drawable
 ** @param xcb_gcontext_t          gc
 ** @param short                   x
 ** @param short                   y
 ** @param /+const+/ xcb_char2b_t *string
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_image_text_16 (xcb_connection_t       *c  /**< */,
                   ubyte                   string_len  /**< */,
                   xcb_drawable_t          drawable  /**< */,
                   xcb_gcontext_t          gc  /**< */,
                   short                   x  /**< */,
                   short                   y  /**< */,
                   /+const+/ xcb_char2b_t *string  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_create_colormap_checked
 **
 ** @param xcb_connection_t *c
 ** @param ubyte             alloc
 ** @param xcb_colormap_t    mid
 ** @param xcb_window_t      window
 ** @param xcb_visualid_t    visual
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_create_colormap_checked (xcb_connection_t *c  /**< */,
                             ubyte             alloc  /**< */,
                             xcb_colormap_t    mid  /**< */,
                             xcb_window_t      window  /**< */,
                             xcb_visualid_t    visual  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_create_colormap
 **
 ** @param xcb_connection_t *c
 ** @param ubyte             alloc
 ** @param xcb_colormap_t    mid
 ** @param xcb_window_t      window
 ** @param xcb_visualid_t    visual
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_create_colormap (xcb_connection_t *c  /**< */,
                     ubyte             alloc  /**< */,
                     xcb_colormap_t    mid  /**< */,
                     xcb_window_t      window  /**< */,
                     xcb_visualid_t    visual  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_free_colormap_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_colormap_t    cmap
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_free_colormap_checked (xcb_connection_t *c  /**< */,
                           xcb_colormap_t    cmap  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_free_colormap
 **
 ** @param xcb_connection_t *c
 ** @param xcb_colormap_t    cmap
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_free_colormap (xcb_connection_t *c  /**< */,
                   xcb_colormap_t    cmap  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_copy_colormap_and_free_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_colormap_t    mid
 ** @param xcb_colormap_t    src_cmap
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_copy_colormap_and_free_checked (xcb_connection_t *c  /**< */,
                                    xcb_colormap_t    mid  /**< */,
                                    xcb_colormap_t    src_cmap  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_copy_colormap_and_free
 **
 ** @param xcb_connection_t *c
 ** @param xcb_colormap_t    mid
 ** @param xcb_colormap_t    src_cmap
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_copy_colormap_and_free (xcb_connection_t *c  /**< */,
                            xcb_colormap_t    mid  /**< */,
                            xcb_colormap_t    src_cmap  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_install_colormap_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_colormap_t    cmap
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_install_colormap_checked (xcb_connection_t *c  /**< */,
                              xcb_colormap_t    cmap  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_install_colormap
 **
 ** @param xcb_connection_t *c
 ** @param xcb_colormap_t    cmap
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_install_colormap (xcb_connection_t *c  /**< */,
                      xcb_colormap_t    cmap  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_uninstall_colormap_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_colormap_t    cmap
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_uninstall_colormap_checked (xcb_connection_t *c  /**< */,
                                xcb_colormap_t    cmap  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_uninstall_colormap
 **
 ** @param xcb_connection_t *c
 ** @param xcb_colormap_t    cmap
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_uninstall_colormap (xcb_connection_t *c  /**< */,
                        xcb_colormap_t    cmap  /**< */);


/*****************************************************************************
 **
 ** xcb_list_installed_colormaps_cookie_t xcb_list_installed_colormaps
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @returns xcb_list_installed_colormaps_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_list_installed_colormaps_cookie_t
xcb_list_installed_colormaps (xcb_connection_t *c  /**< */,
                              xcb_window_t      window  /**< */);


/*****************************************************************************
 **
 ** xcb_list_installed_colormaps_cookie_t xcb_list_installed_colormaps_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_window_t      window
 ** @returns xcb_list_installed_colormaps_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_list_installed_colormaps_cookie_t
xcb_list_installed_colormaps_unchecked (xcb_connection_t *c  /**< */,
                                        xcb_window_t      window  /**< */);


/*****************************************************************************
 **
 ** xcb_colormap_t * xcb_list_installed_colormaps_cmaps
 **
 ** @param /+const+/ xcb_list_installed_colormaps_reply_t *R
 ** @returns xcb_colormap_t *
 **
 *****************************************************************************/

extern(C) xcb_colormap_t *
xcb_list_installed_colormaps_cmaps (/+const+/ xcb_list_installed_colormaps_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_list_installed_colormaps_cmaps_length
 **
 ** @param /+const+/ xcb_list_installed_colormaps_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_list_installed_colormaps_cmaps_length (/+const+/ xcb_list_installed_colormaps_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_colormap_iterator_t xcb_list_installed_colormaps_cmaps_iterator
 **
 ** @param /+const+/ xcb_list_installed_colormaps_reply_t *R
 ** @returns xcb_colormap_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_colormap_iterator_t
xcb_list_installed_colormaps_cmaps_iterator (/+const+/ xcb_list_installed_colormaps_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_list_installed_colormaps_reply_t * xcb_list_installed_colormaps_reply
 **
 ** @param xcb_connection_t                       *c
 ** @param xcb_list_installed_colormaps_cookie_t   cookie
 ** @param xcb_generic_error_t                   **e
 ** @returns xcb_list_installed_colormaps_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_list_installed_colormaps_reply_t *
xcb_list_installed_colormaps_reply (xcb_connection_t                       *c  /**< */,
                                    xcb_list_installed_colormaps_cookie_t   cookie  /**< */,
                                    xcb_generic_error_t                   **e  /**< */);


/*****************************************************************************
 **
 ** xcb_alloc_color_cookie_t xcb_alloc_color
 **
 ** @param xcb_connection_t *c
 ** @param xcb_colormap_t    cmap
 ** @param ushort            red
 ** @param ushort            green
 ** @param ushort            blue
 ** @returns xcb_alloc_color_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_alloc_color_cookie_t
xcb_alloc_color (xcb_connection_t *c  /**< */,
                 xcb_colormap_t    cmap  /**< */,
                 ushort            red  /**< */,
                 ushort            green  /**< */,
                 ushort            blue  /**< */);


/*****************************************************************************
 **
 ** xcb_alloc_color_cookie_t xcb_alloc_color_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_colormap_t    cmap
 ** @param ushort            red
 ** @param ushort            green
 ** @param ushort            blue
 ** @returns xcb_alloc_color_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_alloc_color_cookie_t
xcb_alloc_color_unchecked (xcb_connection_t *c  /**< */,
                           xcb_colormap_t    cmap  /**< */,
                           ushort            red  /**< */,
                           ushort            green  /**< */,
                           ushort            blue  /**< */);


/*****************************************************************************
 **
 ** xcb_alloc_color_reply_t * xcb_alloc_color_reply
 **
 ** @param xcb_connection_t          *c
 ** @param xcb_alloc_color_cookie_t   cookie
 ** @param xcb_generic_error_t      **e
 ** @returns xcb_alloc_color_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_alloc_color_reply_t *
xcb_alloc_color_reply (xcb_connection_t          *c  /**< */,
                       xcb_alloc_color_cookie_t   cookie  /**< */,
                       xcb_generic_error_t      **e  /**< */);


/*****************************************************************************
 **
 ** xcb_alloc_named_color_cookie_t xcb_alloc_named_color
 **
 ** @param xcb_connection_t *c
 ** @param xcb_colormap_t    cmap
 ** @param ushort            name_len
 ** @param /+const+/ char   *name
 ** @returns xcb_alloc_named_color_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_alloc_named_color_cookie_t
xcb_alloc_named_color (xcb_connection_t *c  /**< */,
                       xcb_colormap_t    cmap  /**< */,
                       ushort            name_len  /**< */,
                       /+const+/ char   *name  /**< */);


/*****************************************************************************
 **
 ** xcb_alloc_named_color_cookie_t xcb_alloc_named_color_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_colormap_t    cmap
 ** @param ushort            name_len
 ** @param /+const+/ char   *name
 ** @returns xcb_alloc_named_color_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_alloc_named_color_cookie_t
xcb_alloc_named_color_unchecked (xcb_connection_t *c  /**< */,
                                 xcb_colormap_t    cmap  /**< */,
                                 ushort            name_len  /**< */,
                                 /+const+/ char   *name  /**< */);


/*****************************************************************************
 **
 ** xcb_alloc_named_color_reply_t * xcb_alloc_named_color_reply
 **
 ** @param xcb_connection_t                *c
 ** @param xcb_alloc_named_color_cookie_t   cookie
 ** @param xcb_generic_error_t            **e
 ** @returns xcb_alloc_named_color_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_alloc_named_color_reply_t *
xcb_alloc_named_color_reply (xcb_connection_t                *c  /**< */,
                             xcb_alloc_named_color_cookie_t   cookie  /**< */,
                             xcb_generic_error_t            **e  /**< */);


/*****************************************************************************
 **
 ** xcb_alloc_color_cells_cookie_t xcb_alloc_color_cells
 **
 ** @param xcb_connection_t *c
 ** @param bool              contiguous
 ** @param xcb_colormap_t    cmap
 ** @param ushort            colors
 ** @param ushort            planes
 ** @returns xcb_alloc_color_cells_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_alloc_color_cells_cookie_t
xcb_alloc_color_cells (xcb_connection_t *c  /**< */,
                       bool              contiguous  /**< */,
                       xcb_colormap_t    cmap  /**< */,
                       ushort            colors  /**< */,
                       ushort            planes  /**< */);


/*****************************************************************************
 **
 ** xcb_alloc_color_cells_cookie_t xcb_alloc_color_cells_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param bool              contiguous
 ** @param xcb_colormap_t    cmap
 ** @param ushort            colors
 ** @param ushort            planes
 ** @returns xcb_alloc_color_cells_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_alloc_color_cells_cookie_t
xcb_alloc_color_cells_unchecked (xcb_connection_t *c  /**< */,
                                 bool              contiguous  /**< */,
                                 xcb_colormap_t    cmap  /**< */,
                                 ushort            colors  /**< */,
                                 ushort            planes  /**< */);


/*****************************************************************************
 **
 ** uint * xcb_alloc_color_cells_pixels
 **
 ** @param /+const+/ xcb_alloc_color_cells_reply_t *R
 ** @returns uint *
 **
 *****************************************************************************/

extern(C) uint *
xcb_alloc_color_cells_pixels (/+const+/ xcb_alloc_color_cells_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_alloc_color_cells_pixels_length
 **
 ** @param /+const+/ xcb_alloc_color_cells_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_alloc_color_cells_pixels_length (/+const+/ xcb_alloc_color_cells_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_alloc_color_cells_pixels_end
 **
 ** @param /+const+/ xcb_alloc_color_cells_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_alloc_color_cells_pixels_end (/+const+/ xcb_alloc_color_cells_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** uint * xcb_alloc_color_cells_masks
 **
 ** @param /+const+/ xcb_alloc_color_cells_reply_t *R
 ** @returns uint *
 **
 *****************************************************************************/

extern(C) uint *
xcb_alloc_color_cells_masks (/+const+/ xcb_alloc_color_cells_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_alloc_color_cells_masks_length
 **
 ** @param /+const+/ xcb_alloc_color_cells_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_alloc_color_cells_masks_length (/+const+/ xcb_alloc_color_cells_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_alloc_color_cells_masks_end
 **
 ** @param /+const+/ xcb_alloc_color_cells_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_alloc_color_cells_masks_end (/+const+/ xcb_alloc_color_cells_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_alloc_color_cells_reply_t * xcb_alloc_color_cells_reply
 **
 ** @param xcb_connection_t                *c
 ** @param xcb_alloc_color_cells_cookie_t   cookie
 ** @param xcb_generic_error_t            **e
 ** @returns xcb_alloc_color_cells_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_alloc_color_cells_reply_t *
xcb_alloc_color_cells_reply (xcb_connection_t                *c  /**< */,
                             xcb_alloc_color_cells_cookie_t   cookie  /**< */,
                             xcb_generic_error_t            **e  /**< */);


/*****************************************************************************
 **
 ** xcb_alloc_color_planes_cookie_t xcb_alloc_color_planes
 **
 ** @param xcb_connection_t *c
 ** @param bool              contiguous
 ** @param xcb_colormap_t    cmap
 ** @param ushort            colors
 ** @param ushort            reds
 ** @param ushort            greens
 ** @param ushort            blues
 ** @returns xcb_alloc_color_planes_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_alloc_color_planes_cookie_t
xcb_alloc_color_planes (xcb_connection_t *c  /**< */,
                        bool              contiguous  /**< */,
                        xcb_colormap_t    cmap  /**< */,
                        ushort            colors  /**< */,
                        ushort            reds  /**< */,
                        ushort            greens  /**< */,
                        ushort            blues  /**< */);


/*****************************************************************************
 **
 ** xcb_alloc_color_planes_cookie_t xcb_alloc_color_planes_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param bool              contiguous
 ** @param xcb_colormap_t    cmap
 ** @param ushort            colors
 ** @param ushort            reds
 ** @param ushort            greens
 ** @param ushort            blues
 ** @returns xcb_alloc_color_planes_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_alloc_color_planes_cookie_t
xcb_alloc_color_planes_unchecked (xcb_connection_t *c  /**< */,
                                  bool              contiguous  /**< */,
                                  xcb_colormap_t    cmap  /**< */,
                                  ushort            colors  /**< */,
                                  ushort            reds  /**< */,
                                  ushort            greens  /**< */,
                                  ushort            blues  /**< */);


/*****************************************************************************
 **
 ** uint * xcb_alloc_color_planes_pixels
 **
 ** @param /+const+/ xcb_alloc_color_planes_reply_t *R
 ** @returns uint *
 **
 *****************************************************************************/

extern(C) uint *
xcb_alloc_color_planes_pixels (/+const+/ xcb_alloc_color_planes_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_alloc_color_planes_pixels_length
 **
 ** @param /+const+/ xcb_alloc_color_planes_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_alloc_color_planes_pixels_length (/+const+/ xcb_alloc_color_planes_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_alloc_color_planes_pixels_end
 **
 ** @param /+const+/ xcb_alloc_color_planes_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_alloc_color_planes_pixels_end (/+const+/ xcb_alloc_color_planes_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_alloc_color_planes_reply_t * xcb_alloc_color_planes_reply
 **
 ** @param xcb_connection_t                 *c
 ** @param xcb_alloc_color_planes_cookie_t   cookie
 ** @param xcb_generic_error_t             **e
 ** @returns xcb_alloc_color_planes_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_alloc_color_planes_reply_t *
xcb_alloc_color_planes_reply (xcb_connection_t                 *c  /**< */,
                              xcb_alloc_color_planes_cookie_t   cookie  /**< */,
                              xcb_generic_error_t             **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_free_colors_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_colormap_t    cmap
 ** @param uint              plane_mask
 ** @param uint              pixels_len
 ** @param /+const+/ uint   *pixels
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_free_colors_checked (xcb_connection_t *c  /**< */,
                         xcb_colormap_t    cmap  /**< */,
                         uint              plane_mask  /**< */,
                         uint              pixels_len  /**< */,
                         /+const+/ uint   *pixels  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_free_colors
 **
 ** @param xcb_connection_t *c
 ** @param xcb_colormap_t    cmap
 ** @param uint              plane_mask
 ** @param uint              pixels_len
 ** @param /+const+/ uint   *pixels
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_free_colors (xcb_connection_t *c  /**< */,
                 xcb_colormap_t    cmap  /**< */,
                 uint              plane_mask  /**< */,
                 uint              pixels_len  /**< */,
                 /+const+/ uint   *pixels  /**< */);


/*****************************************************************************
 **
 ** void xcb_coloritem_next
 **
 ** @param xcb_coloritem_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_coloritem_next (xcb_coloritem_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_coloritem_end
 **
 ** @param xcb_coloritem_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_coloritem_end (xcb_coloritem_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_store_colors_checked
 **
 ** @param xcb_connection_t          *c
 ** @param xcb_colormap_t             cmap
 ** @param uint                       items_len
 ** @param /+const+/ xcb_coloritem_t *items
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_store_colors_checked (xcb_connection_t          *c  /**< */,
                          xcb_colormap_t             cmap  /**< */,
                          uint                       items_len  /**< */,
                          /+const+/ xcb_coloritem_t *items  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_store_colors
 **
 ** @param xcb_connection_t          *c
 ** @param xcb_colormap_t             cmap
 ** @param uint                       items_len
 ** @param /+const+/ xcb_coloritem_t *items
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_store_colors (xcb_connection_t          *c  /**< */,
                  xcb_colormap_t             cmap  /**< */,
                  uint                       items_len  /**< */,
                  /+const+/ xcb_coloritem_t *items  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_store_named_color_checked
 **
 ** @param xcb_connection_t *c
 ** @param ubyte             flags
 ** @param xcb_colormap_t    cmap
 ** @param uint              pixel
 ** @param ushort            name_len
 ** @param /+const+/ char   *name
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_store_named_color_checked (xcb_connection_t *c  /**< */,
                               ubyte             flags  /**< */,
                               xcb_colormap_t    cmap  /**< */,
                               uint              pixel  /**< */,
                               ushort            name_len  /**< */,
                               /+const+/ char   *name  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_store_named_color
 **
 ** @param xcb_connection_t *c
 ** @param ubyte             flags
 ** @param xcb_colormap_t    cmap
 ** @param uint              pixel
 ** @param ushort            name_len
 ** @param /+const+/ char   *name
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_store_named_color (xcb_connection_t *c  /**< */,
                       ubyte             flags  /**< */,
                       xcb_colormap_t    cmap  /**< */,
                       uint              pixel  /**< */,
                       ushort            name_len  /**< */,
                       /+const+/ char   *name  /**< */);


/*****************************************************************************
 **
 ** void xcb_rgb_next
 **
 ** @param xcb_rgb_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_rgb_next (xcb_rgb_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_rgb_end
 **
 ** @param xcb_rgb_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_rgb_end (xcb_rgb_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** xcb_query_colors_cookie_t xcb_query_colors
 **
 ** @param xcb_connection_t *c
 ** @param xcb_colormap_t    cmap
 ** @param uint              pixels_len
 ** @param /+const+/ uint   *pixels
 ** @returns xcb_query_colors_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_query_colors_cookie_t
xcb_query_colors (xcb_connection_t *c  /**< */,
                  xcb_colormap_t    cmap  /**< */,
                  uint              pixels_len  /**< */,
                  /+const+/ uint   *pixels  /**< */);


/*****************************************************************************
 **
 ** xcb_query_colors_cookie_t xcb_query_colors_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_colormap_t    cmap
 ** @param uint              pixels_len
 ** @param /+const+/ uint   *pixels
 ** @returns xcb_query_colors_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_query_colors_cookie_t
xcb_query_colors_unchecked (xcb_connection_t *c  /**< */,
                            xcb_colormap_t    cmap  /**< */,
                            uint              pixels_len  /**< */,
                            /+const+/ uint   *pixels  /**< */);


/*****************************************************************************
 **
 ** xcb_rgb_t * xcb_query_colors_colors
 **
 ** @param /+const+/ xcb_query_colors_reply_t *R
 ** @returns xcb_rgb_t *
 **
 *****************************************************************************/

extern(C) xcb_rgb_t *
xcb_query_colors_colors (/+const+/ xcb_query_colors_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_query_colors_colors_length
 **
 ** @param /+const+/ xcb_query_colors_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_query_colors_colors_length (/+const+/ xcb_query_colors_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_rgb_iterator_t xcb_query_colors_colors_iterator
 **
 ** @param /+const+/ xcb_query_colors_reply_t *R
 ** @returns xcb_rgb_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_rgb_iterator_t
xcb_query_colors_colors_iterator (/+const+/ xcb_query_colors_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_query_colors_reply_t * xcb_query_colors_reply
 **
 ** @param xcb_connection_t           *c
 ** @param xcb_query_colors_cookie_t   cookie
 ** @param xcb_generic_error_t       **e
 ** @returns xcb_query_colors_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_query_colors_reply_t *
xcb_query_colors_reply (xcb_connection_t           *c  /**< */,
                        xcb_query_colors_cookie_t   cookie  /**< */,
                        xcb_generic_error_t       **e  /**< */);


/*****************************************************************************
 **
 ** xcb_lookup_color_cookie_t xcb_lookup_color
 **
 ** @param xcb_connection_t *c
 ** @param xcb_colormap_t    cmap
 ** @param ushort            name_len
 ** @param /+const+/ char   *name
 ** @returns xcb_lookup_color_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_lookup_color_cookie_t
xcb_lookup_color (xcb_connection_t *c  /**< */,
                  xcb_colormap_t    cmap  /**< */,
                  ushort            name_len  /**< */,
                  /+const+/ char   *name  /**< */);


/*****************************************************************************
 **
 ** xcb_lookup_color_cookie_t xcb_lookup_color_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_colormap_t    cmap
 ** @param ushort            name_len
 ** @param /+const+/ char   *name
 ** @returns xcb_lookup_color_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_lookup_color_cookie_t
xcb_lookup_color_unchecked (xcb_connection_t *c  /**< */,
                            xcb_colormap_t    cmap  /**< */,
                            ushort            name_len  /**< */,
                            /+const+/ char   *name  /**< */);


/*****************************************************************************
 **
 ** xcb_lookup_color_reply_t * xcb_lookup_color_reply
 **
 ** @param xcb_connection_t           *c
 ** @param xcb_lookup_color_cookie_t   cookie
 ** @param xcb_generic_error_t       **e
 ** @returns xcb_lookup_color_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_lookup_color_reply_t *
xcb_lookup_color_reply (xcb_connection_t           *c  /**< */,
                        xcb_lookup_color_cookie_t   cookie  /**< */,
                        xcb_generic_error_t       **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_create_cursor_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_cursor_t      cid
 ** @param xcb_pixmap_t      source
 ** @param xcb_pixmap_t      mask
 ** @param ushort            fore_red
 ** @param ushort            fore_green
 ** @param ushort            fore_blue
 ** @param ushort            back_red
 ** @param ushort            back_green
 ** @param ushort            back_blue
 ** @param ushort            x
 ** @param ushort            y
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_create_cursor_checked (xcb_connection_t *c  /**< */,
                           xcb_cursor_t      cid  /**< */,
                           xcb_pixmap_t      source  /**< */,
                           xcb_pixmap_t      mask  /**< */,
                           ushort            fore_red  /**< */,
                           ushort            fore_green  /**< */,
                           ushort            fore_blue  /**< */,
                           ushort            back_red  /**< */,
                           ushort            back_green  /**< */,
                           ushort            back_blue  /**< */,
                           ushort            x  /**< */,
                           ushort            y  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_create_cursor
 **
 ** @param xcb_connection_t *c
 ** @param xcb_cursor_t      cid
 ** @param xcb_pixmap_t      source
 ** @param xcb_pixmap_t      mask
 ** @param ushort            fore_red
 ** @param ushort            fore_green
 ** @param ushort            fore_blue
 ** @param ushort            back_red
 ** @param ushort            back_green
 ** @param ushort            back_blue
 ** @param ushort            x
 ** @param ushort            y
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_create_cursor (xcb_connection_t *c  /**< */,
                   xcb_cursor_t      cid  /**< */,
                   xcb_pixmap_t      source  /**< */,
                   xcb_pixmap_t      mask  /**< */,
                   ushort            fore_red  /**< */,
                   ushort            fore_green  /**< */,
                   ushort            fore_blue  /**< */,
                   ushort            back_red  /**< */,
                   ushort            back_green  /**< */,
                   ushort            back_blue  /**< */,
                   ushort            x  /**< */,
                   ushort            y  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_create_glyph_cursor_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_cursor_t      cid
 ** @param xcb_font_t        source_font
 ** @param xcb_font_t        mask_font
 ** @param ushort            source_char
 ** @param ushort            mask_char
 ** @param ushort            fore_red
 ** @param ushort            fore_green
 ** @param ushort            fore_blue
 ** @param ushort            back_red
 ** @param ushort            back_green
 ** @param ushort            back_blue
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_create_glyph_cursor_checked (xcb_connection_t *c  /**< */,
                                 xcb_cursor_t      cid  /**< */,
                                 xcb_font_t        source_font  /**< */,
                                 xcb_font_t        mask_font  /**< */,
                                 ushort            source_char  /**< */,
                                 ushort            mask_char  /**< */,
                                 ushort            fore_red  /**< */,
                                 ushort            fore_green  /**< */,
                                 ushort            fore_blue  /**< */,
                                 ushort            back_red  /**< */,
                                 ushort            back_green  /**< */,
                                 ushort            back_blue  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_create_glyph_cursor
 **
 ** @param xcb_connection_t *c
 ** @param xcb_cursor_t      cid
 ** @param xcb_font_t        source_font
 ** @param xcb_font_t        mask_font
 ** @param ushort            source_char
 ** @param ushort            mask_char
 ** @param ushort            fore_red
 ** @param ushort            fore_green
 ** @param ushort            fore_blue
 ** @param ushort            back_red
 ** @param ushort            back_green
 ** @param ushort            back_blue
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_create_glyph_cursor (xcb_connection_t *c  /**< */,
                         xcb_cursor_t      cid  /**< */,
                         xcb_font_t        source_font  /**< */,
                         xcb_font_t        mask_font  /**< */,
                         ushort            source_char  /**< */,
                         ushort            mask_char  /**< */,
                         ushort            fore_red  /**< */,
                         ushort            fore_green  /**< */,
                         ushort            fore_blue  /**< */,
                         ushort            back_red  /**< */,
                         ushort            back_green  /**< */,
                         ushort            back_blue  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_free_cursor_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_cursor_t      cursor
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_free_cursor_checked (xcb_connection_t *c  /**< */,
                         xcb_cursor_t      cursor  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_free_cursor
 **
 ** @param xcb_connection_t *c
 ** @param xcb_cursor_t      cursor
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_free_cursor (xcb_connection_t *c  /**< */,
                 xcb_cursor_t      cursor  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_recolor_cursor_checked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_cursor_t      cursor
 ** @param ushort            fore_red
 ** @param ushort            fore_green
 ** @param ushort            fore_blue
 ** @param ushort            back_red
 ** @param ushort            back_green
 ** @param ushort            back_blue
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_recolor_cursor_checked (xcb_connection_t *c  /**< */,
                            xcb_cursor_t      cursor  /**< */,
                            ushort            fore_red  /**< */,
                            ushort            fore_green  /**< */,
                            ushort            fore_blue  /**< */,
                            ushort            back_red  /**< */,
                            ushort            back_green  /**< */,
                            ushort            back_blue  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_recolor_cursor
 **
 ** @param xcb_connection_t *c
 ** @param xcb_cursor_t      cursor
 ** @param ushort            fore_red
 ** @param ushort            fore_green
 ** @param ushort            fore_blue
 ** @param ushort            back_red
 ** @param ushort            back_green
 ** @param ushort            back_blue
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_recolor_cursor (xcb_connection_t *c  /**< */,
                    xcb_cursor_t      cursor  /**< */,
                    ushort            fore_red  /**< */,
                    ushort            fore_green  /**< */,
                    ushort            fore_blue  /**< */,
                    ushort            back_red  /**< */,
                    ushort            back_green  /**< */,
                    ushort            back_blue  /**< */);


/*****************************************************************************
 **
 ** xcb_query_best_size_cookie_t xcb_query_best_size
 **
 ** @param xcb_connection_t *c
 ** @param ubyte             _class
 ** @param xcb_drawable_t    drawable
 ** @param ushort            width
 ** @param ushort            height
 ** @returns xcb_query_best_size_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_query_best_size_cookie_t
xcb_query_best_size (xcb_connection_t *c  /**< */,
                     ubyte             _class  /**< */,
                     xcb_drawable_t    drawable  /**< */,
                     ushort            width  /**< */,
                     ushort            height  /**< */);


/*****************************************************************************
 **
 ** xcb_query_best_size_cookie_t xcb_query_best_size_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param ubyte             _class
 ** @param xcb_drawable_t    drawable
 ** @param ushort            width
 ** @param ushort            height
 ** @returns xcb_query_best_size_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_query_best_size_cookie_t
xcb_query_best_size_unchecked (xcb_connection_t *c  /**< */,
                               ubyte             _class  /**< */,
                               xcb_drawable_t    drawable  /**< */,
                               ushort            width  /**< */,
                               ushort            height  /**< */);


/*****************************************************************************
 **
 ** xcb_query_best_size_reply_t * xcb_query_best_size_reply
 **
 ** @param xcb_connection_t              *c
 ** @param xcb_query_best_size_cookie_t   cookie
 ** @param xcb_generic_error_t          **e
 ** @returns xcb_query_best_size_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_query_best_size_reply_t *
xcb_query_best_size_reply (xcb_connection_t              *c  /**< */,
                           xcb_query_best_size_cookie_t   cookie  /**< */,
                           xcb_generic_error_t          **e  /**< */);


/*****************************************************************************
 **
 ** xcb_query_extension_cookie_t xcb_query_extension
 **
 ** @param xcb_connection_t *c
 ** @param ushort            name_len
 ** @param /+const+/ char   *name
 ** @returns xcb_query_extension_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_query_extension_cookie_t
xcb_query_extension (xcb_connection_t *c  /**< */,
                     ushort            name_len  /**< */,
                     /+const+/ char   *name  /**< */);


/*****************************************************************************
 **
 ** xcb_query_extension_cookie_t xcb_query_extension_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param ushort            name_len
 ** @param /+const+/ char   *name
 ** @returns xcb_query_extension_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_query_extension_cookie_t
xcb_query_extension_unchecked (xcb_connection_t *c  /**< */,
                               ushort            name_len  /**< */,
                               /+const+/ char   *name  /**< */);


/*****************************************************************************
 **
 ** xcb_query_extension_reply_t * xcb_query_extension_reply
 **
 ** @param xcb_connection_t              *c
 ** @param xcb_query_extension_cookie_t   cookie
 ** @param xcb_generic_error_t          **e
 ** @returns xcb_query_extension_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_query_extension_reply_t *
xcb_query_extension_reply (xcb_connection_t              *c  /**< */,
                           xcb_query_extension_cookie_t   cookie  /**< */,
                           xcb_generic_error_t          **e  /**< */);


/*****************************************************************************
 **
 ** xcb_list_extensions_cookie_t xcb_list_extensions
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_list_extensions_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_list_extensions_cookie_t
xcb_list_extensions (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_list_extensions_cookie_t xcb_list_extensions_unchecked
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_list_extensions_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_list_extensions_cookie_t
xcb_list_extensions_unchecked (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** int xcb_list_extensions_names_length
 **
 ** @param /+const+/ xcb_list_extensions_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_list_extensions_names_length (/+const+/ xcb_list_extensions_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_str_iterator_t xcb_list_extensions_names_iterator
 **
 ** @param /+const+/ xcb_list_extensions_reply_t *R
 ** @returns xcb_str_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_str_iterator_t
xcb_list_extensions_names_iterator (/+const+/ xcb_list_extensions_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_list_extensions_reply_t * xcb_list_extensions_reply
 **
 ** @param xcb_connection_t              *c
 ** @param xcb_list_extensions_cookie_t   cookie
 ** @param xcb_generic_error_t          **e
 ** @returns xcb_list_extensions_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_list_extensions_reply_t *
xcb_list_extensions_reply (xcb_connection_t              *c  /**< */,
                           xcb_list_extensions_cookie_t   cookie  /**< */,
                           xcb_generic_error_t          **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_change_keyboard_mapping_checked
 **
 ** @param xcb_connection_t       *c
 ** @param ubyte                   keycode_count
 ** @param xcb_keycode_t           first_keycode
 ** @param ubyte                   keysyms_per_keycode
 ** @param /+const+/ xcb_keysym_t *keysyms
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_change_keyboard_mapping_checked (xcb_connection_t       *c  /**< */,
                                     ubyte                   keycode_count  /**< */,
                                     xcb_keycode_t           first_keycode  /**< */,
                                     ubyte                   keysyms_per_keycode  /**< */,
                                     /+const+/ xcb_keysym_t *keysyms  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_change_keyboard_mapping
 **
 ** @param xcb_connection_t       *c
 ** @param ubyte                   keycode_count
 ** @param xcb_keycode_t           first_keycode
 ** @param ubyte                   keysyms_per_keycode
 ** @param /+const+/ xcb_keysym_t *keysyms
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_change_keyboard_mapping (xcb_connection_t       *c  /**< */,
                             ubyte                   keycode_count  /**< */,
                             xcb_keycode_t           first_keycode  /**< */,
                             ubyte                   keysyms_per_keycode  /**< */,
                             /+const+/ xcb_keysym_t *keysyms  /**< */);


/*****************************************************************************
 **
 ** xcb_get_keyboard_mapping_cookie_t xcb_get_keyboard_mapping
 **
 ** @param xcb_connection_t *c
 ** @param xcb_keycode_t     first_keycode
 ** @param ubyte             count
 ** @returns xcb_get_keyboard_mapping_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_get_keyboard_mapping_cookie_t
xcb_get_keyboard_mapping (xcb_connection_t *c  /**< */,
                          xcb_keycode_t     first_keycode  /**< */,
                          ubyte             count  /**< */);


/*****************************************************************************
 **
 ** xcb_get_keyboard_mapping_cookie_t xcb_get_keyboard_mapping_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param xcb_keycode_t     first_keycode
 ** @param ubyte             count
 ** @returns xcb_get_keyboard_mapping_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_get_keyboard_mapping_cookie_t
xcb_get_keyboard_mapping_unchecked (xcb_connection_t *c  /**< */,
                                    xcb_keycode_t     first_keycode  /**< */,
                                    ubyte             count  /**< */);


/*****************************************************************************
 **
 ** xcb_keysym_t * xcb_get_keyboard_mapping_keysyms
 **
 ** @param /+const+/ xcb_get_keyboard_mapping_reply_t *R
 ** @returns xcb_keysym_t *
 **
 *****************************************************************************/

extern(C) xcb_keysym_t *
xcb_get_keyboard_mapping_keysyms (/+const+/ xcb_get_keyboard_mapping_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_get_keyboard_mapping_keysyms_length
 **
 ** @param /+const+/ xcb_get_keyboard_mapping_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_get_keyboard_mapping_keysyms_length (/+const+/ xcb_get_keyboard_mapping_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_keysym_iterator_t xcb_get_keyboard_mapping_keysyms_iterator
 **
 ** @param /+const+/ xcb_get_keyboard_mapping_reply_t *R
 ** @returns xcb_keysym_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_keysym_iterator_t
xcb_get_keyboard_mapping_keysyms_iterator (/+const+/ xcb_get_keyboard_mapping_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_get_keyboard_mapping_reply_t * xcb_get_keyboard_mapping_reply
 **
 ** @param xcb_connection_t                   *c
 ** @param xcb_get_keyboard_mapping_cookie_t   cookie
 ** @param xcb_generic_error_t               **e
 ** @returns xcb_get_keyboard_mapping_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_get_keyboard_mapping_reply_t *
xcb_get_keyboard_mapping_reply (xcb_connection_t                   *c  /**< */,
                                xcb_get_keyboard_mapping_cookie_t   cookie  /**< */,
                                xcb_generic_error_t               **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_change_keyboard_control_checked
 **
 ** @param xcb_connection_t *c
 ** @param uint              value_mask
 ** @param /+const+/ uint   *value_list
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_change_keyboard_control_checked (xcb_connection_t *c  /**< */,
                                     uint              value_mask  /**< */,
                                     /+const+/ uint   *value_list  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_change_keyboard_control
 **
 ** @param xcb_connection_t *c
 ** @param uint              value_mask
 ** @param /+const+/ uint   *value_list
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_change_keyboard_control (xcb_connection_t *c  /**< */,
                             uint              value_mask  /**< */,
                             /+const+/ uint   *value_list  /**< */);


/*****************************************************************************
 **
 ** xcb_get_keyboard_control_cookie_t xcb_get_keyboard_control
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_get_keyboard_control_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_get_keyboard_control_cookie_t
xcb_get_keyboard_control (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_get_keyboard_control_cookie_t xcb_get_keyboard_control_unchecked
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_get_keyboard_control_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_get_keyboard_control_cookie_t
xcb_get_keyboard_control_unchecked (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_get_keyboard_control_reply_t * xcb_get_keyboard_control_reply
 **
 ** @param xcb_connection_t                   *c
 ** @param xcb_get_keyboard_control_cookie_t   cookie
 ** @param xcb_generic_error_t               **e
 ** @returns xcb_get_keyboard_control_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_get_keyboard_control_reply_t *
xcb_get_keyboard_control_reply (xcb_connection_t                   *c  /**< */,
                                xcb_get_keyboard_control_cookie_t   cookie  /**< */,
                                xcb_generic_error_t               **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_bell_checked
 **
 ** @param xcb_connection_t *c
 ** @param byte              percent
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_bell_checked (xcb_connection_t *c  /**< */,
                  byte              percent  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_bell
 **
 ** @param xcb_connection_t *c
 ** @param byte              percent
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_bell (xcb_connection_t *c  /**< */,
          byte              percent  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_change_pointer_control_checked
 **
 ** @param xcb_connection_t *c
 ** @param short             acceleration_numerator
 ** @param short             acceleration_denominator
 ** @param short             threshold
 ** @param bool              do_acceleration
 ** @param bool              do_threshold
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_change_pointer_control_checked (xcb_connection_t *c  /**< */,
                                    short             acceleration_numerator  /**< */,
                                    short             acceleration_denominator  /**< */,
                                    short             threshold  /**< */,
                                    bool              do_acceleration  /**< */,
                                    bool              do_threshold  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_change_pointer_control
 **
 ** @param xcb_connection_t *c
 ** @param short             acceleration_numerator
 ** @param short             acceleration_denominator
 ** @param short             threshold
 ** @param bool              do_acceleration
 ** @param bool              do_threshold
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_change_pointer_control (xcb_connection_t *c  /**< */,
                            short             acceleration_numerator  /**< */,
                            short             acceleration_denominator  /**< */,
                            short             threshold  /**< */,
                            bool              do_acceleration  /**< */,
                            bool              do_threshold  /**< */);


/*****************************************************************************
 **
 ** xcb_get_pointer_control_cookie_t xcb_get_pointer_control
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_get_pointer_control_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_get_pointer_control_cookie_t
xcb_get_pointer_control (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_get_pointer_control_cookie_t xcb_get_pointer_control_unchecked
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_get_pointer_control_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_get_pointer_control_cookie_t
xcb_get_pointer_control_unchecked (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_get_pointer_control_reply_t * xcb_get_pointer_control_reply
 **
 ** @param xcb_connection_t                  *c
 ** @param xcb_get_pointer_control_cookie_t   cookie
 ** @param xcb_generic_error_t              **e
 ** @returns xcb_get_pointer_control_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_get_pointer_control_reply_t *
xcb_get_pointer_control_reply (xcb_connection_t                  *c  /**< */,
                               xcb_get_pointer_control_cookie_t   cookie  /**< */,
                               xcb_generic_error_t              **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_set_screen_saver_checked
 **
 ** @param xcb_connection_t *c
 ** @param short             timeout
 ** @param short             interval
 ** @param ubyte             prefer_blanking
 ** @param ubyte             allow_exposures
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_set_screen_saver_checked (xcb_connection_t *c  /**< */,
                              short             timeout  /**< */,
                              short             interval  /**< */,
                              ubyte             prefer_blanking  /**< */,
                              ubyte             allow_exposures  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_set_screen_saver
 **
 ** @param xcb_connection_t *c
 ** @param short             timeout
 ** @param short             interval
 ** @param ubyte             prefer_blanking
 ** @param ubyte             allow_exposures
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_set_screen_saver (xcb_connection_t *c  /**< */,
                      short             timeout  /**< */,
                      short             interval  /**< */,
                      ubyte             prefer_blanking  /**< */,
                      ubyte             allow_exposures  /**< */);


/*****************************************************************************
 **
 ** xcb_get_screen_saver_cookie_t xcb_get_screen_saver
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_get_screen_saver_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_get_screen_saver_cookie_t
xcb_get_screen_saver (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_get_screen_saver_cookie_t xcb_get_screen_saver_unchecked
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_get_screen_saver_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_get_screen_saver_cookie_t
xcb_get_screen_saver_unchecked (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_get_screen_saver_reply_t * xcb_get_screen_saver_reply
 **
 ** @param xcb_connection_t               *c
 ** @param xcb_get_screen_saver_cookie_t   cookie
 ** @param xcb_generic_error_t           **e
 ** @returns xcb_get_screen_saver_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_get_screen_saver_reply_t *
xcb_get_screen_saver_reply (xcb_connection_t               *c  /**< */,
                            xcb_get_screen_saver_cookie_t   cookie  /**< */,
                            xcb_generic_error_t           **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_change_hosts_checked
 **
 ** @param xcb_connection_t *c
 ** @param ubyte             mode
 ** @param ubyte             family
 ** @param ushort            address_len
 ** @param /+const+/ char   *address
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_change_hosts_checked (xcb_connection_t *c  /**< */,
                          ubyte             mode  /**< */,
                          ubyte             family  /**< */,
                          ushort            address_len  /**< */,
                          /+const+/ char   *address  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_change_hosts
 **
 ** @param xcb_connection_t *c
 ** @param ubyte             mode
 ** @param ubyte             family
 ** @param ushort            address_len
 ** @param /+const+/ char   *address
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_change_hosts (xcb_connection_t *c  /**< */,
                  ubyte             mode  /**< */,
                  ubyte             family  /**< */,
                  ushort            address_len  /**< */,
                  /+const+/ char   *address  /**< */);


/*****************************************************************************
 **
 ** ubyte * xcb_host_address
 **
 ** @param /+const+/ xcb_host_t *R
 ** @returns ubyte *
 **
 *****************************************************************************/

extern(C) ubyte *
xcb_host_address (/+const+/ xcb_host_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_host_address_length
 **
 ** @param /+const+/ xcb_host_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_host_address_length (/+const+/ xcb_host_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_host_address_end
 **
 ** @param /+const+/ xcb_host_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_host_address_end (/+const+/ xcb_host_t *R  /**< */);


/*****************************************************************************
 **
 ** void xcb_host_next
 **
 ** @param xcb_host_iterator_t *i
 ** @returns void
 **
 *****************************************************************************/

extern(C) void
xcb_host_next (xcb_host_iterator_t *i  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_host_end
 **
 ** @param xcb_host_iterator_t i
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_host_end (xcb_host_iterator_t i  /**< */);


/*****************************************************************************
 **
 ** xcb_list_hosts_cookie_t xcb_list_hosts
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_list_hosts_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_list_hosts_cookie_t
xcb_list_hosts (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_list_hosts_cookie_t xcb_list_hosts_unchecked
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_list_hosts_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_list_hosts_cookie_t
xcb_list_hosts_unchecked (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** int xcb_list_hosts_hosts_length
 **
 ** @param /+const+/ xcb_list_hosts_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_list_hosts_hosts_length (/+const+/ xcb_list_hosts_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_host_iterator_t xcb_list_hosts_hosts_iterator
 **
 ** @param /+const+/ xcb_list_hosts_reply_t *R
 ** @returns xcb_host_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_host_iterator_t
xcb_list_hosts_hosts_iterator (/+const+/ xcb_list_hosts_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_list_hosts_reply_t * xcb_list_hosts_reply
 **
 ** @param xcb_connection_t         *c
 ** @param xcb_list_hosts_cookie_t   cookie
 ** @param xcb_generic_error_t     **e
 ** @returns xcb_list_hosts_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_list_hosts_reply_t *
xcb_list_hosts_reply (xcb_connection_t         *c  /**< */,
                      xcb_list_hosts_cookie_t   cookie  /**< */,
                      xcb_generic_error_t     **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_set_access_control_checked
 **
 ** @param xcb_connection_t *c
 ** @param ubyte             mode
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_set_access_control_checked (xcb_connection_t *c  /**< */,
                                ubyte             mode  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_set_access_control
 **
 ** @param xcb_connection_t *c
 ** @param ubyte             mode
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_set_access_control (xcb_connection_t *c  /**< */,
                        ubyte             mode  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_set_close_down_mode_checked
 **
 ** @param xcb_connection_t *c
 ** @param ubyte             mode
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_set_close_down_mode_checked (xcb_connection_t *c  /**< */,
                                 ubyte             mode  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_set_close_down_mode
 **
 ** @param xcb_connection_t *c
 ** @param ubyte             mode
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_set_close_down_mode (xcb_connection_t *c  /**< */,
                         ubyte             mode  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_kill_client_checked
 **
 ** @param xcb_connection_t *c
 ** @param uint              resource
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_kill_client_checked (xcb_connection_t *c  /**< */,
                         uint              resource  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_kill_client
 **
 ** @param xcb_connection_t *c
 ** @param uint              resource
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_kill_client (xcb_connection_t *c  /**< */,
                 uint              resource  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_rotate_properties_checked
 **
 ** @param xcb_connection_t     *c
 ** @param xcb_window_t          window
 ** @param ushort                atoms_len
 ** @param short                 delta
 ** @param /+const+/ xcb_atom_t *atoms
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_rotate_properties_checked (xcb_connection_t     *c  /**< */,
                               xcb_window_t          window  /**< */,
                               ushort                atoms_len  /**< */,
                               short                 delta  /**< */,
                               /+const+/ xcb_atom_t *atoms  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_rotate_properties
 **
 ** @param xcb_connection_t     *c
 ** @param xcb_window_t          window
 ** @param ushort                atoms_len
 ** @param short                 delta
 ** @param /+const+/ xcb_atom_t *atoms
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_rotate_properties (xcb_connection_t     *c  /**< */,
                       xcb_window_t          window  /**< */,
                       ushort                atoms_len  /**< */,
                       short                 delta  /**< */,
                       /+const+/ xcb_atom_t *atoms  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_force_screen_saver_checked
 **
 ** @param xcb_connection_t *c
 ** @param ubyte             mode
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_force_screen_saver_checked (xcb_connection_t *c  /**< */,
                                ubyte             mode  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_force_screen_saver
 **
 ** @param xcb_connection_t *c
 ** @param ubyte             mode
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_force_screen_saver (xcb_connection_t *c  /**< */,
                        ubyte             mode  /**< */);


/*****************************************************************************
 **
 ** xcb_set_pointer_mapping_cookie_t xcb_set_pointer_mapping
 **
 ** @param xcb_connection_t *c
 ** @param ubyte             map_len
 ** @param /+const+/ ubyte  *map
 ** @returns xcb_set_pointer_mapping_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_set_pointer_mapping_cookie_t
xcb_set_pointer_mapping (xcb_connection_t *c  /**< */,
                         ubyte             map_len  /**< */,
                         /+const+/ ubyte  *map  /**< */);


/*****************************************************************************
 **
 ** xcb_set_pointer_mapping_cookie_t xcb_set_pointer_mapping_unchecked
 **
 ** @param xcb_connection_t *c
 ** @param ubyte             map_len
 ** @param /+const+/ ubyte  *map
 ** @returns xcb_set_pointer_mapping_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_set_pointer_mapping_cookie_t
xcb_set_pointer_mapping_unchecked (xcb_connection_t *c  /**< */,
                                   ubyte             map_len  /**< */,
                                   /+const+/ ubyte  *map  /**< */);


/*****************************************************************************
 **
 ** xcb_set_pointer_mapping_reply_t * xcb_set_pointer_mapping_reply
 **
 ** @param xcb_connection_t                  *c
 ** @param xcb_set_pointer_mapping_cookie_t   cookie
 ** @param xcb_generic_error_t              **e
 ** @returns xcb_set_pointer_mapping_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_set_pointer_mapping_reply_t *
xcb_set_pointer_mapping_reply (xcb_connection_t                  *c  /**< */,
                               xcb_set_pointer_mapping_cookie_t   cookie  /**< */,
                               xcb_generic_error_t              **e  /**< */);


/*****************************************************************************
 **
 ** xcb_get_pointer_mapping_cookie_t xcb_get_pointer_mapping
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_get_pointer_mapping_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_get_pointer_mapping_cookie_t
xcb_get_pointer_mapping (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_get_pointer_mapping_cookie_t xcb_get_pointer_mapping_unchecked
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_get_pointer_mapping_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_get_pointer_mapping_cookie_t
xcb_get_pointer_mapping_unchecked (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** ubyte * xcb_get_pointer_mapping_map
 **
 ** @param /+const+/ xcb_get_pointer_mapping_reply_t *R
 ** @returns ubyte *
 **
 *****************************************************************************/

extern(C) ubyte *
xcb_get_pointer_mapping_map (/+const+/ xcb_get_pointer_mapping_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_get_pointer_mapping_map_length
 **
 ** @param /+const+/ xcb_get_pointer_mapping_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_get_pointer_mapping_map_length (/+const+/ xcb_get_pointer_mapping_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_generic_iterator_t xcb_get_pointer_mapping_map_end
 **
 ** @param /+const+/ xcb_get_pointer_mapping_reply_t *R
 ** @returns xcb_generic_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_generic_iterator_t
xcb_get_pointer_mapping_map_end (/+const+/ xcb_get_pointer_mapping_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_get_pointer_mapping_reply_t * xcb_get_pointer_mapping_reply
 **
 ** @param xcb_connection_t                  *c
 ** @param xcb_get_pointer_mapping_cookie_t   cookie
 ** @param xcb_generic_error_t              **e
 ** @returns xcb_get_pointer_mapping_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_get_pointer_mapping_reply_t *
xcb_get_pointer_mapping_reply (xcb_connection_t                  *c  /**< */,
                               xcb_get_pointer_mapping_cookie_t   cookie  /**< */,
                               xcb_generic_error_t              **e  /**< */);


/*****************************************************************************
 **
 ** xcb_set_modifier_mapping_cookie_t xcb_set_modifier_mapping
 **
 ** @param xcb_connection_t        *c
 ** @param ubyte                    keycodes_per_modifier
 ** @param /+const+/ xcb_keycode_t *keycodes
 ** @returns xcb_set_modifier_mapping_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_set_modifier_mapping_cookie_t
xcb_set_modifier_mapping (xcb_connection_t        *c  /**< */,
                          ubyte                    keycodes_per_modifier  /**< */,
                          /+const+/ xcb_keycode_t *keycodes  /**< */);


/*****************************************************************************
 **
 ** xcb_set_modifier_mapping_cookie_t xcb_set_modifier_mapping_unchecked
 **
 ** @param xcb_connection_t        *c
 ** @param ubyte                    keycodes_per_modifier
 ** @param /+const+/ xcb_keycode_t *keycodes
 ** @returns xcb_set_modifier_mapping_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_set_modifier_mapping_cookie_t
xcb_set_modifier_mapping_unchecked (xcb_connection_t        *c  /**< */,
                                    ubyte                    keycodes_per_modifier  /**< */,
                                    /+const+/ xcb_keycode_t *keycodes  /**< */);


/*****************************************************************************
 **
 ** xcb_set_modifier_mapping_reply_t * xcb_set_modifier_mapping_reply
 **
 ** @param xcb_connection_t                   *c
 ** @param xcb_set_modifier_mapping_cookie_t   cookie
 ** @param xcb_generic_error_t               **e
 ** @returns xcb_set_modifier_mapping_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_set_modifier_mapping_reply_t *
xcb_set_modifier_mapping_reply (xcb_connection_t                   *c  /**< */,
                                xcb_set_modifier_mapping_cookie_t   cookie  /**< */,
                                xcb_generic_error_t               **e  /**< */);


/*****************************************************************************
 **
 ** xcb_get_modifier_mapping_cookie_t xcb_get_modifier_mapping
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_get_modifier_mapping_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_get_modifier_mapping_cookie_t
xcb_get_modifier_mapping (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_get_modifier_mapping_cookie_t xcb_get_modifier_mapping_unchecked
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_get_modifier_mapping_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_get_modifier_mapping_cookie_t
xcb_get_modifier_mapping_unchecked (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_keycode_t * xcb_get_modifier_mapping_keycodes
 **
 ** @param /+const+/ xcb_get_modifier_mapping_reply_t *R
 ** @returns xcb_keycode_t *
 **
 *****************************************************************************/

extern(C) xcb_keycode_t *
xcb_get_modifier_mapping_keycodes (/+const+/ xcb_get_modifier_mapping_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** int xcb_get_modifier_mapping_keycodes_length
 **
 ** @param /+const+/ xcb_get_modifier_mapping_reply_t *R
 ** @returns int
 **
 *****************************************************************************/

extern(C) int
xcb_get_modifier_mapping_keycodes_length (/+const+/ xcb_get_modifier_mapping_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_keycode_iterator_t xcb_get_modifier_mapping_keycodes_iterator
 **
 ** @param /+const+/ xcb_get_modifier_mapping_reply_t *R
 ** @returns xcb_keycode_iterator_t
 **
 *****************************************************************************/

extern(C) xcb_keycode_iterator_t
xcb_get_modifier_mapping_keycodes_iterator (/+const+/ xcb_get_modifier_mapping_reply_t *R  /**< */);


/*****************************************************************************
 **
 ** xcb_get_modifier_mapping_reply_t * xcb_get_modifier_mapping_reply
 **
 ** @param xcb_connection_t                   *c
 ** @param xcb_get_modifier_mapping_cookie_t   cookie
 ** @param xcb_generic_error_t               **e
 ** @returns xcb_get_modifier_mapping_reply_t *
 **
 *****************************************************************************/

extern(C) xcb_get_modifier_mapping_reply_t *
xcb_get_modifier_mapping_reply (xcb_connection_t                   *c  /**< */,
                                xcb_get_modifier_mapping_cookie_t   cookie  /**< */,
                                xcb_generic_error_t               **e  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_no_operation_checked
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_no_operation_checked (xcb_connection_t *c  /**< */);


/*****************************************************************************
 **
 ** xcb_void_cookie_t xcb_no_operation
 **
 ** @param xcb_connection_t *c
 ** @returns xcb_void_cookie_t
 **
 *****************************************************************************/

extern(C) xcb_void_cookie_t
xcb_no_operation (xcb_connection_t *c  /**< */);



/**
 * @}
 */
