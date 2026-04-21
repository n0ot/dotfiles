#!/usr/bin/env python

import os
import pathlib
import shutil
import subprocess
import sys

from playwright.sync_api import sync_playwright
from playwright_stealth import Stealth

if len(sys.argv) < 2:
    print(f"Usage: {sys.argv[0]} <url>", file=sys.stderr)
    sys.exit(1)

# Edbrowse prepends `chrmrndr://` to the URL to call the plugin that executes this script.
url = sys.argv[1].removeprefix('chrmrndr://')
if os.path.exists(url):
    url = pathlib.Path(os.path.abspath(url)).as_uri()

def _find(*candidates):
    for c in candidates:
        if c and os.path.isfile(c):
            return c
    return None

CHROME_PATH = _find(
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
    r"C:\Program Files\Google\Chrome\Application\chrome.exe",
    r"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
    shutil.which("google-chrome-stable"),
    shutil.which("google-chrome"),
)

BRAVE_PATH = _find(
    "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser",
    r"C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe",
    r"C:\Program Files (x86)\BraveSoftware\Brave-Browser\Application\brave.exe",
    shutil.which("brave-browser"),
    shutil.which("brave"),
)

launch_args = {
    "headless": True,
    "args": ["--blink-settings=imagesEnabled=false"],
}

def _launch(p):
    for kwargs in [
        {"executable_path": CHROME_PATH} if CHROME_PATH else None,
        {"executable_path": BRAVE_PATH} if BRAVE_PATH else None,
        {},
    ]:
        if kwargs is None:
            continue
        try:
            return p.chromium.launch(**launch_args, **kwargs)
        except Exception:
            pass
    subprocess.run(
        [sys.executable, "-m", "playwright", "install", "chromium"],
        check=True,
    )
    return p.chromium.launch(**launch_args)

with Stealth().use_sync(sync_playwright()) as p:
    browser = _launch(p)
    page = browser.new_page()
    page.goto(url, wait_until="networkidle")
    sys.stdout.write(page.content())
    browser.close()
