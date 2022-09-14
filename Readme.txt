This code is used to individual tree segmentation for airborne or UAV LiDAR point clouds combining the watershed and connection center evolution clustering. This code allows batch processing.
Step 1: Run the individual_tree_seg_ws_li2012_batch.R
Input: filterd point cloud(Classification:1[tree point],2[ground point]), las format
Output: sengmented point clouds by the watershed algorithm, las format
Attention: please set the resolution of CHM and DTM according to the densities of the point clouds. You can set the parameters of the watershed algorithm yourself.
Step 2: Run getbandwidth.py
Input: sengmented point clouds by the watershed algorithm, las format
Output: bandwidth value of each point clouds file, txt format
Step 3: Run its_ws_icce_batch.m
Input: (1) sengmented point clouds by the watershed algorithm, las format; (2) bandwidth value of each point clouds file, txt format
Output: (1) sengmented point clouds by the watershed+improved connection center evolution algorithm, las format; (2) tree structure metrics(Planar coordinates, tree height, crown diameter)
Attention: You can set the appropriate parameter values yourself: Vr:the vertical distance correction factor(line 46); sigSq2: Gaussian kernel(line 47).


**Before you run the code the individual_tree_seg_ws_li2012_batch.R, you need to install the lidR library in R. If you encounter problems with the installation, we recommend changing the version of R (e.g. installing R 4.1.0).
**Before you run the code getbandwidth.py,  you need to install the sklearn and laspy library in Python.This may take a very long time if the point cloud density is very high. Please be patient and wait for the program to finish running.
**We recommend using MATLAB R2018b and above, although lower versions will run as well.

Thanks to lidR(https://github.com/r-lidar/lidR) for providing the callable libraries and mparkan for providing the corresponding MATLAB functions(https://mparkan.github.io/Digital-Forestry-Toolbox/).
Thanks to NEWFOR(https://www.newfor.net/) for providing free LiDAR point cloud data as the test data.
Thanks to Xiurui Geng for the code of connection center evolution clustering(Geng, X., & Tang, H. (2020). Clustering by connection center evolution. Pattern Recognition, 98, 107063.https://doi.org/10.1016/j.patcog.2019.107063. ).
Last update: 2022/09/11

Please contact Yi Li (yili@mail.bnu.edu.cn) with any questions.