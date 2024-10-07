# This script calculates a cache key for all the dependencies and their versions
# It recursively processes CMakeLists.txt and the included files, plus the submodules

import os
import sys
import hashlib
import subprocess
import argparse
import shlex
import re

def hash_file(path):
    with open(path, "rb") as f:
        digest = hashlib.sha1(f.read())
        return digest.hexdigest()

def git(command):
    args = ["git"] + shlex.split(command)
    result = subprocess.run(args, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if result.returncode != 0:
        raise Exception(f"git {command} failed with exit code {result.returncode}")
    return result.stdout.decode("utf-8").rstrip()

def process_includes(cmake_dir, cmake_path):
    status = [f"{hash_file(cmake_path)} {os.path.basename(cmake_path)}"]
    with open(cmake_path, "r") as f:
        for line in f.readlines():
            line = line.strip()
            if line.startswith("include("):
                include_file = line[8:-1]
                include_path = os.path.join(cmake_dir, include_file)
                if os.path.exists(include_path):
                    status += process_includes(cmake_dir, include_path)
    return status

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--debug", action="store_true")
    parser.add_argument("--short", action="store_true")
    args = parser.parse_args()

    # Process CMakeLists.txt and includes
    cmake_dir = os.path.dirname(__file__)
    os.chdir(cmake_dir)
    cmake_path = os.path.join(cmake_dir, "CMakeLists.txt")
    cmake_status = process_includes(cmake_dir, cmake_path)

    # Process submodules
    submodule_status = []
    for dir in sorted(os.listdir(cmake_dir)):
        if os.path.isdir(dir):
            try:
                hash = git(f"submodule status \"{os.path.abspath(dir)}\"").strip().split(" ")[0]
                submodule_status.append(f"{hash} {os.path.basename(dir)}")
            except:
                pass

    # Calculate the final hash
    final_status = str.join("\n", cmake_status)
    final_status += "\n"
    final_status += str.join("\n", submodule_status)
    file_hash = hashlib.sha1(final_status.encode("utf-8")).hexdigest()

    # Extract the restore_hash from the last commit message
    commit_message = git("log -1 --pretty=format:%s")
    match = re.search(r"(reuse_cache|reuse_hash|restore_hash|cache_hash)=([0-9a-f]+)", commit_message)
    if match:
        restore_hash = match.group(2)
    else:
        restore_hash = file_hash

    # Print the output variables
    if args.short:
        output_vars = file_hash[:8] + "\n"
    else:
        output_vars = ""
        output_vars += f"file_hash={file_hash}\n"
        output_vars += f"restore_hash={restore_hash}\n"
    sys.stdout.write(output_vars)

    # Additional debug output to stderr
    if args.debug:
        sys.stderr.write("Debug output:\n")
        sys.stderr.write(final_status + "\n")
        sys.stderr.write(output_vars)
        sys.stderr.flush()

if __name__ == "__main__":
    main()
