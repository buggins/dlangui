// This an example for the X11 binding.
//
// Build/run with rdmd:
//   rdmd -I.. simple.d


module simple;

import X11.Xlib;
import std.c.stdio;
import std.string;

int main(char[][] args)
{
	Display* display = XOpenDisplay(null);	//Open default display
	Window window = XCreateSimpleWindow(	//create a simple windows
        display,                           		// display
        DefaultRootWindow(display),        		// parent window
        0, 0, 200, 100,                    		// x, y, w, h
        0,0x0,0x000000FF                   		// border_width,boder_color,back_color
        );
    XMapWindow(display, window); //map the window
    XRaiseWindow(display, window); //show the window
    XStoreName(display,window, cast(char*) "Hello Window"); //set window name
    XFlush(display); // flush X server

    //wait for a enter pressed (in fact you need to wait for MapNotify event before drawing...)
    printf("press enter to show window content\0");
    getchar();

    XGCValues values;
    values.foreground=0xFFFFFF;
    values.background=0x00FF00;
    GC gc=XCreateGC(display,window, 3<<3 , &values); //create zone for drawing
    XDrawString(display, window,gc, 30,50, cast(char*)"hello world", 11); //draw string
    XDrawRectangle(display,window,gc,20,20,150,50); //draw rectangle
    XFlush(display); //flush X server
    printf("press enter to close program\0");
    getchar(); //wait for a enter pressed to close program
    XUnmapWindow(display, window); // unmap the window
    XDestroyWindow(display, window); //destroy the window
    XCloseDisplay(display); //close the display
	return 0;
};
