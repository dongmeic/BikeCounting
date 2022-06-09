# Objective: to prepare spatial data for the bike share holds during May 2018 and May 2022
# By Dongmei Chen (dchen@lcog.org)
# On June 7th, 2022
library(stringr)
source("T:/DCProjects/GitHub/common_functions.R")

path <- "T:/DCProjects/StoryMap/BikeCounting/BikeShare/Data/Holds"
df <- cbdf(path)

head(df)
names(df)
dim(df)
df <- df[!(is.na(df$Hold.Latitude) | is.na(df$Hold.Longitude)),]

getMinutes <- function(s){
  d <- str_split(s, " ")[[1]]
  return(as.numeric(d[1]) + as.numeric(d[3])/60)
}

df$Minutes <- sapply(df$Hold.Duration, getMinutes)
holdspdf <- df2spdf(df, 'Hold.Longitude', 'Hold.Latitude')
outpath <- "T:/DCProjects/StoryMap/BikeCounting/BikeShare/Output"
writeOGR(holdspdf, dsn=outpath, layer="bike_share_holds", driver="ESRI Shapefile", overwrite_layer=TRUE)
