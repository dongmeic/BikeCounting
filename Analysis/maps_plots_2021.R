
options(warn = -1)
library(rgdal)

BikeCounts <- readOGR(dsn="T:/DCProjects/StoryMap/BikeCounting/BikeCounts/Output", layer="Mean_Daily_Bike_Counts_2021")
BikeShare <- readOGR(dsn="T:/DCProjects/StoryMap/BikeCounting/BikeShare/Output", layer="Sum_Bike_Share_Trips")
BikesOnBuses <- readOGR(dsn="T:/DCProjects/StoryMap/BikeCounting/BikeOnBuses/Output", layer="Sum_Bikes_On_Buses")

countsCut <- 521
shareCut <- 21.3
BOBCut <- 2.15


MPOBound <- readOGR(dsn = "V:/Data/Transportation", layer="MPO_Bound")

outpath <- "T:/DCProjects/StoryMap/BikeCounting/figures"
png(paste0(outpath, "/high_bike_counts_loc.png"), width = 6, height = 5,
    units = "in", res = 300)
par(mar=c(1,1,1,1))
plot(MPOBound)
plot(BikeCounts[BikeCounts$AvDlyCn >= countsCut,], col='blue', cex=2, add=T)
plot(BikeShare[BikeShare$AvgNoTrips >= shareCut,], col='red', pch=2, cex=2, add=T)
plot(BikesOnBuses[BikesOnBuses$avgqty >= BOBCut,], col='green', pch=1, cex=2, add=T)
legend("topright", c("Bike Counts", "Bike Share", "Bikes on Buses"), 
       pch = c(3, 2, 1), col=c("blue", "red", "green"),
       cex = rep(1.5,3))
dev.off()
