# This script was created to organize the bike share trips data
# By Dongmei Chen (dchen@lcog.org)
# On January 23th, 2022

library(lubridate)
library(sf)
library(stringr)
library(dplyr)
#source("C:/Users/clid1852/.0GitHub/RLearning/geocoding_functions.R")
source("C:/Users/clid1852/.0GitHub/BikeCounting/BikeShare/bike_share_functions.R")

path <- "T:/MPO/Bike&Ped/BikeCounting/StoryMap/BikeShare/Data"
inpath <- paste0(path, "/Trips")
outpath <- paste0(path,"/Output/review") # add coordinates on the records with missing coordinates
  
files <- list.files(inpath)
fileso <- list.files(outpath)
#files[which(!(files %in% fileso))]

selected_vars <- c('User.ID', 'Route.ID', 'Start.Hub', 
                   'Start.Latitude', 'Start.Longitude',
                   'Start.Date', 'Start.Time', 
                   'End.Hub', 'End.Latitude', 'End.Longitude',
                   'End.Date', 'End.Time', 'Bike.ID', 'Bike.Name',
                   'Distance..Miles.', 'Duration')

########################################### Collect Data ###############################################

#file = files[1]
# skip geocoding
if(FALSE){
  geocode_hubs <- function(file){
    df1 <- read.csv(paste0(inpath, "/", file))
    df1 <- df1[df1$Start.Latitude != " - " | df1$Start.Longitude != " - " | df1$End.Latitude != " - " | df1$End.Longitude != " - ",]
    df2 <- df1[df1$Start.Hub != "" & df1$End.Hub != "", selected_vars]
    df3 <- df1[df1$Start.Hub == "" & df1$End.Hub != "", selected_vars]
    df4 <- df1[df1$Start.Hub != "" & df1$End.Hub == "", selected_vars]
    
    starthub_google_crd <- df3[ , c("Start.Latitude", "Start.Longitude")]
    
    ptm <- proc.time()
    for(i in 1:dim(starthub_google_crd)[1]){
      df3$Start.Hub[i] <- unlist(strsplit(rev_geocode_google(starthub_google_crd[i,], api_key)$address,","))[1]
      print(paste(i, df3$Start.Hub[i]))
    }
    proc.time() - ptm
    
    df3$Start.Hub <- str_remove(df3$Start.Hub, "Eugene: ")
    
    endhub_google_crd <- df4[ , c("End.Latitude", "End.Longitude")]
    
    ptm <- proc.time()
    for(i in 1:dim(endhub_google_crd)[1]){
      df4$End.Hub[i] <- unlist(strsplit(rev_geocode_google(endhub_google_crd[i,], api_key)$address,","))[1]
      print(paste(i, df4$End.Hub[i]))
    }
    proc.time() - ptm
    
    df4$End.Hub <- str_remove(df4$End.Hub, "Eugene: ")
    
    df5 <- rbind(df2, df3)
    df6 <- rbind(df5, df4)
    return(df6)
  }
  
  for(file in files){
    df <- geocode_hubs(file)
    if(file=='trips_peace_health_rides_05_01_2019-05_31_2019.csv'){
      colnames(df)[which(colnames(df)=='Distance')] <- "Distance..Miles."
    }
    write.csv(df, paste0(outpath, "/", file), row.names = FALSE)
    print(file)
  }
}

# file <- "trips_peace_health_rides_05_01_2019-05_31_2019.csv"
# testdf <- read.csv(paste0(outpath, "/", file))

for(file in files){
  if(file == files[1]){
    df <- read.csv(paste0(inpath, "/", file))
    df$Start.Date <- as.Date(df$Start.Date, format = "%Y-%m-%d")
    df$End.Date <- as.Date(df$End.Date, format = "%Y-%m-%d")
    df <- df[selected_vars]
  }else{
    ndf <- read.csv(paste0(inpath, "/", file))
    
    if(file=='trips_peace_health_rides_05_01_2019-05_31_2019.csv'){
      ndf$Start.Date <- as.Date(ndf$Start.Date, format = "%m/%d/%Y")
      ndf$End.Date <- as.Date(ndf$End.Date, format = "%m/%d/%Y")
      #colnames(ndf)[which(colnames(ndf)=='Distance')] <- "Distance..Miles."
    }else{
      ndf$Start.Date <- as.Date(ndf$Start.Date, format = "%Y-%m-%d")
      ndf$End.Date <- as.Date(ndf$End.Date, format = "%Y-%m-%d")
    }
    ndf <- ndf[selected_vars]
    df <- rbind(df, ndf)
  }
  print(file)
}
excludedIDs <- c(717565, 742339, 764038, 819845, 1228447, 
                 1354709, 1897910, 2184703, 2207685)
df <- df[!(df$User.ID %in% excludedIDs),]

dim(df)
df <- df[!(df$Start.Latitude == " - " | df$Start.Longitude == " - " | df$End.Latitude == " - " | df$End.Longitude == "- "), ]
# dim(sdf)
# dim(sdf)[1]/dim(df)[1]
# dim(df[(df$Start.Hub == "" | df$End.Hub == ""), ])
# ssdf <- sdf[!(sdf$Start.Hub == "" | sdf$End.Hub == ""), ]
# dim(ssdf)[1]/dim(df)[1]
# sdf0 <- df[(df$Start.Latitude == " - " | df$Start.Longitude == " - " | df$End.Latitude == " - " | df$End.Longitude == "- "), ]
# ssdf0 <- sdf0[sdf0$Start.Hub != "" & sdf0$End.Hub != "", ]

df$Minutes <- unlist(lapply(df$Duration, function(x) toMinutes(x)))
dat <- df
df <- df[!(df$Start.Hub == "" | df$End.Hub == ""), ]
# # review hub names
# #unique(df$Start.Hub[grep("HEDCO", df$Start.Hub)])
df$Start.Hub[grep("University of Oregon Station - Bay", df$Start.Hub)]  <- "UO Station"
df$Start.Hub[grep("U of O Station", df$Start.Hub)]  <- "UO Station"
df$Start.Hub[grep("University of Oregon", df$Start.Hub)] <- str_replace(df$Start.Hub[grep("University of Oregon", df$Start.Hub)],
                                                                        "University of Oregon", "UO")
df$Start.Hub[grep("EMU|Erb Memorial Union", df$Start.Hub)] <- "Erb Memorial Union"
df$Start.Hub[grep("Eugene Station", df$Start.Hub)] <- "Eugene Station"
df$Start.Hub[grep("Police Dept", df$Start.Hub)] <- "UO Police Department"
df$Start.Hub[grep("HEDCO", df$Start.Hub)]  <- "HEDCO Education Building"
df$Start.Hub[grep("Virtual", df$Start.Hub)] <- str_replace(df$Start.Hub[grep("Virtual", df$Start.Hub)],
                                                                        " //(Virtual Hub//)", "")

df$End.Hub[grep("University of Oregon Station - Bay", df$End.Hub)]  <- "UO Station"
df$End.Hub[grep("U of O Station", df$End.Hub)]  <- "UO Station"
df$End.Hub[grep("University of Oregon", df$End.Hub)] <- str_replace(df$End.Hub[grep("University of Oregon", df$End.Hub)],
                                                                        "University of Oregon", "UO")
df$End.Hub[grep("EMU|Erb Memorial Union", df$End.Hub)] <- "Erb Memorial Union"
df$End.Hub[grep("Eugene Station", df$End.Hub)] <- "Eugene Station"
df$End.Hub[grep("Police Dept", df$End.Hub)] <- "UO Police Department"
df$End.Hub[grep("HEDCO", df$End.Hub)]  <- "HEDCO Education Building"
df$End.Hub[grep("Virtual", df$End.Hub)] <- str_replace(df$End.Hub[grep("Virtual", df$End.Hub)],
                                                                  " //(Virtual Hub//)", "")

df[df$Start.Hub == "Monroe St & Blair Blvd ", "Start.Hub"] = "Monroe St & Blair Blvd"
df[df$End.Hub == "Monroe St & Blair Blvd ", "End.Hub"] = "Monroe St & Blair Blvd"

df$Path.ID = paste(df$Start.Hub, "-", df$End.Hub)

write.csv(df, paste0(path, "/trips_all.csv"), row.names=FALSE)

#within MPO boundary
df <- dat
cols <- c("Start.Latitude", "Start.Longitude", "End.Latitude", "End.Longitude")
df <- df %>%
  mutate(across(all_of(cols), function(x) as.numeric(x)))

mdf <- df[(df$Start.Latitude >= 43.97865 & df$Start.Latitude <= 44.16123) & 
           (df$Start.Longitude >= -123.2321 & df$Start.Longitude <= -122.8281) & 
           (df$End.Latitude >= 43.97865 & df$End.Latitude <= 44.16123) &
           (df$End.Longitude >= -123.2321 & df$End.Longitude <= -122.8281), ]

mdf <- mdf[!(mdf$Start.Longitude == mdf$End.Longitude & mdf$Start.Latitude == mdf$End.Latitude),]

ndf <- organize_points(mdf)
ndf$Date <- as.Date(ndf$Date, "%Y-%m-%d")
ndf$Weekday <- as.character(wday(ndf$Date, label=TRUE, abbr=FALSE))
ndf$Month <- months(ndf$Date)
ndf$Season <- ifelse(ndf$Month %in% c("December", "January", "February"), "Winter",
                     ifelse(ndf$Month %in% c("March", "April", "May"), "Spring",
                            ifelse(ndf$Month %in% c("June", "July", "August"), "Summer", "Fall")))
ndf$SeasonOrder <- ifelse(ndf$Season == "Spring", 1, 
                          ifelse(ndf$Season == "Summer", 2, 
                                 ifelse(ndf$Season == "Fall", 3, 4)))
ndf$WeekdayOrder <- ifelse(ndf$Weekday == "Monday", 1, 
                           ifelse(ndf$Weekday == "Tuesday", 2, 
                                  ifelse(ndf$Weekday == "Wednesday", 3, 
                                         ifelse(ndf$Weekday == "Thursday", 4, 
                                                ifelse(ndf$Weekday == "Friday", 5, 
                                                       ifelse(ndf$Weekday == "Saturday", 6, 7))))))
ndf$Year <- year(ndf$Date)
write.csv(ndf, paste0(path, "/trips_org_dst.csv"), row.names=FALSE)

# pathname <- as.data.frame(table(df$Path.Name))
# tail(pathname[order(pathname$Freq),])

########################################### Select Stations ##################################################
orgdf <- ndf[ndf$OriginDestination == "Origin", ]
orgdf[orgdf$Location != "",]
#orgdf <- orgdf[orgdf$Location != "",]

sites <- orgdf$Location
sitedf <- as.data.frame(table(sites))

tail(sitedf[order(sitedf$Freq),],100)$sites
hist(sitedf$Freq)
 
########################################### Aggregate Data by Year ###########################################
# trips and duration by year
df_trips <- transform(aggregate(x=list(Trips = df$Route.ID), 
                                by=list(Year = year(df$Start.Date)), 
                                FUN=function(x) length(unique(x))), 
                                Growth=ave(Trips,FUN=function(x) c(NA, diff(x)/x[-length(x)]))) 
df_trips
                                                                                                              
df_users <- transform(aggregate(x=list(Users = df$User.ID), 
                                by=list(Year = year(df$Start.Date)), 
                                FUN=function(x) length(unique(x))), 
                      Growth=ave(Users,FUN=function(x) c(NA, diff(x)/x[-length(x)]))) 

df_users

df_duration <- transform(aggregate(x=list(Duration = df$Minutes), 
                                by=list(Year = year(df$Start.Date)), 
                                FUN=mean), 
                      Growth=ave(Duration,FUN=function(x) c(NA, diff(x)/x[-length(x)]))) 

df_duration
