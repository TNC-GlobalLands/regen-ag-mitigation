# Read packages
library(raster)
library(rgdal)
library(spatialEco)

#### SET WORKING DIRECTORY ####
require(funr)
setwd(funr::get_script_path())

# Read in raster SOC data
med <- raster("../data/04Increase/soc_dif_me.tif")

# Read in raster ag area data
areaAg <- raster("../data/GlcShare_v10_02/glc_shv10_02.Tif")

# Downscale area data
areaAg.ds <- raster.downscale(med, areaAg)

#Write file
writeRaster(areaAg.ds, '../data/areaAg250m.tif', overwrite=TRUE)
