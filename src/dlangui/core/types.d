module dlangui.core.types;

public struct Point {
    int x;
    int y;
    public this(int x0, int y0) {
        x = x0;
        y = y0;
    }
}

public struct Rect {
    public int left;
    public int top;
    public int right;
    public int bottom;
    public this(int x0, int y0, int x1, int y1) {
        left = x0;
        top = y0;
        right = x1;
        bottom = y1;
    }
    public bool empty() {
        return right <= left || bottom <= top;
    }
    public bool intersect(Rect rc) {
        if (left < rc.left)
            left = rc.left;
        if (top < rc.top)
            top = rc.top;
        if (right > rc.right)
            right = rc.right;
        if (bottom > rc.bottom)
            bottom = rc.bottom;
        return right > left && bottom > top;
    }
}
