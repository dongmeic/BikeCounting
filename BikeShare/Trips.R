library(lubridate)

inpath <- "T:/DCProjects/StoryMap/BikeCounting/BikeShare/Data/Trips"
files <- list.files(inpath)
selected_vars <- c('User.ID', 'Route.ID', 'Start.Hub', 
                   'Start.Latitude', 'Start.Longitude',
                   'Start.Date', 'Start.Time', 
                   'End.Hub', 'End.Latitude', 'End.Longitude',
                   'End.Date', 'End.Time', 'Bike.ID', 'Bike.Name',
                   'Distance..Miles.', 'Duration')

organize_points <- function(file){
  trips <- read.csv(paste0(inpath, "/", file))
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

for(file in files){
  if(file == files[1]){
    df1 <- read.csv(paste0(inpath, "/", file))
    df2 <- organize_points(file)
    
  }else{
    ndf1 <- read.csv(paste0(inpath, "/", file))
    df1 <- rbind(df1, ndf1)
    
    ndf2 <- organize_points(file)
    df2 <- rbind(df2, ndf2)
  }
  print(file)
}

df1 <- df1[selected_vars]
write.csv(df1, "T:/DCProjects/StoryMap/BikeCounting/BikeShare/Data/trips_20_21.csv",
          row.names=FALSE)

write.csv(df2, "T:/DCProjects/StoryMap/BikeCounting/BikeShare/Data/trips_org_dst_20_21.csv",
          row.names=FALSE)

# trips and duration by year
df1$Start.Date <- as.Date(df1$Start.Date, format = "%Y-%m-%d")
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

toMinutes <- function(x){
  h <- as.numeric(strsplit(x, ":")[[1]][1])
  m <- as.numeric(strsplit(x, ":")[[1]][2])
  s <- as.numeric(strsplit(x, ":")[[1]][3])
  
  res <- h*60 + m + s/60
  
  return(res)
}

df1$Minutes <- unlist(lapply(df1$Duration, function(x) toMinutes(x)))

df_duration <- transform(aggregate(x=list(Duration = df1$Minutes), 
                                by=list(Year = year(df1$Start.Date)), 
                                FUN=mean), 
                      Growth=ave(Duration,FUN=function(x) c(NA, diff(x)/x[-length(x)]))) 

df_duration
