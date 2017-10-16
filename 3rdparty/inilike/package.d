/**
 * Reading and writing ini-like files used in some Unix systems and Freedesktop specifications.
 * ini-like is informal name for the file format that look like this:
 * ---
# Comment
[Group name]
Key=Value
# Comment inside group
AnotherKey=Value

[Another group]
Key=English value
Key[fr_FR]=Francais value

 * ---
 * Authors:
 *  $(LINK2 https://github.com/FreeSlave, Roman Chistokhodov)
 * Copyright:
 *  Roman Chistokhodov, 2015-2016
 * License:
 *  $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * See_Also:
 *  $(LINK2 http://standards.freedesktop.org/desktop-entry-spec/latest/index.html, Desktop Entry Specification)
 */

module inilike;

public import inilike.common;
public import inilike.range;
public import inilike.file;

unittest
{
    import std.exception;

    final class DesktopEntry : IniLikeGroup
    {
        this() {
            super("Desktop Entry");
        }
    protected:
        @trusted override void validateKey(string key, string value) const {
            if (!isValidDesktopFileKey(key)) {
                throw new IniLikeEntryException("key is invalid", groupName(), key, value);
            }
        }
    }

    final class DesktopFile : IniLikeFile
    {
        //Options to manage .ini like file reading
        static struct DesktopReadOptions
        {
            IniLikeFile.ReadOptions baseOptions;

            alias baseOptions this;

            bool skipExtensionGroups;
            bool ignoreUnknownGroups;
            bool skipUnknownGroups;
        }

        @trusted this(IniLikeReader)(IniLikeReader reader, DesktopReadOptions options = DesktopReadOptions.init)
        {
            _options = options;
            super(reader, null, options.baseOptions);
            enforce(_desktopEntry !is null, new IniLikeReadException("No \"Desktop Entry\" group", 0));
        }

        @safe override bool removeGroup(string groupName) nothrow {
            if (groupName == "Desktop Entry") {
                return false;
            }
            return super.removeGroup(groupName);
        }

    protected:
        @trusted override IniLikeGroup createGroupByName(string groupName)
        {
            if (groupName == "Desktop Entry") {
                _desktopEntry = new DesktopEntry();
                return _desktopEntry;
            } else if (groupName.startsWith("X-")) {
                if (_options.skipExtensionGroups) {
                    return null;
                }
                return createEmptyGroup(groupName);
            } else {
                if (_options.ignoreUnknownGroups) {
                    if (_options.skipUnknownGroups) {
                        return null;
                    } else {
                        return createEmptyGroup(groupName);
                    }
                } else {
                    throw new IniLikeException("Unknown group");
                }
            }
        }

        inout(DesktopEntry) desktopEntry() inout {
            return _desktopEntry;
        }

    private:
        DesktopEntry _desktopEntry;
        DesktopReadOptions _options;
    }

    string contents =
`# First comment
[Desktop Entry]
Key=Value
# Comment in group`;
    DesktopFile.DesktopReadOptions options;

    auto df = new DesktopFile(iniLikeStringReader(contents), options);
    assert(!df.removeGroup("Desktop Entry"));
    assert(!df.removeGroup("NonExistent"));
    assert(df.group("Desktop Entry") !is null);
    assert(df.desktopEntry() !is null);
    assert(equal(df.desktopEntry().byIniLine(), [IniLikeLine.fromKeyValue("Key", "Value"), IniLikeLine.fromComment("# Comment in group")]));
    assert(equal(df.leadingComments(), ["# First comment"]));

    assertThrown(df.desktopEntry().writeEntry("$Invalid", "Valid value"));

    IniLikeEntryException entryException;
    try {
        df.desktopEntry().writeEntry("$Invalid", "Valid value");
    } catch(IniLikeEntryException e) {
        entryException = e;
    }
    assert(entryException !is null);
    df.desktopEntry().writeEntry("$Invalid", "Valid value", IniLikeGroup.InvalidKeyPolicy.save);
    assert(df.desktopEntry().value("$Invalid") == "Valid value");

    assert(df.desktopEntry().appendValue("Another$Invalid", "Valid value", IniLikeGroup.InvalidKeyPolicy.skip).isNull());
    assert(df.desktopEntry().setValue("Another$Invalid", "Valid value", IniLikeGroup.InvalidKeyPolicy.skip) is null);
    assert(df.desktopEntry().value("Another$Invalid") is null);

    contents =
`[X-SomeGroup]
Key=Value`;

    auto thrown = collectException!IniLikeReadException(new DesktopFile(iniLikeStringReader(contents)));
    assert(thrown !is null);
    assert(thrown.lineNumber == 0);

    contents =
`[Desktop Entry]
Valid=Key
$=Invalid`;

    thrown = collectException!IniLikeReadException(new DesktopFile(iniLikeStringReader(contents)));
    assert(thrown !is null);
    assert(thrown.entryException !is null);
    assert(thrown.entryException.key == "$");
    assert(thrown.entryException.value == "Invalid");

    options = DesktopFile.DesktopReadOptions.init;
    options.invalidKeyPolicy = IniLikeGroup.InvalidKeyPolicy.skip;
    assertNotThrown(new DesktopFile(iniLikeStringReader(contents), options));

    contents =
`[Desktop Entry]
Name=Name
[Unknown]
Key=Value`;

    assertThrown(new DesktopFile(iniLikeStringReader(contents)));

    options = DesktopFile.DesktopReadOptions.init;
    options.ignoreUnknownGroups = true;

    assertNotThrown(df = new DesktopFile(iniLikeStringReader(contents), options));
    assert(df.group("Unknown") !is null);

    options.skipUnknownGroups = true;
    df = new DesktopFile(iniLikeStringReader(contents), options);
    assert(df.group("Unknown") is null);

    contents =
`[Desktop Entry]
Name=Name1
[X-Extension]
Name=Name2`;

    options = DesktopFile.DesktopReadOptions.init;
    options.skipExtensionGroups = true;

    df = new DesktopFile(iniLikeStringReader(contents), options);
    assert(df.group("X-Extension") is null);
}
