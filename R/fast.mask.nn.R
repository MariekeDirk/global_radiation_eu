#'Creating a spatialpoint density mask
#'@param sppoints spatial points
#'@param grid grid for which the minimum distance to nmin points needs to be determined
#'@param maxdist maximum distance in meters
#'@param nmin minimum number of points within maxdist
#'@param projRD a projection which has the unit meters
#'@description creates a mask with values 1 for locations on the grid with meet the requirements and NA for locations which don't.
#'This funciton was based on the RK_functions.R script from Richard Cornes.
#'@author Marieke Dirksen
#'
fast.mask.nn <- function(sppoints=obs,grid=st.comb[[1]],maxdist=500000,nmin=4,projRD=RD){
  RDobs<-spTransform(sppoints,projRD)
  RDgrid<-projectRaster(grid,crs=projRD)
  sp.xy<-coordinates(RDobs)
  grid.xy<-coordinates(RDgrid)
  nn.dist<-FNN::get.knnx(sp.xy,grid.xy,4)$nn.dist
  nn.dist[nn.dist<maxdist]<-1
  nn.dist[nn.dist>=maxdist]<-0
  nn.dist<-rowSums(nn.dist)
  idx <- nn.dist>=nmin
  grid.dist<-RDgrid
  values(grid.dist)<-idx
  grid.dist<-projectRaster(grid.dist,crs=crs(grid))
  grid.dist<-crop(grid.dist,extent(grid))
  grid.out<-resample(grid.dist,grid)
  return(grid.out)
}
