#!/usr/bin/env python3

import sys
from pathlib import Path

from gdtoolkit.parser import parser
from lark import Tree


def check_duplicate_functions(tree):
    functions = {}
    errors = []

    def walk_tree(node, depth=0):
        if isinstance(node, Tree):
            if node.data == "func_def":
                func_name = None
                for child in node.children:
                    if isinstance(child, Tree) and child.data == "func_header":
                        func_name = str(child.children[0])
                        break

                if func_name:
                    if func_name in functions:
                        errors.append(f"Duplicate function definition: '{func_name}'")
                    else:
                        functions[func_name] = True

            for child in node.children:
                walk_tree(child, depth + 1)

    walk_tree(tree)
    return errors


def validate_file(filepath):
    try:
        with open(filepath, "r") as f:
            content = f.read()

        tree = parser.parse(content)
        errors = check_duplicate_functions(tree)

        return errors
    except Exception as e:
        return [f"Parse error: {str(e)}"]


def main():
    script_files = list(Path(".").rglob("*.gd"))
    script_files = [
        f
        for f in script_files
        if ".godot" not in str(f) and "validate_scripts.gd" not in str(f)
    ]

    total_checked = 0
    total_failed = 0

    print("Validating GDScript files...")

    for filepath in sorted(script_files):
        total_checked += 1
        errors = validate_file(filepath)

        if errors:
            total_failed += 1
            print(f"❌ {filepath}")
            for error in errors:
                print(f"   {error}")

    print(f"\nChecked {total_checked} files")

    if total_failed > 0:
        print(f"❌ {total_failed} file(s) failed validation")
        return 1
    else:
        print("✅ All files passed validation")
        return 0


if __name__ == "__main__":
    sys.exit(main())
