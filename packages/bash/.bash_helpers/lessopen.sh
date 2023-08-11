#!/bin/sh
case "$1" in
    *.gz) gzip -cdq "$1" 2> /dev/null
    ;;
    *.epub) pandoc -f epub "$1" -t markdown 2> /dev/null
    ;;
esac
