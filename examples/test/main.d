module main;

struct Foo // must be struct to reproduce
{
    uint foo; // any data can be here
}

struct Bar // must be struct to reproduce
{
    // DMD 2.065 hang with 100% CPU load
    // works ok if array size is reduced
	//Foo[0x20000] _array;
    //  0x4000 - < 1 second
    //  0x8000 - 5 seconds
    //  0xC000 - 15 seconds
    //  0xE000 - 20 seconds
    //  0x10000 - 25 seconds
    //  0x20000 - 1:45
}

int main(string[] argv)
{
    return 0;
}
