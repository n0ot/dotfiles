#!/bin/bash

# Helper script to run the Edbrowse Gemini plugin with client certificate
# enabled or disabled, determined by the existence of a file

script_dir="$(dirname "${BASH_SOURCE[0]}")"

if [ -f "$script_dir/ebgmni-client-cert-enabled" ]; then
    "$script_dir/ebgmni.py" -c ~/.config/edbrowse/plugins/ebgmni-client.crt -C ~/.config/edbrowse/plugins/ebgmni-client.key "$@"
else
    "$script_dir/ebgmni.py"  "$@"
fi
