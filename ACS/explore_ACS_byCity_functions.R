# This script was created to save the functions for processing the ACS means of transportation to work data by city
# By Dongmei Chen (dchen@lcog.org)
# On June 14th, 2023

path <- "T:/MPO/Bike&Ped/BikeCounting/StoryMap/ACS"
read_table <- function(file, foldernm="B08006"){
  if(foldernm == "B01003"){
    inpath <- paste0(path, "/", foldernm)
  }else{
    inpath <- paste0(path, "/", foldernm, "/ByCity")
  }
  
  data <- read.csv(paste0(inpath, "/", file))
  year <- as.numeric(substr(file, 8, 11))
  if(foldernm=="B08006"){
    cols <- paste0(foldernm, c("_001E", "_001M",
                               "_014E", "_014M", 
                               "_031E", "_031M",
                               "_048E", "_048M"))
  }else if(foldernm=="B08301"){
    cols <- paste0(foldernm, c("_001E", "_001M", 
                               "_018E", "_018M"))
  }else{
    cols <- paste0(foldernm, c("_001E", "_001M"))
  }
  
  dat <- data[-1,-which(names(data) %in% c("GEO_ID", "NAME"))]
  dat <- apply(dat[,cols], 2, as.numeric)
  dat <- cbind(as.data.frame(dat), data[-1, c("GEO_ID", "NAME")])
  dat$YEAR <- rep(year, dim(dat)[1])
  
  if(foldernm=="B08006"){
    dat$PCT <- dat$B08006_014E/dat$B08006_001E
  }else if(foldernm=="B08301"){
    dat$PCT <- dat$B08301_018E/dat$B08301_001E
  }
  
  return(dat)
}

get_data <- function(foldernm="B08006"){
  pattern <- "_data_with_overlays_|-Data"
  if(foldernm == "B01003"){
    files <- list.files(paste0(path, "/", foldernm), pattern = pattern)
  }else{
    files <- list.files(paste0(path, "/", foldernm, "/ByCity"), pattern = pattern)
  }
  
  for(file in files){
    print(file)
    if(file==files[1]){
      df <- read_table(file, foldernm=foldernm)
    }else{
      ndf <- read_table(file, foldernm=foldernm)
      df <- rbind(df, ndf)
    }
  }
  
  return(df)
}