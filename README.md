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
[FuzzyResult("cd Documents", 17, [0, 1, 3, 4, 5, 10, 11])
,FuzzyResult("vi ~/Documents", 15, [5, 6, 7, 12, 13])
,FuzzyResult("curl localhost/foo", 10, [0, 6, 7, 11, 12, 13, 16, 17])
,FuzzyResult("rm -rf Downloads", 7, [7, 8, 12, 14, 15])
,FuzzyResult("cp bar ../foo", 3, [0, 11, 12])]
*/

fzy("cp /foo");
/* =>
[FuzzyResult("cp bar ../foo", 40, [0, 1, 2, 6, 9, 10, 11, 12])
,FuzzyResult("curl localhost/foo", 35, [0, 4, 6, 7, 11, 14, 15, 16, 17])
,FuzzyResult("rm -rf Downloads", 7, [2, 5, 6, 8, 12])
,FuzzyResult("cd Documents", 5, [0, 2, 4, 5])
,FuzzyResult("vi ~/Documents", 5, [2, 4, 6, 7])]
*/
```

Refer to the [documentation](/docs/core.html) for more details.

## License

MIT
