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

score_fn fuzzy(string[] db) {

  int getPreviousCharScore(int[][] scoreMatrix, int col, int row) {
    return (col > 0 && row > 0) ? scoreMatrix[row-1][col-1] : 0;
  }

  int startBonus(int col, int row) {
    return (col == 0 && row == 0) ? 2 : 0;
  }

  int caseMatchBonus(string input, string pattern, int col, int row) {
    char ci = input[row];
    char cp = pattern[col];
    return (isUpper(ci) && isUpper(cp) && ci == cp) ? 1 : 0;
  }

  int charScore(int[][] scoreMatrix, string input, string pattern, int col, int row) {
    int score = 0;
    if (toLower(input[row]) == toLower(pattern[col])) {
      int previousCharScore = getPreviousCharScore(scoreMatrix, col, row);
      score += 1
        + (previousCharScore * 2)
        + startBonus(col, row)
        + caseMatchBonus(input, pattern, col, row);
    }
    return score;
  }

  Result score(string input, string pattern) {
    int score = 0;
    auto matches = redBlackTree!int();
    int[][] scoreMatrix = new int[][](input.length, pattern.length);

    for (int col = 0; col < pattern.length; col++) {
      for (int row = 0; row < input.length; row++) {
        int charScore = charScore(scoreMatrix, input, pattern, col, row);
        if (charScore > 0) matches.insert(row);
        score += charScore;
        scoreMatrix[row][col] = charScore;
      }
    }

    return Result(input, score, matches.array());
  }

  Result[] search(string pattern) {
    auto maxpq = BinaryHeap!(Result[], "a.score < b.score")(new Result[db.length], 0);
    foreach(e; db) {
      maxpq.insert(score(e, pattern));
    }
    return maxpq.array();
  }

  return &search;
}
