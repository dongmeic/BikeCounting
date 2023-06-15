# This script was created to save the functions for processing the ACS means of transportation to work data
# By Dongmei Chen (dchen@lcog.org)
# On June 13th, 2023

inpath <- "T:/MPO/Bike&Ped/BikeCounting/StoryMap/ACS"

read_table <- function(file, foldernm="B08301"){
  inpath <- paste0(inpath, "/", foldernm)
  data <- read.csv(paste0(inpath, "/", file))
  year <- as.numeric(substr(file, 8, 11))
  if(foldernm=="B08006"){
    cols <- c("B08006_014E", "B08006_014M", 
              "B08006_031E", "B08006_031M",
              "B08006_048E", "B08006_048M")
  }else{
    cols <- c("B08301_001E", "B08301_001M", 
              "B08301_018E", "B08301_018M")
  }
  
  dat <- data[-1,-which(names(data) %in% c("GEO_ID", "NAME"))]
  dat <- apply(dat[,cols], 2, as.numeric)
  if(foldernm=="B08301"){
    dat <- cbind(as.data.frame(dat), data[-1, c("GEO_ID", "NAME")])
  }else{
    dat <- cbind(t(as.data.frame(dat)), data[-1, c("GEO_ID", "NAME")])
    rownames(dat) <- NULL
  }
  dat$YEAR <- rep(year, dim(dat)[1])
  if(foldernm=="B08006"){
    dat$PCT <- dat$B08006_048E/dat$B08006_014E
  }else{
    dat$PCT <- dat$B08301_018E/dat$B08301_001E
  }
  return(dat)
}

get_data <- function(foldernm="B08301"){
  files <- list.files(paste0(inpath, "/", foldernm), pattern = "_data_with_overlays_|-Data")
  for(file in files){
    if(file==files[1]){
      df <- read_table(file, foldernm=foldernm)
    }else{
      ndf <- read_table(file, foldernm=foldernm)
      df <- rbind(df, ndf)
    }
  }
  return(df)
}

add_legend <- function(...){
  opar <- par(fig=c(0,1,0,1), oma=c(0,0,0,0),mar=c(0,0,0,0), new=TRUE)
  on.exit(par(opar))
  plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
  legend(...)
}