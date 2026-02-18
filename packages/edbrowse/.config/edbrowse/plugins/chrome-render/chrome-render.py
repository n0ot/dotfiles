#!/usr/bin/env python

import os
import pathlib
import subprocess
import sys

from playwright.sync_api import sync_playwright

if len(sys.argv) < 2:
    print(f"Usage: {sys.argv[0]} <url>", file=sys.stderr)
    sys.exit(1)

# Edbrowse prepends `chrmrndr://` to the URL to call the plugin that executes this script.
url = sys.argv[1].removeprefix('chrmrndr://')
if os.path.exists(url):
    url = pathlib.Path(os.path.abspath(url)).as_uri()

launch_args = {
    "headless": True,
    "args": ["--blink-settings=imagesEnabled=false"],
}

with sync_playwright() as p:
    try:
        browser = p.chromium.launch(**launch_args)
    except Exception:
        subprocess.run(
            [sys.executable, "-m", "playwright", "install", "chromium"],
            check=True,
        )
        browser = p.chromium.launch(**launch_args)
    page = browser.new_page()
    page.goto(url, wait_until="networkidle")
    sys.stdout.write(page.content())
    browser.close()
