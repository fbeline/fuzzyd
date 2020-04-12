import std.stdio;
import std.array;
import std.container.rbtree;
import std.container.binaryheap;

alias Item[] delegate(string) score_fn;

struct Item {
  int score;
  string value;
  int[] matches;
}

score_fn fuzzy(string[] input) {
  Item score(string s, string t) {
    Item item;
    auto matches = redBlackTree!int();
    int[][] rm = new int[][](s.length, t.length);

    for (int i = 0; i < t.length; i++) {
      for (int j = 0; j < s.length; j++) {
        int v = 0;
        if (s[j] == t[i]) {
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

  Item[] search(string target) {
    Item[] result = new Item[input.length];
    auto maxpq = BinaryHeap!(Item[], "a.score < b.score")(result, 0);
    foreach(e; input) {
      maxpq.insert(score(e, target));
    }
    return result;
  }

  return &search;
}

