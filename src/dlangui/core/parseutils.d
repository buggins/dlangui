module dlangui.core.parseutils;

long parseLong(inout string v, long defValue = 0) {
    int len = cast(int)v.length;
    if (len == 0)
        return defValue;
    int sign = 1;
    long value = 0;
    int digits = 0;
    foreach(i; 0 .. len) {
        char ch = v[i];
        if (ch == '-') {
            if (i != 0)
                return defValue;
            sign = -1;
        } else if (ch >= '0' && ch <= '9') {
            digits++;
            value = value * 10 + (ch - '0');
        } else {
            return defValue;
        }
    }
    return digits > 0 ? (sign > 0 ? value : -value) : defValue;
}

ulong parseULong(inout string v, ulong defValue = 0) {
    int len = cast(int)v.length;
    if (len == 0)
        return defValue;
    ulong value = 0;
    int digits = 0;
    foreach(i; 0 .. len) {
        char ch = v[i];
        if (ch >= '0' && ch <= '9') {
            digits++;
            value = value * 10 + (ch - '0');
        } else {
            return defValue;
        }
    }
    return digits > 0 ? value : defValue;
}
