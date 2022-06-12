#-*-coding: utf-8-*-

import os

input_folder = "../data/"
output_folder = "./data/"

try:
    os.mkdir(output_folder)
except:
    pass

files = os.listdir(input_folder)
for fn in files:
    if fn.endswith("_rclass.dat") or ".mat" in fn:
        continue
    print (fn)

    data = []
    with open(os.path.join(input_folder, fn), "r") as f:
        for line in f:
            linedata = [float(l) for l in line.strip().split(",")]
            data.append(linedata)
    
    feature_dim = len(data[0])
    with open(os.path.join(output_folder, fn), "w") as fw:
        samplestr = "|".join(["Sample %s" % i for i in range(1, len(data) + 1)]) + "|"
        fw.write("|SAMPLE_ID|" + samplestr + "\n")
        
        for fdim in range(0, feature_dim):
            featurestr = "|".join([str(d[fdim]) for d in data]) + "|"
            fw.write("|Feature %s|" % (fdim + 1) + featurestr + "\n")
