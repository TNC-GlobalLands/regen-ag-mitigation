# Read packages
library(raster)
library(rgdal)
library(sf)
library(ggplot2)
library(exactextractr)
library(viridis)

#### SET WORKING DIRECTORY ####
require(funr)
setwd(funr::get_script_path())
#path <- "~/Box Sync/Work/The Nature Conservancy/Global Soils/Regenerative Foodscapes/Mitigation Mapping/"
#setwd(path)

# Read in raster data
hi <- raster("../data/increase_per_grid_cell-high/tc_dif_hi.tif")
med <- raster("../data/increase_per_grid_cell-medium/tc_dif_me.tif")

# Read in shapefile data
countries <- st_read("data/ne_110m_admin_0_countries/ne_110m_admin_0_countries.shp")

# Convert from tonnes x 100 per ha to tonnes. 6.25 is # of ha per 250m grid cell
hi <- hi * .0625
med <- med *.0625

# Calculate high and medium SOC sequestration for each country
countries$hiSOC <- exact_extract(hi, countries, 'sum')
countries$medSOC <- exact_extract(med, countries, 'sum')

# Plot data
# ggplot() +
#   geom_sf(data = countries, size=0, aes(fill = hiSOC)) +
#   scale_fill_viridis() + theme_bw()
# ggplot() +
#   geom_sf(data = countries, size=0, aes(fill = medSOC)) +
#   scale_fill_viridis() + theme_bw()

# Drop unneeded data
drops <- c("featurecla","scalerank","LABELRANK","ADM0_DIF","LEVEL","GEOU_DIF","SU_DIF","BRK_DIFF","BRK_GROUP",
           "FORMAL_FR","MAPCOLOR7","MAPCOLOR8","MAPCOLOR9","MAPCOLOR13","WIKIPEDIA","WOE_ID","WOE_ID_EH","WOE_NOTE",
           "ADM0_A3_UN","ADM0_A3_WB","NAME_LEN","LONG_LEN","ABBREV_LEN","TINY","HOMEPART","MIN_ZOOM","MIN_LABEL",
           "NE_ID","WIKIDATAID","NAME_AR","NAME_BN","NAME_DE","NAME_EN","NAME_ES","NAME_FR","NAME_EL","NAME_HI","NAME_HU",
           "NAME_ID","NAME_IT","NAME_JA","NAME_KO","NAME_NL","NAME_PL","NAME_PT","NAME_RU","NAME_SV","NAME_TR","NAME_VI",
           "NAME_ZH")
countries <- countries[ , !(names(countries) %in% drops)]

# Write data
st_write(countries, "SOCtables.csv", layer_options = "GEOMETRY=AS_XY")
