import glob
import os
import re

files = glob.glob("m12*.csv")
exp = re.compile(r"m12-([0-9x_]+)-(exp|iso).csv")
for f in files:
    newname = exp.sub(r'export_Specimen_001_\2-\1.exported.FCS3.csv', f)
    print((f, newname))
    os.rename(f, newname)
