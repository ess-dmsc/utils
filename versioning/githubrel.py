#!/usr/bin/env python3

import github_release as grel
import sys, argparse, requests

repo = 'mortenjc/sandbox'

# print error message and exit
def error_exit(errMsg):
  print("Error: {}".format(errMsg))
  sys.exit(1)


def release_exists(tag):
  try:
    grel.get_release_info(repo, tag)
  except:
    return False
  return True



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
                       type = str, required=True, default = "")
  parser.add_argument('-c', '--commit_hash',
                       help = "referenced hash",
                       type = str, required=True, default = "")
  parser.add_argument("-d", action='store_true', help = "delete release")


  args = parser.parse_args()

  if args.d:
    print("delete release")
    grel.gh_release_delete(repo, args.release)
    sys.exit(0)

  # Should validate release string
  print("Check for existing release")
  if release_exists(args.release):
    error_exit("Release {} already exists, exiting ...".format(args.release))

  print("Get asset from URL")
  myfile = requests.get(args.url)
  open('files.gz', 'wb').write(myfile.content)

  print("Creating release")
  grel.gh_release_create(repo, args.release, publish=True, target_commitish=args.commit_hash, asset_pattern='files.gz')

  print("Done")

#
if __name__ == '__main__':
    main()
