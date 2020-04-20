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

@("Result is empty if no provided db was empty")
unittest
{
    string[] source = [];
    const result = fuzzy(source)("f");
    assert(result.empty);
}

@("Score is normalized")
unittest
{
    string[] source = [ "fzf", "foo", "bar", "faz"];
    const FuzzyResult[] invalid = fuzzy(source)("f").filter!(x => x.score > 1 || x.score < 0).array;
    assert(invalid.empty);

}