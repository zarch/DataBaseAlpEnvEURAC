# function to extract soil moisture data from station data

# ARGUMENTS
# path2files    path to meteo files
# header.file   header file
# station       station specification
# station_nr    station number
# calibration_function  calibration functions for specific stations/sensors
# aggregation   aggregation performed: "h" hourly, "d" daily, "n" no aggregation, 15min
# minVALUE      minimum VWC value for filter
# maxVALUE      maximum VWC value for filter
# clear_raw_data  not yet included
# remove_freezing only possible for B, I & P stations
# write.csv     should output csv-file be written? default: FALSE    
#               file name: SWC_aggregation_calibrated?_cleared?_removedfreezing?_station.csv
# path2write    path data should be written to

dB_getSWC <- function(path2files, header.file,
                   station, station_nr,
                   calibration=TRUE, 
                   calibration_file="H:/Projekte/HiResAlp/06_Workspace/BrJ/02_data/Station_data_Mazia/calibration.csv",
                   aggregation, 
                   minVALUE=0.05, maxVALUE=.5,
                   clear_raw_data=FALSE,
                   remove_freezing=FALSE,
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
  data <- data_raw[,grep(pattern = "SWC_", x = dimnames(data_raw)[[2]])]

  if (station == "B" | station == "I" | station == "P")
  data <- data[,-grep(pattern = "_Std", x = dimnames(data)[[2]])]
  
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
  
  # FILTER FREEZING DAYS (dependent on soil temperature for B, I & P stations)
  # ? method M, S stations
  if (remove_freezing)
  {
   print("delete freezing periods")
   
   if (station=="I") { patter <- "ST_"; addition <- TRUE; SWC_z2 <- FALSE; domean <- TRUE }
   if (station=="B" & station_nr==1) { patter <- "TS_"; addition <- FALSE; SWC_z2 <- FALSE; domean <- TRUE }
   if (station=="B" & station_nr==2) { patter <- "TS_"; addition <- FALSE; SWC_z2 <- FALSE; domean <- TRUE }
   if (station=="B" & station_nr==3) { patter <- "TS_CS"; addition <- TRUE; SWC_z2 <- FALSE; domean <- FALSE }
   if (station=="P") { patter <- "ST_"; addition <- TRUE; SWC_z2 <- TRUE; domean <- TRUE }
#  if (station=="S" | station=="M") {patter <- "Temp"; addition <- FALSE; SWC_z2 <- FALSE; domean=FALSE }
   
   TS_data <- data_raw[,grep(pattern = patter, x = dimnames(data_raw)[[2]])]

   if (station=="B" & station_nr==3) TS_data <- TS_data[,-grep(pattern = "_z50", x = dimnames(TS_data)[[2]])]
   if (station=="B" & station_nr==1) { 
     TS_data <- TS_data[,-grep(pattern = "_z50", x = dimnames(TS_data)[[2]])]
     TS_data <- TS_data[,-grep(pattern = "SWC", x = dimnames(TS_data)[[2]])]
   }

   if (domean) {
     TS_data_z5  <- rowMeans(TS_data[,grep(pattern = "_z5", x = dimnames(TS_data)[[2]])], na.rm=T)
     TS_data_z20 <- rowMeans(TS_data[,grep(pattern = "_z20", x = dimnames(TS_data)[[2]])], na.rm=T)
     
     if(SWC_z2) TS_data_z2  <- rowMeans(TS_data[,grep(pattern = "_z2_", x = dimnames(TS_data)[[2]])], na.rm=T)
   } else {
     TS_data_z5  <- TS_data[,grep(pattern = "_z5", x = dimnames(TS_data)[[2]])]
     TS_data_z20 <- TS_data[,grep(pattern = "_z20", x = dimnames(TS_data)[[2]])]
     
     if(SWC_z2) TS_data_z2  <- TS_data[,grep(pattern = "_z2_", x = dimnames(TS_data)[[2]])]
   }
   
   # 2cm filter
   if (SWC_z2) {
     for (i in grep(pattern = "_z2_", x = dimnames(data)[[2]])) core[,i] <- ifelse(TS_data_z2 < 0, NA, core[,i])
   }
   # 5cm filter
   for (i in grep(pattern = "_z5", x = dimnames(data)[[2]])) core[,i] <- ifelse(TS_data_z5 < 0, NA, core[,i])
   # 20cm filter
   for (i in grep(pattern = "_z20", x = dimnames(data)[[2]])) core[,i] <- ifelse(TS_data_z20 < 0, NA, core[,i])
  }
  
  # INCLUDE CALIBRATION
  if (calibration)
  {
    print("include calibration")
    
    cal <- read.csv(calibration_file,header=TRUE)
    
    # 2cm (for station I + P)
    if (station=="I" | station=="P") {
      row <- cal$STATION==paste(station, station_nr, sep="") & cal$DEPTH=="SMC5"
      slp <- cal$slope[row]
      int <- cal$intercept[row]   
      core2 <- int + core[,grep("_z2_", colnames(core))] * slp
    
    # 5cm
      row <- cal$STATION==paste(station, station_nr, sep="") & cal$DEPTH=="SMC5"
      slp <- cal$slope[row]
      int <- cal$intercept[row]   
      core5 <- int + core[,grep("_z5", colnames(core))] * slp
      
    # 20cm
      row <- cal$STATION==paste(station, station_nr, sep="") & cal$DEPTH=="SMC20"
      slp <- cal$slope[row]
      int <- cal$intercept[row]   
      core20 <- int + core[,grep("_z20", colnames(core))] * slp  
      
      core <- cbind(core2, core5, core20)
    } else {
      # 5cm
      row <- cal$STATION==paste(station, station_nr, sep="") & cal$DEPTH=="SMC5"
      slp <- cal$slope[row]
      int <- cal$intercept[row]   
      core5 <- int + core[,grep("_z5", colnames(core))] * slp
      
      # 20cm
      row <- cal$STATION==paste(station, station_nr, sep="") & cal$DEPTH=="SMC20"
      slp <- cal$slope[row]
      int <- cal$intercept[row]   
      core20 <- int + core[,grep("_z20", colnames(core))] * slp
      
      core <- cbind(core5, core20)
    }
    
  } else {
    core5 <- core[,grep("_z5", colnames(core))]
    core20 <- core[,grep("_z20", colnames(core))]
    if (station=="I" | station=="P") {
      core2 <- core[,grep("_z2_", colnames(core))]
      core <- cbind(core2, core5, core20)
    } else {
      core <- cbind(core5, core20)
    }
    
  }
  
  # set values below minVALUE / 0 and over maxVALUE to NA
  core <- ifelse(core<=minVALUE, NA, core)
  core <- ifelse(core>=maxVALUE, NA, core)
  
  data <- zoo(core, time(data))
  
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
    if (calibration==TRUE) calibrated <- "calibrated_" else calibrated <- ""
    if (clear_raw_data==TRUE) cleared <- "cleared_" else cleared <- ""
    if (remove_freezing==TRUE) freezing <- "freezrmv_" else freezing <- ""
    file.name <- paste("SWC_",aggregation,"_",calibrated,cleared,freezing,station, station_nr, ".csv", sep="")
    print(paste("writing data to", path2write, file.name))
    
    data2write <- data.frame(Date=substr(time(data),2,17),round(coredata(data),3))
    write.csv(data2write, file.path(path2write,file.name), row.names=F, quote=F)
  }
    
  return(data)
}
