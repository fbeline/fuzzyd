module fuzzyd;

import std.stdio;
import std.array;
import std.container.rbtree;
import std.container.binaryheap;
import std.ascii;

alias Result[] delegate(string) score_fn;

struct Result {
  string value;
  int score;
  int[] matches;
}

score_fn fuzzy(string[] input) {
  Result score(string s, string t) {
    Result item;
    auto matches = redBlackTree!int();
    int[][] rm = new int[][](s.length, t.length);

    for (int i = 0; i < t.length; i++) {
      for (int j = 0; j < s.length; j++) {
        int v = 0;
        if (toLower(s[j]) == toLower(t[i])) {
          v += 1;
          matches.insert(j);
          if (i > 0 && j > 0)
            v += rm[j-1][i-1] * 2;
        }
        item.score += v;
        rm[j][i] = v;
      }
    }

    item.matches = matches.array();
    item.value = s;
    return item;
  }

  Result[] search(string target) {
    auto maxpq = BinaryHeap!(Result[], "a.score < b.score")(new Result[input.length], 0);
    foreach(e; input) {
      maxpq.insert(score(e, target));
    }
    return maxpq.array();
  }

  return &search;
}
