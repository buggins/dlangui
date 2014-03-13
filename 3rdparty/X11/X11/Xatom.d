/* 	Xlib binding for D language
	Copyright 2010 Adam Cigánek <adam.ciganek@gmail.com>
	
	This file is free software, please read COPYING file for more informations
*/

module X11.Xatom;

import X11.X;

immutable Atom XA_PRIMARY = 1;
immutable Atom XA_SECONDARY = 2;
immutable Atom XA_ARC = 3;
immutable Atom XA_ATOM = 4;
immutable Atom XA_BITMAP = 5;
immutable Atom XA_CARDINAL = 6;
immutable Atom XA_COLORMAP = 7;
immutable Atom XA_CURSOR = 8;
immutable Atom XA_CUT_BUFFER0 = 9;
immutable Atom XA_CUT_BUFFER1 = 10;
immutable Atom XA_CUT_BUFFER2 = 11;
immutable Atom XA_CUT_BUFFER3 = 12;
immutable Atom XA_CUT_BUFFER4 = 13;
immutable Atom XA_CUT_BUFFER5 = 14;
immutable Atom XA_CUT_BUFFER6 = 15;
immutable Atom XA_CUT_BUFFER7 = 16;
immutable Atom XA_DRAWABLE = 17;
immutable Atom XA_FONT = 18;
immutable Atom XA_INTEGER = 19;
immutable Atom XA_PIXMAP = 20;
immutable Atom XA_POINT = 21;
immutable Atom XA_RECTANGLE = 22;
immutable Atom XA_RESOURCE_MANAGER = 23;
immutable Atom XA_RGB_COLOR_MAP = 24;
immutable Atom XA_RGB_BEST_MAP = 25;
immutable Atom XA_RGB_BLUE_MAP = 26;
immutable Atom XA_RGB_DEFAULT_MAP = 27;
immutable Atom XA_RGB_GRAY_MAP = 28;
immutable Atom XA_RGB_GREEN_MAP = 29;
immutable Atom XA_RGB_RED_MAP = 30;
immutable Atom XA_STRING = 31;
immutable Atom XA_VISUALID = 32;
immutable Atom XA_WINDOW = 33;
immutable Atom XA_WM_COMMAND = 34;
immutable Atom XA_WM_HINTS = 35;
immutable Atom XA_WM_CLIENT_MACHINE = 36;
immutable Atom XA_WM_ICON_NAME = 37;
immutable Atom XA_WM_ICON_SIZE = 38;
immutable Atom XA_WM_NAME = 39;
immutable Atom XA_WM_NORMAL_HINTS = 40;
immutable Atom XA_WM_SIZE_HINTS = 41;
immutable Atom XA_WM_ZOOM_HINTS = 42;
immutable Atom XA_MIN_SPACE = 43;
immutable Atom XA_NORM_SPACE = 44;
immutable Atom XA_MAX_SPACE = 45;
immutable Atom XA_END_SPACE = 46;
immutable Atom XA_SUPERSCRIPT_X = 47;
immutable Atom XA_SUPERSCRIPT_Y = 48;
immutable Atom XA_SUBSCRIPT_X = 49;
immutable Atom XA_SUBSCRIPT_Y = 50;
immutable Atom XA_UNDERLINE_POSITION = 51;
immutable Atom XA_UNDERLINE_THICKNESS = 52;
immutable Atom XA_STRIKEOUT_ASCENT = 53;
immutable Atom XA_STRIKEOUT_DESCENT = 54;
immutable Atom XA_ITALIC_ANGLE = 55;
immutable Atom XA_X_HEIGHT = 56;
immutable Atom XA_QUAD_WIDTH = 57;
immutable Atom XA_WEIGHT = 58;
immutable Atom XA_POINT_SIZE = 59;
immutable Atom XA_RESOLUTION = 60;
immutable Atom XA_COPYRIGHT = 61;
immutable Atom XA_NOTICE = 62;
immutable Atom XA_FONT_NAME = 63;
immutable Atom XA_FAMILY_NAME = 64;
immutable Atom XA_FULL_NAME = 65;
immutable Atom XA_CAP_HEIGHT = 66;
immutable Atom XA_WM_CLASS = 67;
immutable Atom XA_WM_TRANSIENT_FOR = 68;

immutable Atom XA_LAST_PREDEFINED = 68;
