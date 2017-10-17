/**
 * Parsing contents of ini-like files via range-based interface.
 * Authors:
 *  $(LINK2 https://github.com/FreeSlave, Roman Chistokhodov)
 * Copyright:
 *  Roman Chistokhodov, 2015-2016
 * License:
 *  $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * See_Also:
 *  $(LINK2 http://standards.freedesktop.org/desktop-entry-spec/latest/index.html, Desktop Entry Specification)
 */

module inilike.range;

import inilike.common;


/**
 * Object for iterating through ini-like file entries.
 */
struct IniLikeReader(Range) if (isInputRange!Range && isSomeString!(ElementType!Range) && is(ElementEncodingType!(ElementType!Range) : char))
{
    /**
     * Construct from other range of strings.
     */
    this(Range range)
    {
        _range = range;
    }

    /**
     * Iterate through lines before any group header. It does not check if all lines are comments or empty lines.
     */
    auto byLeadingLines()
    {
        return _range.until!(isGroupHeader);
    }

    /**
     * Object representing single group (section) being parsed in .ini-like file.
     */
    static struct Group(Range)
    {
        private this(Range range, ElementType!Range originalLine)
        {
            _range = range;
            _originalLine = originalLine;
        }

        /**
         * Name of group being parsed (without brackets).
         * Note: This can become invalid during parsing the Input Range
         * (e.g. if string buffer storing this value is reused in later reads).
         */
        auto groupName() {
            return parseGroupHeader(_originalLine);
        }

        /**
         * Original line of group header (i.e. name with brackets).
         * Note: This can become invalid during parsing the Input Range
         * (e.g. if string buffer storing this value is reused in later reads).
         */
        auto originalLine() {
            return _originalLine;
        }

        /**
         * Iterate over group entries - may be key-value pairs as well as comments or empty lines.
         */
        auto byEntry()
        {
            return _range.until!(isGroupHeader);
        }

    private:
        ElementType!Range _originalLine;
        Range _range;
    }

    /**
     * Iterate thorugh groups of .ini-like file.
     * Returns: Range of Group objects.
     */
    auto byGroup()
    {
        static struct ByGroup
        {
            this(Range range)
            {
                _range = range.find!(isGroupHeader);
                ElementType!Range line;
                if (!_range.empty) {
                    line = _range.front;
                    _range.popFront();
                }
                _currentGroup = Group!Range(_range, line);
            }

            auto front()
            {
                return _currentGroup;
            }

            bool empty()
            {
                return _currentGroup.groupName.empty;
            }

            void popFront()
            {
                _range = _range.find!(isGroupHeader);
                ElementType!Range line;
                if (!_range.empty) {
                    line = _range.front;
                    _range.popFront();
                }
                _currentGroup = Group!Range(_range, line);
            }
        private:
            Group!Range _currentGroup;
            Range _range;
        }

        return ByGroup(_range.find!(isGroupHeader));
    }
private:
    Range _range;
}

/**
 * Convenient function for creation of IniLikeReader instance.
 * Params:
 *  range = input range of strings (strings must be without trailing new line characters)
 * Returns: IniLikeReader for given range.
 * See_Also: $(D iniLikeFileReader), $(D iniLikeStringReader)
 */
auto iniLikeRangeReader(Range)(Range range)
{
    return IniLikeReader!Range(range);
}

///
unittest
{
    string contents =
`First comment
Second comment
[First group]
KeyValue1
KeyValue2
[Second group]
KeyValue3
KeyValue4
[Empty group]
[Third group]
KeyValue5
KeyValue6`;
    auto r = iniLikeRangeReader(contents.splitLines());

    auto byLeadingLines = r.byLeadingLines;

    assert(byLeadingLines.front == "First comment");
    assert(byLeadingLines.equal(["First comment", "Second comment"]));

    auto byGroup = r.byGroup;

    assert(byGroup.front.groupName == "First group");
    assert(byGroup.front.originalLine == "[First group]");


    assert(byGroup.front.byEntry.front == "KeyValue1");
    assert(byGroup.front.byEntry.equal(["KeyValue1", "KeyValue2"]));
    byGroup.popFront();
    assert(byGroup.front.groupName == "Second group");
    byGroup.popFront();
    assert(byGroup.front.groupName == "Empty group");
    assert(byGroup.front.byEntry.empty);
    byGroup.popFront();
    assert(byGroup.front.groupName == "Third group");
    byGroup.popFront();
    assert(byGroup.empty);
}

/**
 * Convenient function for reading ini-like contents from the file.
 * Throws: $(B ErrnoException) if file could not be opened.
 * Note: This function uses byLineCopy internally. Fallbacks to byLine on older compilers.
 * See_Also: $(D iniLikeRangeReader), $(D iniLikeStringReader)
 */
@trusted auto iniLikeFileReader(string fileName)
{
    import std.stdio : File;
    static if( __VERSION__ < 2067 ) {
        return iniLikeRangeReader(File(fileName, "r").byLine().map!(s => s.idup));
    } else {
        return iniLikeRangeReader(File(fileName, "r").byLineCopy());
    }
}

/**
 * Convenient function for reading ini-like contents from string.
 * Note: on frontends < 2.067 it uses splitLines thereby allocates strings.
 * See_Also: $(D iniLikeRangeReader), $(D iniLikeFileReader)
 */
@trusted auto iniLikeStringReader(String)(String contents) if (isSomeString!String && is(ElementEncodingType!String : char))
{
    static if( __VERSION__ < 2067 ) {
        return iniLikeRangeReader(contents.splitLines());
    } else {
        return iniLikeRangeReader(contents.lineSplitter());
    }
}
