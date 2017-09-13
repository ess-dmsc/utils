#!/bin/bash

usage() {
    echo "USAGE: clangformatdiff.sh [OPTIONS] <filenames>"
    echo "  <filenames> is a whitespace-separated list of files to be checked."
    echo ""
    echo "OPTIONS:"
    echo "  -h          print this message and exit"
    echo "  -f          use .clang-format style file"
    echo "  -s <style>  use <style> (default: LLVM)"
    echo ""
    echo "  The -f and -s options are exclusive."
    echo ""
    echo "RETURNS:"
    echo "  0  if all files conform to the formatting style"
    echo "  1  if any difference is found"
    echo "  2  if an error occurs"
    exit 2
}

while getopts "fs:h" arg; do
    case "${arg}" in
        f)
            usefile="TRUE"
            ;;
        s)
            style="${OPTARG}"
            ;;
        h)
            usage
            ;;
    esac
done

shift $((OPTIND-1))

if [ $# -eq 0 ] ; then
    >&2 echo "Error: missing filenames"
    >&2 echo ""
    usage
fi

if [ "$usefile" -a "$style" ] ; then
    >&2 echo "Error: -f and -s options are exclusive"
    >&2 echo ""
    usage
fi

result=0

for filename in $@; do
    if [ -d "$filename" ] ; then
        echo "Error: cannot process directories"
        echo "  $filename"
        exit 2
    fi

    if [ ! -f "$filename" ] ; then
        echo "Error: no such file"
        echo "  $filename"
        exit 2
    fi

    if [ "$usefile" ] ; then
        output=$(clang-format -style=file "$filename" | diff "$filename" -)
    elif [ "$style" ] ; then
        output=$(clang-format -style=$style "$filename" | diff "$filename" -)
    else
        output=$(clang-format -style=LLVM "$filename" | diff "$filename" -)
    fi

    if [ ! -z "$output" ] ; then
        printf "%s\n%s\n\n" "${filename}:" "${output}"
        result=1
    else
        printf "%s\n%s\n\n" "${filename}:" "No differences found"
    fi
done

if [ $result -eq 0 ] ; then
    echo "clangformatdiff.sh: files conform to format"
else
    >&2 echo "Error: differences found"
fi

exit $result
