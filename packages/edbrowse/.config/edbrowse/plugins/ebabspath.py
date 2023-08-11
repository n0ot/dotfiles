#!/usr/bin/env python3

import os
import sys

from urllib import parse

if len(sys.argv) < 2:
    print(f"Usage: {sys.argv[0]} <path>", file=sys.stderr)
    sys.exit(1)

relpath = sys.argv[1]
scheme, netloc, *_ = parse.urlsplit(relpath)

if scheme != '' or netloc != '':
    print(relpath)  # This is a URL
else:
    print(os.path.abspath(relpath))  # This is probably a path to a file
