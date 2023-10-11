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
### all-year story maps (titled "[**Biking in Central Lane**](https://storymaps.arcgis.com/stories/4c8e01a034f5438eb17be5436baeb16d)")
1. Introduction

The introduction explains the purpose of the story map, its sections, and how the storymap is updated yearly. 

2. Bike commuters

1) download bike commmuter data B08006 and B08301;

Go to the [data sources](https://github.com/dongmeic/BikeCounting/tree/main#bike-commuters) section, download data with the links provided and save data in the designated folder. 

2) run the scripts to get the annual bike commuter percentage in urbanized area nationwide (boxplot), bike commuter structure by city (ggplot), and bike commuter by city with margin of error;

The script [explore_ACS.R](https://github.com/dongmeic/BikeCounting/blob/main/ACS/explore_ACS.R) exported Figures 1 and 2. The script [explore_ACS_byCity.R](https://github.com/dongmeic/BikeCounting/blob/main/ACS/explore_ACS_byCity.R) exported Figures 3 to 5, including the plotly links for Figures 3 and 4. Check [RPubs](https://rpubs.com/) for the links.

Figure 1: boxplot_bike_commuters.png

Figure 2: bike_commuters_sex.png

Figure 3: bike_commuters_by_city_with_MoE.png

Figure 4: percent_bike_work_commuters.png

Figure 5: bike_commuter_structure.png 

3) write or review the paragrahs with the analysis results.

3. Bike counts

1) BPH and its growth
Dashboard: [**Yearly Bikes Per Hour and the Growth**](https://lcog.maps.arcgis.com/home/item.html?id=264a0023f5514080a15dfdbf7c629291);

Webmap: [Bike Counts Per Hour By Year](https://lcog.maps.arcgis.com/home/item.html?id=56cdac2023ba4635ad106cf52d7a68e4);

Data:  [BPH by Year](https://lcog.maps.arcgis.com/home/item.html?id=6be94ae89dcd4cfa9ccd9748f3d49a89)(T:\MPO\Bike&Ped\BikeCounting\StoryMap\BikeCounts\Output\BPH_by_Year.zip); [BPH](https://lcog.maps.arcgis.com/home/item.html?id=ddcf729f6ca146b5a158b5b63560d526)(T:\MPO\Bike&Ped\BikeCounting\StoryMap\BikeCounts\Output\Bike_counts_per_hour.zip, rename the shapefile "BPH")

Script: [Explore_Bike_Counts.R](https://github.com/dongmeic/BikeCounting/blob/main/BikeCounts/Explore_Bike_Counts.R)

Steps to update the dashboard:

1-1) Run the script to get data bikes per hour by year;

1-2) Update data by overwriting entire feature layer;

1-3) Edit the dashboard title on the year inf and save;

1-4) Revise the storymap content with updated data 

2) BPH by hour, day of the week, month, and season

Dashboard: [**Spatial Patterns of Average Bikes Per Hour**](https://lcog.maps.arcgis.com/home/item.html?id=b3c3f09b17ac4d6ebb81c1d387970f61)

Webmaps: [Spatial Patterns of Average Bikes Per Hour by Hour](https://lcog.maps.arcgis.com/home/item.html?id=651a5ee1e56a4ed88f50f3681e592869); [Spatial Patterns of Average Bikes Per Hour by Weekday](https://lcog.maps.arcgis.com/home/item.html?id=dd8533342e6344579e89b011ddc318b2); [Spatial Patterns of Average Bikes Per Hour by Month](https://lcog.maps.arcgis.com/home/item.html?id=8b48e22af3ef41549d6f72c7a3ca9ee5); [Spatial Patterns of Average Bikes Per Hour by Season](https://lcog.maps.arcgis.com/home/item.html?id=77dc95044fee4cb0b52ca2307f91f184)

Data: data is created in the R script and uploaded in the Python script (T:\MPO\Bike&Ped\BikeCounting\StoryMap\BikeCounts\Output)

Scripts: [Agg_BPH_by_Hour_Month_Weekday_Season.R](https://github.com/dongmeic/BikeCounting/blob/main/BikeCounts/Agg_BPH_by_Hour_Month_Weekday_Season.R), [update_bph_webmap.ipynb](https://github.com/dongmeic/BikeCounting/blob/main/BikeCounts/create_bph_webmap.ipynb)

Steps to update the dashboards:

2-1) Run the R script to get aggregated BPH, then upload the data by running the python script on the Pro environment;

2-2) Update data by overwriting entire feature layer;

2-3) Edit the dashboard title on the year info and save;

2-4) Revise the storymap content with the updated data 

3) work on the viz updates (redesign the vizzes as needed);

4) write or review the paragrahs with the analysis results (redesign the storymap as needed).

4. Bikes on buses

The monthly bikes on buses data prior to 2022 is save at T:\Data\LTD Data\BikeOnBuses\Monthly and from 2022 at T:\Data\LTD Data\MonthlyBoardings. Aggregated data *Yearly_Bikes_On_Buses* (shapefile) is calculated on [Bikes_On_Buses](https://github.com/dongmeic/BikeCounting/blob/main/BikesOnBuses/Bikes_On_Buses.R). The city information is added on ArcGIS Pro. The LTD routes are organized in [LTD_Routes_and_Stops.ipynb](https://github.com/dongmeic/BikeCounting/blob/main/BikesOnBuses/LTD_Routes_and_Stops.ipynb).

Dashboard: [**Yearly Patterns of Bikes on Buses and the Growth**](https://lcog.maps.arcgis.com/home/item.html?id=6662c4fdcf2a4310ad7c3ca371757353)

Webmap:[Yearly Bikes on Buses](https://lcog.maps.arcgis.com/home/item.html?id=61cd99f311c444689dfcae9e78f796d1)

Data: [Yearly Bikes on Buses](https://lcog.maps.arcgis.com/home/item.html?id=5e1a745d6de84049a69ac380be8cb4b0) (T:\MPO\Bike&Ped\BikeCounting\StoryMap\BikeOnBuses\Output\Yearly_Bikes_On_Buses.zip)

Scripts: [Bikes_On_Buses.R](https://github.com/dongmeic/BikeCounting/blob/main/BikesOnBuses/Bikes_On_Buses.R), [LTD_Routes_and_Stops.ipynb](https://github.com/dongmeic/BikeCounting/blob/main/BikesOnBuses/LTD_Routes_and_Stops.ipynb)

Steps to update the dashboard:

1) Review and make sure the raw data is complete in the new year;

2) Run the R script to update the yearly bikes on buses shapefile and update data on ArcGIS Online;

3) In case routes and stops are updated, update and run the python script to get data with new routes and run the last section (commented) of R script to get data with new stops;

4) Edit the dashboard title on the year info and save;

5) Revise the storymap content with the updated data.

5. Bike share trips

To download bike share data, login bike share trips from the [social bicycles](https://data.socialbicycles.com/dashboard/#/154/trips/reports) site (sometimes it takes a while, especially on the "generating" step). Optionally, holds data is also downloaded for other bike share data analysis needs, and saved at T:\MPO\Bike&Ped\BikeCounting\StoryMap\BikeShare\Data\Holds. Bike share [trips](https://data.socialbicycles.com/dashboard/#/154/trips/reports) data is downloaded manually by month, and saved at T:\MPO\Bike&Ped\BikeCounting\StoryMap\BikeShare\Data\Trips. 

The exploratory scripts [R_Explore_Bike_Shares](https://github.com/dongmeic/BikeCounting/blob/main/BikeShare/R_Explore_Bike_Shares.ipynb) checks the bike share trips raw data where *bike_share_locations* is generated for [Bike_Share_Trip_Locations](http://localhost:8888/notebooks/BikeCounting/BikeShare/Bike_Share_Trip_Locations.ipynb) that retrieves coordinates when they are not available (same as [ReverseGeocoding](https://github.com/dongmeic/BikeCounting/blob/main/BikeShare/ReverseGeocoding.ipynb) and [Monthly_ReverseGeocoding](https://github.com/dongmeic/BikeCounting/blob/main/BikeShare/Monthly_ReverseGeocoding.ipynb), this step generates data in the "Output/review" folder), [R_Daily_Bike_Share_Trips](https://github.com/dongmeic/BikeCounting/blob/main/BikeShare/R_Daily_Bike_Share_Trips.ipynb) aggregates daily bike share trip data, [R_Bike_Share_Trips_by_Time_of_Day](https://github.com/dongmeic/BikeCounting/blob/main/BikeShare/R_Bike_Share_Trips_by_Time_of_Day.ipynb) splits bike share trips by time of day, and [R_Nighttime_BikeShare_by_Season](https://github.com/dongmeic/BikeCounting/blob/main/BikeShare/R_Nighttime_BikeShare_by_Season.ipynb) explores night time bike share by season. [Trips](https://github.com/dongmeic/BikeCounting/blob/main/BikeShare/Trips.R) organizes raw data using the codes collected from the exploratory scripts and creates data for the all-year bike share dashboard. 

Dashboard: [**PeaceHealth Rides Yearly Bike Share Trips and Users**](https://lcog.maps.arcgis.com/home/item.html?id=ee605aa23f104ffeb66e6b01dd9ee5c7)

Webmap: [Yearly Bike Share Trips and Users](https://lcog.maps.arcgis.com/home/item.html?id=9d34bbc74e3f474c84d1b45ce60e32cd)

Data: [Yearly Bike Share Trips](https://lcog.maps.arcgis.com/home/item.html?id=29d46d35da4141b9a8fffe221d030ad8)(T:\MPO\Bike&Ped\BikeCounting\StoryMap\BikeShare\Output\Yearly_Bike_Share_Trips.zip); [Sum Bike Share Trips all years](https://lcog.maps.arcgis.com/home/item.html?id=d0c3b153b8bc4ce3a00907394e14b856)(T:\MPO\Bike&Ped\BikeCounting\StoryMap\BikeShare\Output\Sum_Bike_Share_Trips_all_years.zip)

Scripts: [daily_bike_share_trips.R](https://github.com/dongmeic/BikeCounting/blob/main/BikeShare/daily_bike_share_trips.R); [bike_share_functions.R](https://github.com/dongmeic/BikeCounting/blob/main/BikeShare/bike_share_functions.R)


6. Bikeways

1) definitions of bikeway types;

The map tour is created using the photos saved at T:\MPO\Bike&Ped\BikeCounting\StoryMap\photos. The locations are identified from fieldwork or photos saved at T:\MPO\Public Involvement\Photos2020. This part doesn't require regular updates.

2) BPH by bikeway types;

The figure "Bikes Per Hour by Bikeway Type" is created from the script "[Bike_Counts_by_Bikeway_Type.ipynb](https://github.com/dongmeic/BikeCounting/blob/main/Analysis/Bike_Counts_by_Bikeway_Type.ipynb)". 

3) webmap of bicycle network;

The WebApp Builder requires updates on bike counts, bikes on buses, and bike share trips. 

The web map is "[Bike Counting in Central Lane](https://lcog.maps.arcgis.com/home/item.html?id=3f2a7746563c40008fe556f6c1271b21)". Need to rename the layers when uploading new data.

The list of data sets is shown below:

(1) bike counts (BPH.shp created from [Explore_Bike_Counts.R](https://github.com/dongmeic/BikeCounting/blob/48aaff891d51e3bdcc646ed57e0d7da988962075/BikeCounts/Explore_Bike_Counts.R#L177))

[Average Bikes Per Hour During 2012 - 2022](https://lcog.maps.arcgis.com/home/item.html?id=ddcf729f6ca146b5a158b5b63560d526)

(2) bikes on buses (created from [Bikes_On_Buses.ipynb](https://github.com/dongmeic/BikeCounting/blob/main/Analysis/Bikes_On_Buses.ipynb))

[Average Annual Total Counts on Inbound Bikes on Buses During 2013 - 2022](https://lcog.maps.arcgis.com/home/item.html?id=2a9e85a566e54cf1b1596e996259e7b6)(T:\MPO\Bike&Ped\BikeCounting\StoryMap\BikeOnBuses\Output\Bikes_on_Buses_inbound.zip)

[Average Annual Total Counts on Outbound Bikes on Buses During 2013 - 2022](https://lcog.maps.arcgis.com/home/item.html?id=ff9e9fadd94f47558a663167535731c9)(T:\MPO\Bike&Ped\BikeCounting\StoryMap\BikeOnBuses\Output\Bikes_on_Buses_inbound.zip)

[Average Annual Total Counts on Bikes on Buses During 2013 - 2022](https://lcog.maps.arcgis.com/home/item.html?id=030d3528f8fc41109144cee728712b47)(T:\MPO\Bike&Ped\BikeCounting\StoryMap\BikeOnBuses\Output\Bikes_on_Buses.zip)

[Average Annual Total Counts on Inbound Bikes on Buses During 2013 - 2022 (excluded Eugene and Springfield stations)](https://lcog.maps.arcgis.com/home/item.html?id=d249a3303365432ebb0a77bf9bae2a48)(T:\MPO\Bike&Ped\BikeCounting\StoryMap\BikeOnBuses\Output\Bikes_on_Buses_inbound_excluded.zip)

[Average Annual Total Counts on Outbound Bikes on Buses During 2013 - 2022 (excluded Eugene and Springfield stations)](https://lcog.maps.arcgis.com/home/item.html?id=0525e396090a4ba6b5312790c5226ab8)(T:\MPO\Bike&Ped\BikeCounting\StoryMap\BikeOnBuses\Output\Bikes_on_Buses_inbound_excluded.zip)

[Average Annual Total Counts on Bikes on Buses During 2013 - 2022 (excluded Eugene and Springfield stations)](https://lcog.maps.arcgis.com/home/item.html?id=f4f01f031d1c42b48e3fdb5635d2fb86)(T:\MPO\Bike&Ped\BikeCounting\StoryMap\BikeOnBuses\Output\Bikes_on_Buses_excluded.zip)

(3) bike share trips (created from [Bike_Share_Trips.ipynb](https://github.com/dongmeic/BikeCounting/blob/main/Analysis/Bike_Share_Trips.ipynb))

[Total Destination Station Bike Share Trips During 2019 - 2022](https://lcog.maps.arcgis.com/home/item.html?id=c267c6e9d624426f86ffbbeab013e4e8)(T:\MPO\Bike&Ped\BikeCounting\StoryMap\BikeShare\Data\DestinationCounts.zip)

[Total Origin Station Bike Share Trips During 2019 - 2022](https://lcog.maps.arcgis.com/home/item.html?id=bc39817382ef4b67ae61109f4cf26a51)(T:\MPO\Bike&Ped\BikeCounting\StoryMap\BikeShare\Data\OriginCounts.zip)


4) [bike-involved crash](https://www.lcog.org/thempo/page/bicycle-involved-crashes);

The [crash data](https://lcog.maps.arcgis.com/home/item.html?id=49ed11f9b3214b17995c25e84158ba45) is created using ArcGIS Pro and [python](https://github.com/dongmeic/BikeCounting/blob/main/Analysis/Crash_Bicyclists.ipynb). 

Dashboard: [Bicyclist-Involved Crashes in Central Lane](https://lcog.maps.arcgis.com/apps/dashboards/db3ff913377744a3a99f36ff0b02dbb6)

Webmap: [Crash Heat Map](https://lcog.maps.arcgis.com/home/webmap/viewer.html?webmap=d5577b5b6d39494db3c118f372cca9ee)

7. Conclusions

The summary answers the questions of how many bike commuters in Eug-Spr, how often people bike, and where and when people bike the most. It also make suggestions on biking support systems based on data analysis. 

### one-year story map (titled "[**Central Lane Bike Counting in 2022**](https://storymaps.arcgis.com/stories/241cfe53fdc54602b313eeb299729031)")
1. Introduction

The introduction explains the purpose of the story map, its sections, and how the storymap is updated yearly. 

2. Bike counts

1) organize bike counts in the most recent year;

2) update the feature layers on ArcGIS Online to update the Dashboards and webmaps; 

3) write or review the paragrahs with the analysis results (redesign the storymap as needed).

Dashboard: [Daily Bike Counts in 2022](https://lcog.maps.arcgis.com/home/item.html?id=9fa954208df446928f774a0824a7638e)

Instant App: [Average Daily Counts by Season](https://lcog.maps.arcgis.com/home/item.html?id=51161cd8d1e2414fb7ed1cc76ca4010f)

Webmap: [Daily Bike Counts](https://lcog.maps.arcgis.com/home/item.html?id=7595cb635b934021a2546ed164fe57dd), [Average Daily Counts by Season](https://lcog.maps.arcgis.com/home/item.html?id=a4269fcccc5640bbb8b4ae76968030de)

Data: [Daily Bike Counts](https://lcog.maps.arcgis.com/home/item.html?id=d449b3c11fe54cbf9ca867bcf42ac9be)(Daily_Bike_Counts.zip), [Mean Daily Bike Counts](https://lcog.maps.arcgis.com/home/item.html?id=3da6a6d5ab194720b1c53a89d04c44f5)(Mean_Daily_Bike_Counts.zip), [Average Daily Counts by Season](https://lcog.maps.arcgis.com/home/item.html?id=9b3378459b6b4e778719a16c27900188)(DailyCounts_Season.zip)

Scripts: [daily_bike_counts.R](https://github.com/dongmeic/BikeCounting/tree/main/BikeCounts/daily_bike_counts.R), [Agg_DailyCounts_By_Weekday_Month_Season.R](https://github.com/dongmeic/BikeCounting/tree/main/BikeCounts/Agg_DailyCounts_By_Weekday_Month_Season.R)

3. Bike share trips

1) organize bike share trips in the most recent year;

2) update the feature layers on ArcGIS Online to update the Dashboards and webmaps; 

3) write or review the paragrahs with the analysis results (redesign the storymap as needed).

Dashboard: [Daily Bike Share Trips in 2022](https://lcog.maps.arcgis.com/home/item.html?id=313ae9cad34041bfb5442ce697126c0f)

Webmap: [Bike Share Trips](https://lcog.maps.arcgis.com/home/item.html?id=cda04d94998c471db6ca651a28c17763), [Bike Share Destinations-Morning](https://lcog.maps.arcgis.com/home/item.html?id=99630d36981a4e21a3457d1d2fc7496b), [Bike Share Destinations-Afternoon](https://lcog.maps.arcgis.com/home/item.html?id=4557cd4017c64da69498ff1df04b3a2c), [Bike Share Destinations-Evening](https://lcog.maps.arcgis.com/home/item.html?id=826231525662481b9c9d1bf1e22cd095), [Bike Share Destinations-Night](https://lcog.maps.arcgis.com/home/item.html?id=fcd2822734dc4477b9b81da2c3c05a0f)

Data: [Daily_Bike_Share_Trips.shp] (https://lcog.maps.arcgis.com/home/item.html?id=a5920c05b71443979c9e9fec75bbfc96), [Summarized_Bike_Share_Trips.shp](https://lcog.maps.arcgis.com/home/item.html?id=e7c55142446b4e579d8a24f58512c23a), [Bike Share Destinations by Day Parts](https://lcog.maps.arcgis.com/home/item.html?id=2d628489004d41e39b385e820b92c010)

Scripts: [daily_bike_share_trips.R](https://github.com/dongmeic/BikeCounting/blob/main/BikeShare/daily_bike_share_trips.R), [bike_share_trips_by_time_of_day.R](https://github.com/dongmeic/BikeCounting/blob/main/BikeShare/bike_share_trips_by_time_of_day.R)

Steps to update the dashboard:

1) Confirm the completeness of the data and run the R script to get the listed data;

2) Compress the listed data and upload the zip files online;

3) Edit the dashboard title on the year info and save;

4) Revise the storymap content with the updated data.

4. Bikes on buses

1) organize bikes on buses in the most recent year;

2) update the feature layers on ArcGIS Online to update the Dashboards and webmaps; 

3) write or review the paragrahs with the analysis results (redesign the storymap as needed).

Dashboard: [Daily Bikes on Buses in 2022](https://lcog.maps.arcgis.com/home/item.html?id=9ff1afbd5e4545018816b03d59ffa7c2)

Webmap: [Daily Bikes on Buses](https://lcog.maps.arcgis.com/home/item.html?id=b92fab5ea2d840a9a0ad9952695fef95), [Inbound Bikes on Buses by Daypart-Morning](https://lcog.maps.arcgis.com/home/item.html?id=d6bfb0e56533452a882512cf472b0b1d), [Inbound Bikes on Buses by Daypart-Afternoon](https://lcog.maps.arcgis.com/home/item.html?id=d7433f66b0144f65b576c323d0cad457), [Inbound Bikes on Buses by Daypart-Evening](https://lcog.maps.arcgis.com/home/item.html?id=dc59509733aa49669bcaa72d836e1107), [Inbound Bikes on Buses by Daypart-Night](https://lcog.maps.arcgis.com/home/item.html?id=b3e24b419a6e40d78edbfac9fcde1652)

Data: [Daily Bikes On Buses](https://lcog.maps.arcgis.com/home/item.html?id=64261e668c40459695d6a63db25ca8af)(Daily_Bikes_On_Buses.zip), [Sum Bikes On Buses](https://lcog.maps.arcgis.com/home/item.html?id=e7a713c1299c485caf62949b19d8db13)(Sum_Bikes_On_Buses.zip), [Inbound Bikes on Buses by Daypart](https://lcog.maps.arcgis.com/home/item.html?id=040aa80e6dd4497f8cb3f297b87e8e97)(Inbound_BOB_DayPart.zip)

Scripts: [daily_bikes_on_buses.R](https://github.com/dongmeic/BikeCounting/blob/main/BikesOnBuses/daily_bikes_on_buses.R), [bikes_on_buses_by_time_of_day.R](https://github.com/dongmeic/BikeCounting/blob/main/BikesOnBuses/bikes_on_buses_by_time_of_day.R)

Steps to update the dashboard:

1) Confirm the completeness of the data and run the R script to get the listed data;

2) Compress the listed data and upload the zip files online;

3) Edit the dashboard title on the year info and save;

4) Revise the storymap content with the updated data.

5. Conclusions

This part summarizes the hotspots of hourly bike counts, bike share, and bikes on buses by year and time of the day in the most recent year. The image generated from the R script requires further editings on Illustrator. 

Script: [maps_plots_single_year.R](https://github.com/dongmeic/BikeCounting/blob/main/Analysis/maps_plots_single_year.R)

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
Data is saved at T:\MPO\Bike&Ped\BikeCounting\StoryMap\BikeShare\Data\Trips. 
