#'Write NCDF file 
#'@description writes netcdf files according to ecad standards
#'@param iraster raster input file to be saved as ncdf
#'@param Year year in format YYYY
#'@param Month month in format MM
#'@param Day day in format DD
#'@param ofile output filename 
#'@param ivar abbreviation of the meteorological variable
#'@param N number of dimensions or members
#'@param origin 1950-01-01 is the standard ecad convention
#'@param newfile create a new nc file? TRUE/FALSE
#'@param tstart time offset
#'@param compress nc file compression 
#'@author Richard Cornes
write.ncdf <- function(iraster, Year, Month, Day=1, ofile, ivar="qq", N=1, origin="1950-01-01",
                       newfile=TRUE, tstart=1, compress=1){
  require(ncdf4)
  long.names <- c("tx"="maximum temperature", "tn"="minimum temperature",
                  "tg"="mean temperature","rr"="rainfall","pp"="sea level pressure",
                  "tmn"="mean temperature","dtr"="diurnal temperature range",
                  "shape"="gamma shape parameter","scale"="gamma scale parameter",
                  "prob"="rainfall gamma derived","qq"="surface downwelling shortwave flux in air")
  
  standard.names <- c("tx"="air_temperature", "tn"="air_temperature",
                      "tg"="air_temperature","rr"="thickness_of_rainfall_amount",
                      "pp"="air_pressure_at_sea_level","tg"="air_temperature",
                      "dtr"="diurnal_temperature_range","shape"="gamma_shape",
                      "scale"="gamma_scale","prob"="thickness_of_rainfall_amount","qq"="surface_downwelling_shortwave_flux_in_air")
  
  units <- c("tx"="Celsius", "tn"="Celsius","tg"="Celsius","rr"="mm","pp"="hPa",
             "tmn"="Celsius","dtr"="Celsius","shape"="","scale"="","prob"="mm","qq"="W/m2")
  
  origin <- strftime(origin, "%Y-%m-%d %H:%M", tz="GMT")
  itime <- as.POSIXct(paste(Year,Month,Day,sep="-"), tz="GMT")
  timeval <- julian(itime,origin)
  compress <- ifelse(is.null(compress),NA,compress)
  #tstart <- Day - minday + 1
  
  ## scale.offset <- compute.scale.and.offset(scale.range[1],scale.range[2],scale.range[3])
  if(ivar%in%c("rr","pp")){
    scale.offset <- c("scale"=0.1,"offset"=0.0)
  } else if (ivar%in%c("qq")){
    scale.offset <- c("scale"=1,"offset"=0.0)
  } else {
    scale.offset <- c("scale"=0.01,"offset"=0.0)
  }
  lons <- xFromCol(iraster)
  lats <- rev(yFromRow(iraster)) # Reverse latitude values
  nx <- length(lons)
  ny <- length(lats)
  miss <- -9999.
  dimy <- ncdim_def( "latitude", "degrees_north", lats,
                     longname = "Latitude values")
  dimx <- ncdim_def( "longitude", "degrees_east", lons,
                     longname = "Longitude values")
  dimt <- ncdim_def("time", paste("days since", origin), as.integer(0),
                    unlim=TRUE, calendar="standard", longname="Time in days")
  if(N>1){
    dimz <- ncdim_def("ensemble", "", as.integer(1:N),
                      longname = "Ensemble member")
    idims <- list(dimx,dimy,dimz,dimt)
    rast.arr <- as.array(iraster)
    ny <- dim(rast.arr)[1]
    rast.arr <- aperm(rast.arr, c(2,1,3) )[,ny:1,] #Rotate array by 90degrees
    start <- c(1,1,1,tstart)
    count <- c(-1,-1,-1,1)                                                                                      
  } else {
    idims <- list(dimx,dimy,dimt)
    rast.arr <- as.matrix(iraster)
    ny <- dim(rast.arr)[1]
    rast.arr <- aperm(rast.arr, c(2,1) )[,ny:1] #Rotate array by 90degrees
    start <- c(1,1,tstart)
    count <- c(-1,-1,1)
  }
  vartemp <- ncvar_def(ivar, units[ivar], idims, miss,
                       longname=long.names[ivar], prec = "short",
                       compression=compress)
  
  if(newfile){
    nc  <- nc_create(ofile, list(vartemp))
  } else { nc  <- nc_open(ofile, write=TRUE) }
  
  ncvar_put( nc, dimt, timeval, start=tstart, count=1 )
  rast.arr <- (rast.arr - scale.offset["offset"]) / scale.offset["scale"]
  
  ## Variable attributes
  ncvar_put( nc, vartemp, rast.arr, start=start,count=count)
  ncatt_put(nc,ivar,"scale_factor",scale.offset["scale"],prec="float")
  ncatt_put(nc,ivar,"add_offset",scale.offset["offset"],prec="float")
  ncatt_put(nc,ivar,"standard_name",standard.names[ivar])
  
  
  ## Dimension attributes
  ncatt_put(nc,"latitude","axis","Y")
  ncatt_put(nc,"longitude","axis","X")
  
  dim.atts <- sapply(c("longitude","latitude","time"), function(x){
    ncatt_put(nc,x,"standard_name",x)
  })
  
  nc_close(nc)
}



  
  
