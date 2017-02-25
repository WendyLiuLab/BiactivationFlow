import os
import re
import glob

files = glob.glob("*.csv")

old = re.compile(r"Specimen_001_([\d_]+x[\d_]+)-(\w+)_\d+_Single Cells.csv")

for f in files:
    os.rename(f, old.sub(r"Specimen_001_\2-\1.exported.FCS3.csv", f))
