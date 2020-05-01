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

alias fuzzyFn = long delegate(string, ref FuzzyResult[]);

private:

long consecutiveBonus(ref long[] lidx, long cidx)
{
    return lidx.length > 0 && lidx[$ - 1] == cidx - 1 ? 20 : 0;
}

long caseMatchBonus(dchar x, dchar y)
{
    return x.isUpper && y.isUpper ? 15 : 0;
}

long firstIdx(long idx)
{
    return idx == 0 ? 10 : 0;
}

public:

/// fuzzy search result
struct FuzzyResult
{
    string value; /// entry. e.g "Documents/foo/bar/"
    long score; /// similarity metric. (Higher better)
    long[] matches; /// index of matched characters (0 = miss , 1 = hit).
    bool isMatch; /// return true if consecutive characters are matched.
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
   // [FuzzyResult("foo", 0, [], false), FuzzyResult("bar", 1030, [0, 2], true), FuzzyResult("baz", 20, [0], false)]
 * --------------------
 */
fuzzyFn fuzzy(string[] db)
{

    FuzzyResult score(ref string txt, ref dchar[] pattern)
    {
        if (pattern == "")
            return FuzzyResult(txt, 0, [], true);

        const patternLength = pattern.length;
        long score = 0;
        bool start, end;

        long[] lidx;
        long j = 0;
        long i = 0;
        foreach (t; txt.byCodePoint)
        {
            if (t.toLower == pattern[j].toLower)
            {
                score += 10;
                score += firstIdx(i) + consecutiveBonus(lidx, i) + caseMatchBonus(t, pattern[j]);
                if (j == 0)
                    start = true;

                j++;
                lidx ~= i;
                if (j == patternLength)
                {
                    end = true;
                    break;
                }
            }
            i++;
        }
        if (start && end)
        {
            score += 1000;
        }
        return FuzzyResult(txt, score, lidx, start && end);
    }

    long search(string pattern, ref FuzzyResult[] result)
    {
        long totalMatches = 0;
        auto p = pattern.byCodePoint.array;
        for (long i = 0, max = result.length; i < max; i++)
        {
            result[i] = score(db[i], p);
            if (result[i].isMatch)
                totalMatches++;
        }
        return totalMatches;
    }

    return &search;
}
