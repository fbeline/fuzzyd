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

@("Start bonus is applyed")
unittest {
  auto result = prepare("curl")[0].score;
  assert(61 == result);
}

@("Case bonus is applyed")
unittest {
  auto r1 = prepare("docts")[0].score;
  auto r2 = prepare("Docts")[0].score;
  assert(r1 == 27);
  assert(r2 == 34);
}

@("Word boundary bonus is applyed")
unittest {
  auto result = prepare("cd")[0].score;
  assert(14 == result);
}

