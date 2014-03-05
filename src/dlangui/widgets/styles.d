module dlangui.widgets.styles;

enum Align : ubyte {
    Unspecified = 0,
    Left = 1,
    Right = 2,
    HCenter = Left | Right,
    Top = 4,
    Bottom = 8,
    VCenter = Top | Bottom,
    Center = VCenter | HCenter
}
