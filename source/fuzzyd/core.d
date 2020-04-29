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
import std.container.binaryheap;
import std.container.rbtree;
import std.algorithm.mutation;
import std.numeric;

alias fuzzyFn = void delegate(string, ref FuzzyResult[]);
alias bonusFn = long function(Input);

private:

class Input
{
    string value;
    dchar i, p;
    int row, col;
    long[int] previousBonus;

    final void set(dchar i, dchar p, int col, int row, long[int] previousBonus)
    {
        this.i = i;
        this.p = p;
        this.col = col;
        this.row = row;
        this.previousBonus = previousBonus;
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
    long* bonus  = (input.row-1) in input.previousBonus;
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
 * fuzzy(["foo", "bar", "baz"])("br");
 * // => [FuzzyResult("bar", 1, RedBlackTree([0, 2])), FuzzyResult("baz", 0.592593, RedBlackTree([0])), FuzzyResult("foo", 0, RedBlackTree([]))]
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
        long[int] previousMatches;
        long[int] currentMatches;
        uint[] matches = new uint[input.value.walkLength];
        ushort row, col;
        foreach (p; pattern.byCodePoint)
        {
            foreach (i; input.value.byCodePoint)
            {
                input.set(i, p, col, row, previousMatches);
                const charScore = charScore(input);
                if (charScore >= 10)
                {
                    matches[row] = 1;
                    currentMatches[row] = charScore;
                }

                if (charScore == 10)
                    simpleMatchScore += charScore;
                else
                    score += charScore;

                row++;
            }
            previousMatches = currentMatches;
            col++;
            row = 0;
        }

        const totalScore = score + (simpleMatchScore / 2);
        return FuzzyResult(input.value, totalScore, matches);
    }

    void search(string pattern, ref FuzzyResult[] result)
    {
        // auto maxpq = BinaryHeap!(FuzzyResult[], "a.score < b.score")(result, 0);
        Input input = new Input();
        for (int i = 0; i < result.length; i++)
        {
            input.value = db[i];
            // maxpq.insert(score(input, pattern));
            result[i] = score(input, pattern);
        }
        result.sort!("a.score > b.score");
    }

    return &search;
}
