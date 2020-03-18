# Smart Git format tool

## Description

The tool allows to reformat the code not changing the authorship. That means, `git blame` will show (in most cases) the same author that committed reformatted code as before.

## Heuristics

The scripts collects authors from the files, then for each author, the script updates lines which were last committed by author and commits them using git author option.

## TODO

