#The following data input for the test script is used:
#(1a) ECAD blended_mixed radiation
#(1b) ECAD stations metadata
#(2) SOM patterns from CERES edition 4
#(3) Monthly radiation climatology from CERES edition 4
#(4) GIS components from gtopo30

#library
library(caret)
library(data.table)
library(doParallel)
library(foreach)
library(lubridate)
library(raster)
library(tidyr)
source("R/bagEarthGCV_model_caret.R")
source("R/write_ncdf.R")
source("R/fast.mask.nn.R")
source("inst/interpolation_settings.R")

t.seq            <- seq(from=interpolation_settings$tstart,to=interpolation_settings$tstop,by="day")
nCore            = interpolation_settings$nCore
save_model_info  = interpolation_settings$save_model_info
overwrite.files  = interpolation_settings$overwrite.files

# Directories pc150400
#main_dir<-"/net/pc150400/nobackup/users/dirksen/data/radiation_europe/"
#main_save_dir<-"/net/pc150400/nobackup/users/dirksen/data/radiation_europe/NCDF/"
#save_model_info_dir<-"/net/pc150400/nobackup/users/dirksen/data/radiation_europe/model_info/"

#directories birdexp06
 main_dir            = birdexp06_path$main_dir
 main_save_dir       = birdexp06_path$main_save_dir
 save_model_info_dir = birdexp06_path$save_model_info_dir

#filenames sql dump
series_qq_blended    = birdexp06_path$series_qq_blended
stations_qq          = birdexp06_path$stations_qq

#RD projection
RD<-CRS("+init=epsg:28992 +proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889
+k=0.9999079 +x_0=155000 +y_0=463000 +ellps=bessel
+towgs84=565.417,50.3319,465.552,-0.398957,0.343988,-1.8774,4.0725 +units=m +no_defs")

#(1a) ECAD blended_mixed radiation
series_qq <- readRDS(paste0(main_dir,"mysql_dump/",series_qq_blended))
series_qq <-series_qq[which(series_qq$qc==0),] #select series_qq which passed the quality check
series_qq$ser_date<-as.Date(series_qq$ser_date)

#(1b) ECAD stations metadata
stations <- readRDS(paste0(main_dir,"mysql_dump/",stations_qq)) #seperation within columns is a space (check name column)

#(2) SOM patterns from CERES edition 4
SOM_patterns<-readRDS(paste0(main_dir,"Rdata/ceres_som_edition4.rds"))
names(SOM_patterns$map)<-paste0("SOM_",seq(1,15))

#(3) Monthly radiation climatology from CERES edition 4
#st<-stack("/net/pc150400/nobackup/users/dirksen/data/CERES/monthly/CERES_SYN1deg-Month_Terra-Aqua-MODIS_Ed4A_Subset_200003-201811.nc")
st<-stack(paste0(main_dir,"CERES/monthly/CERES_SYN1deg-Month_Terra-Aqua-MODIS_Ed4A_Subset_200003-201811.nc"))
st.dates<-seq(from=as.Date("2000/03/15"),to=as.Date("2018/11/15"),by="months")
st.months<-month(st.dates)
CERES_monthly_mean<-stackApply(st,st.months,fun="mean")
names(CERES_monthly_mean)<-gsub("index","Month",names(CERES_monthly_mean))

#(4) GIS components from gtopo30
gis_comp<-stack(paste0(main_dir,"DEM/elev_comp_0.1deg_reg_v19.0e.grd"))
# crs(gis_comp)<-CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
gis_comp<-subset(gis_comp,subset=c("dist2coast","dist2coast_blur","alt","alt_blur"))

# date.in<-as.Date("1968-11-19") #birthday Gerard

########## Calculation routine ###########


grid_eu_global_rad<-function(date.in,month.in){
  m.outfile<-paste0(main_save_dir,"qq_ens_mean_025_reg_",date.in,"_v01.nc")
  s.outfile<-paste0(main_save_dir,"qq_ens_spread_025_reg_",date.in,"_v01.nc")
  em.outfile<-paste0(main_save_dir,"qq_ens_member_025_reg_",date.in,"_v01.nc")

  bootstrap.out<-paste0(save_model_info_dir,"bootstrap_realization_members_",date.in,".rds")
  model.out<-paste0(save_model_info_dir,"model_info_",date.in,".rds")



  if(overwrite.files==FALSE){#(file.exists(m.outfile) &
    # file.exists(s.outfile) &
    # file.exists(em.outfile) &
     #file.exists(bootstrap.out) &
     #file.exists(model.out) &
    # file.info(m.outfile)$size>50000 &
    # file.info(s.outfile)$size>50000 &
    # file.info(em.outfile)$size>50000){ 
     #file.info(bootstrap.out)$size>4000 &
     #file.info(model.out)$size>50000)
    message(paste0("files exists for ",date.in))
  } else {
    message("files have no data, calculating global radiation...")



    #(A)satellite input
    cm<-CERES_monthly_mean[[paste0("Month_",month.in)]]
    names(cm)<-"CERES_monthly"
    st.ceres<-stack(SOM_patterns$map,cm)

    message("Resampling rasters to 0.1 grid")
    st.res<-projectRaster(st.ceres,gis_comp[[1]])
    st.comb<-stack(st.res,gis_comp)

    #(B)observations
    message("Loading observations for the day")
    series_qq_1day<-series_qq[which(series_qq$ser_date==date.in),]
    obs<-base::merge(series_qq_1day,stations)#,by.x=c("sta_id","sta_id"),by.y=c("sta_id","s_id")) #sta_id is not unique blend_id and ser_id are
    coordinates(obs)<-~lon+lat
    crs(obs)<-crs(st.comb)

    
################ Minimum distance 200km #########################
    message("Creating Spatial Point Density Raster")

    #This is Marieke's code
    # r.dist<-mask(distanceFromPoints(object=raster(st.res),xy=obs)/1000,gis_comp[[1]])
    # r.dist[which(values(r.dist)>200)]<-NA

    #From Richard and a bit modified by Marieke
    grid.out<-fast.mask.nn(sppoints=obs,grid=st.comb[[1]],projRD=RD)



    message("Masking layers with density raster")
    st.comb<-mask(st.comb,grid.out,maskvalue=0)
    spdf<-as(st.comb,"SpatialGridDataFrame")

    ################ Interpolation #########################
    message("Interpolation routine...")
    #system.time(
    #cl<-makeCluster(nCore)
    #registerDoParallel(cl)
    rad_eu<-bagEarthGCV_model_caret(groundstations = obs,
                                    variable = "qq",
                                    grid_prediction = spdf,
                                    form.in=formula(paste0("Tint ~ ",paste(names(spdf),collapse = "+"))))
    #stopCluster(cl)

    #)

    #Remove values below zero
    rad_eu$spatial[rad_eu$spatial<0]<-0
    rad_eu$bootstrap_realizations[rad_eu$bootstrap_realizations<0]<-0
    members.names<-paste0("Member_",seq(1,length(names(rad_eu$bootstrap_realizations)),by=1))
    names(rad_eu$bootstrap_realizations)<-members.names

    rad_eu$range<-raster::calc(rad_eu$bootstrap_realizations,fun=function(x){quantile(x,probs=c(0.05,0.95),na.rm=TRUE)})
    rad_eu$spread<-rad_eu$range[[2]]-rad_eu$range[[1]]

    ################ Saving files #########################
    
    if(save_model_info==TRUE){
    message("Saving model info")
    bootstrap.ls<-list("observations_in"=rad_eu$bootstrap_subset,"observations"=obs)
    saveRDS(bootstrap.ls,file = bootstrap.out)
    
    model.ls<-list("model"=rad_eu$model,"varimp"=rad_eu$variable_importance)
    saveRDS(model.ls,file = model.out)
    }
	
    message("Writing NCDF files")
    write.ncdf(iraster=rad_eu$spatial,ofile=m.outfile,
               Year = year(date.in),Month = month(date.in),Day = day(date.in))
    write.ncdf(iraster=rad_eu$spread,ofile=s.outfile,
               Year = year(date.in),Month = month(date.in),Day = day(date.in))
    write.ncdf(iraster=rad_eu$bootstrap_realizations,ofile=em.outfile,N=10,
               Year = year(date.in),Month = month(date.in),Day = day(date.in))


    raster::removeTmpFiles(h=0)
  }
}

cl<-makeCluster(nCore)
registerDoParallel(cl)

#make sure traincontrol --> allowParallel=FALSE
 test<-foreach(i=1:length(t.seq), 
         .export=c('grid_eu_global_rad','bagEarthGCV_model_caret','write.ncdf','fast.mask.nn'),
         .packages=c("caret",'earth','gstat','sp',"doParallel","foreach","lubridate","raster","tidyr"),
         .combine = c) %dopar% {
           date.start<-t.seq[i]
           print(date.start)
           month.start<-month(date.start)
           grid_eu_global_rad(date.start,month.start)
         }

stopCluster(cl)


#for(i in 1:length(t.seq)){
#  date.start<-t.seq[i]
#  print(date.start)
#  month.start<-month(date.start)
#  grid_eu_global_rad(date.start,month.start)
#
#}



# m.outfile<-paste0(main_save_dir,"qq_ens_mean_025_reg_",date.in,"_v01.nc")
# s.outfile<-paste0(main_save_dir,"qq_ens_spread_025_reg_",date.in,"_v01.nc")
# em.outfile<-paste0(main_save_dir,"qq_ens_member_025_reg_",date.in,"_v01.nc")
#
# bootstrap.out<-paste0(save_model_info_dir,"bootstrap_realization_members_",date.in,".rds")
# model.out<-paste0(save_model_info_dir,"model_info_",date.in,".rds")
#
#
#
# if(file.exists(m.outfile) &
#    file.exists(s.outfile) &
#    file.exists(em.outfile) &
#    file.exists(bootstrap.out) &
#    file.exists(model.out) &
#    file.info(m.outfile)$size>50000 &
#    file.info(s.outfile)$size>50000 &
#    file.info(em.outfile)$size>50000 &
#    file.info(bootstrap.out)$size>4000 &
#    file.info(model.out)$size>50000){
#   message(paste0("files exists for ",date.in))
# } else {
#   message("files have no data, calculating global radiation...")
#
#
#
#   #(A)satellite input
#   cm<-CERES_monthly_mean[[paste0("Month_",month.in)]]
#   names(cm)<-"CERES_monthly"
#   st.ceres<-stack(SOM_patterns$map,cm)
#
#   message("Resampling rasters to 0.1 grid")
#   st.res<-projectRaster(st.ceres,gis_comp[[1]])
#   st.comb<-stack(st.res,gis_comp)
#
#   #(B)observations
#   series_qq_1day<-series_qq[which(series_qq$ser_date==date.in),]
#   obs<-base::merge(series_qq_1day,stations,by.x=c("sta_id","blend_id"),by.y=c("sta_id","ser_id")) #sta_id is not unique blend_id and ser_id are
#   coordinates(obs)<-~lon+lat
#   crs(obs)<-crs(st.comb)
#
#   ################ Minimum distance 200km #########################
#   message("Creating Spatial Point Density Raster")
#
#   #This is Marieke's code
#   # r.dist<-mask(distanceFromPoints(object=raster(st.res),xy=obs)/1000,gis_comp[[1]])
#   # r.dist[which(values(r.dist)>200)]<-NA
#
#   #From Richard and a bit modified by Marieke
#   grid.out<-fast.mask.nn()
#
#   message("Masking layers with density raster")
#   st.comb<-mask(st.comb,grid.out,maskvalue=0)
#   spdf<-as(st.comb,"SpatialGridDataFrame")
#
#   ################ Interpolation #########################
#   message("Interpolation routine...")
#   #system.time(
#   rad_eu<-bagEarthGCV_model_caret(groundstations = obs,
#                                   variable = "qq",
#                                   grid_prediction = spdf,
#                                   form.in=formula(paste0("Tint ~ ",paste(names(spdf),collapse = "+"))))
#
#   #)
#
#   #Remove values below zero
#   rad_eu$spatial[rad_eu$spatial<0]<-0
#   rad_eu$bootstrap_realizations[rad_eu$bootstrap_realizations<0]<-0
#   members.names<-paste0("Member_",seq(1,length(names(rad_eu$bootstrap_realizations)),by=1))
#   names(rad_eu$bootstrap_realizations)<-members.names
#
#   rad_eu$range<-raster::calc(rad_eu$bootstrap_realizations,fun=function(x){quantile(x,probs=c(0.05,0.95),na.rm=TRUE)})
#   rad_eu$spread<-rad_eu$range[[2]]-rad_eu$range[[1]]
#
#   ################ Saving files #########################
#   message("Saving model info")
#   bootstrap.ls<-list("observations_in"=rad_eu$bootstrap_subset,"observations"=obs)
#   saveRDS(bootstrap.ls,file = bootstrap.out)
#
#   model.ls<-list("model"=rad_eu$model,"varimp"=rad_eu$variable_importance)
#   saveRDS(model.ls,file = model.out)
#
#   message("Writing NCDF files")
#   write.ncdf(iraster=rad_eu$spatial,ofile=m.outfile,
#              Year = year(date.in),Month = month(date.in),Day = day(date.in))
#   write.ncdf(iraster=rad_eu$spread,ofile=s.outfile,
#              Year = year(date.in),Month = month(date.in),Day = day(date.in))
#   write.ncdf(iraster=rad_eu$bootstrap_realizations,ofile=em.outfile,N=10,
#              Year = year(date.in),Month = month(date.in),Day = day(date.in))
#
#
#   raster::removeTmpFiles(h=0)
# }

