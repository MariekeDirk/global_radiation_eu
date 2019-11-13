library(lubridate)
source("inst/interpolation_settings.R")

#Settings
version = global_settings$version
year    = year(interpolation_settings$tstop)
months  = seq(1,month(interpolation_settings$tstop),by=1)
months<-sprintf("%02d",months)

#which nc files should be created?
do.010    = which_month_year_nc$do.010
do.025    = which_month_year_nc$do.025
do.full   = which_month_year_nc$do.full
do.year   = which_month_year_nc$do.year
do.months = which_month_year_nc$do.months
do.15year = which_month_year_nc$do.15year

#Paths
grid010    = birdexp06_nc$grid010
grid025    = birdexp06_nc$grid025
write_dir  = birdexp06_nc$write_dir

mean010<-"qq_ens_mean_025_reg_"
spread010<-"qq_ens_spread_025_reg_"
member010<-"qq_ens_member_025_reg_"

mean025<-"qq_ens_mean_0.25_reg_"
spread025<-"qq_ens_spread_0.25_reg_"

if(do.full==TRUE){

   	if(do.010==TRUE){
system(sprintf("cdo -O -z zip_1 mergetime %sqq_ens_mean_* %sqq_ens_mean_0.1deg_reg_%s.nc",grid010,write_dir,version))
system(sprintf("cdo -O -z zip_1 mergetime %sqq_ens_spread_* %sqq_ens_spread_0.1deg_reg_%s.nc",grid010,write_dir,version))
system(sprintf("cdo -O -z zip_1 mergetime %sqq_ens_member_* %sqq_ens_member_0.1deg_reg_%s.nc",grid010,write_dir,version))

message("adding global attributes")
#system(sprintf("ncap2 -O -s 'time=int(time)' %sqq_ens_mean_0.1deg_reg_%s.nc",write_dir,version))
system(sprintf("ncatted -h -O -a history,global,d,, %sqq_ens_mean_0.1deg_reg_%s.nc",write_dir,version))
system(sprintf("ncatted -O -h -a E-OBS_version,global,a,c,20.0e %sqq_ens_mean_0.1deg_reg_%s.nc",write_dir,version))
system(sprintf("ncatted -O -h -a References,global,a,c,'http://surfobs.climate.copernicus.eu/dataaccess/access_eobs.php' %sqq_ens_mean_0.1deg_reg_%s.nc",write_dir,version))

#system(sprintf("ncap2 -O -s 'time=int(time)' %sqq_ens_spread_0.1deg_reg_%s.nc",write_dir,version))
system(sprintf("ncatted -h -O -a history,global,d,, %sqq_ens_spread_0.1deg_reg_%s.nc",write_dir,version))
system(sprintf("ncatted -O -h -a E-OBS_version,global,a,c,20.0e %sqq_ens_spread_0.1deg_reg_%s.nc",write_dir,version))
system(sprintf("ncatted -O -h -a References,global,a,c,'http://surfobs.climate.copernicus.eu/dataaccess/access_eobs.php' %sqq_ens_spread_0.1deg_reg_%s.nc",write_dir,version))

#system(sprintf("ncap2 -O -s 'time=int(time)' %sqq_ens_member_0.1deg_reg_%s.nc",write_dir,version))
system(sprintf("ncatted -h -O -a history,global,d,, %sqq_ens_member_0.1deg_reg_%s.nc",write_dir,version))
system(sprintf("ncatted -O -h -a E-OBS_version,global,a,c,20.0e %sqq_ens_member_0.1deg_reg_%s.nc",write_dir,version))
system(sprintf("ncatted -O -h -a References,global,a,c,'http://surfobs.climate.copernicus.eu/dataaccess/access_eobs.php' %sqq_ens_member_0.1deg_reg_%s.nc",write_dir,version))

   	}

	if(do.025==TRUE){

system(sprintf("cdo -O -z zip_1 mergetime %sqq_ens_spread_* %sqq_ens_spread_0.25deg_reg_%s.nc",grid025,write_dir,version))
system(sprintf("cdo -O -z zip_1 mergetime %sqq_ens_mean_* %sqq_ens_mean_0.25deg_reg_%s.nc",grid025,write_dir,version))

message("adding global attributes")	
#system(sprintf("ncap2 -O -s 'time=int(time)' %sqq_ens_mean_0.25deg_reg_%s.nc",write_dir,version))
system(sprintf("ncatted -h -O -a history,global,d,, %sqq_ens_mean_0.25deg_reg_%s.nc",write_dir,version))
system(sprintf("ncatted -O -h -a E-OBS_version,global,a,c,20.0e %sqq_ens_mean_0.25deg_reg_%s.nc",write_dir,version))
system(sprintf("ncatted -O -h -a References,global,a,c,'http://surfobs.climate.copernicus.eu/dataaccess/access_eobs.php' %sqq_ens_mean_0.25deg_reg_%s.nc",write_dir,version))

#system(sprintf("ncap2 -O -s 'time=int(time)' %sqq_ens_spread_0.25deg_reg_%s.nc",write_dir,version))
system(sprintf("ncatted -h -O -a history,global,d,, %sqq_ens_spread_0.25deg_reg_%s.nc",write_dir,version))
system(sprintf("ncatted -O -h -a E-OBS_version,global,a,c,20.0e %sqq_ens_spread_0.25deg_reg_%s.nc",write_dir,version))
system(sprintf("ncatted -O -h -a References,global,a,c,'http://surfobs.climate.copernicus.eu/dataaccess/access_eobs.php' %sqq_ens_spread_0.25deg_reg_%s.nc",write_dir,version))
	}
}

if(do.15year==TRUE){

	if(do.010==TRUE){
	system("echo mean 0.10")
	system(sprintf("cdo -z zip_1 mergetime %sqq_ens_mean_*{1980..1994}* %sqq_ens_mean_0.1deg_reg_1980-1994_%s.nc",grid010,write_dir,version))
	system(sprintf("cdo -z zip_1 mergetime %sqq_ens_mean_*{1995..2010}* %sqq_ens_mean_0.1deg_reg_1995-2010_%s.nc",grid010,write_dir,version))
	system(sprintf("cdo -z zip_1 mergetime %sqq_ens_mean_*{2011..2018}* %sqq_ens_mean_0.1deg_reg_2011-2018_%s.nc",grid010,write_dir,version))

message("adding global attributes to 15 year 0.1deg mean")
#system(sprintf("ncap2 -O -s 'time=int(time)' %sqq_ens_mean_0.1deg_reg_1980-1994_%s.nc",write_dir,version))
system(sprintf("ncatted -h -O -a history,global,d,, %sqq_ens_mean_0.1deg_reg_1980-1994_%s.nc",write_dir,version))
system(sprintf("ncatted -O -h -a E-OBS_version,global,a,c,20.0e %sqq_ens_mean_0.1deg_reg_1980-1994_%s.nc",write_dir,version))
system(sprintf("ncatted -O -h -a References,global,a,c,'http://surfobs.climate.copernicus.eu/dataaccess/access_eobs.php' %sqq_ens_mean_0.1deg_reg_1980-1994_%s.nc",write_dir,version))

#system(sprintf("ncap2 -O -s 'time=int(time)' %sqq_ens_mean_0.1deg_reg_1995-2010_%s.nc",write_dir,version))
system(sprintf("ncatted -h -O -a history,global,d,, %sqq_ens_mean_0.1deg_reg_1995-2010_%s.nc",write_dir,version))
system(sprintf("ncatted -O -h -a E-OBS_version,global,a,c,20.0e %sqq_ens_mean_0.1deg_reg_1995-2010_%s.nc",write_dir,version))
system(sprintf("ncatted -O -h -a References,global,a,c,'http://surfobs.climate.copernicus.eu/dataaccess/access_eobs.php' %sqq_ens_mean_0.1deg_reg_1995-2010_%s.nc",write_dir,version))

#system(sprintf("ncap2 -O -s 'time=int(time)' %sqq_ens_mean_0.1deg_reg_2011-2018_%s.nc",write_dir,version))
system(sprintf("ncatted -h -O -a history,global,d,, %sqq_ens_mean_0.1deg_reg_2011-2018_%s.nc",write_dir,version))
system(sprintf("ncatted -O -h -a E-OBS_version,global,a,c,20.0e %sqq_ens_mean_0.1deg_reg_2011-2018_%s.nc",write_dir,version))
system(sprintf("ncatted -O -h -a References,global,a,c,'http://surfobs.climate.copernicus.eu/dataaccess/access_eobs.php' %sqq_ens_mean_0.1deg_reg_2011-2018_%s.nc",write_dir,version))

system("echo spread 0.10")
system(sprintf("cdo -z zip_1 mergetime %sqq_ens_spread_*{1980..1994}* %sqq_ens_spread_0.1deg_reg_1980-1994_%s.nc",grid010,write_dir,version))
system(sprintf("cdo -z zip_1 mergetime %sqq_ens_spread_*{1995..2010}* %sqq_ens_spread_0.1deg_reg_1995-2010_%s.nc",grid010,write_dir,version))
system(sprintf("cdo -z zip_1 mergetime %sqq_ens_spread_*{2011..2018}* %sqq_ens_spread_0.1deg_reg_2011-2018_%s.nc",grid010,write_dir,version))



message("adding global attributes to 15 year 0.1deg spread")
#system(sprintf("ncap2 -O -s 'time=int(time)' %sqq_ens_spread_0.1deg_reg_1980-1994_%s.nc",write_dir,version))
system(sprintf("ncatted -h -O -a history,global,d,, %sqq_ens_spread_0.1deg_reg_1980-1994_%s.nc",write_dir,version))
system(sprintf("ncatted -O -h -a E-OBS_version,global,a,c,20.0e %sqq_ens_spread_0.1deg_reg_1980-1994_%s.nc",write_dir,version))
system(sprintf("ncatted -O -h -a References,global,a,c,'http://surfobs.climate.copernicus.eu/dataaccess/access_eobs.php' %sqq_ens_spread_0.1deg_reg_1980-1994_%s.nc",write_dir,version))

#system(sprintf("ncap2 -O -s 'time=int(time)' %sqq_ens_spread_0.1deg_reg_1995-2010_%s.nc",write_dir,version))
system(sprintf("ncatted -h -O -a history,global,d,, %sqq_ens_spread_0.1deg_reg_1995-2010_%s.nc",write_dir,version))
system(sprintf("ncatted -O -h -a E-OBS_version,global,a,c,20.0e %sqq_ens_spread_0.1deg_reg_1995-2010_%s.nc",write_dir,version))
system(sprintf("ncatted -O -h -a References,global,a,c,'http://surfobs.climate.copernicus.eu/dataaccess/access_eobs.php' %sqq_ens_spread_0.1deg_reg_1995-2010_%s.nc",write_dir,version))

#system(sprintf("ncap2 -O -s 'time=int(time)' %sqq_ens_spread_0.1deg_reg_2011-2018_%s.nc",write_dir,version))
system(sprintf("ncatted -h -O -a history,global,d,, %sqq_ens_spread_0.1deg_reg_2011-2018_%s.nc",write_dir,version))
system(sprintf("ncatted -O -h -a E-OBS_version,global,a,c,20.0e %sqq_ens_spread_0.1deg_reg_2011-2018_%s.nc",write_dir,version))
system(sprintf("ncatted -O -h -a References,global,a,c,'http://surfobs.climate.copernicus.eu/dataaccess/access_eobs.php' %sqq_ens_spread_0.1deg_reg_2011-2018_%s.nc",write_dir,version))

	}
	if(do.025==TRUE){
system("echo mean 0.25")
system(sprintf("cdo -z zip_1 mergetime %sqq_ens_mean_*{1980..1994}* %sqq_ens_mean_0.25deg_reg_1980-1994_%s.nc",grid025,write_dir,version))
system(sprintf("cdo -z zip_1 mergetime %sqq_ens_mean_*{1995..2010}* %sqq_ens_mean_0.25deg_reg_1995-2010_%s.nc",grid025,write_dir,version))
system(sprintf("cdo -z zip_1 mergetime %sqq_ens_mean_*{2011..2018}* %sqq_ens_mean_0.25deg_reg_2011-2018_%s.nc",grid025,write_dir,version))

message("adding global attributes to 15 year 0.25deg mean")
#system(sprintf("ncap2 -O -s 'time=int(time)' %sqq_ens_mean_0.25deg_reg_1980-1994_%s.nc",write_dir,version))
system(sprintf("ncatted -h -O -a history,global,d,, %sqq_ens_mean_0.25deg_reg_1980-1994_%s.nc",write_dir,version))
system(sprintf("ncatted -O -h -a E-OBS_version,global,a,c,20.0e %sqq_ens_mean_0.25deg_reg_1980-1994_%s.nc",write_dir,version))
system(sprintf("ncatted -O -h -a References,global,a,c,'http://surfobs.climate.copernicus.eu/dataaccess/access_eobs.php' %sqq_ens_mean_0.25deg_reg_1980-1994_%s.nc",write_dir,version))

#system(sprintf("ncap2 -O -s 'time=int(time)' %sqq_ens_mean_0.25deg_reg_1995-2010_%s.nc",write_dir,version))
system(sprintf("ncatted -h -O -a history,global,d,, %sqq_ens_mean_0.25deg_reg_1995-2010_%s.nc",write_dir,version))
system(sprintf("ncatted -O -h -a E-OBS_version,global,a,c,20.0e %sqq_ens_mean_0.25deg_reg_1995-2010_%s.nc",write_dir,version))
system(sprintf("ncatted -O -h -a References,global,a,c,'http://surfobs.climate.copernicus.eu/dataaccess/access_eobs.php' %sqq_ens_mean_0.25deg_reg_1995-2010_%s.nc",write_dir,version))

#system(sprintf("ncap2 -O -s 'time=int(time)' %sqq_ens_mean_0.25deg_reg_2011-2018_%s.nc",write_dir,version))
system(sprintf("ncatted -h -O -a history,global,d,, %sqq_ens_mean_0.25deg_reg_2011-2018_%s.nc",write_dir,version))
system(sprintf("ncatted -O -h -a E-OBS_version,global,a,c,20.0e %sqq_ens_mean_0.25deg_reg_2011-2018_v20.0e.nc",write_dir))
system(sprintf("ncatted -O -h -a References,global,a,c,'http://surfobs.climate.copernicus.eu/dataaccess/access_eobs.php' %sqq_ens_mean_0.25deg_reg_2011-2018_%s.nc",write_dir,version))



system("echo spread 0.25")
system(sprintf("cdo -O -z zip_1 mergetime %sqq_ens_spread_*{1980..1994}* %sqq_ens_spread_0.25deg_reg_1980-1994_%s.nc",grid025,write_dir,version))
system(sprintf("cdo -O -z zip_1 mergetime %sqq_ens_spread_*{1995..2010}* %sqq_ens_spread_0.25deg_reg_1995-2010_%s.nc",grid025,write_dir,version))
system(sprintf("cdo -O -z zip_1 mergetime %sqq_ens_spread_*{2011..2018}* %sqq_ens_spread_0.25deg_reg_2011-2018_%s.nc",grid025,write_dir,version))

message("adding global attributes to 15 year 0.25deg spread")
#system(sprintf("ncap2 -O -s 'time=int(time)' %sqq_ens_spread_0.25deg_reg_1980-1994_%s.nc",write_dir,version))
system(sprintf("ncatted -h -O -a history,global,d,, %sqq_ens_spread_0.25deg_reg_1980-1994_%s.nc",write_dir,version))
system(sprintf("ncatted -O -h -a E-OBS_version,global,a,c,20.0e %sqq_ens_spread_0.25deg_reg_1980-1994_%s.nc",write_dir,version))
system(sprintf("ncatted -O -h -a References,global,a,c,'http://surfobs.climate.copernicus.eu/dataaccess/access_eobs.php' %sqq_ens_spread_0.25deg_reg_1980-1994_%s.nc",write_dir,version))

#system(sprintf("ncap2 -O -s 'time=int(time)' %sqq_ens_spread_0.25deg_reg_1995-2010_%s.nc",write_dir,version))
system(sprintf("ncatted -h -O -a history,global,d,, %sqq_ens_spread_0.25deg_reg_1995-2010_%s.nc",write_dir,version))
system(sprintf("ncatted -O -h -a E-OBS_version,global,a,c,20.0e %sqq_ens_spread_0.25deg_reg_1995-2010_%s.nc",write_dir,version))
system(sprintf("ncatted -O -h -a References,global,a,c,'http://surfobs.climate.copernicus.eu/dataaccess/access_eobs.php' %sqq_ens_spread_0.25deg_reg_1995-2010_%s.nc",write_dir,version))

#system(sprintf("ncap2 -O -s 'time=int(time)' %sqq_ens_spread_0.25deg_reg_2011-2018_%s.nc",write_dir,version))
system(sprintf("ncatted -h -O -a history,global,d,, %sqq_ens_spread_0.25deg_reg_2011-2018_%s.nc",write_dir,version))
system(sprintf("ncatted -O -h -a E-OBS_version,global,a,c,20.0e %sqq_ens_spread_0.25deg_reg_2011-2018_%s.nc",write_dir,version))
system(sprintf("ncatted -O -h -a References,global,a,c,'http://surfobs.climate.copernicus.eu/dataaccess/access_eobs.php' %sqq_ens_spread_0.25deg_reg_2011-2018_%s.nc",write_dir,version))


	}
}

#nc_month<-list.files(grid010,pattern=paste0("mean_025_reg_",year,"-",months[1]),full.names=TRUE)
if(do.months==TRUE){
message(paste("creating monthly ncfiles for the months"))
for(i in 1:length(months)){
message(months[1])
	if(do.010==TRUE){
	nc_month_mean<-paste0(grid010,mean010,year,"-",months[i],"*")
	nc_out_mean<-paste0(write_dir,"qq_0.1deg_day_",year,"_",months[i],"_grid_ensmean.nc")
	nc_month_spread<-paste0(grid010,spread010,year,"-",months[i],"*")
	nc_out_spread<-paste0(write_dir,"qq_0.1deg_day_",year,"_",months[i],"_grid_se.nc")

	system((sprintf("cdo -O -z zip_1 mergetime %s %s",nc_month_mean,nc_out_mean)))
	system((sprintf("cdo -O -z zip_1 mergetime %s %s",nc_month_spread,nc_out_spread)))

	#system(sprintf("ncap2 -O -s 'time=int(time)' %s",nc_out_mean))
	#system(sprintf("ncap2 -O -s 'time=int(time)' %s",nc_out_spread))
	system(sprintf("ncatted -h -O -a history,global,d,, %s",nc_out_mean))
	system(sprintf("ncatted -h -O -a history,global,d,, %s",nc_out_spread))
	}
	if(do.025==TRUE){
	nc_month_mean<-paste0(grid025,mean025,year,"-",months[i],"*")
	nc_out_mean<-paste0(write_dir,"qq_0.25deg_day_",year,"_",months[i],"_grid_ensmean.nc")
	nc_month_spread<-paste0(grid025,spread025,year,"-",months[i],"*")
	nc_out_spread<-paste0(write_dir,"qq_0.25deg_day_",year,"_",months[i],"_grid_se.nc")

	system((sprintf("cdo -O -z zip_1 mergetime %s %s",nc_month_mean,nc_out_mean)))
	system((sprintf("cdo -O -z zip_1 mergetime %s %s",nc_month_spread,nc_out_spread)))

	#system(sprintf("ncap2 -O -s 'time=int(time)' %s",nc_out_mean))
        #system(sprintf("ncap2 -O -s 'time=int(time)' %s",nc_out_spread))
        system(sprintf("ncatted -h -O -a history,global,d,, %s",nc_out_mean))
        system(sprintf("ncatted -h -O -a history,global,d,, %s",nc_out_spread))

	}

}
}

if(do.year==TRUE){
message(paste0("cdo for yearly ncfiles"))

	if(do.010==TRUE){
	nc_year_mean<-paste0(grid010,mean010,year,"*")
	nc_out_mean<-paste0(write_dir,"qq_0.1deg_day_",year,"_grid_ensmean.nc")
	nc_year_spread<-paste0(grid010,spread010,year,"*")
	nc_out_spread<-paste0(write_dir,"qq_0.1deg_day_",year,"_grid_se.nc")

	system((sprintf("cdo -O -z zip_1 mergetime %s %s",nc_year_mean,nc_out_mean)))
	system((sprintf("cdo -O -z zip_1 mergetime %s %s",nc_year_spread,nc_out_spread)))
	
        #system(sprintf("ncap2 -O -s 'time=int(time)' %s",nc_out_mean))
        #system(sprintf("ncap2 -O -s 'time=int(time)' %s",nc_out_spread))
        system(sprintf("ncatted -h -O -a history,global,d,, %s",nc_out_mean))
        system(sprintf("ncatted -h -O -a history,global,d,, %s",nc_out_spread))

	}
	if(do.025==TRUE){
	nc_year_mean<-paste0(grid025,mean025,year,"*")
	nc_out_mean<-paste0(write_dir,"qq_0.25deg_day_",year,"_grid_ensmean.nc")
	nc_year_spread<-paste0(grid025,spread025,year,"*")
	nc_out_spread<-paste0(write_dir,"qq_0.25deg_day_",year,"_grid_se.nc")

	system((sprintf("cdo -O -z zip_1 mergetime %s %s",nc_year_mean,nc_out_mean)))
	system((sprintf("cdo -O -z zip_1 mergetime %s %s",nc_year_spread,nc_out_spread)))

        #system(sprintf("ncap2 -O -s 'time=int(time)' %s",nc_out_mean))
        #system(sprintf("ncap2 -O -s 'time=int(time)' %s",nc_out_spread))
        system(sprintf("ncatted -h -O -a history,global,d,, %s",nc_out_mean))
        system(sprintf("ncatted -h -O -a history,global,d,, %s",nc_out_spread))

	}
}


