#!/bin/bash

# The script is designed to commit code by the same authors as previously
#
# Possible strategies
####   
#    1. For all changed files, collect all authors of original lines
#    2. For each author: pass through all changes, see if he owned it, stage and commit 
#    
# TODO
# If lines are removed: do nothing
# If lines are added: consider author at the previous line
#     OR: if there is a conflict (m.b. trying to commit new code, then, abort)
####
#    1. Collect all authors in git
#    2. For each author, call clang-format for lines he edited
#    3. Commit it
# 
# TODO
# There may be case of overriding the authors
####
# TODO
# cosider spaces in filenames
# split author name and email correctly (now, "~~~~~~" is used for joining and grepping)
# sanity check: if collect_change_authors does not contain "Not Committed Yet <not.committed.yet>

# Collect all git blame information
# Example output:
# 645c8c7feaf5d9e421f3a29dae96411e1aa1cf47 76 76 2
# author Tobias Olausson
# author-mail <tobias.olausson@pelagicore.com>
# author-time 1483545390
# author-tz +0100
# filename libsoftwarecontainer/src/gateway/network/networkgatewayparser.h

extract_git_blame_info() {
    git blame --line-porcelain HEAD $1 \
	| grep -v "^previous " \
	| grep --no-group-separator "^author " -B 1 -A 9 \
	| grep -v "^committer[- ]" | grep -v "^summary " \
        | awk '{if(NR%6==1){print "line",$2}else{print;if(NR%6==0){print "######"}}}'
}

# Collect change authors and glue them in one line 
# return an array with name and email
collect_change_authors() {
    extract_git_blame_info $1 | xargs -n7 -d '\n' bash -c 'echo $1 %%%%%% $2 | sed "s/author //" | sed "s/author-mail //"' | sort | uniq
}

export -f extract_git_blame_info
export -f collect_change_authors

show_all_git_changed_files() {
    # TODO: use git-ls-files to see changed files
    git status --porcelain=2 --untracked-files=no | awk '{print $9}'
}

show_all_git_files() {
    # TODO: exclude submodules
    git ls-files $(git rev-parse --show-toplevel) HEAD
}

check_if_state_is_clean() {
     # TODO: return 1 if state is not clean (changed files), 0 otherwise
     return 0
}

list_submodules() {
    # INFO: print relative path to submodule
    git submodule status | awk '{print $2}'
}

cur_timestamp() {
    date "+%s.%N"
}

collect_lines_for_authors()
{
    field_sep=$IFS
    
    # TODO: authors generation takes a lot of time
    echo $(cur_timestamp) Get files
    files=$(show_all_git_files | tr '\n' ';')

#    echo $(cur_timestamp) Get authors
#    authors=$(show_all_git_files | xargs -n1 -I % bash -c "collect_change_authors %" | tr '\n' ';')

    echo $(cur_timestamp) Get submodules
    submodules=$(list_submodules | tr '\n' ';')

    if ! check_if_state_is_clean; then
    	echo "ERROR: files are already changed. Repository state should be clean"
    	exit 1
    fi
    
    IFS=';'
#    for a in $authors
#    do
        a="Jacques GUILLOU %%%%%% <jacques.guillou@pelagicore.com>"
    	echo "Apply changes for $a"
#		for f in $files
#		do
                    f="../libsoftwarecontainer/src/container.cpp"
			echo "$f: reformat lines changed by $a"

			if echo $submodules | grep -q $f; then
			    # echo "WARNING: ignoring submodule $f"
			    continue
			fi
        	    # TODO: make output in the format:
                    # author <author>
                    # author-email <email>
                    # lines_changed <from> <to>
        	
        	# HINT: sed prints first and last line from git blame output
    		# TODO: with first, last lines, what if something is inbetween from another author?
		echo $f \
			| xargs -n1 -I % bash -c "extract_git_blame_info %" \
			| xargs -n7 -d '\n' bash -c 'echo $0 %%%%%% $1 %%%%%% $2 | sed "s/line //" | sed "s/author //" | sed "s/author-mail //"' | grep $a \
			| awk '{print}' \
			| sort -n | uniq \
			| awk -f get-intervals.awk

#	    done
        # TODO: remove
        exit 1
#    done
    IFS=$field_sep
}

gen_random_string() {
    xxd -l4 -ps /dev/urandom
}

get_current_branch() {
     git branch | grep "^*" | awk '{print $2}'
}

method_2() {
    echo "Make prerequisite checks"
    # Check if there are no changes to repository
    cnt=$(show_all_git_changed_files | wc -l)
    if [ $cnt -ne 0 ]; then
        echo "ERROR: Cannot work with already changed files"
        exit 1
    fi

    echo "Create temporary git branch"
    cur_branch=$(get_current_branch)
    if ! $(echo $cur_branch | grep -q "^TMP-BRANCH-"); then
	    echo "Create temporary branch"
	    tmp_branch_name="TMP-BRANCH-$(gen_random_string)"
	    git checkout -b $tmp_branch_name
	    if [ ! $? ]; then
	        echo "ERROR: Failed to swich to temporary branch: $tmp_branch_name"
		exit 1
	    fi
    fi

    collect_lines_for_authors
#    field_sep=$IFS
#    files_and_lines=$(collect_lines_for_authors | tr '\n' ';')
#    echo $files_and_lines
#    IFS=';'
#    for fal in $(collect_lines_for_authors)
#    do
#        echo $fal
#        IFS=' ' read -a wordarr <<< "$fal"
#
#        if [ -z ${wordarr[4]} ]; then
#            wordarr[4]=${wordarr[3]}
#        fi
#        set -x
#        clang-format -i ${wordarr[0]} --lines=${wordarr[3]}:${wordarr[4]}
#        set +x
#    done
#    IFS=$field_sep

    echo "Commit changes by using author: <TODO>"
}

echo "Run clang-format for all lines for each author"
method_2

# echo "../libsoftwarecontainer/src/gateway/network/networkgateway.cpp" | xargs -I % bash -c "extract_git_blame_info %"

