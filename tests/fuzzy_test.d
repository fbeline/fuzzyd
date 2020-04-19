module fuzzyd_test;

import std.stdio;
import std.array;
import std.algorithm;
import std.algorithm.comparison : equal;

import fuzzyd.core;

private FuzzyResult[] prepare(string s)
{
    string[] source = [
        "cd Documents", "curl localhost/foo", "cp bar ../foo",
        "rm -rf Downloads", "vi ~/Documents"
    ];
    return fuzzy(source)(s);
}

@("Matches in expected order")
unittest
{
    auto result = prepare("docts").map!(x => x.value);
    const expected = [
        "cd Documents", "vi ~/Documents", "rm -rf Downloads",
        "curl localhost/foo", "cp bar ../foo"
    ];
    assert(equal(expected, result));
}

@("Matches indexes")
unittest
{
    const result = prepare("docts")[0].matches.array();
    const expected = [0, 1, 3, 4, 5, 10, 11];
    assert(equal(expected, result));
}

@("Start bonus is applied")
unittest
{
    const result = prepare("curl")[0].score;
    assert(59 == result);
}

@("Case bonus is applied")
unittest
{
    const r1 = prepare("docts")[0].score;
    const r2 = prepare("Docts")[0].score;
    assert(r1 == 26);
    assert(r2 == 33);
}

@("Word boundary bonus is applied")
unittest
{
    const result = prepare("cd")[0].score;
    assert(13 == result);
}
