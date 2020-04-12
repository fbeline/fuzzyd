# fuzzyd [![Build Status](https://travis-ci.org/fbeline/fuzzy-d.svg?branch=master)](https://travis-ci.org/fbeline/fuzzy-d)

A D language fuzzy search library. 

The algorithm used is a modification of the [Smith–Waterman algorithm](https://en.m.wikipedia.org/wiki/Smith%E2%80%93Waterman_algorithm). The worst-case performance is O(m*n) for each entry provided in the input. (m and n are the respective length of the tested strings).

## Rationale

fuzzyd is intended to be used to fuzzy search in a list of files and/or commands.

Note: I would not recommend the usage of fuzzyd if you are looking for a general-purpose fuzzy search library.

## Usage

```d
import fuzzyd;

string[] source = ["cd Documents"
                  ,"curl localhost/foo"
                  ,"rm -rf Downloads"
                  ,"vi ~/Documents"];

auto fzs = fuzzy(source);

fzs("docts");
/* =>
[Result("cd Documents", 17, [0, 1, 3, 4, 5, 10, 11])
,Result("vi ~/Documents", 15, [5, 6, 7, 12, 13])
,Result("curl localhost/foo", 10, [0, 6, 7, 11, 12, 13, 16, 17])
,Result("rm -rf Downloads", 7, [7, 8, 12, 14, 15])
,Result("cp bar ../foo", 3, [0, 11, 12])]
*/

fzs("cp /foo");
/* =>
[Result("cp bar ../foo", 40, [0, 1, 2, 6, 9, 10, 11, 12])
,Result("curl localhost/foo", 35, [0, 4, 6, 7, 11, 14, 15, 16, 17])
,Result("rm -rf Downloads", 7, [2, 5, 6, 8, 12])
,Result("cd Documents", 5, [0, 2, 4, 5])
,Result("vi ~/Documents", 5, [2, 4, 6, 7])]
*/
```

Result struct:

```d
struct Result {
  string value; // entry tested against the provided string. 
  int score; // metrifies how "similar" the entry is. (Higher better)
  int[] matches; // list of indexes of matched characters.
}
```

## License
MIT
