#!/bin/bash

version_str="1.0.1"

usage_str="\
USAGE: $0 [OPTIONS] <path> <remote> <user> <channel>
  Upload Conan package
"

description_str="\
DESCRIPTION:
  <path> must point to a conanfile.py from which the package name and version
  will be obtained using grep. The package is then uploaded to <remote> as

    <name>/<version>@<user>/<channel>
"

options_and_returns_str="\
OPTIONS:
  -h            Print help and exit
  -v            Print version and exit

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

while getopts "hv" arg; do
    case "${arg}" in
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

# Uploading
# =========

# Get package name from conanfile.py.
pkg_name=$(grep "name = " ${conanfile_path} | awk '{print $3}')
# Remove quotes from package name.
pkg_name=$(echo $pkg_name | sed -e "s/\"//g")

# Get package version from conanfile.py.
pkg_version=$(grep "version = " ${conanfile_path} | awk '{print $3}')
# Remove quotes from package name.
pkg_version=$(echo $pkg_version | sed -e "s/\"//g")

pkg="${pkg_name}/${pkg_version}@${conan_user}/${conan_channel}"

echo "Uploading package ${pkg} to ${conan_remote}"

conan upload --all --remote "$conan_remote" "$pkg"
result=$?
if [ $result -ne 0 ] ; then
    >&2 echo "Error: packaging failed with return code $result"
    exit 1
fi

exit 0
