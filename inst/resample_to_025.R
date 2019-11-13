library(ncdf4)
library(raster)
library(lubridate)
library(foreach)
library(doParallel)
source("R/write_ncdf.R")
source("inst/interpolation_settings.R")
data_dir  = birdexp06_resample$data_dir
elev_dir  = birdexp06_resample$elev_dir
save_dir  = birdexp06_resample$save_dir

time.seq  = seq(from=interpolation_settings$tstart,to=interpolation_settings$tstop,by="day")
nCore     = interpolation_settings$nCore

qq_spread<-paste0(data_dir,"qq_ens_spread_025_reg_YYYY-MM-DD_v01.nc")
qq_mean<-paste0(data_dir,"qq_ens_mean_025_reg_YYYY-MM-DD_v01.nc")

elev025<-paste0(elev_dir,"elev_ens_0.25deg_reg_v19.0e.nc")

qq_spread025<-paste0(save_dir,"qq_ens_spread_0.25_reg_YYYY-MM-DD_v01.nc")
qq_mean025<-paste0(save_dir,"qq_ens_mean_0.25_reg_YYYY-MM-DD_v01.nc")



resample_ncdf4<-function(ncfile,grid,filenm,date.in){

start_time<-Sys.time()
message(paste0("started reading files: ",start_time))

x<-stack(ncfile)
y<-raster(grid)

read_time<-Sys.time()
message(paste0("read file, going to resample: ",read_time))

r.res<-resample(x, y, method="bilinear")

stop_time<-Sys.time()
message(paste0("finished resampling: ",stop_time))

write.ncdf(iraster=r.res,ofile=filenm,
               Year = year(date.in),Month = month(date.in),Day = day(date.in))


}

cl<-makeCluster(nCore)
registerDoParallel(cl)

foreach(i=1:length(time.seq),.export='write.ncdf',.packages=c("ncdf4","raster","lubridate"))%dopar% {
d=time.seq[i]
qq_spread_day<-stack(gsub("YYYY-MM-DD",d,qq_spread))
qq_mean_day<-stack(gsub("YYYY-MM-DD",d,qq_mean))

qq_spread025_day<-gsub("YYYY-MM-DD",d,qq_spread025)
qq_mean025_day<-gsub("YYYY-MM-DD",d,qq_mean025)

resample_ncdf4(ncfile=qq_spread_day,grid=elev025,filenm=qq_spread025_day,date.in=d)
resample_ncdf4(ncfile=qq_mean_day,grid=elev025,filenm=qq_mean025_day,date.in=d)
}

stopCluster(cl)
