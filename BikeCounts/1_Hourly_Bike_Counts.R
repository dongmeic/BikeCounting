
# load libraries
library(readxl)
library(lubridate)
library(rgdal)
library(RColorBrewer)
library(classInt)

inpath <- 'T:/Data/COUNTS/Nonmotorized Counts/Summary Tables/Bicycle/'
outpath <- "T:/DCProjects/StoryMap/BikeCounting"
data <- read.csv(paste0(inpath, 'Bicycle_HourlyForTableau.csv'))
data$Date <- as.Date(data$Date, "%Y-%m-%d")
locdata <- read.csv("T:/Data/COUNTS/Nonmotorized Counts/Supporting Data/Supporting Bicycle Data/CountLocationInformation.csv")
MPOBound <- readOGR(dsn = "V:/Data/Transportation", layer="MPO_Bound")

# require MPOBound
df2spdf <- function(df, lon_col_name, lat_col_name, trans = TRUE){
  lonlat <- sp::CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")
  lon_col_no <- which(names(df)==lon_col_name)
  lat_col_no <- which(names(df)==lat_col_name)
  xy <- data.frame(df[,c(lon_col_no,lat_col_no)])
  coordinates(xy) <- c(lon_col_name, lat_col_name)
  proj4string(xy) <- lonlat
  spdf <- sp::SpatialPointsDataFrame(coords = xy, data = df)
  if(trans){
    spdf <- spTransform(spdf, CRS(proj4string(MPOBound)))
  }
  return(spdf)
}

# use only the total direction
data1 <- data[data$Direction == 'Total',]
# aggregate the mean by year and location
outdata <- aggregate(x=list(BPH = data1$Hourly_Count), 
                     by=list(Year = data1$Year, 
                             Location = data1$Location), 
                     FUN=mean)
# combine with location info
locvars <- c('Location', 'Latitude', 'Longitude', 'Site_Name', 
             'DoubleCountLocation', 'IsOneway', 'OnewayDirection', 
             'IsSidewalk')
outdata <- merge(outdata, locdata[,locvars], by = 'Location')

for(loc in unique(outdata$Location)){
  years <- sort(unique(outdata[outdata$Location == loc,"Year"]))
  for(yr in years){
    if(yr==min(years)){
      outdata[outdata$Location==loc & outdata$Year==yr,"Growth"] <- NA
    }else{
      i <- which(years==yr)
      x1 <- outdata[outdata$Location==loc & outdata$Year==yr,"BPH"]
      x2 <- outdata[outdata$Location==loc & outdata$Year==years[i-1],"BPH"]
      n <- yr - years[i-1]
      outdata[outdata$Location==loc & outdata$Year==yr,"Growth"] <- (x1-x2)/(n*x2)
    }
  }
}

outspdf <- df2spdf(outdata, 'Longitude', 'Latitude')

