#!/usr/bin/python2.7 -u
import glob
import subprocess
for f in sorted(glob.glob("*.*")):
    print subprocess.check_output(['wc', '-l', f]).rstrip()
