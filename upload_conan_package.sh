#!/bin/bash

version_str="1.1.2"

usage_str="\
USAGE: $0 [OPTIONS] <path> <remote> <user> <channel>
  Upload Conan package
"

description_str="\
DESCRIPTION:
  <path> must point to a conanfile.py from which the package name and version
  will be obtained using grep. The package is then uploaded to <remote> as

    <name>/<version>@<user>/<channel>

  If -f <filepath> is used, the full package name is appended to <filepath>.
"

options_and_returns_str="\
OPTIONS:
  -h             print help and exit
  -v             print version and exit
  -f <filepath>  append full package name to <filepath>

RETURNS:
  0  success
  1  packaging error
  2  script error
"

usage() {
    printf "%s\n%s" \
        "$usage_str" \
        "$options_and_returns_str"
}

full_usage() {
    printf "%s\n%s\n%s" \
        "$usage_str" \
        "$description_str" \
        "$options_and_returns_str"
}

version() {
    printf "$0 version %s\n" "$version_str"
}

# Argument and option handling
# ============================

unset is_release
unset keep_folder
unset append_pkg_name_to_file
unset dest_pkg_name_file

while getopts "f:hv" arg; do
    case "${arg}" in
        f)
            append_pkg_name_to_file="TRUE"
            dest_pkg_name_file="${OPTARG}"
            ;;
        h)
            full_usage
            exit 0
            ;;
        v)
            version
            exit 0
            ;;
    esac
done

shift $((OPTIND-1))

if [ $# -lt 4 ] ; then
    >&2 echo "Error: missing arguments"
    >&2 echo ""
    usage
    exit 2
fi

if [ $# -gt 4 ] ; then
    >&2 echo "Error: too many arguments"
    >&2 echo ""
    usage
    exit 2
fi

conanfile_path=$1
conan_remote=$2
conan_user=$3
conan_channel=$4

if [ ! -f "$conanfile_path" ] ; then
    >&2 echo "Error: file not found"
    >&2 echo "  $conanfile_path"
    >&2 echo ""
    usage
    exit 2
fi

if [ -z "$conan_remote" ] ; then
    >&2 echo "Error: remote cannot be empty"
    >&2 echo ""
    usage
    exit 2
fi

if [ -z "$conan_user" ] ; then
    >&2 echo "Error: user cannot be empty"
    >&2 echo ""
    usage
    exit 2
fi

if [ -z "$conan_channel" ] ; then
    >&2 echo "Error: channel cannot be empty"
    >&2 echo ""
    usage
    exit 2
fi

if [ -n "$append_pkg_name_to_file" -a -z "$dest_pkg_name_file" ] ; then
    >&2 echo "Error: file path cannot be empty"
    >&2 echo ""
    usage
    exit 2
fi

# Uploading
# =========

# Get package name from conanfile.py.
pkg_name=$(conan inspect --attribute name ${conanfile_path} | awk '{print $2}')

# Get package version from conanfile.py.
pkg_version=$(conan inspect --attribute version ${conanfile_path} | awk '{print $2}')

pkg="${pkg_name}/${pkg_version}@${conan_user}/${conan_channel}"

echo "Uploading package ${pkg} to ${conan_remote}"

conan upload --all --remote "$conan_remote" "$pkg"
result=$?
if [ $result -ne 0 ] ; then
    >&2 echo "Error: packaging failed with return code $result"
    exit 1
fi

if [ -n "$dest_pkg_name_file" ] ; then
    echo "$pkg" >> "$dest_pkg_name_file"
fi

exit 0
