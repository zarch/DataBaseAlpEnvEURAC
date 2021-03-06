\name{dB_getSWC}
\alias{dB_getSWC}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{Get soil moisture data from EURAC micro-meteo station (Mazia/Matsch)
%%  ~~function to do ... ~~
}
\description{
Retrieve soil moisture data from EURAC micro-meteo station located in Mazia/Matsch
}
\usage{
dB_getSWC(path2files, header.file, station, station_nr, calibration, calibration_file, aggregation, minVALUE=0.05, maxVALUE=0.50, clear_raw_data=FALSE, remove_freezing=FALSE, write.csv=FALSE, path2write)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{path2files}{
  path to meteo files
  }
  \item{header.file}{
  header file, absolute path and file name
  }
   \item{station}{
  character, name of micro-meteo station, e.g. "B"
  }
  \item{station_nr}{
  integer, number of micro-meteo station, e.g. 2
  }
  \item{calibration}{
  boolean, TRUE: calibrated SMC sensor data is used for comparision with simulated SMC; FALSE: use of uncalibrated SMC data
  }
    \item{calibration_file}{
  path and file name of file containing calibration functions for specific stations/sensors
  }
  \item{aggregation}{
  character, time aggregation applied. "n" no aggregation of raw data,"h": hourly, "d": daily
  }
  \item{minVALUE}{
  numeric, minimum value of soil temperature for filtering, default = 5 vol\%
  }
  \item{maxVALUE}{
  numeric, maximum value of soil temperature for filtering, default = 50 vol\%
  }
  \item{clear_raw_data}{
  boolean, TRUE: clearing of raw data, not yet implemented, default = FALSE
  }
  \item{remove_freezing}{
  boolean, TRUE: freezing periods are remove from raw data; only possible for B, P and I stations, default = FALSE
  }
  \item{write.csv}{
  boolean, default = FALSE; TRUE: .csv file is written to path2write, FALSE: no .csv file is written
  }
   \item{path2write}{
  path data should be written to
  }
}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
\enumerate{
  \item zoo object containing processed data
  \item file output containing processed data, .csv format
}
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
}
\references{
%% ~put references to the literature/web site here ~
}
\author{
Johannes Brenner, \email{Johannes.Brenner@eurac.edu}
}
\note{
calibration file is stored here: \file{//ABZ02FST.EURAC.EDU/Projekte/HiResAlp/06_Workspace/BrJ/02_data/Station_data_Mazia/calibration.csv}
}
\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{
}

