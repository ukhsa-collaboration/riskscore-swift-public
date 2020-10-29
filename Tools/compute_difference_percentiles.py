#!/usr/bin/env python3

import subprocess
import numpy as np
from argparse import ArgumentParser

parser = ArgumentParser()
parser.add_argument("-s", "--scan-instances-dir", dest="scanInstancesDir",
                    help="The directory containing ScanInstances to compare", metavar="DIR_PATH", required=True)
parser.add_argument("-r", "--risk-score-data-file", dest="riskScoreDataFile",
                    help="The file containing the Python riskscore calculations", metavar="FILE_PATH", required=True)
parser.add_argument("outputFilePath", nargs='?', default=None, help="if present, store percentiles at <filepath>.csv and histogram at <filepath>.png, otherwise write percentiles to standard out")

args = parser.parse_args()

results = subprocess.run(["swift", "run", "--configuration", "release", "risk-score-checker", args.scanInstancesDir, args.riskScoreDataFile], capture_output=True, text=True)
differences = [ float(r.split(" ")[-1]) for r in results.stdout.strip().split("\n")[1:] ]

percentiles = [80, 85, 90, 95, 100]
percentileResults = zip(percentiles, np.percentile([abs(d) for d in differences], percentiles))

percentileString = "percentile value\n" + "\n".join(["{} {}".format(p, v) for p, v in percentileResults])

if args.outputFilePath is None:
    print(percentileString)
else:
    with open(args.outputFilePath + ".csv", "w", encoding="utf8") as f:
        f.write(percentileString)

    import matplotlib.pyplot as plt
    plt.hist(differences)
    plt.savefig(args.outputFilePath + ".png")
