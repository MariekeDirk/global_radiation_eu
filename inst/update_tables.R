source("inst/rscipts/database_connection.R")

metadata<-get_metadata()
blended_mixed<-get_blended_mixed_series()

saveRDS(metadata,file = "/net/pc150400/nobackup/users/dirksen/data/radiation_europe/mysql_dump/stations_qq_nov.rds")
saveRDS(blended_mixed,file = "/net/pc150400/nobackup/users/dirksen/data/radiation_europe/mysql_dump/series_qq_blended_mixed_nov.rds")

#table for ecad online:
table_else<-get_metadata_else()
table_else$start<-as.Date(table_else$start)
table_else$stop<-as.Date(table_else$stop)
table_else$start[which(table_else$start<as.Date("1981-01-01"))]<-as.Date("1981-01-01")
table_else$stop[which(table_else$stop>as.Date("2018-10-31"))]<-as.Date("2018-10-31")
table_else$sta_id<-as.numeric(table_else$sta_id)
table_else$lat<-as.numeric(table_else$lat)
table_else$lon<-as.numeric(table_else$lon)
table_else$elev<-as.numeric(table_else$elev)

outfile<-"/net/pc150400/nobackup/users/dirksen/data/radiation_europe/metadata_qq_nov.txt"
line1 <- sprintf("#STATION | NAME                                     | COUNTRY                        | LAT    | LON    | ELEV   | START      | STOP ")
write(line1,"/net/pc150400/nobackup/users/dirksen/data/radiation_europe/metadata_qq_nov.txt")

#centreer eerste 3 links
for(i in 1:length(table_else$sta_id)){
line <- sprintf("%-8s | %-40s | %-30s | %6.2f | %6.2f | %6.1f | %s | %s",trimws(table_else$sta_id[i]),trimws(table_else$name[i]),trimws(table_else$country[i]),
                table_else$lat[i],table_else$lon[i],table_else$elev[i],table_else$start[i],table_else$stop[i])
write(line,outfile,append=TRUE)
}
# table_else<-reader::conv.fixed.width(table_else)
# write.table(table_else,file="/net/pc150400/nobackup/users/dirksen/data/radiation_europe/metadata_qq_oct.txt",
#             row.names=FALSE,sep="|",quote=FALSE)
