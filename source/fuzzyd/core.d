module fuzzyd.core;

import std.stdio;
import std.array;
import std.range;
import std.container.rbtree;
import std.math;
import std.conv;
import std.uni;
import std.algorithm.iteration;
import std.algorithm.sorting;
import std.algorithm : max;

alias fuzzyFn = void delegate(string, ref FuzzyResult[]);
alias bonusFn = double function(Input);

private:

class Input
{
    string value;
    dchar i, p;
    int row, col;
    double[int] previousBonus;

    void set(dchar i, dchar p, int col, int row, double[int] previousBonus) {
        this.i = i;
        this.p = p;
        this.col = col;
        this.row = row;
        this.previousBonus = previousBonus;
    }

    bool isMatch()
    {
        return i.toLower == p.toLower;
    }

    bool isCaseSensitiveMatch()
    {
        return i.isUpper && p.isUpper && isMatch;
    }
}

double previousCharBonus(Input input)
{
    const r = input.row-1;
    return (r in input.previousBonus) ? 2.5 * input.previousBonus[r] : 0;
}

double startBonus(Input input)
{
    return (input.col == 0 && input.row == 0) ? 1 : 0;
}

double caseMatchBonus(Input input)
{
    return input.isCaseSensitiveMatch ? 1.5 : 0;
}

void normalize(ref FuzzyResult[] result)
{
    const maxScore = !result.empty ? result[0].score : 1;
    for (long i = 0; i < result.length; i++)
    {
        result[i].score /= maxScore;
    }
}

public:

/// fuzzy search result
struct FuzzyResult
{
    string value; //// entry. e.g "Documents/foo/bar/"
    double score; //// similarity metric. (Higher better)
    RedBlackTree!(int, "a < b", false) matches; //// index of matched characters.
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

    double charScore(Input input)
    {
        return input.isMatch ? reduce!((acc, f) => acc + f(input))(1.0, bonusFns) : 0;
    }

    FuzzyResult score(Input input, string pattern)
    {
        double score = 0;
        double simpleMatchScore = 0;
        auto matches = redBlackTree!int();
        double[int] previousMatches;
        double[int] currentMatches;
        int row, col;
        foreach (p; pattern.byCodePoint)
        {
            foreach (i; input.value.byCodePoint)
            {
                input.set(i, p, col, row, previousMatches);
                const charScore = charScore(input);
                if (charScore > 0) {
                    matches.insert(row);
                    currentMatches[row] = charScore;
                }

                if (charScore is 1.0)
                    simpleMatchScore += 1;
                else
                    score += charScore;

                row++;
            }
            previousMatches = currentMatches;
            col++;
            row = 0;
        }

        const totalScore = score + (simpleMatchScore / 2.0);
        return FuzzyResult(input.value, totalScore, matches);
    }

    void search(string pattern, ref FuzzyResult[] result)
    {
        Input input = new Input();
        for (int i = 0; i < result.length; i++)
        {
            input.value = db[i];
            result[i] = score(input, pattern);
        }

        result.sort!("a.score > b.score");
        normalize(result);
    }

    return &search;
}
