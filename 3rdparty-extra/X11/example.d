module std.c.linux.X11.example;

/* this an example for this binding*/
/* please read README file before */

/* compile with: dmd example.d Xlib.d X.d  -L-lX11*/

import std.c.linux.X11.Xlib;

version(Tango)
{
    import tango.stdc.stdio;
}
else
{
    import std.c.stdio;
}

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
    XStoreName(display,window,"Hello Window\0"); //set window name , don't forget /0 term char !
    XFlush(display); // flush X server

    //wait for a enter pressed (in fact you need to wait for MapNotify event before drawing...)
    printf("press enter to show window content\0");
    getchar();

    XGCValues values;
    values.foreground=0xFFFFFF;
    values.background=0x00FF00;
    GC gc=XCreateGC(display,window,GCMask.GCForeground | GCMask.GCBackground,&values); //create zone for drawing
    char* chaine="hello world";
    XDrawString(display, window,gc, 30,50,chaine, 11); //draw string
    XDrawRectangle(display,window,gc,20,20,150,50); //draw rectangle
    XFlush(display); //flush X server
    printf("press enter to close program\0");
    getchar(); //wait for a enter pressed to close program
    XUnmapWindow(display, window); // unmap the window
    XDestroyWindow(display, window); //destroy the window
    XCloseDisplay(display); //close the display
	return 0;
};
