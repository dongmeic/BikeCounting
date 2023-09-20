# This script was created to organize the daily bike counts data
# By Dongmei Chen (dchen@lcog.org)
# On September 6th, 2023

library(lubridate)
library(sp)
library(sf)
source('C:/Users/clid1852/.0GitHub/BikeCounting/BikeCounts/bike_counts_functions.R')

options(warn = -1)
inpath <- 'T:/Data/COUNTS/Nonmotorized Counts/Summary Tables/Bicycle/'
rawdata <- read.csv(paste0(inpath, 'Bicycle_HourlyForTableau.csv'))

year <- 2022

data <- rawdata[rawdata$Year == year & rawdata$Direction == "Total" & rawdata$ObsHours == 24,]
locdata <- read.csv("T:/Data/COUNTS/Nonmotorized Counts/Supporting Data/Supporting Bicycle Data/CountLocationInformation.csv")
locvars <- c('CountType', 'Direction', 'FacilityType', 'RoadWidth', 'City', 
             'Location', 'Latitude', 'Longitude', 'Site_Name', 
             'DoubleCountLocation', 'IsOneway', 'OnewayDirection', 
             'IsSidewalk', 'Location_Description')
data$Date <- as.Date(data$Date, "%m/%d/%Y")
range(data$Date)
aggdata <- aggregate(x=list(DailyCounts = data$Hourly_Count), 
                     by=list(Date = data$Date, Location = data$Location), 
                     FUN=sum, na.rm=TRUE)
no_days <- aggregate(x=list(ObsDays = data$Date), 
                     by=list(Location = data$Location), 
                     FUN=function(x) length(unique(x)))
datedata <- unique(data[,c("Date", "Month", "MonthDesc", "Season", "Weekday", "IsHoliday", "UoInSession", "IsSpecialEvent")])
ave_daily_cnt <- aggregate(x=list(AveDailyCnt = aggdata$DailyCounts), 
                           by=list(Location = aggdata$Location), 
                           FUN=mean)
AveDailyCnt <- merge(ave_daily_cnt, no_days, by="Location")
AveDailyCnt <- merge(AveDailyCnt, locdata[,locvars], by = 'Location')
range(AveDailyCnt$AveDailyCnt)
AveDailyCnt$Pct <- AveDailyCnt$ObsDays / 3.65
range(AveDailyCnt$ObsDays)
# percentage of year-round counting
dim(AveDailyCnt[AveDailyCnt$ObsDays == max(AveDailyCnt$ObsDays),])[1]/dim(AveDailyCnt)[1]
# percentage of sites that are counted for more than 200 days 
length(AveDailyCnt[AveDailyCnt$ObsDays >= 200,"Site_Name"])/length(AveDailyCnt$Site_Name)
# most counted locations
AveDailyCnt[AveDailyCnt$ObsDays == max(AveDailyCnt$ObsDays),"Site_Name"]

aggdata <- merge(aggdata, datedata, by="Date")
aggdata <- merge(aggdata, locdata[,locvars], by = 'Location')
aggdata$SeasonOrder <- ifelse(aggdata$Season == "Spring", 1, 
                              ifelse(aggdata$Season == "Summer", 2, 
                                     ifelse(aggdata$Season == "Fall", 3, 4)))
aggdata$WeekdayOrder <- ifelse(aggdata$Weekday == "Monday", 1, 
                               ifelse(aggdata$Weekday == "Tuesday", 2, 
                                      ifelse(aggdata$Weekday == "Wednesday", 3, 
                                             ifelse(aggdata$Weekday == "Thursday", 4, 
                                                    ifelse(aggdata$Weekday == "Friday", 5, 
                                                           ifelse(aggdata$Weekday == "Saturday", 6, 7))))))

outpath <- "T:/MPO/Bike&Ped/BikeCounting/StoryMap/BikeCounts/Output"
write.csv(aggdata, paste0(outpath, "/Daily_Bike_Counts.csv"), row.names = FALSE)
#dailybc <- read.csv(paste0(outpath, "/Daily_Bike_Counts.csv"))
aggspdf <- df2spdf(aggdata, 'Longitude', 'Latitude')
st_write(st_as_sf(aggspdf), dsn=outpath, layer="Daily_Bike_Counts", 
         driver="ESRI Shapefile", delete_layer=TRUE)
AveDailyCnt_spdf <- df2spdf(AveDailyCnt, 'Longitude', 'Latitude')
st_write(st_as_sf(AveDailyCnt_spdf), dsn=outpath, layer="Mean_Daily_Bike_Counts", 
         driver="ESRI Shapefile", delete_layer=TRUE)
