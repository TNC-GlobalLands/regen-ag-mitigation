library(ggplot2)
library(tidyverse)
library(readxl)
library(sf)
library(viridis)
library(lwgeom)

# Reading working director
# require(funr)
# setwd(funr::get_script_path())
path <- "~/Box Sync/Work/The Nature Conservancy/Global Soils/Regenerative Foodscapes/Mitigation Mapping/"
setwd(path)

# Read data
lulc <- read_csv("data/OECD_LAND_COVER_10082020154419035.csv")
ncsmapper <- read_excel("data/06-02-2020_15pthways_INTERNAL.xlsx")
countries <- st_read("data/ne_110m_admin_0_countries/ne_110m_admin_0_countries.shp")

# Modify data
ncsmapper <- ncsmapper %>%
  select(CountryGeography:`Cost-effective Reforestation`) %>%
  slice(2:n())

lulc <- lulc %>% filter(VARIABLE=='GRSL') %>%
  filter(Year=='2018') %>% filter(MEAS=='PCNT') %>% 
  select('Country','COU','Value')

names(ncsmapper)[1:2] <- c('Country','COU')  

lulc <- lulc %>% select(-Country)
ncsmapper <- ncsmapper %>% select(-Country)

data <- full_join(lulc,ncsmapper)

# Calculate silvopasture potential
data <- data %>% 
  mutate(grassland_seq = (Value/100) * as.numeric(Reforestation), # Multiple reforestation by fraction of grassland
         silvopasture = grassland_seq / 2, # Call half of that reforestation and half silvopasture
         grassland_seq_CE = (Value/100) * as.numeric(`Cost-effective Reforestation`),
         silvopasture_CE = grassland_seq_CE / 2
  )

# Join to spatial data
names(data)[1] <- "ADM0_A3"
countries <- right_join(countries, data)

# Visualize data
countries$area <- as.numeric(st_area(countries)/100000000000)
countries$silvopastArea <- countries$silvopasture/countries$area

countries <- cbind(countries, st_coordinates(st_centroid(countries)))

countries <- countries %>%
  mutate(silvopasture = round(silvopasture, 1),
         silvopastArea = round(silvopastArea, 1))

# All data
ggplot() +
  geom_sf(data = countries, size=0, aes(fill = silvopasture)) +
  geom_text(data = countries, aes(X,Y,label = silvopasture), size = 1,color='white') +
  xlab("") + ylab("") +
  scale_fill_viridis(name = "Silvopasture\nTg C yr-1") + theme_bw() + theme(legend.position="bottom")
ggplot() +
  geom_sf(data = countries, size=0, aes(fill = log(silvopastArea))) +
  xlab("") + ylab("") +
  scale_fill_viridis(name = "Silvopasture\nTg C yr-1") + theme_bw() + theme(legend.position="bottom")
ggplot() +
  geom_sf(data = countries %>%
            filter(ADM0_A3 != 'GBR') %>%
            filter(ADM0_A3 != 'IRL') %>%
            filter(ADM0_A3 != 'HTI'), size=0, aes(fill = silvopastArea)) +
  xlab("") + ylab("") +
  scale_fill_viridis(name = "Silvopasture\nTg C per yr\nper 100000 sq km") + theme_bw() + theme(legend.position="bottom")

# All CE data
ggplot() +
  geom_sf(data = countries, size=0, aes(fill = silvopasture_CE)) +
  geom_text(data = countries, aes(X,Y,label = silvopasture), size = 1,color='white') +
  xlab("") + ylab("") +
  scale_fill_viridis(name = "Silvopasture\nTg C yr-1\nat $100/ton") + theme_bw()
# CE Without China
ggplot() +
  geom_sf(data = countries %>%
            filter(ADM0_A3 != 'CHN'), size=0, aes(fill = silvopasture_CE)) +
  geom_text(data = countries, aes(X,Y,label = silvopasture), size = 1,color='white') +
  xlab("") + ylab("") +
  scale_fill_viridis(name = "Silvopasture\nTg C yr-1\nat $100/ton") + theme_bw()


# Drop unneeded data
drops <- c("featurecla","scalerank","LABELRANK","ADM0_DIF","LEVEL","GEOU_DIF","SU_DIF","BRK_DIFF","BRK_GROUP",
           "FORMAL_FR","MAPCOLOR7","MAPCOLOR8","MAPCOLOR9","MAPCOLOR13","WIKIPEDIA","WOE_ID","WOE_ID_EH","WOE_NOTE",
           "ADM0_A3_UN","ADM0_A3_WB","NAME_LEN","LONG_LEN","ABBREV_LEN","TINY","HOMEPART","MIN_ZOOM","MIN_LABEL",
           "NE_ID","WIKIDATAID","NAME_AR","NAME_BN","NAME_DE","NAME_EN","NAME_ES","NAME_FR","NAME_EL","NAME_HI","NAME_HU",
           "NAME_ID","NAME_IT","NAME_JA","NAME_KO","NAME_NL","NAME_PL","NAME_PT","NAME_RU","NAME_SV","NAME_TR","NAME_VI",
           "NAME_ZH")
countries <- countries[ , !(names(countries) %in% drops)]

# Write data
st_write(countries, "silvopasture-export.csv")
