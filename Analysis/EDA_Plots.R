# This script was created by Dongmei Chen (dchen@lcog.org) to explore data
# for the bike counting story map
# on February 18th, 2022

library(rgdal)
# bikes per hour
bph <- readOGR(dsn = "T:/DCProjects/StoryMap/BikeCounting/BikeCounts/Output",
               layer = "BPH")

# bikes on buses
bob_in <- readOGR(dsn = "T:/DCProjects/StoryMap/BikeCounting/BikeCounts/Output",
               layer = "Bikes_on_Buses_inbound")

bob_out <- readOGR(dsn = "T:/DCProjects/StoryMap/BikeCounting/BikeCounts/Output",
                   layer = "Bikes_on_Buses_outbound")

# bike share trips
destination <- readOGR(dsn = "T:/DCProjects/StoryMap/BikeCounting/BikeShare/Data",
                       layer = "DestinationCounts")
origin <- readOGR(dsn = "T:/DCProjects/StoryMap/BikeCounting/BikeShare/Data",
                  layer = "OriginCounts")

plot(bph, cex=scale(bph$BPH), pch=1)
