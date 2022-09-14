# input: segmented point clouds by the Watershed Algorithm(las format)
# output: bandwidth (the input of mean shift,txt format)
import os
import sys
from pathlib import *
import glob
import numpy as np
from sklearn.cluster import estimate_bandwidth
import laspy
file_path = r'~'
data_dir = Path(file_path)
sys.path.append(data_dir.__str__())
f = open(r'~\bandwidth.txt','w+')
for x in data_dir.glob('*.las'):
    filename = os.path.basename(x)
    f.write(filename)
    f.write('\t')
    inFile = laspy.file.File(x, mode='r')
    xyz_total = np.vstack((inFile.x, inFile.y, inFile.z)).transpose()
    P = xyz_total
    zd = 6
    a = np.array([1, 1, zd])
    P = P / a
    nP = np.shape(P)[0]
    x0 = P[np.lexsort([P[:, 0]])[0], 0]
    x1 = P[np.lexsort([-P[:, 0]])[0], 0]
    y0 = P[np.lexsort([P[:, 1]])[0], 1]
    y1 = P[np.lexsort([-P[:, 1]])[0], 1]
    den0 = round(nP / ((x1 - x0) * (y1 - y0)))
    bandwidth = estimate_bandwidth(P, quantile=den0 / nP)
    f.write(str(bandwidth))
    f.write('\r\n')
f.close()
