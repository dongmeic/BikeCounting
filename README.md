The repository is to organize bike counting related datasets (bike counts, bike shares, bikes on buses, bike facilities and infrastructure, etc.) collected in CLMPO. The US Census ACS [Table B08301: Means of Transportation to Work](https://censusreporter.org/tables/B08301/) ([download](https://data.census.gov/cedsci/table?q=Table%20B08301&g=0100000US%243100000&tid=ACSDT5Y2021.B08301)) and [Table B08006: Sex of Workers by Means of Transportation to Work](https://censusreporter.org/tables/B08006/) ([download](https://data.census.gov/cedsci/table?q=Table%20B08006&g=310XX00US21660&tid=ACSDT5Y2021.B08006)) are also reviewed to understand the number and percent of bike commuters in the metropolitan area.

# Data
## Bike counts

Bicycle counts in Central Lane MPO area combine both permanent and short-term tube counts. There are 16 permanent counters that are collecting data continuously and data is accessible from [Eco-Visio](https://www.eco-visio.net/v5/login/?callback=%2Fv5%2F#::) with credentials. Six [short-term bike counting tubes](https://www.eco-counter.com/produits/pyro-evo-range-en/urban-postevo/) are rotated manually every two weeks from March to October among the locations determined by a process described in the Section 2 Data Collection (page 19) in [the ODOT bicycle count data report](https://www.oregon.gov/odot/Programs/ResearchDocuments/304-761%20Bicycle%20Counts%20Travel%20Safety%20Health.pdf#page=24). The CLMPO bike counts can be viewed and downloaded from the [data portal](https://www.lcog.org/thempo/page/bicycle-counts). The data includes various spatial and temporal information about bike counts with a temporal resolution of hourly. Bikes per hour (BPH) is chosen as an indicator to [explore](https://github.com/dongmeic/BikeCounting/blob/main/BikeCounts/Explore_Bike_Counts.ipynb) the spatial and temporal patterns.

In the "[BikeCounts](https://github.com/dongmeic/BikeCounting/tree/main/BikeCounts)" folder, the script "[Explore_Bike_Counts.ipynb](https://github.com/dongmeic/BikeCounting/blob/main/BikeCounts/Explore_Bike_Counts.ipynb)" aggregates the average bikes per hour by year and location and merges the data with the sampling locations. The script also calculates the growth of bikers per hour over year and aggregates MPO-wide average bike counts. The script is reorganized to [Hourly_Bike_Counts.R](https://github.com/dongmeic/BikeCounting/blob/main/BikeCounts/Hourly_Bike_Counts.R) in the review process. The script "[Bike_Counts_Merged_by_Locations.ipynb](https://github.com/dongmeic/BikeCounting/blob/main/BikeCounts/Bike_Counts_Merged_by_Locations.ipynb)" merges bike counts and sampling locations without aggregation. Both scripts generate data for the Tableau viz "Bike Counts".

## Bike shares

Bike share data is provided by [Cascadia Mobility](https://forthmobility.org/CascadiaMobility) through the [PeaceHealth Rides](https://peacehealthrides.com/) program and is accessible [here](https://peacehealthrides.com/opendata). The bike share is organized and presented in the [MPO data portal](https://www.lcog.org/thempo/page/peacehealth-rides-bike-share-program). More explanations on the bike share data can be found [here](https://github.com/NABSA/gbfs). Account credentials are required to access the [PeachHealth Rides data portal](https://data.socialbicycles.com/) for the bike trips data. The data portal also covers members, hubs and bikes data. Bike shares are explored and visualized in the [(near) real-time bike availability](https://public.tableau.com/views/RealTimeBikeShareAvailability/BikeShareAvailability?:language=en-US&:display_count=n&:origin=viz_share_link), [monthly paths and counts](https://public.tableau.com/views/MonthlyBikeShareTrips/MapofPaths?:language=en-US&:display_count=n&:origin=viz_share_link), and [yearly patterns](https://public.tableau.com/shared/5P9Z6MMBR?:display_count=n&:origin=viz_share_link). For the real-time data visualization, a [web data connector](https://github.com/KeshiaRose/JSON-XML-WDC) is applied. The Tableau workbooks are saved at T:\MPO\Bike&Ped\BikeCounting\StoryMap\BikeShare. 

In the "[BikeShare](https://github.com/dongmeic/BikeCounting/tree/main/BikeShare)" folder, the script [GetBikeShareData.ipynb](https://github.com/dongmeic/BikeCounting/blob/main/BikeShare/GetBikeShareData.ipynb) downloads bike availability data from the [PeachHealth Rides data portal](https://data.socialbicycles.com/). The script "[Explore_Bike_Shares.ipynb](https://github.com/dongmeic/BikeCounting/blob/main/BikeShare/Explore_Bike_Shares.ipynb)" reshapes origin and destination data. The script "[Bike_Share_Trip_Locations.ipynb](https://github.com/dongmeic/BikeCounting/blob/main/BikeShare/Bike_Share_Trip_Locations.ipynb)" collects the address information for the bike share path map. The scripts "[Trips.R](https://github.com/dongmeic/BikeCounting/blob/main/BikeShare/Trips.R)" and "[Yearly_Bike_Share_Trip_Locations.ipynb](https://github.com/dongmeic/BikeCounting/blob/main/BikeShare/Yearly_Bike_Share_Trip_Locations.ipynb)" organizes bike share data by year.

## Bike on buses

Bike on buses data is provided by LTD monthly since 2013. The April and October data can be explored by routes in the [MPO data portal](https://www.lcog.org/thempo/page/bikes-buses). The monthly data is [aggregated](https://github.com/dongmeic/BikeCounting/blob/main/BikeCounts/Explore_Bikes_On_Buses.ipynb) to show the stations with the most frequent bikes on buses. The script "[Explore_Bikes_On_Buses.ipynb](https://github.com/dongmeic/BikeCounting/blob/main/BikeCounts/Explore_Bikes_On_Buses.ipynb)" combines all-year data and aggregates bikes on buses by stop name and year.

## Bike facilities and infrastructure (bike map)

The [interactive bike map](https://arcg.is/09XWmC) is built using [ArcGIS Web AppBuilder](https://developers.arcgis.com/web-appbuilder/). The 'about' widget describes the map layers and basic map design. The 'layer list' is used to toggle on and off layers.

The bike facilities data is available on [RLID](https://www.rlid.org/). Only "built" facilities are included in the maps and data analysis. The map also includes bike shops, bike share stations, bike racks, bike friendly business, bike lockers, and bike fixit stations. Bike shops in Eugene are listed [here](https://www.eugene-or.gov/3260/Bike-Repair-Rentals). Bike shops and bike racks are provided by City of Eugene. Bike share locations are from the [map on PeaceHealth Rides](https://www.peacehealthrides.com/). The bike share stations are [organized](https://github.com/dongmeic/BikeCounting/blob/main/BikeMap/BikeShareStations.ipynb) from the [open data portal](https://peacehealthrides.com/opendata/station_information.json). Bike lockers, and bike fixit stations are from previous work by Chrissy. The bike facilities data was further modified by reviewing the NULL status and changing some status to built, adding to the existing built ones. The LTD stops are from the Winter 2019 version.

The bike-friendly business data is from Travel Oregon provided with business name, address, and coordinates. The coordinates are mostly from the InfoUSA (now Data Axle USA) business data by matching the business names, since a few provided coordinates are not accurate. If there is not a match, the coordinates are from Google Maps by manually typing in the address or using `geopy`. The discrepancy between the two approaches is not neglectable in some addresses because geopy can't get the exact addresses. As such, coordinates values from the manual searching are retained. There are six points located outside of the MPO boundary. The coordinates were reviewed between data sources to correct errors, although the data was not checked one by one.

<!---[Eugene bike map](https://www.eugene-or.gov/DocumentCenter/View/4268/Eugene-Bike-Map---English?bidId=);
[Springfield bike map](https://www.eugene-or.gov/DocumentCenter/View/4270/Springfield-Bike-Map---English?bidId=);
[previous bike map](https://lcog.maps.arcgis.com/apps/webappviewer/index.html?id=c598924750d94d06a372bb467ec9a01e)--->

# Analysis
## Spatial overlay between bike counts and bike facility type
To understand the bike count distribution among the bike facility types, a spatial join links the two dataset with the nearest function. Setting 10 meters as the reference for road width based the maximum lane width 15 feet and the typical two-lane roadway, the bikes per hour data is aggregated by bike lane type to compare.

## Data aggregation on bike counts, bike share counts and bikes on buses counts
Bike counts, bike share counts, and bikes on buses counts are aggregated from multi-year data using summary statistics, saved as spatial data, and uploaded to the [online bike map](https://arcg.is/K59Oi0) for reference. Bike counting data includes average bikes per hour during 2012 and 2020, total origin and destination bike share station trips during 2019 - 2021, and average annual total counts on bikes on buses during 2013 - 2021.

## Exploratory data analysis
To understand the bike counting spatial patterns, [hot spot analysis](https://github.com/dongmeic/BikeCounting/blob/main/Analysis/EDA_Plots.R) is conducted in R and ArcGIS Pro.

#  Storymap update
## Save copies before update the story map with new contents

Export [the storymap content](https://github.com/dongmeic/BikeCounting/blob/main/StoryMap/get_storymap_text.py) and [save it to word](https://github.com/dongmeic/BikeCounting/blob/main/StoryMap/export_text_to_word.py) for historical copies. 

## Steps to update the storymaps
### all-year story maps (titled "**Biking in Central Lane**")
1. Introduction

The introduction explains the purpose of the story map, its sections, and how the storymap is updated yearly. 

2. Bike commuters

1) download bike commmuter data B08006 and B08301;)

Go to the [data sources](https://github.com/dongmeic/BikeCounting/tree/main#bike-commuters) section, download data with the links provided and save data in the designated folder. 

2) run the scripts to get the annual bike commuter percentage in urbanized area nationwide (boxplot), bike commuter structure by city (ggplot), and bike commuter by city with margin of error;

The script [explore_ACS.R](https://github.com/dongmeic/BikeCounting/blob/main/ACS/explore_ACS.R) exported Figures 1 and 2. The script [explore_ACS_byCity.R](https://github.com/dongmeic/BikeCounting/blob/main/ACS/explore_ACS_byCity.R) exported Figures 3 to 5, including the plotly links for Figures 3 and 4. 

Figure 1: boxplot_bike_commuters.png
Figure 2: bike_commuters_sex.png
Figure 3: bike_commuters_by_city_with_MoE.png
Figure 4: percent_bike_work_commuters.png
Figure 5: bike_commuter_structure.png 

3) write or review the paragrahs with the analysis results.

3. Bike counts

1) download bike share data;

Login bike share trips from the [social bicycles](https://data.socialbicycles.com/dashboard/#/154/trips/reports) site sometimes takes a while, especially in the "generating" step. Optionally, holds data is also downloaded for other bike share data analysis needs, and saved at T:\MPO\Bike&Ped\BikeCounting\StoryMap\BikeShare\Data\Holds.

2) run the scripts to get average bikes per hour (BPH), growth in BPH, heatmaps of BPH, bikes on buses, and bike shares;

2-1) BPH and its growth
Dashboard: [**Yearly Bikes Per Hour and the Growth**](https://lcog.maps.arcgis.com/home/item.html?id=264a0023f5514080a15dfdbf7c629291)
Webmap: [Bike Counts Per Hour By Year](https://lcog.maps.arcgis.com/home/item.html?id=56cdac2023ba4635ad106cf52d7a68e4)
Data:  [BPH by Year](https://lcog.maps.arcgis.com/home/item.html?id=6be94ae89dcd4cfa9ccd9748f3d49a89)(T:\MPO\Bike&Ped\BikeCounting\StoryMap\BikeCounts\Output\BPH_by_Year.zip);
[BPH](https://lcog.maps.arcgis.com/home/item.html?id=ddcf729f6ca146b5a158b5b63560d526)(T:\MPO\Bike&Ped\BikeCounting\StoryMap\BikeCounts\Output\Bike_counts_per_hour.zip, rename the shapefile "BPH")
Script: [Explore_Bike_Counts.R](https://github.com/dongmeic/BikeCounting/blob/main/BikeCounts/Explore_Bike_Counts.R)

Steps to update the dashboard:
2-1-1) Run the script to get data bikes per hour by year;
2-1-2) Update data by overwriting entire feature layer;
2-1-3) Edit the dashboard title on the year inf and save;
2-1-4) Revise the storymap content with updated data 

2-2) BPH by hour, day of the week, month, 
Dashboard: [**Spatial Patterns of Average Bikes Per Hour**](https://lcog.maps.arcgis.com/home/item.html?id=b3c3f09b17ac4d6ebb81c1d387970f61)
Webmaps: [Spatial Patterns of Average Bikes Per Hour by Hour](https://lcog.maps.arcgis.com/home/item.html?id=651a5ee1e56a4ed88f50f3681e592869); [Spatial Patterns of Average Bikes Per Hour by Weekday](https://lcog.maps.arcgis.com/home/item.html?id=dd8533342e6344579e89b011ddc318b2); [Spatial Patterns of Average Bikes Per Hour by Month](https://lcog.maps.arcgis.com/home/item.html?id=8b48e22af3ef41549d6f72c7a3ca9ee5); [Spatial Patterns of Average Bikes Per Hour by Season](https://lcog.maps.arcgis.com/home/item.html?id=77dc95044fee4cb0b52ca2307f91f184)
Data:
Scripts: [Agg_BPH_by_Hour_Month_Weekday_Season.R](https://github.com/dongmeic/BikeCounting/blob/main/BikeCounts/Agg_BPH_by_Hour_Month_Weekday_Season.R), [update_bph_webmap.ipynb](https://github.com/dongmeic/BikeCounting/blob/main/BikeCounts/create_bph_webmap.ipynb)

Steps to update the dashboards:
2-2-1) Run the R script to get aggregated BPH, then upload the data by running the python script on the Pro environment;
2-2-2) Update data by overwriting entire feature layer;
2-2-3) Edit the dashboard title on the year inf and save;
2-2-4) Revise the storymap content with updated data 

3) work on the viz updates (redesign the vizzes as needed);


4) write or review the paragrahs with the analysis results (redesign the storymap as needed).

4. Bikeways

1) definitions of bikeway types;
2) BPH by bikeway types;
3) [bike-involved crash](https://www.lcog.org/thempo/page/bicycle-involved-crashes);
4) webmap of bicycle network.

5. Conclusions

The summary answers the questions of how many bike commuters in Eug-Spr, how often people bike, and where and when people bike the most.

### one-year story map
1. Introduction

The introduction explains the purpose of the story map, its sections, and how the storymap is updated yearly. 

2. Bike counts

1) organize bike counts in the most recent year;
2) update the feature layers on ArcGIS Online to update the Dashboards and webmaps; 
3) write or review the paragrahs with the analysis results (redesign the storymap as needed).

3. Bike share trips

1) organize bike share trips in the most recent year;
2) update the feature layers on ArcGIS Online to update the Dashboards and webmaps; 
3) write or review the paragrahs with the analysis results (redesign the storymap as needed).

4. Bikes on buses

1) organize bikes on buses in the most recent year;
2) update the feature layers on ArcGIS Online to update the Dashboards and webmaps; 
3) write or review the paragrahs with the analysis results (redesign the storymap as needed).

5. Conclusions

This part summarizes the hotspots of hourly bike counts, bike share, and bikes on buses by year and time of the day in the most recent year. 

## Data sources

### Bike commuters

1. [Table B08301: Means of Transportation to Work](https://data.census.gov/table?q=Table+B08301&g=010XX00US$3100000&tid=ACSDT5Y2021.B08301) (T:\MPO\Bike&Ped\BikeCounting\StoryMap\ACS\B08301,  [by city](https://data.census.gov/table?q=Table+B08301&g=321XX00US412166023850,412166069600))

Table B08301 data is organized by nationwide metro area and by city. 

2. [Table B08006: Sex of Workers by Means of Transportation to Work](https://data.census.gov/cedsci/table?q=Table%20B08006&g=310XX00US21660&tid=ACSDT5Y2021.B08006) (T:\MPO\Bike&Ped\BikeCounting\StoryMap\ACS\B08006,  [by city](https://data.census.gov/table?q=Table+B08301&g=321XX00US412166023850,412166069600))

Table B08006 data is organized by Eugene-Springfield metro area and by city. 

3. [Table B01003 Total Population](https://data.census.gov/table?q=Table+B01003&g=321XX00US412166023850,412166069600) (T:\MPO\Bike&Ped\BikeCounting\StoryMap\ACS\B01003)

Table B01003 data is organized by city. 

### Hourly bike counts
Data is saved at T:\Data\COUNTS\Nonmotorized Counts\Summary Tables\Bicycle\Bicycle_HourlyForTableau.csv.

### Bikes on buses
Data is saved at T:\Data\LTD Data\MonthlyBoardings.

### Bike shares
Bike share [trips](https://data.socialbicycles.com/dashboard/#/154/trips/reports) data is downloaded manually by month, and saved at T:\MPO\Bike&Ped\BikeCounting\StoryMap\BikeShare\Data\Trips. 