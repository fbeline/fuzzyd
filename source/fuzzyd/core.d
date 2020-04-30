module fuzzyd.core;

import std.stdio;
import std.array;
import std.range;
import std.math;
import std.conv;
import std.uni;
import std.algorithm.iteration;
import std.algorithm.sorting;
import std.algorithm : max;
import std.typecons;

alias fuzzyFn = void delegate(string, ref FuzzyResult[]);
alias bonusFn = long function(ref Input);

private:

struct Input
{
    string value;
    dchar i;
    dchar p;
    int col;
    int row;
    long[Tuple!(int, int)] history;
    bool hasSequence = false;

    bool isMatch()
    {
        return i.toLower == p.toLower;
    }

    bool isCaseSensitiveMatch()
    {
        return i.isUpper && p.isUpper && isMatch;
    }
}

long previousCharBonus(ref Input input)
{
    long* bonus = tuple(input.row - 1, input.col - 1) in input.history;
    if (bonus !is null)
    {
        *bonus = *bonus * 2;
        input.hasSequence = true;
        return *bonus;
    }
    return 0;
}

long startBonus(ref Input input)
{
    return (input.col == 0 && input.row == 0) ? 10 : 0;
}

long caseMatchBonus(ref Input input)
{
    return input.isCaseSensitiveMatch ? 15 : 0;
}

public:

/// fuzzy search result
struct FuzzyResult
{
    string value; /// entry. e.g "Documents/foo/bar/"
    long score; /// similarity metric. (Higher better)
    int[] matches; /// index of matched characters (0 = miss , 1 = hit).
    bool isValid; /// return true if consecutive characters are matched.
}

/**
 * Fuzzy search
 * Params:
 *   db = Array of string containing the search list.
 * Examples:
 * --------------------
 * auto result = new FuzzyResult[3];
 * fuzzy(["foo", "bar", "baz"])("br", result);
 * // => result
   // [FuzzyResult("bar", 25, [0, 2]), FuzzyResult("baz", 20, [0]), FuzzyResult("foo", 0, [])]
 * --------------------
 */
fuzzyFn fuzzy(string[] db)
{
    bonusFn[] bonusFns = [&previousCharBonus, &startBonus, &caseMatchBonus];

    long charScore(ref Input input)
    {
        return input.isMatch ? reduce!((acc, f) => acc + f(input))(10L, bonusFns) : 0;
    }

    FuzzyResult score(string txt, string pattern)
    {
        long score = 0;
        long simpleMatchScore = 0;
        auto input = Input(txt);
        foreach (p; pattern.byCodePoint)
        {
            input.p = p;
            foreach (i; txt.byCodePoint)
            {
                input.i = i;
                const charScore = charScore(input);
                if (charScore >= 10)
                {
                    input.history[tuple(input.row, input.col)] = charScore;
                }

                if (charScore == 10)
                    simpleMatchScore += charScore;
                else
                    score += charScore;

                input.row++;
            }
            input.col++;
            input.row = 0;
        }

        const totalScore = score + (simpleMatchScore / 2);
        if (pattern.walkLength == 1 && totalScore > 0)
            input.hasSequence = true;

        return FuzzyResult(txt, totalScore, input.history.keys.map!(x => x[0]).array, input.hasSequence);
    }

    void search(string pattern, ref FuzzyResult[] result)
    {
        long totalMatches = 0;
        for (long i = 0, max = result.length; i < max; i++)
        {
            result[i] = score(db[i], pattern);
            if (result[i].isValid)
                totalMatches++;
        }
    }

    return &search;
}
