# This script was created to export bikes per hour and the growth
# By Dongmei Chen (dchen@lcog.org)
# On June 16th, 2023

# load libraries
library(readxl)
library(lubridate)
library(RColorBrewer)
library(classInt)
library(raster)

options(warn = -1)
start_year <- 2012
end_year <- 2022
prj4str <- "+proj=merc +a=6378137 +b=6378137 +lat_ts=0 +lon_0=0 +x_0=0 +y_0=0 +k=1 +units=m +nadgrids=@null +wktext +no_defs +type=crs"
inpath <- 'T:/Data/COUNTS/Nonmotorized Counts/Summary Tables/Bicycle/'
data <- read.csv(paste0(inpath, 'Bicycle_HourlyForTableau.csv'))

data$Date <- as.Date(data$Date, "%Y-%m-%d")
locdata <- read.csv("T:/Data/COUNTS/Nonmotorized Counts/Supporting Data/Supporting Bicycle Data/CountLocationInformation.csv")

# remove the site names with direction info
loc1 <- locdata[!grepl('EB|WB|SB|NB', locdata$Site_Name),]
# these location IDs are duplicated
ids <- unique(loc1$LocationId[duplicated(loc1$LocationId)])
for(id in ids){
  print(id)
  print(unique(loc1[loc1$LocationId == id, 'Site_Name']))
}

# duplicated Ids with the same site name
loc1$Site_Name[duplicated(loc1$Site_Name)]
loc1[duplicated(loc1$Site_Name), 'LocationId']

loc2 <- loc1[!grepl('EB|WB|SB|NB', loc1$Location),]
loc2[loc2$Site_Name == 'E Amazon Dr east of Hilyard St', c('LocationId', 'Location', 'Site_Name', 'Direction', 'Latitude','Longitude')]

# remove missing data
data1 <- data[!is.na(data$Hourly_Count),]
# use only the total direction
data1 <- data1[data1$Direction == 'Total',]

range(data1$Date)
#most_recent_year <- 2023
# if the most recent year is not complete, remove it first
data1 <- data1[data1$Year != end_year+1,]
outdata <- aggregate(x=list(BPH = data1$Hourly_Count), by=list(Year = data1$Year, Location = data1$Location), FUN=mean)
locvars <- c('Location', 'Latitude', 'Longitude', 'Site_Name', 'DoubleCountLocation', 
             'IsOneway', 'OnewayDirection', 'IsSidewalk')
outdata <- merge(outdata, locdata[,locvars], by = 'Location')

df2spdf <- function(df, lon_col_name, lat_col_name, trans = TRUE){
  lonlat <- sp::CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")
  lon_col_no <- which(names(df)==lon_col_name)
  lat_col_no <- which(names(df)==lat_col_name)
  xy <- data.frame(df[,c(lon_col_no,lat_col_no)])
  coordinates(xy) <- c(lon_col_name, lat_col_name)
  proj4string(xy) <- lonlat
  spdf <- sp::SpatialPointsDataFrame(coords = xy, data = df)
  if(trans){
    spdf <- spTransform(spdf, CRS(prj4str))
  }
  return(spdf)
}

mapping <- function(plotvar, spdf, nclr=8, col="BrBG", sty="kmeans", legtlt='BPH', 
                    title='Bikes Per Hour in CLMPO'){
  plotclr <- rev(brewer.pal(nclr,col))
  class <- classIntervals(plotvar, nclr, style=sty)
  colcode <- findColours(class, plotclr) 
  par(mfrow=c(1,1),mar=c(0,0,2,0))
  plot(MPOBound %>% st_geometry(), col='grey')
  plot(spdf, pch=16, col=colcode, cex=3, add=T)
  legend("topright", legend=names(attr(colcode, "table")),
         fill=attr(colcode, "palette"), cex=0.9, bty="n", title=legtlt)
}

for(loc in unique(outdata$Location)){
  years <- sort(unique(outdata[outdata$Location == loc,"Year"]))
  for(yr in years){
    if(yr==min(years)){
      outdata[outdata$Location==loc & outdata$Year==yr,"Growth"] <- NA
    }else{
      i <- which(years==yr)
      x1 <- outdata[outdata$Location==loc & outdata$Year==yr,"BPH"]
      x2 <- outdata[outdata$Location==loc & outdata$Year==years[i-1],"BPH"]
      n <- yr - years[i-1]
      outdata[outdata$Location==loc & outdata$Year==yr,"Growth"] <- (x1-x2)/(n*x2)
    }
  }
}

for(loc in unique(outdata$Location)){
  years <- sort(unique(outdata[outdata$Location == loc,"Year"]))
  outdata[outdata$Location==loc,"Nyrs"] <- paste0(length(years), " (", paste(years, collapse=', '), ")")
}

tail(outdata)
outspdf <- df2spdf(outdata, 'Longitude', 'Latitude')
# add city info
ugb <- shapefile("X:/Data/Boundary/UGB/UGB_CLMPO.shp")
ugb <- spTransform(ugb, CRS(prj4str))
outspdf$City <- over(outspdf, ugb)$ugbcitynam
shapefile(outspdf, filename='T:/MPO/Bike&Ped/BikeCounting/StoryMap/BikeCounts/Output/BPH_by_Year.shp', overwrite=TRUE)

outspdf <- outspdf[order(outspdf$BPH),]
MPOBound <- st_read(dsn = "X:/Data/Transportation", layer="MPO_Bound")
mapping(outspdf$BPH, outspdf)

plot(outspdf$Longitude, outspdf$Latitude, type="n")
symbols(outspdf$Longitude, outspdf$Latitude, outspdf$BPH, inches=0.1, add=T)

options(repr.plot.width=12, repr.plot.height=12)
par(mfrow=c(1,1),mar=c(0,0,2,0))
plot(MPOBound %>% st_geometry())
plot(outspdf, add=TRUE)
points(outspdf$Longitude, outspdf$Latitude, cex=outspdf$BPH/10)

options(repr.plot.width=8, repr.plot.height=8)
par(mfrow=c(1,1),mar=c(4,4,2,0))
boxplot(BPH~Year,data=outdata)

outpath <- "T:/MPO/Bike&Ped/BikeCounting/StoryMap/figures"
png(paste0(outpath, "/boxplot_bph_growth.png"), width = 5, 
    height = 5, units = "in", res = 300)
par(mfrow=c(1,1),mar=c(4,4,1,1))
boxplot(Growth~Year,data=outdata, ylab="Growth in Bikes Per Hour")
abline(h=0, col='red', lwd=2, lty=2)
dev.off()

# MPO-wide growth in BPH
df <- transform(aggregate(x=list(BPH = data1$Hourly_Count), by=list(Year = data1$Year), FUN=mean), Growth=ave(BPH, 
                                                                                                              FUN=function(x) c(NA, diff(x)/x[-length(x)])))
df_n = aggregate(x=list(N = data1$Location), by=list(Year = data1$Year), FUN=function(x) length(unique(x))) 
df <- cbind(df, df_n$N)
colnames(df)[4] <- 'n'
df
data2 <- merge(data1[,c('Location', 'Year', 'Hourly_Count')], locdata[,locvars], by='Location')
head(data2)
data3 <- data2[data2$IsSidewalk,]
# MPO-wide growth in sidewalk riding BPH
df1 <- transform(aggregate(x=list(BPH = data3$Hourly_Count), by=list(Year = data3$Year), FUN=mean), Growth=ave(BPH, 
                                                                                                               FUN=function(x) c(NA, diff(x)/x[-length(x)]))) #FUN=function(x) c(NA,exp(diff(log(x)))-1)
df1
df_n1 = aggregate(x=list(N = data3$Location), by=list(Year = data3$Year), FUN=function(x) length(unique(x)))
df1 <- cbind(df1, df_n1$N)
colnames(df1)[4] <- 'n'
df1

#png(paste0(outpath, "/line_bph_mpo.png"), width = 5, 
#    height = 5, units = "in", res = 300)
pdf(paste0(outpath, "/line_bph_mpo.pdf"), width = 5, height = 5)
par(mfrow=c(1,1),mar=c(4,4,1,1))
plot(df$Year, df$BPH, pch=16, col='blue', cex=1.2, ylim=c(0, 17),
     xlim=c(start_year - 0.5, end_year + 0.5), xlab="Year", ylab="Average Bikes Per Hour")
lines(df$Year, df$BPH, col='blue',lwd=2)
points(df1$Year, df1$BPH, pch=16, col='red', cex=1.2)
lines(df1$Year, df1$BPH, col='red',lwd=2)
legend("topright", c("All", "Sidewalk Riding"), bty="n",
       lty = rep(1,2), pch = rep(16,2), col=c("blue", "red"),
       cex = rep(1.2,2), lwd=rep(2,2))
text(x = df$Year,                               
     y = df$BPH - 0.6,
     labels = paste0(round(df$BPH, 1), "(", df$n, ")"), col='blue')
text(x = df1$Year,                               
     y = df1$BPH - 0.6,
     labels = paste0(round(df1$BPH, 1), "(", df1$n, ")"), col='red')
dev.off()

pdf(paste0(outpath, "/line_growth_mpo.pdf"), width = 5, height = 5)
par(mfrow=c(1,1),mar=c(4,4,1,1))
plot(df$Year, df$Growth, pch=16, col='blue', cex=1.2, ylim=c(-0.7, 1.6),
     xlim=c(start_year - 0.5, end_year + 0.5), 
     xlab="Year", ylab="Growth in Average Bikes Per Hour")
lines(df$Year, df$Growth, col='blue',lwd=2)
points(df1$Year, df1$Growth, pch=16, col='red', cex=1.2)
lines(df1$Year, df1$Growth, col='red',lwd=2)
legend("topleft", c("All", "Sidewalk Riding"), bty="n",
       lty = rep(1,2), pch = rep(16,2), col=c("blue", "red"),
       cex = rep(1.2,2), lwd=rep(2,2))
text(x = df$Year,                               
     y = df$Growth - 0.06,
     labels = paste0(round(df$Growth, 2), "(", df$n, ")"), col='blue')
text(x = df1$Year,                               
     y = df1$Growth - 0.06,
     labels = paste0(round(df1$Growth, 2), "(", df1$n, ")"), col='red')
abline(h=0, lwd=2, lty=2)
dev.off()

outpath1 <- "T:/MPO/Bike&Ped/BikeCounting/StoryMap/BikeCounts/Output/"
write.csv(outdata, paste0(outpath1, "BPH.csv"), row.names = FALSE)

bph <- read.csv(paste0(outpath1, "BPH.csv"))
aggdata <- aggregate(x=list(BPH = bph$BPH), by=list(Location = bph$Location), FUN=mean)
aggdata <- merge(aggdata, unique(bph[locvars]), by = 'Location')
aggyear <- aggregate(x=list(Years = bph$Year), by=list(Location = bph$Location), FUN=function(x) length(x))
aggdata <- merge(aggdata, aggyear, by = 'Location')
names(aggdata)[which(names(aggdata) %in% c('DoubleCountLocation', 'OnewayDirection'))] <- c('DoubleCNT', 'OnewayDIR')
aggspdf <- df2spdf(aggdata, 'Longitude', 'Latitude')
# add city info
aggspdf$City <- over(aggspdf, ugb)$ugbcitynam
shapefile(aggspdf, filename='T:/MPO/Bike&Ped/BikeCounting/StoryMap/BikeCounts/Output/BPH.shp', overwrite=TRUE)

# revise the text
outspdf@data[outspdf$BPH==max(outspdf$BPH),]
