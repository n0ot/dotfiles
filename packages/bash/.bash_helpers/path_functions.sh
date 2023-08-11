# Setting the complete path explicitly is not portable across systems. But if
# .bash_profile is sourced multiple times, $PATH will grow indefinitely, and
# the order will be unexpected.  The following functions allow for modifying
# the path in a more sane manner.

# prepend_to_path prepends each path_arg, removing existing copies if necessary.
prepend_to_path () {
    # Since each iteration through the loop will insert a path component before
    # the last, path_args must be inserted in reverse, so they are prepended in
    # the order in which they were passed.
    local i
    for ((i=$#; i>0; i--)); do
        local path_arg="${!i}"
        # If $path_arg is not at the beginning of the path, add it, and remove any existing copies.
        [[ "$PATH:" == "$path_arg":* ]] || PATH="$path_arg:${PATH//:"$path_arg"/}"
    done
}

# append_to_path appends each path_arg, only if it isn't already in the path.
append_to_path () {
    local path_arg
    for path_arg in $@; do
        # If $path_arg is not at the end of the path, add it, and remove any existing copies.
        [[ ":$PATH" == *:"$path_arg" ]] || PATH="${PATH//"$path_arg":/}:$path_arg"
    done
}

# remove_path_dupes removes duplicate components in $PATH, preferring the
# earlier entries.
remove_path_dupes () {
    [ -z "$PATH" ] && return
    local dir old_PATH="$PATH:"
    PATH=""
    # While processing, PATH and old_PATH will have the format
    # component1:component2:...componentN:
    # The trailing : means different logic isn't required for the lasst
    # entry.
    #
    # Remove components from old_PATH, adding them to PATH if they weren't already added beforehand.
    while [ -n "$old_PATH" ];do
        dir="${old_PATH%%:*}"  # Grab the first remaining component
        if [[ ":$PATH" != *:"$dir":* ]]; then
            PATH+="$dir:"
        fi
        old_PATH="${old_PATH#*:}"  # Remove this entry
    done
    PATH="${PATH%:}"  # Remove the trailing :
}

