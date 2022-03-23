# This script was created by Dongmei Chen (dchen@lcog.org) to explore data
# for the bike counting story map
# on February 18th, 2022

options(warn = -1)
library(rgdal)
library(raster)
library(rgeos)
library(sf)
library(RODBC)

outpath <- "T:/DCProjects/StoryMap/BikeCounting"
# MPO boundary
MPOBound <- readOGR(dsn = "V:/Data/Transportation", layer="MPO_Bound")

# bikes per hour
bph <- readOGR(dsn = paste0(outpath, "/BikeCounts/Output"), layer = "BPH")

# bikes on buses
bob_in <- readOGR(dsn = paste0(outpath, "/BikeCounts/Output"), layer = "Bikes_on_Buses_inbound")

bob_out <- readOGR(dsn = paste0(outpath, "/BikeCounts/Output"), layer = "Bikes_on_Buses_outbound")

bob_in_ex <- readOGR(dsn = paste0(outpath, "/BikeCounts/Output"), layer = "Bikes_on_Buses_inbound_excluded")

bob_out_ex <- readOGR(dsn = paste0(outpath, "/BikeCounts/Output"), layer = "Bikes_on_Buses_outbound_excluded")

# bike share trips
destination <- readOGR(dsn = paste0(outpath, "/BikeShare/Data"),
                       layer = "DestinationCounts")

origin <- readOGR(dsn = paste0(outpath, "/BikeShare/Data"),
                  layer = "OriginCounts")

cols <- c("ntrips", "nbikers")
origin@data[cols] <- sapply(origin@data[cols],as.numeric)
destination@data[cols] <- sapply(destination@data[cols],as.numeric)

origin@data[cols] <- sapply(origin@data[cols],function(x) x/3)
destination@data[cols] <- sapply(destination@data[cols],function(x) x/3)

plot(bph, cex=scale(bph$BPH), pch=1)

pixelsize = 100
box = round(extent(MPOBound) / pixelsize) * pixelsize
template = raster(box, crs = CRS(proj4string(MPOBound)),
                  nrows = (box@ymax - box@ymin) / pixelsize, 
                  ncols = (box@xmax - box@xmin) / pixelsize)

bph_r = rasterize(bph, template, field = 'BPH', fun = sum)
plot(bph_r)
plot(MPOBound, border='#00000040', add=T)

bob_in_r = rasterize(bob_in, template, field = 'Counts', fun = sum)
plot(bob_in_r)

bob_out_r = rasterize(bob_out, template, field = 'Counts', fun = sum)
plot(bob_out_r)

bob_in_ex_r = rasterize(bob_in_ex, template, field = 'Counts', fun = sum)
plot(bob_in_ex_r)

bob_out_ex_r = rasterize(bob_out_ex, template, field = 'Counts', fun = sum)
plot(bob_out_ex_r)

origin_r1 = rasterize(origin, template, field = 'ntrips', fun = sum)
origin_r2 = rasterize(origin, template, field = 'nbikers', fun = sum)

plot(origin_r1)
plot(origin_r2)

destination_r1 = rasterize(destination, template, field = 'ntrips', fun = sum)
destination_r2 = rasterize(destination, template, field = 'nbikers', fun = sum)

kernel = focalWeight(bph_r, d = 264, type = 'Gauss')
heat_bph = focal(bph_r, kernel, fun = sum, na.rm=T)
plot(heat_bph)
plot(MPOBound, border='#00000040', add=T)

threshold = 1.25
polygons = rasterToPolygons(x = heat_bph, n=16, fun = function(x) { x >= threshold })
contours_bph = gBuffer(gUnaryUnion(polygons), width=100)


pal <- colorRampPalette(c("lightgrey","red"))
plot(MPOBound, border="grey")
plot(heat_bph, col=pal(7), axes=FALSE, box=FALSE, legend=F, 
     frame.plot=F,useRaster=F, add=T)
plot(contours_bph, border='blue', add=T)
plot(heat_bph, col=pal(7), legend.only=TRUE, 
     horizontal = TRUE, legend.args = list(text="Bikes Per Hour"),
     smallplot=c(0.55,0.85, 0.65,0.68)); par(mar = par("mar"))


# funtions
# reference: http://michaelminn.net/tutorials/r-point-analysis/

library(odbc)
con <- dbConnect(odbc(),
                 Driver = "SQL Server",
                 Server = "rliddb.int.lcog.org,5433",
                 Database = "RLIDGeo",
                 Trusted_Connection = "True")
sql = "
SELECT 
OBJECTID AS id,
name,
type,
fed_class,
Shape.STAsBinary() AS geom
FROM dbo.Road;
"

roads <- st_read(con, geometry_column = "geom", query = sql)
class(roads)
plot(st_geometry(roads))
majroads <- roads[!grepl("Collector|Local", roads$fed_class),] %>% st_set_crs(2914)
majroads <- st_transform(majroads, 3857)


heat_map_analysis <- function(shp=bph, field='BPH', pixelsize=100, 
                              d=264, threshold.p = 0.99, 
                              legend.title='Bikes Per Hour',
                              outname='heatmap_bph', res=FALSE, 
                              print=TRUE, export=FALSE){
  
  box = round(extent(MPOBound) / pixelsize) * pixelsize
  template = raster(box, crs = CRS(proj4string(MPOBound)),
                    nrows = (box@ymax - box@ymin) / pixelsize, 
                    ncols = (box@xmax - box@xmin) / pixelsize)
  
  r = rasterize(shp, template, field = field, fun = sum)
  kernel = focalWeight(r, d = d, type = 'Gauss')
  heat = focal(r, kernel, fun = sum, na.rm=T)
  threshold = quantile(getValues(heat), threshold.p, na.rm=T)
  polygons = rasterToPolygons(x = heat, n=16, fun = function(x) { x >= threshold })
  contours = gBuffer(gUnaryUnion(polygons), width=pixelsize)
  if(res){
    return(contours)
  }
  
  pal <- colorRampPalette(c("lightgrey","red"))
  
  if(print){
    png(paste0(outpath, "/figures/", outname, ".png"), width = 8, 
        height = 5, units = "in", res = 300)
    par(mar=c(0,0,0,0))
    plot(MPOBound, border='grey')
    plot(heat, xlim=extent(r)[1:2], ylim=extent(r)[3:4],
         col=pal(7), legend=F, axes=F, box=F,
         frame.plot=F,useRaster=F, add=T)
    plot(st_geometry(majroads), col='grey', add=T)
    plot(contours, border='blue', add=T)
    plot(heat, col=pal(7), legend.only=TRUE, 
         horizontal = TRUE, legend.args = list(text=legend.title),
         smallplot=c(0.55,0.85, 0.75,0.78)); par(mar = par("mar"))
    dev.off()
  }
  if(export){
    p = contours
    p.df <- data.frame( ID=1:length(p))
    pid <- sapply(slot(p, "polygons"), function(x) slot(x, "ID"))
    p.df <- data.frame( ID=1:length(p), row.names = pid)
    p <- SpatialPolygonsDataFrame(p, p.df)
    writeOGR(p, dsn=paste0(outpath, "/shapefiles"), layer=outname,
             driver="ESRI Shapefile", overwrite_layer=TRUE)
  }
}

heat_map_analysis()

heat_map_analysis(shp=bob_in, field='Counts', 
                  legend.title='Inbound Bikes On Buses Per Year',
                  outname='heatmap_bob_in')

heat_map_analysis(shp=bob_out, field='Counts', 
                  legend.title='Outbound Bikes On Buses Per Year',
                  outname='heatmap_bob_out')

heat_map_analysis(shp=destination, field='ntrips', 
                  legend.title='Bike Share Trips Per Year',
                  outname='heatmap_bs_dest')


png(paste0(outpath, "/figures/hot_spots_by_data.png"), width = 8, 
    height = 5, units = "in", res = 300)
par(mar=c(0,0,2,0))
plot(MPOBound, bord="darkgrey", main="Bike Counting Hot Spots By Data Sources")
plot(st_geometry(majroads), col='grey', add=T)
plot(heat_map_analysis(res=TRUE, print = FALSE), bord='red', add=T)

plot(heat_map_analysis(shp=bob_in, field='Counts', 
                  legend.title='Bikes On Buses Per Year',
                  outname='heatmap_bob_in',
                  res=TRUE, print = FALSE), bord='blue', add=T)

plot(heat_map_analysis(shp=bob_out, field='Counts', 
                       legend.title='Bikes On Buses Per Year',
                       outname='heatmap_bob_out',
                       res=TRUE, print = FALSE), bord='purple', add=T)

plot(heat_map_analysis(shp=destination, field='ntrips', 
                  legend.title='Bike Share Trips Per Year',
                  outname='heatmap_bs_dest',
                  res=TRUE, print = FALSE), bord='green', add=T)
legend(x=-13693639, y=5489428, pch = c(1,1,1,1), col = c("red", "blue", "purple", "green"), 
       legend = c("Bike Counts", "Bikes On Buses (inbound)", "Bikes On Buses (outbound)", "Bike Shares"),
       bty = "n")
text(x=-13685639, y=5482828, "* Top 1% are included as the hot spots", cex=0.8)
dev.off()

heat_map_analysis(res=FALSE, print = FALSE, export = TRUE)
heat_map_analysis(shp=bob_in, field='Counts', 
                  legend.title='Bikes On Buses Per Year',
                  outname='heatmap_bob_in',
                  res=FALSE, print = FALSE, export = TRUE)
heat_map_analysis(shp=destination, field='ntrips', 
                  legend.title='Bike Share Trips Per Year',
                  outname='heatmap_bs_dest',
                  res=FALSE, print = FALSE, export = TRUE)

png(paste0(outpath, "/figures/bound_roads.png"), width = 8, 
    height = 5, units = "in", res = 300)
par(mar=c(0,0,2,0))
plot(MPOBound, bord="black")
plot(st_geometry(majroads), col='darkgrey', add=T)
dev.off()