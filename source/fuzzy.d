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

  int charScore(int[][] rm, string base, string target, int col, int row) {
    int score = 0;
    if (toLower(base[row]) == toLower(target[col])) {
      score += 1;
      if (col > 0 && row > 0)
        score += rm[row-1][col-1] * 2;
    }
    return score;
  }

  Result score(string base, string target) {
    int score = 0;
    auto matches = redBlackTree!int();
    int[][] rm = new int[][](base.length, target.length);

    for (int col = 0; col < target.length; col++) {
      for (int row = 0; row < base.length; row++) {
        int charScore = charScore(rm, base, target, col, row);
        if (charScore > 0) matches.insert(row);
        score += charScore;
        rm[row][col] = charScore;
      }
    }

    return Result(base, score, matches.array());
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
