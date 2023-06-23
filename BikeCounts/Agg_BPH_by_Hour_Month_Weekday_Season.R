# This script was created to export aggregated bikes per hour by hour, weekday, month and season
# By Dongmei Chen (dchen@lcog.org)
# On June 20th, 2023

library(readxl)
library(lubridate)
library(raster)
library(stringr)

options(warn = -1)
start_year <- 2012
end_year <- 2022
source('C:/Users/clid1852/.0GitHub/BikeCounting/BikeCounts/bike_counts_functions.R')
inpath <- 'T:/Data/COUNTS/Nonmotorized Counts/Summary Tables/Bicycle/'
data <- read.csv(paste0(inpath, 'Bicycle_HourlyForTableau.csv'))
range(data$Year)
range(na.omit(data$DailyCounts))
data$Date <- as.Date(data$Date, "%Y-%m-%d")
locdata <- read.csv("T:/Data/COUNTS/Nonmotorized Counts/Supporting Data/Supporting Bicycle Data/CountLocationInformation.csv")
# remove missing data
data1 <- data[!is.na(data$Hourly_Count),]
# use only the total direction
data1 <- data1[data1$Direction == 'Total',]
# if the most recent year is not complete, remove it first
data1 <- data1[data1$Year != end_year+1,]

locvars <- c('Location', 'Latitude', 'Longitude', 'Site_Name', 
             'DoubleCountLocation', 'IsOneway', 'OnewayDirection', 
             'IsSidewalk')
MPOBound <- st_read(dsn = "X:/Data/Transportation", layer="MPO_Bound")

agg_data()
for(var in c("Weekday", "Month", "Season")){
  agg_data(var=var)
}