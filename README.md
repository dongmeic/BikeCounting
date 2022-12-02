# MTIP mapping
To organize data for MTIP mapping

# Reference
[ODOT TransGIS](https://gis.odot.state.or.us/transgis/)

[Transportation Project Tracker](https://gis.odot.state.or.us/tpt/)

# Contacts
[Dan Callister](dcallister@lcog.org), [Ellen Currier](ecurrier@lcog.org)

# Steps for FY 24-27
## Review projects with location info

The ODOT project tracker mapped MTIP projects in Lane [here](https://gis.odot.state.or.us/tpt/projects?county=Lane&mapped=TRUE).The map is available [here](https://gis.odot.state.or.us/arcgis1006/rest/services/tpt/tpt_display/MapServer/). However, the json file missed spatial data and can't be converted to GIS data. As such, the shapefiles were transferred from ODOT.

The draft data table is reorganized to a machine-readable format following the steps: 1) add a column "Geo" to reorganize the location information on the rows; 2) remove the extra rows with field names when combining the separated tables; 3) remove the "Merge & Center" and "Wrap Text" formats; 4) remove the "Total" rows; 5) separate funding and source on the fields; 6) clean all the font and cell formats. When the final data table is available, simply remove all the extra rows (geo info and field names) and columns (total and blank), add field names, and merge the first edited table to get the geo info.

To review or create spatial data, the first step is to match FME_PROJ_KEY_NO with STIP Key to get the existing spatial data. The next step is to review the project details in *T:\MPO\TIP\Calls For Projects\Call for Projects 25-27\Apps Received\Word Versions* to get the location info and match the projects geographically in ArcGIS Pro. I reviewed separately the mapped and unmapped projects and added notes on feature type, location file path, and clarification needed. Then I followed up for further clarification on data and project info. 

# Steps for FY 21-24
## Review existing data

The MTIP 21-24 projects are mapped [here](https://arcg.is/15rCGy). The spatial information was collected from multiple resources, including MTIP projects from 2018 to 2021, ODOT web maps and project tracker.

The new 21 projects on June 2020 need to be added in August 2020.

## Collect spatial information

<!-- Spatial information can be found on [this document](https://www.lcog.org/AgendaCenter/ViewFile/Item/3168?fileID=11682). -->
Contact agencies for existing shapefiles in the CLMPO 2022-2024 STBG/TA/CMAQ Candidate Project Summary, particularly for the below three projects. Identify whether spatial projects are lines and add coordinates to all spatial projects. Review the mapped and revised projects in ArcGIS Pro.

1. [Division Ave Roundabouts](https://documentcloud.adobe.com/link/track?uri=urn:aaid:scds:US:a0a1af2a-bc26-4e80-be89-10fb28bc4ebf) - Dan updated the map

2. [Vision Zero Intersection Study](https://documentcloud.adobe.com/link/track?uri=urn:aaid:scds:US:229a19d4-9f0f-4598-b255-89cb119bb6fc) - Dan suggested not to map this project

3. [FTN Safety & Amenity Program](https://documentcloud.adobe.com/link/track?uri=urn:aaid:scds:US:0c6876a8-c7fa-4157-a626-e0b814b26b2d) - Dan suggested not to map this project

## Map the projects

The previous feature created as "MTIP_Lines" is saved in C:/Users/clid1852/Documents/ArcGIS/Projects/MTIP/MTIP.gdb. The last final version of the MTIP maps are saved as "Lines200428" (last revision time April 28th, 2020) and "Points200428" in G:/projects/Transportation/MTIP/MTIP_FY21-24.gdb.

Steps to map the projects:

1. [Create Feature Class](https://pro.arcgis.com/en/pro-app/help/data/feature-classes/create-a-feature-class.htm)

Need to set Feature Class Name and Geometry Type.

2. [Create Features](https://pro.arcgis.com/en/pro-app/help/editing/create-polyline-features.htm)

Search the street name on [Google Maps](https://www.google.com/maps) and draw the lines for each line project in the new feature class.

3. [Modify Features](https://pro.arcgis.com/en/pro-app/help/editing/introduction-to-modifying-features.htm)

Select the feature, go to Edit and Modify.

4. [Merge](https://pro.arcgis.com/en/pro-app/tool-reference/data-management/merge.htm)

Point projects are mapped with coordinates by adding [XY Point Data](https://pro.arcgis.com/en/pro-app/help/mapping/layer-properties/add-x-y-coordinate-data-as-a-layer.htm)(go to Map --> Add Data --> XY Point Data). [Add Attribute Index](https://pro.arcgis.com/en/pro-app/tool-reference/data-management/add-attribute-index.htm) to join tables of newly created line feature and the CSV table that lists the project items using MTIP ID (since STIP key is not complete). Merge the new line and point projects with previous projects. Change the variable names due to the length limit (10 characters).

5. [ArcGIS Online](https://arcg.is/OuiCW)

Compress the shapefile and upload to the map. [Configure](https://doc.arcgis.com/en/arcgis-online/create-maps/configure-pop-ups.htm) the pop-ups.



## Revision
Added new projects in August, 2020.

# Story map
## Organize tables

The databased is organized by removing the summary rows from the original tables and combing the projects from different time periods. Some projects have been updated with new data.

## Tableau

The tableau dashboard includes a bar chart and a map showing project introduciton and funding information. The chart and map use different data sources since the map only shows the summary information while the chart covers data from different phases. As such, they cannot be linked using actions in the dashboard. To overlap the line and point features, spatial join is applied between the two shapefiles and dual axis is set for the points.

## ArcGIS Online
