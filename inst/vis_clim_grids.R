library(raster)
library(ncdf4)
countries<-readOGR(dsn="D:/natural_earth/ne_10m_admin_0_countries",layer="ne_10m_admin_0_countries")
countries_crop<-crop(countries,r1)
countries_crop<-spTransform(countries_crop,crs(ss2qq))
countries_crop<-list("sp.polygons",countries,cex=0.3,col="darkgrey",alpha=0.7,first=FALSE)

qq_daily<-list.files("/net/pc150400/nobackup/users/dirksen/data/radiation_europe/NCDF_month_year")
files_dir<-"/net/pc150400/nobackup/users/dirksen/data/radiation_europe/NCDF_month_year/"

qq_025<-stack(paste0(files_dir,"qq_ens_mean_0.25deg_reg_v20.0e.nc"))

qq_025<-qq_025[[1:which(names(qq_025)=="X2018.12.31")]]
qq_dates<-as.Date(names(qq_025),format="X%Y.%m.%d")


remove.NAs.stack<-function(rast.stack){
  nom<-names(rast.stack)
  test1<-calc(rast.stack, fun=sum)
  test1[!is.na(test1)]<-1
  test2<-rast.stack*test1
  test2<-stack(test2)
  names(test2)<-nom
  return(test2)
}

qq_025<-remove.NAs.stack(qq_025)
write.raster(qq_025,file="/net/pc150400/nobackup/users/dirksen/data/radiation_europe/climatology/qq_025.grd")

stackApply(qq_025,1,fun=mean,na.rm=TRUE)