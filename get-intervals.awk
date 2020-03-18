#!/usr/bin/awk -f

# The script does the following:
# Read list of integers as input
# Calculate intervals, filter number between intervals
# Output: interval borders, even number of rows
BEGIN {
    prev_inc = 0
    prev = 0
}

{
    # Print first line
    if (NR == 1) {
        prev = $0
        print
        next
    }

    # If the current line is increment, skip it
    split(prev,arr," ")
    if ($1 == arr[1] + 1) {
        prev_inc = 1 
    }
    else {
        # Print previous and current integer
        print prev
        print
        prev_inc = 0
    }
    prev = $0
}

END {
    # Print last line
    print prev
}