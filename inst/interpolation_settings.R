global_settings <- list(
  version = "v20.0e" #eobs version number for NCDF4 attributes
  
 )

#start and stop interpolation dates
interpolation_settings <- list(
  tstart=as.Date("2019-01-01"), #start day of the interpolation
  tstop=as.Date("2019-10-30"),  #stop day of the interpolation
  nCore=24,                     #number of cores to be used for parallel computations
  save_model_info=FALSE,        #model info save functions are not yet up to date
  overwrite.files=TRUE          #should existing files be overwritten?
  )

#file names and paths
birdexp06_path <- list(
  main_dir             = "/data3/global_radiation_europe/data/",
  main_save_dir        = "/data3/global_radiation_europe/data/NCDF/",
  save_model_info_dir  = "/data2/global_radiation_europe/model_info/",
  series_qq_blended    = "series_qq_blended_mixed_nov.rds",
  stations_qq          = "stations_qq_nov.rds"
  )

pc15400_path <- list(
  main_dir             = "/net/pc150400/nobackup/users/dirksen/data/radiation_europe/",
  main_save_dir        = "/net/pc150400/nobackup/users/dirksen/data/radiation_europe/NCDF/",
  save_model_info_dir  = "/net/pc150400/nobackup/users/dirksen/data/radiation_europe/model_info/",
  series_qq_blended    = "series_qq_blended_mixed_nov.rds",
  stations_qq          = "stations_qq_nov.rds"
  )

#resample to 0.25 settings
birdexp06_resample <- list(
  data_dir = "/data3/global_radiation_europe/data/NCDF/",
  elev_dir = "/data3/global_radiation_europe/data/grid025/",
  save_dir = "/data3/global_radiation_europe/data/NCDF025/"
  )

#month year nc file settings
birdexp06_nc <- list(
  grid010   = "/data3/global_radiation_europe/data/NCDF/",
  grid025   = "/data3/global_radiation_europe/data/NCDF025/",
  write_dir = "/data3/global_radiation_europe/data/NCDF_month_year/"
  )

which_month_year_nc <- list(
  do.010    = TRUE, #0.10 degree grids
  do.025    = TRUE, #0.25 degree grids
  do.full   = FALSE,#full period
  do.year   = TRUE, #year file of the running year
  do.months = TRUE, #month files of the running year months
  do.15year = FALSE #15 year files according to the standard time periods 
  )