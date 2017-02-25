#!/usr/bin/python

import re
from os import rename
import glob

r = re.compile(r"([0-9_]+x[0-9_]+)-(\w+).csv")

files = glob.glob("*.csv")
for fn in files:
    newname = r.sub(r"Specimen_001_\2-\1.exported.FCS3.csv", fn)
    print fn, "=>", newname
    rename(fn, newname)
