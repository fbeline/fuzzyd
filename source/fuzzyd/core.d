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
alias bonusFn = long function(Input);

private:

class Input
{
    string value;
    dchar i, p;
    int row, col;
    long[Tuple!(int, int)] history;

    final void set(dchar i, dchar p, int col, int row, long[Tuple!(int, int)] history)
    {
        this.i = i;
        this.p = p;
        this.col = col;
        this.row = row;
        this.history = history;
    }

    final bool isMatch()
    {
        return i.toLower == p.toLower;
    }

    final bool isCaseSensitiveMatch()
    {
        return i.isUpper && p.isUpper && isMatch;
    }
}

long previousCharBonus(Input input)
{
    long* bonus = tuple(input.row - 1, input.col - 1) in input.history;
    return bonus !is null ? 2 * *bonus : 0;
}

long startBonus(Input input)
{
    return (input.col == 0 && input.row == 0) ? 10 : 0;
}

long caseMatchBonus(Input input)
{
    return input.isCaseSensitiveMatch ? 15 : 0;
}

public:

/// fuzzy search result
struct FuzzyResult
{
    string value; //// entry. e.g "Documents/foo/bar/"
    long score; //// similarity metric. (Higher better)
    uint[] matches; //// index of matched characters (0 = miss , 1 = hit).
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
   // [FuzzyResult("bar", 25, [1, 0, 1]), FuzzyResult("baz", 20, [1, 0, 0]), FuzzyResult("foo", 0, [0, 0, 0])]
 * --------------------
 */
fuzzyFn fuzzy(string[] db)
{
    bonusFn[] bonusFns = [&previousCharBonus, &startBonus, &caseMatchBonus];

    long charScore(Input input)
    {
        return input.isMatch ? reduce!((acc, f) => acc + f(input))(10L, bonusFns) : 0;
    }

    FuzzyResult score(Input input, string pattern)
    {
        long score = 0;
        long simpleMatchScore = 0;
        long[Tuple!(int, int)] history;
        uint[] matches = new uint[input.value.walkLength];
        int row, col;
        foreach (p; pattern.byCodePoint)
        {
            foreach (i; input.value.byCodePoint)
            {
                input.set(i, p, col, row, history);
                const charScore = charScore(input);
                if (charScore >= 10)
                {
                    matches[row] = 1;
                    history[tuple(row, col)] = charScore;
                }

                if (charScore == 10)
                    simpleMatchScore += charScore;
                else
                    score += charScore;

                row++;
            }
            col++;
            row = 0;
        }

        const totalScore = score + (simpleMatchScore / 2);
        return FuzzyResult(input.value, totalScore, matches);
    }

    void search(string pattern, ref FuzzyResult[] result)
    {
        Input input = new Input();
        for (long i = 0, max = result.length; i < max; i++)
        {
            input.value = db[i];
            result[i] = score(input, pattern);
        }
    }

    return &search;
}
