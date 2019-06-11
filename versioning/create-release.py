#!/usr/bin/env python3

from sh.contrib import git
from sh import cat
import os, sys, argparse, sh, re

version_file="VERSION"

# Update this script from github
def update_self(branch):
    previous_dir = os.getcwd()
    path, file = os.path.split(os.path.realpath(__file__))
    print("Update {} in {}".format(file, path))
    os.chdir(path)
    if branch == "":
        branch = 'master'
    check_branch(branch)
    repo_is_clean()
    gitcmd('fetch', 'git fetch failed')
    gitcmd('pull', 'git pull failed')
    os.chdir(previous_dir)
    print("Release script updated.")
    return

# print error message and exit
def error_exit(errMsg):
  print("Error: {}".format(errMsg))
  sys.exit(1)

# write the version string to the version file
def write_version(ver_str):
    try:
        f = open(version_file, "w")
        f.write(ver_str)
        f.close()
    except:
        error_exit('unable to write version to file')

# wrapper function for calling git commands
def gitcmd(command, error_string):
    try:
        res = git(command.split(' ')).strip('\n')
    except:
        error_exit(error_string)
    return res

# check for untracked files or uncommitted changes
def repo_is_clean():
    res = gitcmd('status --porcelain', 'git status failed')
    if res != '':
        error_exit('uncommitted changes or untracked files present')

# check if current branch matches the requested branch
def check_branch(branch):
    res = gitcmd('rev-parse --abbrev-ref HEAD', 'git rev-parse failed')
    if (res != branch):
        error_exit('current branch {} != {}'.format(res, branch))

def git_checkout_branch(branch):
    gitcmd('checkout {}'.format(branch), 'unable to checkout branch {}'.format(branch))

def git_checkout_create_branch(branch):
    res = gitcmd('checkout -b {}'.format(branch), 'unable to checkout/create branch {}'.format(branch))
    print(res)

# Return tags as a string, replace newlines with space
def git_get_tags():
    return gitcmd('tag', 'failed to get tags').replace('\n', ' ')


# used for both tags and VERSION file, strips leading 'v'
def version_from_string(ver_str):
    res = re.match('v?([0-9])\.([0-9])\.([0-9])', ver_str)
    if res:
        return [int(res.group(1)), int(res.group(2)), int(res.group(3))]
    else:
        return [0, 0, 0]

# Get latest version from version file (patch release only)
def latest_ver_from_file():
    try:
        res = cat(version_file).strip('\n')
    except:
        error_exit('failed to get version from file')
    return version_from_string(res)

# Get latest version from tags (major and minor releases only)
def latest_ver_from_list(versions):
    curmaj, curmin, curpat = [0, 0, 0]
    for v in versions.split(' '):
        maj, min, pat = version_from_string(v.replace(' ', ''))
        if (maj > curmaj) or (maj == curmaj and min > curmin) or (maj == curmaj and min == curmin and pat > curpat):
            curmaj, curmin, curpat = [maj, min, pat]
    return [curmaj, curmin, curpat]

# return version strings from version numbers
def strings_from_version(ver):
    version = '{}.{}.{}'.format(ver[0], ver[1], ver[2])
    tag = 'v'+version
    branch  = 'release-{}.{}'.format(ver[0], ver[1])
    return [version, tag, branch]

# increment major, minor or patch numbers, return new version strings
def bump_version(ver, release):
    if release == "major":
        new = [ver[0]+1, 0, 0]
    elif release == "minor":
        new = [ver[0], ver[1]+1, 0]
    elif release == "patch":
        new = [ver[0], ver[1], ver[2]+1]
    else:
        error_exit('Illegal relase (use major/minor/patch)')
    return strings_from_version(new)


#
# #
#
def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-r", metavar='release', choices=['major', 'minor', 'patch'],
                        help = "release method (major, minor, patch)",
                        type = str, default = "minor")
    parser.add_argument("-b", metavar='branch',
                        help = "branch (for patch releases, format: 'x.y')",
                        type = str, default = "")
    parser.add_argument("-u", action='store_true', help = "update this script")
    parser.add_argument("-i", action='store_true', help = "user confirmation before applying changes")
    parser.add_argument("-n", action='store_false', help = "don't fetch tags")
    args = parser.parse_args()

    if args.u:
        update_self(args.b)
        sys.exit(0)

    # initial sanity checks
    if args.r == 'patch' and args.b == "":
        error_exit('-r patch requires -b branch')

    if args.r != 'patch' and args.b != "":
        error_exit('-b branch can only be used with -r patch')

    check_branch('master')

    if os.path.isfile(version_file):
        error_exit('VERSION file in master branch is not allowed')

    repo_is_clean()

    # if -n is specified, skip fetching
    if args.n:
        gitcmd('fetch --tags', 'git fetch failed')

    # Release procedure
    if args.r == 'patch':
        print("checking out branch \"release-{}\"".format(args.b))
        git_checkout_branch('release-{}'.format(args.b))
        oldver = latest_ver_from_file()
    else:
        check_branch('master')
        oldver = latest_ver_from_list(git_get_tags())

    version, tag, branch = bump_version(oldver, args.r)

    print("Changes to be made:")
    print("  new version {}".format(version))
    print("  release tag {}".format(tag))
    print("  updates version in file \'{}\'".format(version_file))
    print("  on branch \"{}\"".format(branch))

    # do interactive prompt, last escape chance
    if args.i:
        reply = str(input('proceed? (y/n): ')).lower().strip()
        if reply[0] != 'y':
            print('release terminated by user')
            git_checkout_branch('master')
            sys.exit(1)

    if args.r != 'patch':
        git_checkout_create_branch(branch)

    check_branch(branch)
    write_version(version)
    gitcmd('add {}'.format(version_file), 'git add {} failed'.format(version_file))
    gitcmd('commit -m create-release.py:{}'.format(version), 'git commit failed')
    gitcmd('tag {}'.format(tag), 'git tag {} failed'.format(tag))
    gitcmd('push origin {} --follow-tags'.format(branch), 'git push failed')
    print("Release {} created.".format(version))
    git_checkout_branch('master')

#
if __name__ == '__main__':
    main()
