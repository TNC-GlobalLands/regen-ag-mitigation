# Read packages
library(raster)
library(rgdal)
library(sf)
library(ggplot2)
library(exactextractr)
library(viridis)
library(lwgeom)

#### SET WORKING DIRECTORY ####
require(funr)
setwd(funr::get_script_path())
# path <- "~/Box Sync/Work/The Nature Conservancy/Global Soils/Regenerative Foodscapes/Mitigation Mapping/code/"
# setwd(path)

# Read in raster SOC data
med <- raster("../data/increase_per_grid_cell-medium/tc_dif_me.tif")

# Read in shapefile data
countries <- st_read("../data/ne_110m_admin_0_countries/ne_110m_admin_0_countries.shp")

# Convert from tons x 100 per ha to tons per grid cell per year (med/100*6.25/20)
med <- med * 0.003125
medAdopt75 <- med * .75
medAdopt75CE <- medAdopt75 * .9

# Calculate medium SOC sequestration for each country
countries$medSOC <- exact_extract(med, countries, 'sum')
countries$medSOCAdopt75 <- exact_extract(medAdopt75, countries, 'sum')
countries$medSOCAdopt75CE <- exact_extract(medAdopt75CE, countries, 'sum')

# Convert to Tg: 1000000 tonnes per yr (Tg)
countries$medSOC <- countries$medSOC/1000000
countries$medSOCAdopt75 <- countries$medSOCAdopt75/1000000
countries$medSOCAdopt75CE <- countries$medSOCAdopt75CE/1000000

# Calculate area of polygons
countries$area <- as.numeric(st_area(countries)/100000000000)
countries$SOCperArea <- countries$medSOCAdopt75/countries$area

# Plot data
ggplot() + 
  geom_sf(data = countries, size=0, aes(fill = medSOCAdopt75)) + 
  scale_fill_viridis(name="Soil carbon\nTg C yr-1") + theme_bw() +
  theme(
    legend.position="bottom"
  )
ggplot() + 
  geom_sf(data = countries, size=0, aes(fill = medSOCAdopt75CE)) + 
  scale_fill_viridis(name="Soil carbon\nTg C yr-1\nat $100") + theme_bw() +
  theme(
    legend.position="bottom"
  )
ggplot() + 
  geom_sf(data = countries, size=0, aes(fill = SOCperArea)) + 
  ggtitle("Conservation Agriculture") +
  scale_fill_viridis(name="Tg C per yr\nper 100000 sq km") + theme_bw() +
  theme(
    legend.position="bottom"
  )


# Drop unneeded data
drops <- c("featurecla","scalerank","LABELRANK","ADM0_DIF","LEVEL","GEOU_DIF","SU_DIF","BRK_DIFF","BRK_GROUP",
           "FORMAL_FR","MAPCOLOR7","MAPCOLOR8","MAPCOLOR9","MAPCOLOR13","WIKIPEDIA","WOE_ID","WOE_ID_EH","WOE_NOTE",
           "ADM0_A3_UN","ADM0_A3_WB","NAME_LEN","LONG_LEN","ABBREV_LEN","TINY","HOMEPART","MIN_ZOOM","MIN_LABEL",
           "NE_ID","WIKIDATAID","NAME_AR","NAME_BN","NAME_DE","NAME_EN","NAME_ES","NAME_FR","NAME_EL","NAME_HI","NAME_HU",
           "NAME_ID","NAME_IT","NAME_JA","NAME_KO","NAME_NL","NAME_PL","NAME_PT","NAME_RU","NAME_SV","NAME_TR","NAME_VI",
           "NAME_ZH")
countries <- countries[ , !(names(countries) %in% drops)]

# Write data
st_write(countries, "../data/conAg_export.csv")
