# This script was created to aggregate daily bike counts data by day of the week, month, and season in the most recent year
# By Dongmei Chen (dchen@lcog.org)
# On September 6th, 2023

options(warn = -1)

library(readxl)
library(lubridate)
library(sf)
source('C:/Users/clid1852/.0GitHub/BikeCounting/BikeCounts/bike_counts_functions.R')
most_recent <- 2022

inpath <- 'T:/Data/COUNTS/Nonmotorized Counts/Summary Tables/Bicycle/'
outpath <- "T:/MPO/Bike&Ped/BikeCounting/StoryMap/BikeCounts/Output"

data <- read.csv(paste0(inpath, 'Bicycle_HourlyForTableau.csv'))
data <- data[(data$Year == most_recent) & (data$Direction == 'Total') & (data$ObsHours == 24),]
data$Date <- as.Date(data$Date, "%m/%d/%Y")
dim(data)
length(unique(data$UniqueId))
locdata <- read.csv("T:/Data/COUNTS/Nonmotorized Counts/Supporting Data/Supporting Bicycle Data/CountLocationInformation.csv")
length(unique(data$Location))
dim(data[is.na(data$Date),])

locvars <- c('Location', 'Latitude', 'Longitude', 'Site_Name', 
             'DoubleCountLocation', 'IsOneway', 'OnewayDirection', 
             'IsSidewalk')
aggdata <- aggregate(x=list(DailyCounts = data$Hourly_Count), 
                     by=list(Date = data$Date, Location = data$Location), 
                     FUN=sum, na.rm=TRUE)
datedata <- unique(data[,c("Date", "Year", "Month", "MonthDesc", "Season",
                            "Weekday", "IsHoliday", "UoInSession", "IsSpecialEvent")])

aggdata <- merge(aggdata, datedata, by="Date")

for(var in c("Weekday", "Month", "Season")){
  aggData(year=most_recent, var=var)
}
