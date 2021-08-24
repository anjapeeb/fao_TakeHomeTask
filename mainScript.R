library(data.table)
library(janitor)
library(shiny)
library(tidyr)
library(ggplot2)
library(gganimate)
library(ggthemes)

# ----SET WORKING DIRECTORY AND LOAD DATA ----

  setwd('/Users/annapeebles-brown/Documents/FAO')
  
  agriValueData <- clean_names(read.csv('./data/FAOSTAT_data_8-24-2021.csv'))
  popData <- clean_names(read.csv('./data/a040d781-1c47-4a3a-acb3-1366e0e24308_Data.csv'))
  countryMapData <- clean_names(read.csv('./data/FAOSTAT_data_8-24-2021 (1).csv'))
  countryGroupMapData <- clean_names(read.csv('./data/CountryGroups_codes.csv'))

# ----  MAP COUNTRY AND COUNTRY GROUPS MAPPING DATA TOGETHER  ----
  setDT(countryMapData)
  setDT(countryGroupMapData)
    # map on m49 code and area_code
  area_base_names <- c("area_code", "area")
  country_base_names <- c("country_code", "country")
  
  setnames(countryGroupMapData, "area_code_faostat", "area_code")
  setnames(countryMapData, country_base_names, area_base_names)
  
  completeMapData <- countryMapData[countryGroupMapData, on=c("area_code", "m49_code"), wb_group2021:=i.wb_group2021]

# ---- MAP COUNTRYMAPDATA TO AGRIVALUE DATA ON AREA/COUNTRY CODE -- USING FAO NAMES AS BASE STANDARD  ----
    
    # work in data.table but the following can also be done with dply, this is simply a personal preference
  setDT(agriValueData)
  setnames(agriValueData, "area_code_fao", "area_code")
  
    # Map countryMapData on to agriValueData to extract ISO3 codes to map with WB data 
  #countryMappedAgriData <- completeMapData[agriValueData, on=area_base_names, `:=` (year_code = i.year_code, unit = i.unit, value=i.value )]
  
  countryMappedAgriData <- merge(completeMapData, agriValueData, by = c("area_code", "area"), allow.cartesian=TRUE)
  
    # Remove observations if argriculture value is missing 
  agriMappedData <- countryMappedAgriData[!is.na(value),]

# ---- MAP popData ONTO countryMappedAgriData TO GET POPULATION TOTALS ----
  
    # Convert pop data from wide to long and rename year
  popLong <- gather(popData, year_codeA, population, x2014_yr2014:x2020_yr2020)
  setDT(popLong)
  popLong[,year_code := fcase(year_codeA=="x2014_yr2014",2014,
                              year_codeA=="x2015_yr2015",2015,
                               year_codeA=="x2016_yr2016",2016,
                               year_codeA=="x2017_yr2017",2017,
                               year_codeA=="x2018_yr2018",2018,
                               year_codeA=="x2019_yr2019",2019,
                              year_codeA=="x2020_yr2020",2020)]
  
  
  popLong$year_code <- as.integer(popLong$year_code)
  
    # Map population onto mapped agrivalue data
  setnames(popLong, "country_code", "iso3_code")
  fullDataset <- agriMappedData[popLong, on=c("iso3_code", "year_code"), population := i.population]
  
  

# ---- CALCULATE PER CAPITA AGRICULTURE VALUE OF PRODUCTION FOR ALL COUNTRIES FOR THE 5 MOST RECENT YEARS ----
  fullDataset$population <- as.numeric(fullDataset$population)
  fullDataset[, agriculture_production_value_per_capita := round((value*1000)/population,2), by=c("area_code", "year_code")]
  
    # List of countries with missing population values
  missing_population_list <- list(unique(fullDataset[is.na(population),area]))
  
  fullDataset <- fullDataset[!is.na(population),]

# ---- CALCULATE PER CAPITA AGRICULTURE VALUE OF PRODUCTION FOR ALL COUNTRIES FOR THE 5 MOST RECENT YEARS BY COUNTRY GROUP (USING FAO COUNTRY GROUPS) ----
  
    # Since there is a very large number of FAO country groups which would be difficult to look at in a static graph, I have used WB groups
    # Create country group aggregates
  cols <- c("wb_group2021","year_code", "population", "value")
  cols2 <- c("country_group","year_code", "population", "value")
  
  aggregateData <- unique(fullDataset[,cols,with=F],by=cols)
  aggregateData[, agriculture_production_value_aggregate_group := round(sum(value)*1000,0), by=c("wb_group2021", "year_code")]
  aggregateData[, population_aggregate_group := round(sum(population),2), by=c("wb_group2021", "year_code")]
  aggregateData[,agriculture_production_value_per_capita_countrygroup := round(agriculture_production_value_aggregate_group/population_aggregate_group,0)]
  aggregateData$agriculture_production_value_per_capita_countrygroup <- as.integer(aggregateData$agriculture_production_value_per_capita_countrygroup)
  
  
    # WB groups don't include a global group so to ensure that there is no double counting, I'm using the FAO "World" grouping
  global <- unique(fullDataset[country_group=="World",cols2, with=F], by=cols2)
  global[, agriculture_production_value_aggregate_group := round(sum(value)*1000,0), by=c("country_group", "year_code")]
  global[, population_aggregate_group := round(sum(population),2), by=c("country_group", "year_code")]
  global[,agriculture_production_value_per_capita_countrygroup := round(agriculture_production_value_aggregate_group/population_aggregate_group,0)]
  global$agriculture_production_value_per_capita_countrygroup <- as.integer(global$agriculture_production_value_per_capita_countrygroup)
  
  setnames(global, "country_group", "wb_group2021")
  
  cols <- c("wb_group2021", "year_code", "agriculture_production_value_per_capita_countrygroup")
  global <- unique(global[,cols,with=F], by=cols)
  aggregateData <- unique(aggregateData[,cols,with=F], by=cols)
  
  # Combine the two into one table to create the plotting data 
  list <- list(global, aggregateData)
  plot_data <- rbindlist(list, use.names = TRUE)
  plot_data[,wb_group2021:= fifelse(is.na(wb_group2021), "China", wb_group2021)]

# ---- PLOT OUPUT ----

  plot <-ggplot(plot_data) +
    geom_line(aes(x=year_code, 
                   y=agriculture_production_value_per_capita_countrygroup, group = factor(wb_group2021), colour =factor(wb_group2021) ), size=1.5, linetype = "dashed") +
    geom_point(aes(x=year_code, 
                   y=agriculture_production_value_per_capita_countrygroup, group = factor(wb_group2021), colour =factor(wb_group2021) ), size=3) + theme_ipsum() +
    scale_color_ipsum() + scale_fill_ipsum() +
    ylab("Agriculture Production Value per Capita") + xlab("Year") + labs(color='Region') +
    labs(
    title="Per capita Agriculture Production Value",
    subtitle="by World Bank Country Regions and Year",
    caption="Source: World Bank & FAO"
  ) 
  
  
# ---- WRITE OUT KEY DATA TABLES
  
  fwrite(plot_data, "./data/plot_data.csv")
  fwrite(fullDataset, "./data/fullDataset.csv")

