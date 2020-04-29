module tests.performance_test;

import fuzzyd.core;
import std.stdio;
import std.file;
import std.string;
import std.datetime;

unittest
{
    // 3800 ms
    string[] db;
    File file = File("tests/input.txt", "r");

    while (!file.eof())
    {
        string line = chomp(file.readln());
        db ~= line;
    }
    // start
    StopWatch sw;
    sw.start();
    // --------
    auto r = new FuzzyResult[db.length];

    const f = fuzzy(db);
    f("n", r);
    f("c", r);
    f("u", r);
    f("r", r);
    f("s", r);


    // end
    const long exec_ms = sw.peek().msecs;
    writeln("-------- Result --------");
    writeln("Nº lines: ", db.length);
    writeln("Time: ", exec_ms);
}
