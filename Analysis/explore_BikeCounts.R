options(warn = -1)
library(readxl)
library(lubridate)
library(rgdal)
library(RColorBrewer)
library(classInt)

path <- "T:/Data/COUNTS/Nonmotorized Counts"
inpath <- paste0(path, "/Summary Tables/Bicycle/")
data <- read.csv(paste0(inpath, 'Bicycle_HourlyForTableau.csv'))

data$Date <- as.Date(data$Date, "%Y-%m-%d")
locdata <- read.csv(paste0(path, "/Supporting Data/Supporting Bicycle Data/CountLocationInformation.csv"))

# remove missing data
data1 <- data[!is.na(data$Hourly_Count),]
# use only the total direction
data1 <- data1[data1$Direction == 'Total',]
# if the most recent year is not complete, remove it first
data1 <- data1[data1$Year != 2022,]
data1$Season <- ifelse(data1$MonthDesc == "September", "Fall", data1$Season)

locvars <- c('Location', 'Latitude', 'Longitude', 'Site_Name', 
             'DoubleCountLocation', 'IsOneway', 'OnewayDirection', 
             'IsSidewalk')
MPOBound <- readOGR(dsn = "V:/Data/Transportation", layer="MPO_Bound")

