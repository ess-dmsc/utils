#!/bin/bash

version_str="3.0.0"

usage_str="\
USAGE: $0 [OPTIONS] <path> <version> <commit>
  Substitute variables in conanfile and build Conan package
"

description_str="\
DESCRIPTION:
  <path> must be the path to a directory containing a conanfile.py and a test
  package. Its conanfile.py and test_package folder are copied into a
  destination folder that must not already exist, named conan_packaging by
  default, and <version> and <commit> are substituted using sed. The package is
  built and the destination folder is removed afterwards, unless -k is used.
  The destination folder name can be changed with -d. If -r is not set, a '+'
  character and the first seven characters of <commit> are appended to
  <version>.
"

options_and_returns_str="\
OPTIONS:
  -h            Print help and exit
  -u <user>     Set package user name (default: ess-dmsc)
  -c <channel>  Set package channel name (default: testing)
  -d <dest>     Destination folder name (default: conan_packaging)
  -r            Create release package
  -k            Keep destination package folder
  -v            Print version and exit

ENVIRONMENT VARIABLES:
  pkg_version  replaces version
  pkg_commit   replaces commit
  is_release       set to omit commit number from version string

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

while getopts "d:u:c:rkhv" arg; do
    case "${arg}" in
        u)
            pkg_user="${OPTARG}"
            ;;
        c)
            pkg_channel="${OPTARG}"
            ;;
        d)
            dest_folder="${OPTARG}"
            ;;
        r)
            is_release="TRUE"
            ;;
        k)
            keep_folder="TRUE"
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

if [ $# -lt 3 ] ; then
    >&2 echo "Error: missing arguments"
    >&2 echo ""
    usage
    exit 2
fi

if [ $# -gt 3 ] ; then
    >&2 echo "Error: too many arguments"
    >&2 echo ""
    usage
    exit 2
fi

conan_dir=$1
pkg_version=$2
pkg_commit=$3

if [ ! -d "$conan_dir" ] ; then
    >&2 echo "Error: invalid directory"
    >&2 echo "  $conan_dir"
    >&2 echo ""
    usage
    exit 2
fi

if [ -z "$pkg_version" ] ; then
    >&2 echo "Error: version cannot be empty"
    >&2 echo ""
    usage
    exit 2
fi

if [ -z "$pkg_commit" ] ; then
    >&2 echo "Error: commit cannot be empty"
    >&2 echo ""
    usage
    exit 2
fi

if [ -z "$pkg_user" ] ; then
    pkg_user="ess-dmsc"
fi

if [ -z "$pkg_channel" ] ; then
    pkg_channel="testing"
fi

if [ -z "$dest_folder" ] ; then
    dest_folder="conan_packaging"
fi

if [ -d "$dest_folder" ] ; then
    >&2 echo "Error: destination folder already exists"
    >&2 echo "  $dest_folder"
    >&2 echo ""
    usage
    exit 2
fi

# Packaging
# =========

# If this is not a release, add commit information to version string.
if [ -z "$is_release" ] ; then
    # Get first seven characters in string.
    commit_short="$(echo $pkg_commit | awk '{print substr($0,0,7)}')"
    pkg_version="${pkg_version}+${commit_short}"
fi

mkdir "$dest_folder"
cp "${conan_dir}/conanfile.py" "${dest_folder}/" || exit 2
cp -r "${conan_dir}/test_package" "${dest_folder}/" || exit 2

# Substitute values in conanfile.py.
sed -i"" -e "s/<version>/${pkg_version}/g" "$dest_folder"/conanfile.py
sed -i"" -e "s/<commit>/${pkg_commit}/g" "$dest_folder"/conanfile.py

# Print script and packaging information.
version
echo "pkg_version=${pkg_version}"
echo "pkg_commit=${pkg_commit}"
echo "conan_dir=${conan_dir}"
echo "dest_folder=${dest_folder}"

# Create package.
current_dir="$(pwd)"
cd "$dest_folder" && conan create "${pkg_user}/${pkg_channel}"
result=$?
if [ $result -ne 0 ] ; then
    >&2 echo "Error: packaging failed with return code $result"
    exit 1
fi
cd "$current_dir"

# Delete packaging folder if not requested to keep it.
if [ "$keep_folder" != "TRUE" ] ; then
    rm -rf "$dest_folder" || exit 2
fi

exit 0
