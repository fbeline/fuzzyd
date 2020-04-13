module fuzzyd;

import std.stdio;
import std.array;
import std.container.rbtree;
import std.container.binaryheap;
import std.ascii;
import std.algorithm.iteration;

alias Result[] delegate(string) scoreFn;
alias int function(Input) bonusFn;

export struct Result {
  string value;
  int score;
  int[] matches;
}

struct Input {
  string input;
  string pattern;
  int col;
  int row;
  int[][] scoreMatrix;

  char inputAtIndex() {
    return input[row];
  }

  char patternAtIndex() {
    return pattern[col];
  }

  char isMatch() {
    return toLower(inputAtIndex) == toLower(patternAtIndex);
  }

  char isCaseSensitiveMatch() {
    return isUpper(inputAtIndex) && isUpper(patternAtIndex) && isMatch ? 1 : 0;
  }
}

int previousCharBonus(Input input) {
  return (input.col > 0 && input.row > 0) ?
    2 * input.scoreMatrix[input.row-1][input.col-1] : 0;
}

int startBonus(Input input) {
  return (input.col == 0 && input.row == 0) ? 1 : 0;
}

int caseMatchBonus(Input input) {
  return input.isCaseSensitiveMatch ? 1 : 0;
}

int wordBoundaryBonus(Input input) {
  bool isInputAt = input.row == 0 ||
    input.row == input.input.length-1 ||
    isWhite(input.input[input.row-1]) ||
    isWhite(input.input[input.row+1]);
  return isInputAt ? 1 : 0;
}

/**
 * Fuzzy search
 * Params:
 *   db = Array of string containing the search list.
 * Examples:
 * --------------------
 * auto f = fuzzy(["foo", "bar", "baz"]);
 * f("br")
 * // => [Result("bar", 5, [0, 2]), Result("baz", 3, [0]), Result("foo", 0, [])]
 * --------------------
 */
export scoreFn fuzzy(string[] db) {

  bonusFn[] bonusFns = [&previousCharBonus, &startBonus, &caseMatchBonus, &wordBoundaryBonus];

  int charScore(Input input) {
    return input.isMatch ?
      reduce!((acc, f) => acc + f(input))(1, bonusFns) : 0;
  }

  Result score(string input, string pattern) {
    int score = 0;
    auto matches = redBlackTree!int();
    int[][] scoreMatrix = new int[][](input.length, pattern.length);

    for (int col = 0; col < pattern.length; col++) {
      for (int row = 0; row < input.length; row++) {
        int charScore = charScore(Input(input, pattern, col, row, scoreMatrix));
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
