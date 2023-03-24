#!/usr/bin/env python3

"""
Solve app dependencies defined in 'app.json' file.
@note Updated 2023-03-24.

@examples
./app-dependencies.py 'mamba'
"""

from argparse import ArgumentParser
from json import load
from os.path import abspath, dirname, join
from sys import exit as sys_exit


def get_deps(app_name: str, json_data: dict) -> list:
    """
    Get unique build dependencies and dependencies in an ordered list.
    @note Updated 2023-03-24.
    """
    build_deps = []
    deps = []
    if "build_dependencies" in json_data[app_name]:
        build_deps = json_data[app_name]["build_dependencies"]
    if "dependencies" in json_data[app_name]:
        deps = json_data[app_name]["dependencies"]
    out = build_deps + deps
    # This makes list unique but keeps order intact, whereas usage of 'set()'
    # can rearrange.
    out = list(dict.fromkeys(out))
    return out


def main(app_name: str, json_file: str):
    """
    Parse the koopa 'app.json' file for defined values.
    @note Updated 2023-03-20.
    """
    with open(json_file, encoding="utf-8") as con:
        json_data = load(con)
        keys = json_data.keys()
        if app_name not in keys:
            sys_exit(1)
        deps = get_deps(app_name=app_name, json_data=json_data)
        if not deps:
            return True
        i = 0
        # FIXME We need to work on appending the list here...need to
        # use '.append' for that I think...
        lst = [[]]
        lst[i] = deps
        while i + 1:
            deps2 = lst[i]
            deps3 = [[]]
            j = 0
            for app_name in deps2:
                print(app_name)
                print(j)
                xxx = get_deps(app_name=app_name, json_data=json_data)
                if xxx:
                    deps3[j] = xxx
                j = j + 1
            print(len(deps3))
            print(deps3)
            break
            i = i + 1
        # print(lst)
        # print(lst[0])
        return True


parser = ArgumentParser()
parser.add_argument('app_name', nargs='?', type=str)
args = parser.parse_args()

_json_file = abspath(join(dirname(__file__), "../../etc/koopa/app.json"))

main(app_name=args.app_name, json_file=_json_file)
