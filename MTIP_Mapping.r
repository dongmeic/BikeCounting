# This script was created to get coordinate information for the MTIP projects (2021 - 2024)
# and organize field names for output data
# By Dongmei Chen (dchen@lcog.org)
# On February 28th, 2020

library(rgdal)
library(writexl)
library(sp)
library(readxl)

# read spatial data from json conversation
fgdb <- "T:/MPO/TIP/TIP FY18-21/MAPS/MTIP_18_21.gdb"
json2shp.gdb <- "G:/projects/Transportation/MTIP/json2shp.gdb"
pprojects <- readOGR(dsn = fgdb, layer = "MTIP_18_21_point")
lprojects <- readOGR(dsn = fgdb, layer = "MTIP_18_21_line")
lpprojects <- readOGR(dsn = "G:/projects/Transportation/MTIP/MTIP_FY21-24.gdb", layer = "MTIP_18_21_line2points")
prjs2019 <- readOGR(dsn = "G:/projects/Transportation/MTIP/opt_view.gdb", layer = "MTIP_Points_merge_Dissolve")
FY21_24.gdb  <- "G:/projects/Transportation/MTIP/MTIP_FY21-24.gdb"
outpath <- "G:/projects/Transportation/MTIP/MTIP_FY21-24"

# function to get coordinate information by project transformation
write.longlat <- function(gdb, filenm){
  require(rgdal)
  require(writexl)
  outfolder <- "//clsrv111/transpor/MPO/TIP/TIP FY21-24/MAPS/"
  shp <- readOGR(dsn = gdb, layer = filenm)
  shp_lonlat <- spTransform(shp, CRS("+init=epsg:4326"))
  lonlat.df <- as.data.frame(shp_lonlat@coords)
  names(lonlat.df) <- c("Longitude", "Latitude")
  shp_df <- cbind(lonlat.df, shp_lonlat@data)
  write_xlsx(shp_df, paste0(outfolder, paste0(filenm, "_coordinates.xlsx")))
}

# write out coordinates
write.longlat(fgdb, "MTIP_18_21_point")
write.longlat(FY21_24.gdb, "MTIP_18_21_line2points")
write.longlat(json2shp.gdb, "STIP_DesignPhase5")
write.longlat(json2shp.gdb, "points_merge")
write.longlat(json2shp.gdb, "lines_merge_points")

# clean the coordinate information from the original table by removing the empty values
path <- "C:/Users/clid1852/OneDrive - lanecouncilofgovernments/MTIP/"
MTIP <- read_xlsx(paste0(path, "MTIP.xlsx"), sheet=1)
#head(MTIP)
MTIP_pts <- MTIP[!is.na(MTIP$Longitude),]
# double check the non-spatial projects
length(unique(na.omit(MTIP$STIP_Key)))
length(unique(na.omit(MTIP_pts$STIP_Key)))
write.csv(MTIP_pts, paste0(path, "MTIP.csv"), row.names = FALSE)

# double check the projects with line features
lines <- MTIP_pts[MTIP_pts$Line %in% c("Y", "B"), ]
length(unique(na.omit(lines$STIP_Key)))
unique(lines$STIP_Key)

# reorganize the field names for output
"MTIP_spatial_lines"
MTIP_lines <- readOGR(FY21_24.gdb, "MTIP_spatial_lines")
MTIP_lines <- MTIP_lines[,-which(names(MTIP_lines)=="STIP_Key")]
names(MTIP_lines) <- c("STIP_Key", "Owner", "Longitude", "Latitude", "Line", "MTIP_ID", "Proj_Name", 
                       "Proj_Des", "Work_Type", "RTP_Ref", "AQ_Status", "Fiscal_Yrs", "Fed_Fund", 
                       "Fed_Source", "Fed_Req_Ma", "FRM_Source", "Combined", "Other_Fund", "OF_Source", 
                       "T_All_Fund", "Shp_Length")
writeOGR(MTIP_lines, dsn = outpath, layer = "MTIP_Lines", driver = "ESRI Shapefile", overwrite_layer = TRUE) 

MTIP_points <- readOGR(FY21_24.gdb, "MTIP_spatial_points")
names(MTIP_points) <- c("Owner", "Longitude", "Latitude", "Line", "MTIP_ID", "Proj_Name", 
                        "Proj_Des", "Work_Type", "RTP_Ref", "AQ_Status", "STIP_Key", "Fiscal_Yrs", "Fed_Fund", 
                        "Fed_Source", "Fed_Req_Ma", "FRM_Source", "Combined", "Other_Fund", "OF_Source", 
                        "T_All_Fund") 
writeOGR(MTIP_points, dsn = outpath, layer = "MTIP_Points", driver = "ESRI Shapefile", overwrite_layer = TRUE) 

# reorganize the field names for output again
inpath <- "//clsrv111/transpor/MPO/TIP/TIP FY21-24/MAPS/MTIP21_24.gdb"
outpath <- "C:/Users/clid1852/OneDrive - lanecouncilofgovernments/data/MTIP"
MTIP_lines <- readOGR(inpath, "Lines200806")
names(MTIP_lines) <- c("Applicant", "Longitude", "Latitude", "Line", "MTIP_ID", "Proj_Name",                
                       "STIP_Key", "Fiscal_Yrs", "Fed_Fund", "Fed_Source",     
                       "Fed_Req_Ma", "Other_Fund", "OF_Source", "T_All_Fund", "Shp_Length")
writeOGR(MTIP_lines, dsn = outpath, layer = "MTIP_Lines", driver = "ESRI Shapefile", 
         overwrite_layer = TRUE) 

MTIP_points <- readOGR(inpath, "Points200806")
names(MTIP_points) <- c("Applicant", "Longitude", "Latitude", "Line", "MTIP_ID", "Proj_Name",                
                        "STIP_Key", "Fiscal_Yrs", "Fed_Fund", "Fed_Source",     
                        "Fed_Req_Ma", "Other_Fund", "OF_Source", "T_All_Fund") 
writeOGR(MTIP_points, dsn = outpath, layer = "MTIP_Points", driver = "ESRI Shapefile", 
         overwrite_layer = TRUE) 


# add project description
inpath <- "C:/Users/clid1852/OneDrive - lanecouncilofgovernments/MTIP/"
outpath <- "C:/Users/clid1852/OneDrive - lanecouncilofgovernments/data/MTIP"
tb <- read.csv(paste0(inpath, "MTIP_project_description.csv"))
tb <- unique(tb)
colnames(tb) <- c('MTIP_ID','Proj_Desc')
MTIP_lines <- readOGR(outpath, "MTIP_Lines")
MTIP_lines <- merge(MTIP_lines, tb, by='MTIP_ID')
writeOGR(MTIP_lines, dsn = outpath, layer = "MTIP_Lines", driver = "ESRI Shapefile", 
         overwrite_layer = TRUE) 

MTIP_points <- readOGR(outpath, "MTIP_Points")
MTIP_points <- merge(MTIP_points, tb, by='MTIP_ID')
writeOGR(MTIP_points, dsn = outpath, layer = "MTIP_Points", driver = "ESRI Shapefile", 
         overwrite_layer = TRUE)


