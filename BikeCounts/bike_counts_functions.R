
prj4str <- "+proj=merc +a=6378137 +b=6378137 +lat_ts=0 +lon_0=0 +x_0=0 +y_0=0 +k=1 +units=m +nadgrids=@null +wktext +no_defs +type=crs"

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

agg_data <- function(dt=data1, var="Hour"){
  main_dir <- "T:/MPO/Bike&Ped/BikeCounting/StoryMap/BikeCounts/Output/"
  outdata <- aggregate(x=list(BPH = dt$Hourly_Count), by=list(Category = dt[,var], Location = dt$Location), FUN=mean)
  outdata <- merge(outdata, locdata[,locvars], by = 'Location')
  for(loc in unique(outdata$Location)){
    for(cat in unique(outdata$Category)){
      c <- dt[dt$Location == loc & dt[,var] == cat, var]
      outdata[outdata$Location==loc & outdata$Category == cat,"N"] <- length(c)
    }
    
  }
  names(outdata)[which(names(outdata)=='Category')] <- var
  write.csv(outdata, paste0(path, "/BPH_", var,".csv"), row.names = FALSE)
  print(paste("Got the aggregated data by", var))
  outspdf <- df2spdf(outdata, 'Longitude', 'Latitude')
  filename <- paste0("BPH_", var)
  sub_dir <- filename
  if (!file.exists(sub_dir)){
    dir.create(file.path(main_dir, sub_dir))
  }
  shapefile(outspdf, filename=paste0(main_dir, sub_dir, "/", filename, ".shp"), overwrite=TRUE)
  print(paste("Got the spatial aggregated data by", var))
}

convert_time_to_hour <- function(x){
  s <- unlist(str_split(x, ":"))
  return(as.numeric(s[1])+as.numeric(s[2])/60)
}

