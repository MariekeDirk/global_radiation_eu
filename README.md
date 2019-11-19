# Gridding of Global Radiation
The gridding of global radiation uses station data, patterns from satellite data and geospatial predictors (height and distance to the coast). All the spatial predictors were stored as .grd files (.nc would also be possible) and read by the function `stack`. The spatial predictors are projected on `CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")`. 

The station data is stored in two seperate files, one with metadata and one with the global radiation observations in the format of a `data.table`. The stations file has the following columns: sta_id,name,lat,lon,elev representing the unique station code, station name, latitude, longitude and elevation; where the corresponding classes are respectively: int,chr,num,num,num. The lat,lon are in WGS84 coordinate system and the elev in the elevation in meters. The global radiation observations has the columns: sta_id,ser_date,qq,qc where qq are the global radiation observations and qc are the quality control flags, both as class num. 

There are a total of 3 Rscripts, one for the interpolation, one for the resampling and one for the NCDF4 output files. To run all the Rscripts in the corresponding order please use `global_radiation_gridding_exe.R`. 

### Interpolation methods
Before running the script `/inst/radiation_eu_interpolation.R` settings and directories should be specified in `/inst/interpolation_settings.R`. Because the interpolation routine can take some time the script is running in parallel. Therefore, the number of cores with `Ncore` should be specified. The interpolation method requires a minimum of 4 observations within a radius of 500km. The spatial prediction domain is calculated using the function `/R/fast.mask.nn.R`. 

Using a overlay function the values of the spatial predictors at the stations location in determined. The multiple adaptive regression spline (MARS) fits to this `data.frame` and optimizes using repeated bootstrap. In order to prevent the model from overfitting the MARS function uses pruning. Note that without the setting `allowParallel=FALSE` the model from the `caret` package automatically runs in parallel, which interferes with the parallel loop over the predition days. Besides the control run which uses all the data a total of 10 ensemble member are calculated using only a subset of the observations. From these members the spread was calculated as the 5-95\% confidence interval. 

### Resampling and NCDF4 output 
After running the interpolation on a 0.1 degree grid the NCDF files are resampled to 0.25 degree using a bilinear resampling methods of the `raster` package (script `/inst/resample_to_025.R`). From all the single day file the script `/inst/month_year_nc.R` combines the NCDF files for the current years months, current year, 15 yearly files and the full period. 

