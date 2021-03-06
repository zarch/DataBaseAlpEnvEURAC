# function to extract soil temperature data from station data

# ARGUMENTS
# path2files    path to meteo files
# header.file   header file
# station       station specification
# station_nr    station number
# aggregation   aggregation performed: "h" hourly, "d" daily, "n" no aggregation, 15min
# minVALUE      minimum Soil Temp value for filter
# maxVALUE      maximum Soil Temp value for filter
# clear_raw_data  not yet included
# write.csv     should output csv-file be written? default: FALSE    
#               file name: SWC_aggregation_cleared?_station.csv
# path2write    path data should be written to

dB_getSoilTemp <- function(path2files, header.file,
                   station, station_nr,
                   aggregation, 
                   minVALUE=-30, maxVALUE=30,
                   clear_raw_data=FALSE,
                   write.csv=FALSE,
                   path2write)
{
  #require(zoo)
  #require(xts)
  #require(chron)
  
  # supress chron year abbreviation  
  options(chron.year.abb = FALSE)
  
  #source("H:/Projekte/HiResAlp/06_Workspace/BrJ/04_R_data_analyses/data_base/FUN_readStationData2zoo.R")
  #source(("H:/Projekte/HiResAlp/06_Workspace/BrJ/04_R_data_analyses/FunctionsAllg/chron.R"))
  
  data_raw <- dB_readStationData(path = path2files, header.file = header.file, station=paste(station,station_nr,sep=""))
  
  # filter SWC data
  # for all stations SWC
  if (station=="B") data <- data_raw[,grep(pattern = "TS_", x = dimnames(data_raw)[[2]])]
  if (station=="P" | station=="I") {
    data <- data_raw[,grep(pattern = "ST_", x = dimnames(data_raw)[[2]])]
    data <- data[,-grep(pattern = "_Std", x = dimnames(data)[[2]])]
  } 
  
#   if (station == "B" | station == "I" | station == "P")
#     data <- data[,-grep(pattern = "_Std", x = dimnames(data)[[2]])]
  
  # NaN to NA
  core <- ifelse(is.nan(coredata(data)), NA, coredata(data))
  
  # DELETE "BAD" DATA (clear_file)
  if (clear_raw_data)
  {
    #     plot(data[,4])
    #     plot(window(data[,4],start = chron(dates. = "10/01/14", times. = "00:00:00", out.format = c(dates="y-m-d", times="h:m:s")), 
    #                            end = chron(dates. = "10/10/14", times. = "00:00:00", out.format = c(dates="y-m-d", times="h:m:s"))))
    #     
    print("remove bad data")
    #     station_name <- paste(station, station_nr, sep="")
    #     tab2clear <- read.csv("")
    
  }

  if (station=="B") {
    core0  <- core[,grep("_z0", colnames(core))]
    core5  <- core[,grep("_z5", colnames(core))]
    core5  <- core5[,-grep("_z50", colnames(core5))]
    core10 <- core[,grep("_z10", colnames(core))]
    core20 <- core[,grep("_z20", colnames(core))]
    core50 <- core[,grep("_z50", colnames(core))]
    
    core <- cbind(core0, core5,  core10, core20, core50)
  }
  if (station=="P" | station=="I") {
    core2  <- core[,grep("_z2_", colnames(core))]
    core5  <- core[,grep("_z5", colnames(core))]
    core20 <- core[,grep("_z20_", colnames(core))]
    
    core <- cbind(core2, core5,  core20)
  }
  
  # set values below minVALUE / 0 and over maxVALUE to NA
  core <- ifelse(core<=minVALUE, NA, core)
  core <- ifelse(core>=maxVALUE, NA, core)
  
  data <- zoo(core, time(data))

  # plot.zoo(data, screens = c(1,2,1,2,1,2,1,2,1,2), plot.type = "multiple", col = c(1,1,2,2,3,3,4,4,5,5))

  # daily aggregation
  if (aggregation == "d") data <- aggregate(x=data,by=as.Date(time(data)),FUN=mean, na.rm=T)
  if (aggregation == "h") 
  {
    # aggregation around hour: for 06:00  [05:30;06:30]
    #aggr_vec <- as.POSIXct(round(as.numeric(time(data))/3600)*3600, origin="1970-01-01")
    aggr_vec <- floor(as.numeric(time(data))*24)
    #aggr_vec <- trunc.minutes(x = time(data), n.minutes = 60)
    data <- aggregate(x=data, by=aggr_vec, FUN=mean, na.rm=F)
    data <- zoo(x =  coredata(data), order.by = chron(time(data)/24))
  }
  
  if (write.csv)
  {
    # write data in csv file
    if (clear_raw_data==TRUE) cleared <- "cleared_" else cleared <- ""
    file.name <- paste("SoilTemp_",aggregation,"_",cleared,station, station_nr, ".csv", sep="")
    print(paste("writing data to", path2write, file.name))
    
    data2write <- data.frame(Date=substr(time(data),2,17),round(coredata(data),3))
    write.csv(data2write, file.path(path2write,file.name), row.names=F, quote=F)
  }
  
  return(data)
}
