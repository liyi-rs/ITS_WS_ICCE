# Individual tree segmentation by the Watershed algorithm 
#Load lidR
library(lidR)
# file directory
# input
file_dir <- "~"
#output Please note that the backslash needs to be preserved
normalized_dir <- "~\\"
dtm_dir <- "~\\"
chm_dir <- "~\\"
ws_dir <- "~\\"
li2012_dir <- "~\\" 
#Batch process filtered las files
file_names <- list.files(file_dir)
for (i in 1:length(file_names)) {
  #file name
  lasname<-gsub(".las","",file_names[i])
  #read point clouds
  las_dir <- paste(file_dir,'\\',lasname,'.las',sep="")
  las <- readLAS(las_dir)
  #generate dtm
  dtm <- grid_terrain(las, res = 0.2, algorithm = tin())
  #save dtm
  dtm_name <- paste(dtm_dir,lasname,'_dtm.tif',sep="")
  dtm_save <- writeRaster(dtm, dtm_name, format="GTiff", overwrite=TRUE)
  #normalize point clouds
  las <- lasnormalize(las, tin())
  #save normalized point clouds
  lassavename_normalized = paste(normalized_dir,lasname,'_normalized.las',sep="")
  writeLAS(las,lassavename_normalized)
  #generate chm
  chm <- grid_canopy(las, res = 0.2, pitfree())
  #save chm
  chm_name <- paste(chm_dir,lasname,'_chm.tif',sep="")
  chm_save <- writeRaster(chm, chm_name, format="GTiff", overwrite=TRUE)
  #Extracting tree tops
  ttops <- tree_detection(chm, lmf(4, 2))
  #the watershed
  las_ws <- lastrees(las, watershed(chm))
  #Remove non-tree pointsµã
  trees_ws = filter_poi(las_ws, !is.na(treeID))
  #Save parameters & point clouds
  metrics_ws = tree_metrics(trees_ws)
  #trees_ws <- unnormalize_height(trees_ws)
  trees_ws@data$treeID[trees_ws@data$Classification==2]=0
  #csvname_ws = paste(ws_dir,lasname,'_seg_ws.csv',sep="")
  #write.csv(metrics_ws,file=csvname_ws)
  lassavename_ws = paste(ws_dir,lasname,'_seg_ws.las',sep="")
  writeLAS(trees_ws,lassavename_ws)
  #pcs
  #las_li2012 <- lastrees(las, li2012())
  #trees_li2012 = filter_poi(las_li2012, !is.na(treeID))
  #metrics_li2012 = tree_metrics(trees_li2012)
  #trees_li2012 <- unnormalize_height(trees_li2012)
  #trees_li2012@data$treeID[trees_li2012@data$Classification==2]=0
  #csvname_li2012 = paste(li2012_dir,lasname,'_seg_li2012.csv',sep="")
  #write.csv(metrics_li2012,file=csvname_li2012)
  #lassavename_li2012 = paste(li2012_dir,lasname,'_seg_li2012.las',sep="")
  #writeLAS(trees_li2012,lassavename_li2012)
}