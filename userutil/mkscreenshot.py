#!/usr/bin/env python
from argparse import ArgumentParser
from subprocess import call
from tempfile import NamedTemporaryFile
from time import time

TMPDIR = "/tmp/"
OUTNAME = TMPDIR + str(int(time())) + '.png'

p = ArgumentParser(description="Takes a screenshot using maim.")
p.add_argument('--select', '-s', action='store_true')
args = p.parse_args()

f = NamedTemporaryFile()
command = ['maim', '--format=png', '--hidecursor']

if args.select:
    command.append('--select')

call(command + [f.name])
call(['pngcrush', '-rem alla', '-reduce', f.name, OUTNAME])

f.close()
