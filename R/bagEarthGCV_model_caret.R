#'
#'@title bagEarthGCV model caret
#'@param groundstations Data from the ground station in spatial format without na values
#'@param method.overlay Method to overlay the points and the grid, choose between over (1 cell) and extract function (which averages over 4 nearest cells)
#'@param variable the variable of the groundstations you want to interpolate
#'@param grid_prediction trend grid for the interpolation with same spatial extent as groundstations
#'@param k number of bootstrap realizations
#'@param length tune length of the model
#'@param method model caret
#'@param formula formula used for the kriging interpolation
#'@description Function overlays the ground stations and the grid, trains and predicts using the caret package function train.
#'@details after running this function take a look at \code{get_statistical_summary}
#'@return returns a list with the interpolation output and a dataframe with the difference between your observations and predicted grid
#'@author Marieke Dirksen
#'@export
bagEarthGCV_model_caret<-function(groundstations,
                          method.overlay='extract',
                          form.in,
                          variable,
                          grid_prediction,
                          length=20,
                          k = 10,
                          method="bagEarthGCV"){
  # requireNamespace("raster", quietly = TRUE)
  # requireNamespace("fields", quietly = TRUE)
  # requireNamespace("gstat", quietly = TRUE)
  # requireNamespace("sp", quietly = TRUE)
  # requireNamespace("caret",quietly = TRUE)
  # requireNamespace("raster", quietly = TRUE)
  ##########################################################################
  #Catching possible problems with the code before continue
  ##########################################################################
  if (!inherits(variable,"character")){
    message("variable name is not a character, returning FALSE")
    return(FALSE)
  }

  if (!inherits(groundstations,"SpatialPointsDataFrame")){
    message("groundstations is not in the format of a SpatialPointsDataFrame, returning FALSE")
    return(FALSE)
  }

  if(!inherits(grid_prediction,"SpatialGridDataFrame")){
    message("grid_drift is not in the format of a SpatialGridDataFrame, returning FALSE")
    return(FALSE)
  }
  ##########################################################################
  names(groundstations)[names(groundstations)==variable] <- "Tint"



  # over functions
  #names(grid_drift)<-"distshore"

  # over Distshore on Var (choose between 2 methods)
  if(method.overlay == 'over'){

    distshore.ov = sp::over(groundstations , grid_prediction)

  } else if(method.overlay == 'extract'){

    distshore.ov = raster::extract(stack(grid_prediction),
                           groundstations,
                           method = 'bilinear',
                           fun = mean,
                           df = TRUE) # interpolated with the 4 nearest raster cells

  } else {message("unknow overlay method")
    return(FALSE)}
  # Copy the values to Var )

  var = groundstations


  var@data[names(grid_prediction)]=distshore.ov[names(grid_prediction)]

  #Prepare input
  field = grid_prediction
  field@data = cbind(field@data, coordinates(field))
  names(field@data) = c("s","x","y")
  #field$log = log(field$s)
  #for(fieldlog in field$s) {try(print(paste("log of", fieldlog, "=", log(fieldlog))))}

  #field$log=fieldlog
  var$x = sp::over(var,field)$x
  var$y = sp::over(var,field)$y
  var$s = sp::over(var,field)$s

  # Remove nodata from dataframe based on missing distshore
  var = var[complete.cases(var@data[names(grid_prediction)]),]

  ###############################################################################################
  ############HERE THE INTERPOLATION STARTS######################################################
  ###############################################################################################
   # control<-trainControl(method = "repeatedcv",
  #                       repeats = 10,
  #                       number = 2,
  #                       returnData = FALSE)
  var<-data.frame(var)
  rownames(var)<-NULL
  mod<-caret::train(form=form.in,
                    data=var,
                    method=method,
                    tuneLength=length,trControl = trainControl(savePredictions = TRUE,allowParallel = FALSE))#method = validation,
  pred<-raster::predict(object=stack(grid_prediction),model=mod)

  sumstat<-mod$results

  #uncertainty using bootstrap methods
  # Number of bootstrap realisations


  # Empty matrix to store validation predictions
  # val_preds <- matrix(nrow = nrow(var), ncol = k)

  # Empty RasterStack to store rasters of bootstrap realisation predictions
  z_realisations <- stack()
  z_rows<-list()

  # Do r bootstrap realisations
  for(i in 1:k) {

    # Generate a bootstrap resample of ph_cal rows
    cal_rows <- unique(sample(nrow(var), nrow(var), replace = TRUE))
    z_rows[[i]]<-cal_rows
    # Fit a Cubist model
    cubist_fit_boot <- caret::train(form=form.in,
                             data=var[cal_rows,],
                             method=method,
                             tuneLength=length,trControl = trainControl(savePredictions = TRUE,allowParallel=FALSE))#method = validation,

    # Predict onto validation samples: subset the data into train and val before bootstrapping
    # val_preds[, i] <- predict(cubist_fit_boot,
    #                           newdata = var[-cal_rows, ])
    #
    # Predict onto raster
    z_realisations <- stack(z_realisations,
                            raster::predict(object=stack(grid_prediction),model=cubist_fit_boot))
  }

  return(list("spatial"=pred,
              "bootstrap_realizations"=z_realisations,
              "bootstrap_subset"=z_rows,
              "model"=mod,
              "pred_obs"=mod$pred,
              "variable_importance"=varImp(mod),
              "statistical_summary"=sumstat))
}
