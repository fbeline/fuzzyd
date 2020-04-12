module fuzzyd_test;

import std.stdio;
import std.algorithm;
import std.algorithm.comparison : equal;

import fuzzyd;

Result[] prepare(string s) {
  string[] source = ["cd Documents",
                     "curl localhost/foo",
                     "cp bar ../foo",
                     "rm -rf Downloads",
                     "vi ~/Documents"];
  return fuzzy(source)(s);
}

@("Matches in expected order")
unittest {
  auto result = prepare("docts").map!(x => x.value);
  auto expected = ["cd Documents",
                   "vi ~/Documents",
                   "curl localhost/foo",
                   "rm -rf Downloads",
                   "cp bar ../foo"];
  assert(equal(expected, result));
}

@("Matches indexes")
unittest {
  auto result = prepare("docts")[0].matches;
  auto expected = [0, 1, 3, 4, 5, 10, 11];
  assert(equal(expected, result));
}
