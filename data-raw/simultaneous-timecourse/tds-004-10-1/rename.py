#!/usr/bin/python

import re
from os import rename
import glob

r = re.compile(r"export_Specimen_001_(\d+h)-([0-9_]+x[0-9_]+)-(\w+)_\d+_Single Cells.csv")

files = glob.glob("*Single Cells.csv")
for fn in files:
    newname = r.sub(r"Specimen_001_\1-\2-\3.exported.FCS3.csv", fn)
    print fn, "=>", newname
    rename(fn, newname)
