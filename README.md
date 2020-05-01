# fuzzyd [![Build Status](https://travis-ci.org/fbeline/fuzzyd.svg?branch=master)](https://travis-ci.org/fbeline/fuzzyd)

A D language fuzzy search library.

### Criteria

Score extra points when:

- pattern is found at the beggining of the string.
- pattern is at word boundary position.
- case sensitive matches.

Penalty for:

- isolated matches worth half of the points.

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
[FuzzyResult("cd Documents", 1050, [1, 4, 5, 10, 11], true),
 FuzzyResult("curl localhost/foo", 0, [], false),
 FuzzyResult("rm -rf Downloads", 20, [7, 8], false),
 FuzzyResult("vi ~/Documents", 1050, [5, 6, 7, 12, 13], true)]
*/
```

## License

MIT
