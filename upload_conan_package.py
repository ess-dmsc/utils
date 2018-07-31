import argparse
from conans.client.conan_api import Conan
import mmap

parser = argparse.ArgumentParser()
parser.description = "Upload Conan package"
parser.add_argument("-f", "--filepath")
parser.add_argument("path")
parser.add_argument("remote", type=str)
parser.add_argument("user", type=str)
parser.add_argument("channel", type=str)
parser.epilog = ''' returns:
 0=success,
 1=packaging error,
 2=script error '''
args = parser.parse_args()


def find_in_conanfile(conan_lib_property):
    try:
        with open(args.path, 'rb', 0) as file, \
             mmap.mmap(file.fileno(), 0, access=mmap.ACCESS_READ) as s:
            start_index = s.find(conan_lib_property + b' =')
            nl_index = s.find(b'\n', start_index)
            return str(s[start_index:nl_index]).split("= ")[1].replace("\"", "").replace("\'", "")
    except FileNotFoundError as e:
        print("Error: script file not found: ", e)
        exit(2)
    except Exception as e:
        print("Error: script error", e)
        exit(2)


name = find_in_conanfile(b'name')
version = find_in_conanfile(b'version')

pkg = "{}/{}@{}/{}".format(name, version, args.user, args.channel)

try:
    Conan.upload(args.path, remote=args.remote, all_packages=True)
except AttributeError:
    print("Error: packaging failed")
    exit(1)
exit(0)
