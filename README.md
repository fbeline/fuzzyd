# fuzzyd

A D library designed to provide a fuzzy search in an array of strings. 

The algorithm used is a modification of the [Smith–Waterman algorithm](https://en.m.wikipedia.org/wiki/Smith%E2%80%93Waterman_algorithm). The worst-case performance is O(m*n) for each entry provided in the input. (m and n are the respective length of the tested strings).

## Rationale

fuzzyd is intended to be used to fuzzy search in a list of files and/or commands. I would not
recommend the usage of fuzzyd if you are looking for a general-purpose fuzzy search library.

## Usage

```d
import fuzzyd;

string[] source = ["cd Documents",
                   "curl localhost/foo",
                   "rm -rf Downloads",
                   "vi ~/Documents"];
                   
auto fzs = fuzzy(source);
auto result = fzs("docts");

/* result => 
[Item(17, "cd Documents", [0, 1, 3, 4, 5, 10, 11]),
 Item(15, "vi ~/Documents", [5, 6, 7, 12, 13]),
 Item(7, "rm -rf Downloads", [7, 8, 12, 14, 15]),
 Item(10, "curl localhost/foo", [0, 6, 7, 11, 12, 13, 16, 17])]
*/
```

The result is a list of `Item`

```d
struct Item {
  string value; // entry tested against the provided string. 
  int score; // metrifies how "similar" the entry is. (Higher better)
  int[] matches; // List of the entry indexes that matched in the provided string.
}
```

## License
MIT
