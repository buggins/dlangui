DlangUI Coding Style
====================

Tabs and indentation
--------------------

No Tab characters should be used in source code.
Use 4 spaces instead of tabs.


Identifiers
-----------

Class names: CamelCase with uppercase first letter, e.g.: `LinearLayout`, `GridWidget`.  
Method and property names: camelCase with lowercase first letter, e.g.: `textAlign`, `layoutWidth`.  
Private and protected class and struct fields: \_camelCase prepended with underscore, e.g. `_windowWidth`.  
Signal names: camelCase.  
Enum member names: currently, 3 styles are used: JAVA_LIKE, CamelCase and camelCase. TODO: make it consistent?  
```D
class MyClass {
    private int _magicNumber;
    @property int magicNumber() { return _magicNumber; }
}
```

Spaces
------

Always put space after comma or semicolon if there are more items in the same line.
```D
update(x, y, isAnimating(this));

auto list = [1, 2, 3, 4, 5];
```
Usually there is no space after opening or before closing `[]` and `()`.

Spaces may be added to improve readability when there is a sequence brackets of the same type.
```D
auto y = (x * x + ( ((a - b) + c) ) * 2);
```
Use spaces before and after == != && || + - * / etc.


Brackets
--------

Curly braces for `if`, `switch`, `for`, `foreach` - preferable placed on the same lines as keyword:
```D
if (a == b) {
    //
} else {
    //
}

foreach (item; list) {
    writeln(item);
}
```
Cases in switch should be indented:
```D
switch(action.id) {
    case 1:
        processAction(1);
        break;
    default:
        break;
}
```
For classes and structs opening { can be either at end of line or in a new line). 
```D
class Foo {
}

class Bar : Foo
{
}
```
For methods  { should be at the end of line.

Short methods (e.g. property getters) may be written in one line.
```D
void invalidate() {
    //
}

int length() { return _list.length; }
```
