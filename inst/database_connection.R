library(RMySQL)
source("inst/database_key.R")

get_all_ser_id<-function(var){
dbin <- dbConnect(MySQL(), host=database_key$host,user=database_key$user, password=database_key$password, dbname=database_key$dbname)
query_ser_id<-dbSendQuery(dbin,paste0("select distinct ser_id from series_",var,";"))
ser_id <- fetch(query_ser_id, n=-1)
lapply( dbListConnections( dbDriver( drv = "MySQL")), dbDisconnect)
return(ser_id)
}

get_metadata_else<-function(){
  dbin <- dbConnect(MySQL(), host=database_key$host,user=database_key$user, password=database_key$password, dbname=database_key$dbname)
  query_metadata<-dbSendQuery(dbin,paste0("select stations.sta_id,stations.name as name,country.name as country,
stations.lat/3600 as lat,stations.lon/3600 as lon,stations.elev/10 as elev,
min(series_qq_blended_mixed.ser_date) as start,max(series_qq_blended_mixed.ser_date) as stop
from stations,series,country,series_qq_blended_mixed
where series.sta_id=stations.sta_id and stations.sta_id=series_qq_blended_mixed.sta_id and stations.coun_id=country.coun_id
group by sta_id;"))
  metadata<-fetch(query_metadata, n=-1)
  lapply( dbListConnections( dbDriver( drv = "MySQL")), dbDisconnect)
  return(metadata)

}

get_metadata<-function(var="qq"){
  dbin <- dbConnect(MySQL(), host=database_key$host,user=database_key$user, password=database_key$password, dbname=database_key$dbname)
  query_metadata<-dbSendQuery(dbin,paste0("select distinct stations.sta_id as sta_id,stations.name as name,
  stations.lat/3600 as lat,stations.lon/3600 as lon,elev/10 as elev
  from stations,series,elements where series.sta_id=stations.sta_id
  and series.ele_id=elements.ele_id and elements.ele_grp='",var,"';"))
  metadata<-fetch(query_metadata, n=-1)
  lapply( dbListConnections( dbDriver( drv = "MySQL")), dbDisconnect)
  return(metadata)

}

get_series<-function(stn,var="qq"){
  dbin <- dbConnect(MySQL(), host=database_key$host,user=database_key$user, password=database_key$password, dbname=database_key$dbname)
  query_series<-dbSendQuery(dbin,paste0("select ser_id,ser_date,",var," from series_",var," where ser_id=",stn,";"))
  series<-fetch(query_series)
  lapply( dbListConnections( dbDriver( drv = "MySQL")), dbDisconnect)
  return(series)
}

get_series_day<-function(var="qq",datum="2014-07-01"){
  dbin <- dbConnect(MySQL(), host=database_key$host,user=database_key$user, password=database_key$password, dbname=database_key$dbname)
  query_obs_day<-dbSendQuery(dbin,paste0("select distinct stations.lat/3600 as lat,stations.lon/3600 as lon,
                    stations.sta_id as sta_id,
                    series_",var,"_blended_mixed.ser_date as ser_date,series_",var,"_blended_mixed.",var," as ",var,",series_",var,"_blended_mixed.qc as qc from stations,series,
                    series_",var,"_blended_mixed where
                    stations.sta_id=series.sta_id and
                    series_",var,"_blended_mixed.sta_id=stations.sta_id and
                    series_",var,"_blended_mixed.ser_date='",datum,"';"))
  series<-fetch(query_obs_day,n=-1)
  lapply( dbListConnections( dbDriver( drv = "MySQL")), dbDisconnect)
  return(series)
}

get_blended_mixed_series<-function(var="qq"){
  dbin <- dbConnect(MySQL(), host=database_key$host,user=database_key$user, password=database_key$password, dbname=database_key$dbname)
  query_obs_day<-dbSendQuery(dbin,paste0("select stations.sta_id as sta_id,
                    series_",var,"_blended_mixed.ser_date as ser_date,
                    series_",var,"_blended_mixed.",var," as ",var,",
                    series_",var,"_blended_mixed.qc as qc from stations,
                    series_",var,"_blended_mixed where
                    series_",var,"_blended_mixed.sta_id=stations.sta_id;"))
  series<-fetch(query_obs_day,n=-1)
  lapply( dbListConnections( dbDriver( drv = "MySQL")), dbDisconnect)
  return(series)
}

get_blended_public_series<-function(var="qq"){
  dbin <- dbConnect(MySQL(), host=database_key$host,user=database_key$user, password=database_key$password, dbname=database_key$dbname)
  query_obs_day<-dbSendQuery(dbin,paste0("select stations.sta_id as sta_id,
                    series_",var,"_blended_public.ser_date as ser_date,
                    series_",var,"_blended_public.",var," as ",var,",
                    series_",var,"_blended_public.qc as qc from stations,
                    series_",var,"_blended_public where
                    series_",var,"_blended_public.sta_id=stations.sta_id;"))
  series<-fetch(query_obs_day,n=-1)
  lapply( dbListConnections( dbDriver( drv = "MySQL")), dbDisconnect)
  return(series)
}
