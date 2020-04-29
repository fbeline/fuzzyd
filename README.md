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
auto result = new FuzzyResult[source.length];
auto fzy = fuzzy(source);

fzy("docts", result);
/* result =>
[FuzzyResult("cd Documents", 150, [1, 1, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1]),
 FuzzyResult("vi ~/Documents", 140, [0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1]),
 FuzzyResult("curl localhost/foo", 90, [1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 1, 1]),
 FuzzyResult("rm -rf Downloads", 75, [0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0, 1, 1])]
*/
```

## License

MIT
