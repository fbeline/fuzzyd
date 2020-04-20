# fuzzyd [![Build Status](https://travis-ci.org/fbeline/fuzzyd.svg?branch=master)](https://travis-ci.org/fbeline/fuzzyd)

A D language fuzzy search library.

The algorithm used is a modified version of [Smith–Waterman algorithm](https://en.m.wikipedia.org/wiki/Smith%E2%80%93Waterman_algorithm). The worst-case performance is O(m*n) for each entry provided in the input. (m and n are the respective length of the tested strings).

## About

fuzzyd was primarily created to search matches in a list of files and commands.

### Criteria

Score extra points when:

- pattern is found at the beggining of the string.
- pattern is at word boundary position.
- case sensitive matches.

Penalty for:

- isolated matches worth half of the points.

Note: The algorithm examines all the occurrences of the provided pattern, making it slower but more accurate.

## Usage

```d
import fuzzyd.core;

string[] source = ["cd Documents"
                  ,"curl localhost/foo"
                  ,"rm -rf Downloads"
                  ,"vi ~/Documents"];

auto fzy = fuzzy(source);

fzy("docts");
/* =>
[FuzzyResult("cd Documents", 1, RedBlackTree([0, 1, 3, 4, 5, 10, 11])),
 FuzzyResult("vi ~/Documents", 0.533052, RedBlackTree([5, 6, 7, 12, 13])),
 FuzzyResult("rm -rf Downloads", 0.33474, RedBlackTree([7, 8, 12, 14, 15])),
 FuzzyResult("curl localhost/foo", 0.292546, RedBlackTree([0, 6, 7, 11, 12, 13, 16, 17]))]
*/
```

Refer to the [documentation](https://htmlpreview.github.io/?https://github.com/fbeline/fuzzyd/blob/master/docs/core.html) for more details.

## License

MIT
