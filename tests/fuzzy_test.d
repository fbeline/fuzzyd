module fuzzyd_test;

import std.stdio;
import std.array;
import std.algorithm;
import std.algorithm.comparison : equal;
import std.container.binaryheap;
import std.range;

import fuzzyd.core;

private FuzzyResult[] prepare(string s)
{
    string[] source = [
        "cd Documents", "curl localhost/foo", "cp bar ../foo",
        "rm -rf Downloads", "vi ~/Documents"
    ];
    FuzzyResult[] response = new FuzzyResult[source.length];
    fuzzy(source)(s, response);
    return heapify!"a.score < b.score"(response).take(source.length).array;
}

@("Matches in expected order")
unittest
{
    auto result = prepare("docts").map!(x => x.value);
    const expected = [
        "cd Documents", "vi ~/Documents", "curl localhost/foo",
        "rm -rf Downloads", "cp bar ../foo"
    ];
    assert(equal(expected, result));
}

@("Matches indexes")
unittest
{
    const result = prepare("docts")[0].matches;
    const expected = [1, 1, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1];
    assert(equal(expected, result));
}

@("Result is empty if provided db is empty")
unittest
{
    string[] source = [];
    FuzzyResult[] result = new FuzzyResult[0];
    fuzzy(source)("f", result);
    assert(result.empty);
}

@("Unicode support")
unittest
{
    string[] source = ["férias"];
    auto result = new FuzzyResult[source.length];
    fuzzy(source)("fé", result);
    assert(equal([1, 1, 0, 0, 0, 0], result[0].matches));
    fuzzy(["foo", "bar", "baz"])("br", result);
}
