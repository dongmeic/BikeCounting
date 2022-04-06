# This script was created to organize bike share trips data
# By Dongmei Chen (dchen@lcog.org)
# On January 23th, 2022

library(lubridate)
source("T:/DCProjects/GitHub/RLearning/geocoding_functions.R")

inpath <- "T:/DCProjects/StoryMap/BikeCounting/BikeShare/Data/Trips"
outpath <- "T:/DCProjects/StoryMap/BikeCounting/BikeShare/Data/Output"
  
files <- list.files(inpath)
selected_vars <- c('User.ID', 'Route.ID', 'Start.Hub', 
                   'Start.Latitude', 'Start.Longitude',
                   'Start.Date', 'Start.Time', 
                   'End.Hub', 'End.Latitude', 'End.Longitude',
                   'End.Date', 'End.Time', 'Bike.ID', 'Bike.Name',
                   'Distance..Miles.', 'Duration')

#test <- read.csv("T:/DCProjects/StoryMap/BikeCounting/BikeShare/Data/trips_2019-05-01_2019-05-31.csv")

########################################### Collect Data ###############################################
organize_points <- function(trips){
  #trips <- read.csv(paste0(inpath, "/", file))
  org <- trips[,c('Route.ID', 'Bike.ID', 'User.ID', 
                  'Start.Hub', 'Start.Latitude', 'Start.Longitude',
                  'Start.Date', 'Start.Time')]
  names(org) <- c("RouteID", "BikeID", 'UserID',
                  "Location", "Latitude", "Longitude",
                  "Date", "Time")
  org$OriginDestination <- rep("Origin", dim(org)[1])
  dst <- trips[,c('Route.ID', 'Bike.ID', 'User.ID', 'End.Hub',
                  'End.Latitude', 'End.Longitude',
                  'End.Date','End.Time')]
  names(dst) <- c("RouteID", "BikeID", 'UserID',
                  "Location", "Latitude", "Longitude", 
                  "Date", "Time")
  dst$OriginDestination <- rep("Destination", dim(dst)[1])
  df <- rbind(org, dst)
  return(df)
}

toMinutes <- function(x){
  h <- as.numeric(strsplit(x, ":")[[1]][1])
  m <- as.numeric(strsplit(x, ":")[[1]][2])
  s <- as.numeric(strsplit(x, ":")[[1]][3])
  
  res <- h*60 + m + s/60
  
  return(res)
}

#file = files[1]
geocode_hubs <- function(file){
  df1 <- read.csv(paste0(inpath, "/", file))
  df2 <- df1[df1$Start.Hub != "" & df1$Start.Latitude != " - " & df1$End.Hub != "", selected_vars]
  df3 <- df1[df1$Start.Hub == "" & df1$Start.Latitude != " - " & df1$End.Hub != "", selected_vars]
  df4 <- df1[df1$Start.Hub != "" & df1$Start.Latitude != " - " & df1$End.Hub == "", selected_vars]
  
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
  if(file == files[1]){
    df1 <- geocode_hubs(file)
    write.csv(df1, paste0(outpath, "/", file), row.names = FALSE)
  }else{
    ndf1 <- geocode_hubs(file)
    write.csv(ndf1, paste0(outpath, "/", file), row.names = FALSE)
    if(file=='trips_peace_health_rides_05_01_2019-05_31_2019.csv'){
      colnames(ndf1)[which(colnames(ndf1)=='Distance')] <- "Distance..Miles."
    }
    df1 <- rbind(df1, ndf1)
  }
  print(file)
}

df1$Start.Date <- as.Date(df1$Start.Date, format = "%Y-%m-%d")
df1$Minutes <- unlist(lapply(df1$Duration, function(x) toMinutes(x)))

df2 <- organize_points(df1)

write.csv(df1, "T:/DCProjects/StoryMap/BikeCounting/BikeShare/Data/trips_all.csv",
          row.names=FALSE)

write.csv(df2, "T:/DCProjects/StoryMap/BikeCounting/BikeShare/Data/trips_org_dst.csv",
          row.names=FALSE)

########################################### Select Stations ##################################################
df3 <- df2[df2$OriginDestination == "Origin", ]
df4 <- df3[df3$Location != "",]

site <- df4$Location
df <- as.data.frame(table(site))
df[order(df$Freq),]
  
########################################### Aggregate Data by Year ###########################################
# trips and duration by year
df_trips <- transform(aggregate(x=list(Trips = df1$Route.ID), 
                                by=list(Year = year(df1$Start.Date)), 
                                FUN=function(x) length(unique(x))), 
                                Growth=ave(Trips,FUN=function(x) c(NA, diff(x)/x[-length(x)]))) 
df_trips
                                                                                                              
df_users <- transform(aggregate(x=list(Users = df1$User.ID), 
                                by=list(Year = year(df1$Start.Date)), 
                                FUN=function(x) length(unique(x))), 
                      Growth=ave(Users,FUN=function(x) c(NA, diff(x)/x[-length(x)]))) 

df_users

df_duration <- transform(aggregate(x=list(Duration = df1$Minutes), 
                                by=list(Year = year(df1$Start.Date)), 
                                FUN=mean), 
                      Growth=ave(Duration,FUN=function(x) c(NA, diff(x)/x[-length(x)]))) 

df_duration
