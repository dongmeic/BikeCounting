
# read data from RLID
# https://github.com/dongmeic/RTP/blob/main/data/bikeways_MPO.ipynb
# https://github.com/dongmeic/RTP/blob/main/read_geodata.py

import geopandas as gpd
import os
from sqlalchemy import create_engine
import matplotlib.pyplot as plt
import contextily as ctx


engine = create_engine(   
"mssql+pyodbc:///?odbc_connect="
"Driver%3D%7BODBC+Driver+17+for+SQL+Server%7D%3B"
"Server%3Drliddb.int.lcog.org%2C5433%3B"
"Database%3DRLIDGeo%3B"
"Trusted_Connection%3Dyes%3B"
"ApplicationIntent%3DReadWrite%3B"
"WSID%3Dclwrk4087.int.lcog.org%3B")

MPObd = gpd.read_file("V:/Data/Transportation/MPO_Bound.shp")

def readBikeFacility(add=True):
    sql = '''
    SELECT 
    name,
    ftypedes AS type,
    source,
    Shape.STAsBinary() AS geom
    FROM dbo.BikeFacility
    WHERE status = 'built';
    '''
    
    bikeways = gpd.GeoDataFrame.from_postgis(sql, engine, geom_col='geom')
    bikeways.crs = "EPSG:2914"
    if add:
        path = r'T:\DCProjects\StoryMap\BikeCounting\BikeMap\AGO\AGO.gdb'
        morebikeways = gpd.read_file(path, layer='BikeFacilityNullStatus')
        morebikeways = morebikeways[morebikeways.status=='Built'][['name', 'ftypedes', 'source', 'geometry']]
        morebikeways.rename(columns={'ftypedes': 'type', 'geometry':'geom'}, inplace=True)
        bikeways = bikeways.append(morebikeways, ignore_index=True)
        
    bikeways = bikeways.to_crs(epsg=3857)
    return bikeways

def readBusiness():
    path = r'X:\Projects\RLID\BusinessData\InfoUSA\2021\October\Geocoded.gdb'
    business = gpd.read_file(path, layer="Oct2021_Geo")
    return business

def readEugeneBikeShops():
    path = r'T:\DCProjects\StoryMap\BikeCounting\BikeMap\BikeMap.gdb'
    bikeshops = gpd.read_file(path, layer="EugeneBikeShops")
    return bikeshops

def readBikeStores():
    path = r'T:\DCProjects\StoryMap\BikeCounting\BikeMap\data\InteractiveBikeMap.gdb'
    bikestores = gpd.read_file(path, layer="Bike_Stores")
    return bikestores

def readLensBikeShops():
    path = r'T:\DCProjects\StoryMap\BikeCounting\BikeMap\BikeMap.gdb'
    bikeshops = gpd.read_file(path, layer="LensBikeShop")
    return bikeshops

def mapBikeFacilityType(ftype='Shared Use Path'):
    bikeways = readBikeFacility()
    fig, ax = plt.subplots(figsize=(14, 12))
    bikeways[bikeways['type']==ftype].plot(ax=ax, color='blue', aspect=1)
    MPObd.plot(ax=ax, facecolor="none", edgecolor="black", linestyle='--', linewidth = 1.5, aspect=1)
    ctx.add_basemap(ax, alpha = 0.7)
    plt.title(ftype + " in Central MPO", fontsize=30, fontname="Palatino Linotype", 
              color="grey")
    ax.axis("off");

def readBikeRacks():
    path = r'T:\DCProjects\StoryMap\BikeCounting\BikeMap\MoreBikeData.gdb'
    bikeracks = gpd.read_file(path, layer="Bike_Racks")
    bikeracks.fillna("",inplace=True)
    bikeracks['Address'] = bikeracks.AddressNo + ' ' + bikeracks.Direction + ' ' + bikeracks.AddressName.str.capitalize() + ' ' + bikeracks.AddressType.str.capitalize()
    bikeracks.Address.replace('\s+', ' ', regex=True, inplace=True)
    bikeracks['Business'] = bikeracks.Business.str.capitalize()
    bikeracks.rename(columns={'Color_Style': 'ColorStyle'}, inplace=True)
    bikeracks = bikeracks[['RackType', 'NoOfRacks', 'ColorStyle', 'Business', 'Address', 'geometry']]
    bikeracks = bikeracks.to_crs(epsg=3857)
    return bikeracks
    
def readLTDstops():
    sql = '''
    SELECT 
    stop_number AS stopNumber,
    stop_name AS stopName,
    longitude,
    latitude,
    Shape.STAsBinary() AS geom
    FROM dbo.LTD_Stop;
    '''
    
    ltdstops = gpd.GeoDataFrame.from_postgis(sql, engine, geom_col='geom')
    ltdstops.crs = "EPSG:2914"
    
    ltdstops = ltdstops.to_crs(epsg=3857)
    return ltdstops
