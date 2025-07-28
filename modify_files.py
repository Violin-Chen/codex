#!/usr/bin/env python3
import os

HEADER = "`ifdef SMBUS_SS_DVENV\n"
FOOTER = "`endif // SMBUS_SS_DVENV\n"


def modify_file(path):
    with open(path, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    with open(path, 'w', encoding='utf-8') as f:
        f.write(HEADER + content + FOOTER)


def main():
    script_name = os.path.basename(__file__)
    for entry in os.listdir('.'):        
        if os.path.isfile(entry) and entry != script_name:
            modify_file(entry)


if __name__ == '__main__':
    main()
