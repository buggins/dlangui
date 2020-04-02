module dom.cssparser;

/**
Before sending the input stream to the tokenizer, implementations must make the following code point substitutions:
    * Replace any U+000D CARRIAGE RETURN (CR) code point, U+000C FORM FEED (FF) code point, or pairs of U+000D CARRIAGE RETURN (CR) followed by U+000A LINE FEED (LF) by a single U+000A LINE FEED (LF) code point.
    * Replace any U+0000 NULL code point with U+FFFD REPLACEMENT CHARACTER.
*/
char[] preProcessCSS(char[] src) {
    char[] res;
    res.assumeSafeAppend();
    int p = 0;
    bool last0D = false;
    foreach(ch; src) {
        if (ch == 0) {
            // append U+FFFD 1110xxxx 10xxxxxx 10xxxxxx == EF BF BD
            res ~= 0xEF;
            res ~= 0xBF;
            res ~= 0xBD;
        } else if (ch == 0x0D || ch == 0x0C) {
            res ~= 0x0A;
        } else if (ch == 0x0A) {
            if (!last0D)
                res ~= 0x0A;
        } else {
            res ~= ch;
        }
        last0D = (ch == 0x0D);
    }
    return res;
}

struct CSSImportRule {
    /// start position - byte offset of @import
    size_t startPos;
    /// end position - byte offset of next char after closing ';'
    size_t endPos;
    /// url of CSS to import
    string url;
    /// content of downloaded URL to apply in place of rule
    string content;
}

enum CSSTokenType : ubyte {
    eof, // end of file
    delim, // delimiter (may be unknown token or error)
    comment, /* some comment */
    //newline, // any of \n \r\n \r \f
    whitespace, // space, \t, newline
    ident, // identifier
    url, // url()
    badUrl, // url() which is bad
    func, // function(
    str, // string '' or ""
    badStr, // string '' or "" ended with newline character
    hashToken, // #
    prefixMatch, // ^=
    suffixMatch, // $=
    substringMatch, // *=
    includeMatch, // ~=
    dashMatch, // |=
    column, // ||
    parentOpen, // (
    parentClose, // )
    squareOpen, // [
    squareClose, // ]
    curlyOpen, // {
    curlyClose, // }
    comma, // ,
    colon, // :
    semicolon, // ;
    number, // +12345.324e-3
    dimension, // 1.23px  -- number with dimension
    cdo, // <!--
    cdc, // -->
    atKeyword, // @someKeyword -- tokenText will contain keyword w/o @ prefix
    unicodeRange, // U+XXX-XXX
}

struct CSSToken {
    CSSTokenType type;
    string text;
    string dimensionUnit;
    union {
        struct {
            long intValue = 0; /// for number and dimension
            double doubleValue = 0; /// for number and dimension
            bool typeFlagInteger; /// for number and dimension - true if number is integer, false if double
        }
        struct {
            uint unicodeRangeStart; /// for unicodeRange (initialized to 0 via intValue=0)
            uint unicodeRangeEnd; /// for unicodeRange (initialized to 0 via intValue=0)
        }
        bool typeFlagId; // true if identifier is valid ID
    }
}

int decodeHexDigit(char ch) {
    if (ch >= 'a' && ch <= 'f')
        return (ch - 'a') + 10;
    if (ch >= 'A' && ch <= 'F')
        return (ch - 'A') + 10;
    if (ch >= '0' && ch <= '9')
        return (ch - '0');
    return -1;
}

bool isCSSWhiteSpaceChar(char ch) {
    return ch == ' ' || ch == '\t' || ch == 0x0C || ch == 0x0D || ch == 0x0A;
}

// returns true if code point is letter, underscore or non-ascii
bool isCSSNameStart(char ch) {
    return ((ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z') || (ch & 0x80) > 0 || ch == '_');
}

bool isCSSNonPrintable(char ch) {
    if (ch >= 0 && ch <= 8)
        return true;
    if (ch == 0x0B || ch == 0x7F)
        return true;
    if (ch >= 0x0E && ch <= 0x1F)
        return true;
    return false;
}
// This section describes how to check if two code points are a valid escape
bool isCSSValidEscSequence(char ch, char ch2) {
    //If the first code point is not U+005D REVERSE SOLIDUS (\), return false.
    if (ch != '\\')
        return false;
    if (ch2 == '\r' || ch2 == '\n')
        return false;
    return true;
}

struct CSSTokenizer {
    /// CSS source code (utf-8)
    char[] src;
    /// current token type
    CSSTokenType tokenType;
    /// current token start byte offset
    size_t tokenStart;
    /// current token end byte offset
    size_t tokenEnd;
    char[] tokenText;
    char[] dimensionUnit;
    bool tokenTypeFlagId; // true if identifier is valid ID
    bool tokenTypeInteger; // for number and dimension - true if number is integer, false if double
    long tokenIntValue; // for number and dimension
    double tokenDoubleValue; // for number and dimension
    uint unicodeRangeStart = 0; // for unicodeRange
    uint unicodeRangeEnd = 0; // for unicodeRange
    void start(string _src) {
        src = _src.dup;
        tokenStart = tokenEnd = 0;
        tokenText.length = 1000;
        tokenText.assumeSafeAppend;
        dimensionUnit.length = 1000;
        dimensionUnit.assumeSafeAppend;
    }
    bool eof() {
        return tokenEnd >= src.length;
    }
    /**
      Skip whitespace; return true if at least one whitespace char is skipped; move tokenEnd position
      tokenType will be set to newline if any newline character found, otherwise - to whitespace
    */
    bool skipWhiteSpace() {
        bool skipped = false;
        tokenType = CSSTokenType.whitespace;
        for (;;) {
            if (tokenEnd >= src.length) {
                return false;
            }
            char ch = src.ptr[tokenEnd];
            if (ch == '\r' || ch == '\n' || ch == 0x0C) {
                tokenEnd++;
                //tokenType = CSSTokenType.newline;
                skipped = true;
            } if (ch == ' ' || ch == '\t') {
                tokenEnd++;
                skipped = true;
            } else if (ch == 0xEF && tokenEnd  + 2 < src.length && src.ptr[tokenEnd + 1] == 0xBF && src.ptr[tokenEnd + 2] == 0xBD) {
                // U+FFFD 1110xxxx 10xxxxxx 10xxxxxx == EF BF BD
                tokenEnd++;
                skipped = true;
            } else {
                return skipped;
            }
        }
    }

    private dchar parseEscape(ref size_t p) {
        size_t pos = p + 1;
        if (pos >= src.length)
            return cast(dchar)0xFFFFFFFF; // out of bounds
        char ch = src.ptr[pos];
        pos++;
        if (ch == '\r' || ch == '\n' || ch == 0x0C)
            return cast(dchar)0xFFFFFFFF; // unexpected newline: invalid esc sequence
        int hex = decodeHexDigit(ch);
        if (hex >= 0) {
            dchar res = hex;
            int count = 1;
            while (count < 6) {
                if (pos >= src.length)
                    break;
                ch = src.ptr[pos];
                hex = decodeHexDigit(ch);
                if (hex < 0)
                    break;
                res = (res << 4) | hex;
                pos++;
                count++;
            }
            if (isCSSWhiteSpaceChar(ch))
                pos++;
            p = pos;
            return res;
        } else {
            // not a hex: one character is escaped
            p = pos;
            return ch;
        }
    }
    private void appendEscapedIdentChar(dchar ch) {
        if (ch < 0x80) {
            // put as is
            tokenText ~= cast(char)ch;
        } else {
            // UTF-8 encode
            import std.utf : encode, isValidDchar;
            char[4] buf;
            size_t chars = isValidDchar(ch) ? encode(buf, ch) : 0;
            if (chars)
                tokenText ~= buf[0 .. chars];
            else
                tokenText ~= '?'; // replacement for invalid character
        }
    }

    /** Consume identifier at current position, append it to tokenText */
    bool consumeIdent(ref char[] tokenText) {
        size_t p = tokenEnd;
        char ch = src.ptr[p];
        bool hasHyphen = false;
        if (ch == '-') {
            p++;
            if (p >= src.length)
                return false; // eof
            hasHyphen = true;
            ch = src.ptr[p];
        }
        if ((ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z') || ch == '_' || ch >= 0x80) {
            if (hasHyphen)
                tokenText ~= '-';
            tokenText ~= ch;
            p++;
        } else if (ch == '\\') {
            dchar esc = parseEscape(p);
            if (esc == 0xFFFFFFFF)
                return false; // invalid esc
            // encode to UTF-8
            appendEscapedIdentChar(esc);
        } else {
            return false;
        }
        for (;;) {
            if (p >= src.length)
                break;
            ch = src.ptr[p];
            if ((ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z')  || (ch >= '0' && ch <= '9') || ch == '_'  || ch == '-' || ch >= 0x80) {
                tokenText ~= ch;
                p++;
            } else if (ch == '\\') {
                dchar esc = parseEscape(p);
                if (esc == 0xFFFFFFFF)
                    break; // invalid esc
                // encode to UTF-8
                appendEscapedIdentChar(esc);
            } else {
                break;
            }
        }
        tokenEnd = p;
        return true;
    }

    /**
      Parse identifier.
      Returns true if identifier is parsed. tokenText will contain identifier text.
    */
    bool parseIdent() {
        if (!isIdentStart(tokenEnd))
            return false;
        if (consumeIdent(tokenText)) {
            tokenType = tokenType.ident;
            return true;
        }
        return false;
    }

    /** returns true if current tokenEnd position is identifier start */
    bool isIdentStart(size_t p) {
        if (p >= src.length)
            return false;
        char ch = src.ptr[p];
        if (isCSSNameStart(ch))
            return true;
        if (ch == '-') {
            //If the second code point is a name-start code point or the second and third code points are a valid escape, return true. Otherwise, return false.
            p++;
            if (p >= src.length)
                return false;
            ch = src.ptr[p];
            if (isCSSNameStart(ch))
                return true;
        }
        if (ch == '\\') {
            p++;
            if (p >= src.length)
                return false;
            char ch2 = src.ptr[p];
            return isCSSValidEscSequence(ch, ch2);
        }
        return false;
    }

    /**
    Parse identifier.
    Returns true if identifier is parsed. tokenText will contain identifier text.
    */
    bool parseNumber() {
        tokenTypeInteger = true;
        tokenIntValue = 0;
        tokenDoubleValue = 0;
        size_t p = tokenEnd;
        char ch = src.ptr[p];
        int numberSign = 1;
        int exponentSign = 1;
        bool hasPoint = false;
        ulong intValue = 0;
        ulong afterPointValue = 0;
        ulong exponentValue = 0;
        int beforePointDigits = 0;
        int afterPointDigits = 0;
        int exponentDigits = 0;
        if (ch == '+' || ch == '-') {
            if (ch == '-')
                numberSign = -1;
            tokenText ~= ch;
            p++;
            if (p >= src.length)
                return false; // eof
            ch = src.ptr[p];
        }
        // append digits before point
        while (ch >= '0' && ch <= '9') {
            tokenText ~= ch;
            intValue = intValue * 10 + (ch - '0');
            beforePointDigits++;
            p++;
            if (p >= src.length) {
                ch = 0;
                break;
            }
            ch = src.ptr[p];
        }
        // check for point
        if (ch == '.') {
            hasPoint = true;
            tokenText ~= ch;
            p++;
            if (p >= src.length)
                return false; // eof
            ch = src.ptr[p];
        }
        // append digits after point
        while (ch >= '0' && ch <= '9') {
            tokenText ~= ch;
            afterPointValue = afterPointValue * 10 + (ch - '0');
            afterPointDigits++;
            p++;
            if (p >= src.length) {
                ch = 0;
                break;
            }
            ch = src.ptr[p];
        }
        if (!beforePointDigits && !afterPointDigits) {
            if (tokenText.length)
                tokenText.length = 0;
            return false; // not a number
        }
        if (ch == 'e' || ch == 'E') {
            char nextCh = p + 1 < src.length ? src.ptr[p + 1] : 0;
            char nextCh2 = p + 2 < src.length ? src.ptr[p + 2] : 0;
            int skip = 1;
            if (nextCh == '+' || nextCh == '-') {
                if (nextCh == '-')
                    exponentSign = -1;
                skip = 2;
                nextCh = nextCh2;
            }
            if (nextCh >= '0' && nextCh <= '9') {
                tokenText ~= src.ptr[p .. p + skip];
                p += skip;
                ch = nextCh;
                // append exponent digits
                while (ch >= '0' && ch <= '9') {
                    tokenText ~= ch;
                    exponentValue = exponentValue * 10 + (ch - '0');
                    exponentDigits++;
                    p++;
                    if (p >= src.length) {
                        ch = 0;
                        break;
                    }
                    ch = src.ptr[p];
                }
            }
        }
        tokenType = CSSTokenType.number;
        tokenEnd = p;
        if (exponentDigits || afterPointDigits) {
            // parsed floating point
            tokenDoubleValue = cast(long)intValue;
            if (afterPointDigits) {
                long divider = 1;
                for (int i = 0; i < afterPointDigits; i++)
                    divider *= 10;
                tokenDoubleValue += afterPointValue / cast(double)divider;
            }
            if (numberSign < 0)
                tokenDoubleValue = -tokenDoubleValue;
            if (exponentDigits) {
                import std.math : pow;
                double exponent = (cast(long)exponentValue * exponentSign);
                tokenDoubleValue = tokenDoubleValue * pow(10, exponent);
            }
            tokenIntValue = cast(long)tokenDoubleValue;
        } else {
            // parsed integer
            tokenIntValue = cast(long)intValue;
            if (numberSign < 0)
                tokenIntValue = -tokenIntValue;
            tokenDoubleValue = tokenIntValue;
        }
        dimensionUnit.length = 0;
        if (isIdentStart(tokenEnd)) {
            tokenType = CSSTokenType.dimension;
            consumeIdent(dimensionUnit);
        }
        return true;
    }

    bool parseString(char quotationChar) {
        tokenType = CSSTokenType.str;
        // skip first delimiter ' or "
        size_t p = tokenEnd + 1;
        for (;;) {
            if (p >= src.length) {
                // unexpected end of file
                tokenEnd = p;
                return true;
            }
            char ch = src.ptr[p];
            if (ch == '\r' || ch == '\n') {
                tokenType = CSSTokenType.badStr;
                tokenEnd = p - 1;
                return true;
            } else if (ch == quotationChar) {
                // end of string
                tokenEnd = p + 1;
                return true;
            } else if (ch == '\\') {
                if (p + 1 >= src.length) {
                    // unexpected end of file
                    tokenEnd = p;
                    return true;
                }
                ch = src.ptr[p + 1];
                if (ch == '\r' || ch == '\n') {
                    // \ NEWLINE
                    //tokenText ~= 0x0A;
                    p++;
                } else {
                    dchar esc = parseEscape(p);
                    if (esc == 0xFFFFFFFF) {
                        esc = '?'; // replace invalid code point
                        p++;
                    }
                    // encode to UTF-8
                    appendEscapedIdentChar(esc);
                }
            } else {
                // normal character
                tokenText ~= ch;
                p++;
            }
        }
    }
    CSSTokenType emitDelimToken() {
        import std.utf : stride, UTFException;
        try {
            uint len = stride(src[tokenStart .. $]);
            tokenEnd = tokenStart + len;
        } catch (UTFException e) {
            tokenEnd = tokenStart + 1;
        }
        tokenText ~= src[tokenStart .. tokenEnd];
        tokenType = CSSTokenType.delim;
        return tokenType;
    }
    // #token
    CSSTokenType parseHashToken() {
        tokenTypeFlagId = false;
        tokenEnd++;
        // set tokenTypeFlagId flag
        if (parseIdent()) {
            tokenType = CSSTokenType.hashToken;
            if (tokenText[0] < '0' || tokenText[0] > '9')
                tokenTypeFlagId = true; // is valid ID
            return tokenType;
        }
        // invalid ident
        return emitDelimToken();
    }
    /// current chars are /*
    CSSTokenType parseComment() {
        size_t p = tokenEnd + 2; // skip /*
        while (p < src.length) {
            char ch = src.ptr[p];
            char ch2 = p + 1 < src.length ? src.ptr[p + 1] : 0;
            if (ch == '*' && ch2 == '/') {
                p += 2;
                break;
            }
            p++;
        }
        tokenEnd = p;
        tokenType = CSSTokenType.comment;
        return tokenType;
    }
    /// current chars are U+ or u+ followed by hex digit or ?
    CSSTokenType parseUnicodeRangeToken() {
        unicodeRangeStart = 0;
        unicodeRangeEnd = 0;
        size_t p = tokenEnd + 2; // skip U+
        // now we have hex digit or ?
        int hexCount = 0;
        uint hexNumber = 0;
        int questionCount = 0;
        // consume hex digits
        while (p < src.length) {
            char ch = src.ptr[p];
            int digit = decodeHexDigit(ch);
            if (digit < 0)
                break;
            hexCount++;
            hexNumber = (hexNumber << 4) | digit;
            p++;
            if (hexCount >= 6)
                break;
        }
        // consume question marks
        while (p < src.length && questionCount + hexCount < 6) {
            char ch = src.ptr[p];
            if (ch != '?')
                break;
            questionCount++;
            p++;
        }
        if (questionCount) {
            int shift = 4 * questionCount;
            unicodeRangeStart = hexNumber << shift;
            unicodeRangeEnd = unicodeRangeStart + ((1 << shift) - 1);
        } else {
            unicodeRangeStart = hexNumber;
            char ch = p < src.length ? src.ptr[p] : 0;
            char ch2 = p + 1 < src.length ? src.ptr[p + 1] : 0;
            int digit = decodeHexDigit(ch2);
            if (ch == '-' && digit >= 0) {
                p += 2; // skip - and first digit
                hexCount = 1;
                hexNumber = digit;
                while (p < src.length) {
                    ch = src.ptr[p];
                    digit = decodeHexDigit(ch);
                    if (digit < 0)
                        break;
                    hexCount++;
                    hexNumber = (hexNumber << 4) | digit;
                    p++;
                    if (hexCount >= 6)
                        break;
                }
                unicodeRangeEnd = hexNumber;
            } else {
                unicodeRangeEnd = unicodeRangeStart;
            }
        }
        tokenEnd = p;
        tokenType = CSSTokenType.unicodeRange;
        return tokenType;
    }
    /// emit single char token like () {} [] : ;
    CSSTokenType emitSingleCharToken(CSSTokenType type) {
        tokenType = type;
        tokenEnd = tokenStart + 1;
        tokenText ~= src[tokenStart];
        return type;
    }
    /// emit double char token like $= *=
    CSSTokenType emitDoubleCharToken(CSSTokenType type) {
        tokenType = type;
        tokenEnd = tokenStart + 2;
        tokenText ~= src[tokenStart .. tokenStart + 2];
        return type;
    }
    void consumeBadUrl() {
        for (;;) {
            char ch = tokenEnd < src.length ? src.ptr[tokenEnd] : 0;
            char ch2 = tokenEnd + 1 < src.length ? src.ptr[tokenEnd + 1] : 0;
            if (ch == ')' || ch == 0) {
                if (ch == ')')
                    tokenEnd++;
                break;
            }
            if (isCSSValidEscSequence(ch, ch2)) {
                parseEscape(tokenEnd);
            }
            tokenEnd++;
        }
        tokenType = CSSTokenType.badUrl;
    }
    // Current position is after url(
    void parseUrlToken() {
        tokenText.length = 0;
        skipWhiteSpace();
        if (tokenEnd >= src.length)
            return;
        char ch = src.ptr[tokenEnd];
        if (ch == '\'' || ch == '\"') {
            if (parseString(ch)) {
                skipWhiteSpace();
                ch = tokenEnd < src.length ? src.ptr[tokenEnd] : 0;
                if (ch == ')' || ch == 0) {
                    // valid URL token
                    if (ch == ')')
                        tokenEnd++;
                    tokenType = CSSTokenType.url;
                    return;
                }
            }
            // bad url
            consumeBadUrl();
            return;
        }
        // not quoted
        for (;;) {
            if (skipWhiteSpace()) {
                ch = tokenEnd < src.length ? src.ptr[tokenEnd] : 0;
                if (ch == ')' || ch == 0) {
                    if (ch == ')')
                        tokenEnd++;
                    tokenType = CSSTokenType.url;
                    return;
                }
                consumeBadUrl();
                return;
            }
            ch = tokenEnd < src.length ? src.ptr[tokenEnd] : 0;
            char ch2 = tokenEnd + 1 < src.length ? src.ptr[tokenEnd + 1] : 0;
            if (ch == ')' || ch == 0) {
                if (ch == ')')
                    tokenEnd++;
                tokenType = CSSTokenType.url;
                return;
            }
            if (ch == '(' || ch == '\'' || ch == '\"' || isCSSNonPrintable(ch)) {
                consumeBadUrl();
                return;
            }
            if (ch == '\\') {
                if (isCSSValidEscSequence(ch, ch2)) {
                    dchar esc = parseEscape(tokenEnd);
                    appendEscapedIdentChar(ch);
                } else {
                    consumeBadUrl();
                    return;
                }
            }
            tokenText ~= ch;
            tokenEnd++;
        }
    }
    CSSTokenType next() {
        // move beginning of token
        tokenStart = tokenEnd;
        tokenText.length = 0;
        // check for whitespace
        if (skipWhiteSpace())
            return tokenType; // whitespace or newline token
        // check for eof
        if (tokenEnd >= src.length)
            return CSSTokenType.eof;
        char ch = src.ptr[tokenEnd];
        char nextCh = tokenEnd + 1 < src.length ? src.ptr[tokenEnd + 1] : 0;
        if (ch == '\"' || ch == '\'') {
            parseString(ch);
            return tokenType;
        }
        if (ch == '#') {
            return parseHashToken();
        }
        if (ch == '$') {
            if (nextCh == '=') {
                return emitDoubleCharToken(CSSTokenType.suffixMatch);
            } else {
                return emitDelimToken();
            }
        }
        if (ch == '^') {
            if (nextCh == '=') {
                return emitDoubleCharToken(CSSTokenType.prefixMatch);
            } else {
                return emitDelimToken();
            }
        }
        if (ch == '(')
            return emitSingleCharToken(CSSTokenType.parentOpen);
        if (ch == ')')
            return emitSingleCharToken(CSSTokenType.parentClose);
        if (ch == '[')
            return emitSingleCharToken(CSSTokenType.squareOpen);
        if (ch == ']')
            return emitSingleCharToken(CSSTokenType.squareClose);
        if (ch == '{')
            return emitSingleCharToken(CSSTokenType.curlyOpen);
        if (ch == '}')
            return emitSingleCharToken(CSSTokenType.curlyClose);
        if (ch == ',')
            return emitSingleCharToken(CSSTokenType.comma);
        if (ch == ':')
            return emitSingleCharToken(CSSTokenType.colon);
        if (ch == ';')
            return emitSingleCharToken(CSSTokenType.semicolon);
        if (ch == '*') {
            if (nextCh == '=') {
                return emitDoubleCharToken(CSSTokenType.substringMatch);
            } else {
                return emitDelimToken();
            }
        }
        if (ch == '~') {
            if (nextCh == '=') {
                return emitDoubleCharToken(CSSTokenType.includeMatch);
            } else {
                return emitDelimToken();
            }
        }
        if (ch == '|') {
            if (nextCh == '=') {
                return emitDoubleCharToken(CSSTokenType.dashMatch);
            } else if (nextCh == '|') {
                return emitDoubleCharToken(CSSTokenType.column);
            } else {
                return emitDelimToken();
            }
        }
        if (ch == '/') {
            if (nextCh == '*') {
                return parseComment();
            } else {
                return emitDelimToken();
            }
        }
        char nextCh2 = tokenEnd + 2 < src.length ? src.ptr[tokenEnd + 2] : 0;
        if (ch == 'u' || ch == 'U') {
            if (nextCh == '+' && (decodeHexDigit(nextCh2) >= 0 || nextCh2 == '?')) {
                return parseUnicodeRangeToken();
            }
        }
        if (parseNumber())
            return tokenType;
        if (parseIdent()) {
            ch = tokenEnd < src.length ? src.ptr[tokenEnd] : 0;
            if (ch == '(') {
                tokenEnd++;
                import std.uni : icmp;
                if (tokenText.length == 3 && icmp(tokenText, "url") == 0) {
                    // parse URL function
                    parseUrlToken();
                } else {
                    tokenType = CSSTokenType.func;
                }
            }
            return tokenType;
        }
        if (ch == '-') {
            if (nextCh == '-' && nextCh2 == '>') {
                tokenEnd = tokenStart + 3;
                tokenType = CSSTokenType.cdc;
                tokenText ~= src[tokenStart .. tokenEnd];
                return tokenType;
            }
            return emitDelimToken();
        }
        if (ch == '<') {
            char nextCh3 = tokenEnd + 3 < src.length ? src.ptr[tokenEnd + 3] : 0;
            if (nextCh == '!' && nextCh2 == '-' && nextCh3 == '-') {
                tokenEnd = tokenStart + 4;
                tokenType = CSSTokenType.cdo;
                tokenText ~= src[tokenStart .. tokenEnd];
                return tokenType;
            }
            return emitDelimToken();
        }
        if (ch == '@') {
            if (isIdentStart(tokenEnd + 1)) {
                tokenEnd++;
                parseIdent();
                tokenType = CSSTokenType.atKeyword;
                return tokenType;
            }
            return emitDelimToken();
        }
        return emitDelimToken();
    }
    /// same as next() but returns filled CSSToken struct
    CSSToken nextToken() {
        CSSToken res;
        res.type = next();
        if (res.type == CSSTokenType.str || res.type == CSSTokenType.ident || res.type == CSSTokenType.atKeyword || res.type == CSSTokenType.url || res.type == CSSTokenType.func) {
            if (tokenText.length)
                res.text = tokenText.dup;
        }
        if (res.type == CSSTokenType.dimension && dimensionUnit.length)
            res.dimensionUnit = dimensionUnit.dup;
        if (res.type == CSSTokenType.dimension || res.type == CSSTokenType.number) {
            res.doubleValue = tokenDoubleValue;
            res.intValue = tokenIntValue;
            res.typeFlagInteger = tokenTypeInteger;
        } else if (res.type == CSSTokenType.ident) {
            res.typeFlagId = tokenTypeFlagId;
        } else if (res.type == CSSTokenType.unicodeRange) {
            res.unicodeRangeStart = unicodeRangeStart;
            res.unicodeRangeEnd = unicodeRangeEnd;
        }
        return res;
    }
}

unittest {
    CSSTokenizer tokenizer;
    tokenizer.start("ident-1{ }\n#id\n'blabla' \"bla bla 2\" -ident2*=12345 -.234e+5 "
                    ~ "1.23px/* some comment */U+123?!"
                    ~"url(   'text.css'  )url(bad url)functionName()url( bla )"
                    ~"'\\30 \\31'");
    assert(tokenizer.next() == CSSTokenType.ident);
    assert(tokenizer.tokenText == "ident-1");
    assert(tokenizer.next() == CSSTokenType.curlyOpen);
    assert(tokenizer.next() == CSSTokenType.whitespace);
    assert(tokenizer.next() == CSSTokenType.curlyClose);
    assert(tokenizer.next() == CSSTokenType.whitespace); //newline
    assert(tokenizer.next() == CSSTokenType.hashToken);
    assert(tokenizer.tokenText == "id");
    assert(tokenizer.tokenTypeFlagId == true);
    assert(tokenizer.next() == CSSTokenType.whitespace); //newline
    assert(tokenizer.next() == CSSTokenType.str);
    assert(tokenizer.tokenText == "blabla");
    assert(tokenizer.next() == CSSTokenType.whitespace);
    assert(tokenizer.next() == CSSTokenType.str);
    assert(tokenizer.tokenText == "bla bla 2");
    assert(tokenizer.next() == CSSTokenType.whitespace);
    assert(tokenizer.next() == CSSTokenType.ident);
    assert(tokenizer.tokenText == "-ident2");
    assert(tokenizer.next() == CSSTokenType.substringMatch);
    assert(tokenizer.next() == CSSTokenType.number);
    assert(tokenizer.tokenText == "12345");
    assert(tokenizer.tokenIntValue == 12345);
    assert(tokenizer.next() == CSSTokenType.whitespace);
    assert(tokenizer.next() == CSSTokenType.number);
    assert(tokenizer.tokenText == "-.234e+5");
    assert(tokenizer.tokenIntValue == -23400);
    assert(tokenizer.tokenDoubleValue == -.234e+5);
    assert(tokenizer.next() == CSSTokenType.whitespace);
    // next line
    assert(tokenizer.next() == CSSTokenType.dimension);
    assert(tokenizer.tokenText == "1.23");
    assert(tokenizer.tokenIntValue == 1);
    assert(tokenizer.tokenDoubleValue == 1.23);
    assert(tokenizer.dimensionUnit == "px");
    assert(tokenizer.next() == CSSTokenType.comment);
    assert(tokenizer.next() == CSSTokenType.unicodeRange);
    assert(tokenizer.unicodeRangeStart == 0x1230 && tokenizer.unicodeRangeEnd == 0x123F);
    assert(tokenizer.next() == CSSTokenType.delim);
    assert(tokenizer.tokenText == "!");
    // next line
    assert(tokenizer.next() == CSSTokenType.url);
    assert(tokenizer.tokenText == "text.css");
    assert(tokenizer.next() == CSSTokenType.badUrl);
    assert(tokenizer.next() == CSSTokenType.func);
    assert(tokenizer.tokenText == "functionName");
    assert(tokenizer.next() == CSSTokenType.parentClose);
    assert(tokenizer.next() == CSSTokenType.url);
    assert(tokenizer.tokenText == "bla");
    // next line
    assert(tokenizer.next() == CSSTokenType.str);
    assert(tokenizer.tokenText == "01"); //'\30 \31'
    assert(tokenizer.next() == CSSTokenType.eof);
}


/**
Tokenizes css source, returns array of tokens (last token is EOF).
Source must be preprocessed utf-8 string.
*/
static CSSToken[] tokenizeCSS(string src) {
    CSSTokenizer tokenizer;
    tokenizer.start(src);
    CSSToken[] res;
    res.assumeSafeAppend();
    for(;;) {
        res ~= tokenizer.nextToken();
        if (res[$ - 1].type == CSSTokenType.eof)
            break;
    }
    return res;
}

unittest {
    string src = "pre {123em}";
    auto res = tokenizeCSS(src);
    assert(res.length == 6);
    assert(res[0].type == CSSTokenType.ident);
    assert(res[0].text == "pre");
    assert(res[1].type == CSSTokenType.whitespace);
    assert(res[2].type == CSSTokenType.curlyOpen);
    assert(res[3].type == CSSTokenType.dimension);
    assert(res[3].typeFlagInteger == true);
    assert(res[3].intValue == 123);
    assert(res[3].dimensionUnit == "em");
    assert(res[4].type == CSSTokenType.curlyClose);
    assert(res[$ - 1].type == CSSTokenType.eof);
}

// easy way to extract and apply imports w/o full document parsing
/**
    Extract CSS vimport rules from source.
*/
CSSImportRule[] extractCSSImportRules(string src) {
    enum ParserState {
        start, // before rule begin, switch to this state after ;
        afterImport, // after @import
        afterCharset, // after @charset
        afterCharsetName, // after @charset
        afterImportUrl, // after @charset
    }
    ParserState state = ParserState.start;
    CSSImportRule[] res;
    CSSTokenizer tokenizer;
    tokenizer.start(src);
    bool insideImportRule = false;
    string url;
    size_t startPos = 0;
    size_t endPos = 0;
    for (;;) {
        CSSTokenType type = tokenizer.next();
        if (type == CSSTokenType.eof)
            break;
        if (type == CSSTokenType.whitespace || type == CSSTokenType.comment)
            continue; // skip whitespaces and comments
        if (type == CSSTokenType.atKeyword) {
            if (tokenizer.tokenText == "charset") {
                state = ParserState.afterCharset;
                continue;
            }
            if (tokenizer.tokenText != "import")
                break;
            // import rule
            state = ParserState.afterImport;
            startPos = tokenizer.tokenStart;
            continue;
        }
        if (type == CSSTokenType.str || type == CSSTokenType.url) {
            if (state == ParserState.afterImport) {
                url = tokenizer.tokenText.dup;
                state = ParserState.afterImportUrl;
                continue;
            }
            if (state == ParserState.afterCharset) {
                state = ParserState.afterCharsetName;
                continue;
            }
            break;
        }
        if (type == CSSTokenType.curlyOpen)
            break;
        if (type == CSSTokenType.ident && state == ParserState.start)
            break; // valid @imports may be only at the beginning of file
        if (type == CSSTokenType.semicolon) {
            if (state == ParserState.afterImportUrl) {
                // add URL
                endPos = tokenizer.tokenEnd;
                CSSImportRule rule;
                rule.startPos = startPos;
                rule.endPos = endPos;
                rule.url = url;
                res ~= rule;
            }
            state = ParserState.start;
            continue;
        }
    }
    return res;
}

/**
  Replace source code import rules obtained by extractImportRules() with imported content.
*/
string applyCSSImportRules(string src, CSSImportRule[] rules) {
    if (!rules.length)
        return src; // no rules
    char[] res;
    res.assumeSafeAppend;
    size_t start = 0;
    for (int i = 0; i < rules.length; i++) {
        res ~= src[start .. rules[i].startPos];
        res ~= rules[i].content;
        start = rules[i].endPos;
    }
    if (start < src.length)
        res ~= src[start .. $];
    return cast(string)res;
}


unittest {
    string src = q{
        @charset "utf-8";
        /* comment must be ignored */
        @import "file1.css"; /* string */
        @import url(file2.css); /* url */
        pre {}
        @import "ignore_me.css";
        p {}
    };
    auto res = extractCSSImportRules(src);
    assert(res.length == 2);
    assert(res[0].url == "file1.css");
    assert(res[1].url == "file2.css");
    res[0].content = "[file1_content]";
    res[1].content = "[file2_content]";
    string s = applyCSSImportRules(src, res);
    assert (s.length != src.length);
}

enum ASTNodeType {
    simpleBlock,
    componentValue,
    preservedToken,
    func,
    atRule,
    qualifiedRule,
}

class ASTNode {
    ASTNodeType type;
}

class ComponentValueNode : ASTNode {
    this() {
        type = ASTNodeType.componentValue;
    }
}

class SimpleBlockNode : ComponentValueNode {
    CSSTokenType blockType = CSSTokenType.curlyOpen;
    ComponentValueNode[] componentValues;
    this() {
        type = ASTNodeType.simpleBlock;
    }
}

class FunctionNode : ComponentValueNode {
    ComponentValueNode[] componentValues;
    this(string name) {
        type = ASTNodeType.func;
    }
}

class PreservedTokenNode : ComponentValueNode {
    CSSToken token;
    this(ref CSSToken token) {
        this.token = token;
        type = ASTNodeType.preservedToken;
    }
}

class QualifiedRuleNode : ASTNode {
    ComponentValueNode[] componentValues;
    SimpleBlockNode block;
    this() {
        type = ASTNodeType.qualifiedRule;
    }
}

class ATRuleNode : QualifiedRuleNode {
    string name;
    this() {
        type = ASTNodeType.atRule;
    }
}


class CSSParser {
    CSSToken[] tokens;
    int pos = 0;
    this(CSSToken[] _tokens) {
        tokens = _tokens;
    }
    /// peek current token
    @property ref CSSToken currentToken() {
        return tokens[pos];
    }
    /// peek next token
    @property ref CSSToken nextToken() {
        return tokens[pos + 1 < $ ? pos + 1 : pos];
    }
    /// move to next token
    bool next() {
        if (pos < tokens.length) {
            pos++;
            return true;
        }
        return false;
    }
    /// move to nearest non-whitespace token; return current token type (does not move if current token is not whitespace)
    CSSTokenType skipWhiteSpace() {
        while (currentToken.type == CSSTokenType.whitespace || currentToken.type == CSSTokenType.comment || currentToken.type == CSSTokenType.delim)
            next();
        return currentToken.type;
    }
    /// skip current token, then move to nearest non-whitespace token; return new token type
    @property CSSTokenType nextNonWhiteSpace() {
        next();
        return skipWhiteSpace();
    }
    SimpleBlockNode parseSimpleBlock() {
        auto type = skipWhiteSpace();
        CSSTokenType closeType;
        if (type == CSSTokenType.curlyOpen) {
            closeType = CSSTokenType.curlyClose;
        } else if (type == CSSTokenType.squareOpen) {
            closeType = CSSTokenType.squareClose;
        } else if (type == CSSTokenType.parentOpen) {
            closeType = CSSTokenType.parentClose;
        } else {
            // not a simple block
            return null;
        }
        SimpleBlockNode res = new SimpleBlockNode();
        res.blockType = type;
        auto t = nextNonWhiteSpace();
        res.componentValues = parseComponentValueList(closeType);
        t = skipWhiteSpace();
        if (t == closeType)
            nextNonWhiteSpace();
        return res;
    }
    FunctionNode parseFunctionBlock() {
        auto type = skipWhiteSpace();
        if (type != CSSTokenType.func)
            return null;
        FunctionNode res = new FunctionNode(currentToken.text);
        auto t = nextNonWhiteSpace();
        res.componentValues = parseComponentValueList(CSSTokenType.parentClose);
        t = skipWhiteSpace();
        if (t == CSSTokenType.parentClose)
            nextNonWhiteSpace();
        return res;
    }
    ComponentValueNode[] parseComponentValueList(CSSTokenType endToken1 = CSSTokenType.eof, CSSTokenType endToken2 = CSSTokenType.eof) {
        ComponentValueNode[] res;
        for (;;) {
            auto type = skipWhiteSpace();
            if (type == CSSTokenType.eof)
                return res;
            if (type == endToken1 || type == endToken2)
                return res;
            if (type == CSSTokenType.squareOpen || type == CSSTokenType.parentOpen || type == CSSTokenType.curlyOpen) {
                res ~= parseSimpleBlock();
            } else if (type == CSSTokenType.func) {
                res ~= parseFunctionBlock();
            } else {
                res ~= new PreservedTokenNode(currentToken);
                next();
            }
        }
    }
    ATRuleNode parseATRule() {
        auto type = skipWhiteSpace();
        if (type != CSSTokenType.atKeyword)
            return null;
        ATRuleNode res = new ATRuleNode();
        res.name = currentToken.text;
        type = nextNonWhiteSpace();
        res.componentValues = parseComponentValueList(CSSTokenType.semicolon, CSSTokenType.curlyOpen);
        type = skipWhiteSpace();
        if (type == CSSTokenType.semicolon) {
            next();
            return res;
        }
        if (type == CSSTokenType.curlyOpen) {
            res.block = parseSimpleBlock();
            return res;
        }
        if (type == CSSTokenType.eof)
            return res;
        return res;
    }

    QualifiedRuleNode parseQualifiedRule() {
        auto type = skipWhiteSpace();
        if (type == CSSTokenType.eof)
            return null;
        QualifiedRuleNode res = new QualifiedRuleNode();
        res.componentValues = parseComponentValueList(CSSTokenType.curlyOpen);
        type = skipWhiteSpace();
        if (type == CSSTokenType.curlyOpen) {
            res.block = parseSimpleBlock();
        }
        return res;
    }
}

unittest {
    ATRuleNode atRule = new CSSParser(tokenizeCSS("@atRuleName;")).parseATRule();
    assert(atRule !is null);
    assert(atRule.name == "atRuleName");
    assert(atRule.block is null);

    atRule = new CSSParser(tokenizeCSS("@atRuleName2 { }")).parseATRule();
    assert(atRule !is null);
    assert(atRule.name == "atRuleName2");
    assert(atRule.block !is null);
    assert(atRule.block.blockType == CSSTokenType.curlyOpen);

    atRule = new CSSParser(tokenizeCSS("@atRuleName3 url('bla') { 123 }")).parseATRule();
    assert(atRule !is null);
    assert(atRule.name == "atRuleName3");
    assert(atRule.componentValues.length == 1);
    assert(atRule.componentValues[0].type == ASTNodeType.preservedToken);
    assert(atRule.block !is null);
    assert(atRule.block.blockType == CSSTokenType.curlyOpen);
    assert(atRule.block.componentValues.length == 1);


    atRule = new CSSParser(tokenizeCSS("@atRuleName4 \"value\" { funcName(123) }")).parseATRule();
    assert(atRule !is null);
    assert(atRule.name == "atRuleName4");
    assert(atRule.componentValues.length == 1);
    assert(atRule.componentValues[0].type == ASTNodeType.preservedToken);
    assert(atRule.block !is null);
    assert(atRule.block.blockType == CSSTokenType.curlyOpen);
    assert(atRule.block.componentValues.length == 1);
    assert(atRule.block.componentValues[0].type == ASTNodeType.func);
}

unittest {
    QualifiedRuleNode qualifiedRule = new CSSParser(tokenizeCSS(" pre { display: none } ")).parseQualifiedRule();
    assert(qualifiedRule !is null);
    assert(qualifiedRule.componentValues.length == 1);
    assert(qualifiedRule.block !is null);
    assert(qualifiedRule.block.componentValues.length == 3);
}
