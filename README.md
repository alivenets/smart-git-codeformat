# Smart Git format tool

## Description

The tool allows to reformat the code not changing the authorship. That means, `git blame` will show (in most cases) the same author that committed reformatted code as before.

## How to use

To find out available options, run:
```
$ smart-git-codeformat -h
```

## Heuristics

The script collects authors from the files, then for each author, the script updates lines which were last committed by author and commits them using git author option.

## TODO

* For C++ and clang-format, consider:

  1. comments formatting
  2. `#include`s formatting. HINT: One of the options may be: the last one (or the main one designated in priority list, reformats the file in the end again to have consistent formatting)

* Ignore submodules
* Optimize python loops
* Consider cmake-format, clang-format and other formatting tools
* Use prioritized author lists to select author commit priority; also, consider author replacement with another author
* Initialize temporary branch in the script
* Dry run mode (patch generation without commits)
* Use GitPython to work with Git
