library(rgdal)
ugb <- readOGR(dsn = "T:/DCProjects/StoryMap/BikeCounting/BikeCounts/ReviewBikeCounts/ReviewBikeCounts.gdb",
               layer = "CLMPO_UGB")
proj4string(ugb)
ugb_lonlat <- spTransform(ugb, CRS("+init=epsg:4326"))
ugb_lonlat[ugb_lonlat$ugbcity=="EUG",]@bbox
# min        max
# x -123.21044 -123.03022
# y   43.98386   44.13865
ugb_lonlat[ugb_lonlat$ugbcity=="SPR",]@bbox
# min        max
# x -123.05014 -122.87815
# y   44.00676   44.10293
ugb_lonlat[ugb_lonlat$ugbcity=="COB",]@bbox
# min        max
# x -123.07390 -123.04221
# y   44.12646   44.15568