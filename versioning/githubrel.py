#!/usr/bin/env python3

import github_release as grel
import os, sys, argparse, requests, json, re, ast

# replace with 'ess-dmsc/event-formation-unit'
# or even better infer from the repo in current working dir
repo = 'mortenjc/sandbox'

# print error message and exit
def error_exit(errMsg):
  print("Error: {}".format(errMsg))
  sys.exit(1)

# check if a release already exists by asking for its info
def release_exists(tag):
  try:
    grel.get_release_info(repo, tag)
  except:
    return False
  return True

# check that version tag corresponds to the agreed format, exit if not
def check_tag_valid(tag):
    res = re.match('v?([0-9])\.([0-9])\.([0-9])', tag)
    if res:
        return True
    error_exit("tag {} has invalid format".format(tag))


# download file from url to file and return filename
def get_file_from_url(url):
    filename=os.path.basename(url)
    if url != "":
        print("Get asset from URL")
        try:
            tmpfile = requests.get(url)
            open(filename, 'wb').write(tmpmyfile.content)
            return filename
        except:
            error_exit("unable to retrieve url to disk")
    return ""


#def show_releases():
#    releases = grel.get_releases(repo)
#    for rel in releases:
#        res = re.match('tag_name.*:.*v', tag)

#
# #
#
def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-r', '--release',
                       help = "release tag",
                       type = str, required=True, default = "")
    parser.add_argument('-u', '--url',
                       help = "asset download URL",
                       type = str, default = "")
    parser.add_argument('-c', '--commit_hash',
                       help = "referenced hash",
                       type = str, default = "")
    parser.add_argument('-d', '--delete', action='store_true', help = "delete release")
#    parser.add_argument('-l', '--list', action='store_true', help = "list current releases")


    args = parser.parse_args()

    # if args.list:
    #     show_releases();
    #     sys.exit(0);

    check_tag_valid(args.release)

    if args.delete:
        print("delete release")
        grel.gh_release_delete(repo, args.release)
        sys.exit(0)

    # Should validate release string
    print("Check for existing release")
    if release_exists(args.release):
        error_exit("Release {} already exists, exiting ...".format(args.release))

    asset = get_file_from_url(args.url)

    print("Creating release")
    
    grel.gh_release_create(repo, args.release, publish=True, target_commitish=args.commit_hash, asset_pattern=asset)

    print("Done")

#
if __name__ == '__main__':
    main()
