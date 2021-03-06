# AUTHOR: Johannes Brenner, Institute for Alpine Environments
# DATE.VERSION: 19.08.2014 V1

# PURPOSE
# read ZRX data files (province Bozen, WISKI, batch download) with function readZRX
# general quality check | min - max variable dependent
# & hourly aggregation (mean - sum) possible
# AND
# return .csv file for each station with available variables

# required libraries: zoo
# required source:    readZRX.R

# ARGUMENTS
# files       ZRX file names (absolute paths)
# write.csv   logical, if TRUE .csv files for each station are written
# output_path path to which .csv files are writte
# do.hourly   logical, if TRUE data gets hourly aggregated
# do.quality  logical, if FALSE general quality check is performed (min - max)

# VALUES
# output .csv files containing available variables for each station
# list containing zoo objects for each station

dB_readZRX2station <- function(files, write_csv, output_path, do.hourly, do.quality, chron)
  
  {
    # source function readZRX
    #source("readZRX")
  
    # dummies for station names, data and meta data
    stnames <- c()
    out_data <- list()
    out_metadata <- list()
    
    # read data via loop over files
    for (i in files)
    {
      out  <- dB_readZRX(i, do.hourly = do.hourly, do.quality = do.quality, chron = FALSE)
      out_data[[substr(i,1,nchar(i)-4)]] <- out[[1]]
      out_metadata[[substr(i,1,nchar(i)-4)]] <- out[[2]]
      stnames <- c(stnames, names(out_data[[substr(i,1,nchar(i)-4)]]))
    }
  
    # get unique station IDs
    stations <- unique(stnames)
    
    # preperation for dummy with minimal time frame 
    t <- lapply(X = out_data, FUN = function(x){
      lapply(X = x, FUN = function(x){
        diff(range(time(x)))
      })
    })
    t <- lapply(t, unlist)
    min1 <- lapply(t, which.min)
    min2 <- which.min(unlist(lapply(t, which.min)))
    
    # dummy for station data
    station_data <- list()
    
      # loop over unique station vector
      for (i in stations)
      {
        # dummy for specific station and variable available for this station
        dummy <- zoo(NA, time(out_data[[min2]][[min1[[min2]]]]))
        name_spec <- c()
        
        # loop over variables
        for (dat in names(out_data))
        {
          #get meta data for variable dat
          metadata <- out_metadata[[dat]]
          
          #get data for variable dat and station i
          data <- out_data[[dat]]
          
          if ( any(names(data)==i) ){
            st_data <- data[[i]]
           
            dummy <- merge(dummy, st_data)
            name_spec <- c(name_spec, TRUE)
          } else {
            name_spec <- c(name_spec, FALSE)
          }
        }
        dummy <- dummy[,-1]
        
        # name coloums of zoo object
        names(dummy) <- names(out_data)[name_spec]
        
        # write .csv file containing station data
        if (write_csv)
        {
          #STinMetadata <- which(substr(i,3,nchar(i))==metadata[,"st_id"])
          if (do.hourly==T){
            output_filename <- paste(i, "60", sep="_")
          } else {
            output_filename <- paste(i, unique(metadata[,"time_agg"]), sep="_")
          }
          write.zoo( x = dummy, file = file.path(output_path, paste(output_filename,".csv",sep="")), 
                     row.names=F, col.names=T, sep=",", quote=F, index.name="date")
        }
        
        # save data in station data list
        station_data[[i]] <- dummy
      }
      
    # return function output
    return(station_data)

  }
