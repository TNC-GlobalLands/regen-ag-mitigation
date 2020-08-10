library(ggplot2)
library(tidyverse)
library(sf)
library(viridis)

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
         silvopasture = grassland_seq / 2) # Call half of that reforestation and half silvopasture

# Join to spatial data
names(data)[1] <- "ADM0_A3"
countries <- right_join(countries, data)

# Visualize data
# All data
ggplot() +
  geom_sf(data = countries, size=0, aes(fill = silvopasture)) +
  scale_fill_viridis() + theme_bw()

# Without China
ggplot() +
  geom_sf(data = countries %>%
            filter(ADM0_A3 != 'CHN'), size=0, aes(fill = silvopasture)) +
  scale_fill_viridis() + theme_bw()

