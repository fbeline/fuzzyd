module tests.performance_test;

import fuzzyd.core;
import std.stdio;
import std.file;
import std.string;
import std.datetime.stopwatch;
import std.container.binaryheap;
import std.range;

unittest
{
    string[] db;
    File file = File("tests/input.txt", "r");

    while (!file.eof())
    {
        string line = chomp(file.readln());
        db ~= line;
    }
    // start
    StopWatch sw = StopWatch(AutoStart.no);
    sw.start();
    // --------
    auto r = new FuzzyResult[db.length];

    const f = fuzzy(db);
    f("n", r);
    heapify!"a.score < b.score"(r).take(20).array;
    f("c", r);
    heapify!"a.score < b.score"(r).take(20).array;
    f("u", r);
    heapify!"a.score < b.score"(r).take(20).array;
    f("r", r);
    heapify!"a.score < b.score"(r).take(20).array;
    f("s", r);
    heapify!"a.score < b.score"(r).take(20).array;

    sw.stop();
    // end
    const long exec_ms = sw.peek.total!"msecs";
    writeln("-------- Result --------");
    writeln("Nº lines: ", db.length);
    writeln("Time: ", exec_ms);
}
