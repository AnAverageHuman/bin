#!/usr/bin/env bash

# Counts the number of words in a PDF document every time it is written to.
# Useful if writing with LaTeX using $(latexmk -pvc) in the background.

while true; do
    inotifywait -qe close_write "$1"; pdftotext "$1" - | wc -w
done

