# Data scraping
library(rvest)
library(purrr) # for the keep() and pluck() functions
library(dplyr)
url <- "https://en.wikipedia.org/wiki/Washington,_D.C."
page <- read_html(url)

# Extract all html tables and find the population table
pop_table <- page |>
  html_elements("table") |>
  html_table() |>
  keep(~ any(grepl("Census", names(.x)))) |>
  pluck(1)

head(pop_table)

pop=pop_table|>
rename(Year= Census,Population=Pop.,Change_pct= `%±`)|>
  slice(-n())|>
  select(-3) |>
  mutate(Population = gsub(",","", Population),
         Change_pct = gsub("%", "", Change_pct))|>
  mutate(Change_pct= gsub("-", "-", Change_pct))|>
  mutate(Year= as.numeric(substr(Year,1,4)),
         Population= as.numeric(Population),
         Change_pct= as.numeric(Change_pct))
summary(pop)

write.csv(pop,"dataderived/popD.csv", row.names = FALSE)
  
library(httr2)
library(readr)

# Build API request for NOAA station 8577330 (Solomons Island, MD)
req <- request("https://api.tidesandcurrents.noaa.gov/api/prod/datagetter") |>
  req_url_query(
    begin_date  = "20240101",
    end_date    = "20240131",
    station     = "8577330",
    product     = "water_temperature",
    units       = "metric",
    time_zone   = "gmt",
    application = "UMCES_MEES702",
    format      = "csv"
  )

# Perform request and parse CSV response
resp <- req_perform(req)
water_temp <- resp |>
  resp_body_string() |>
  I() |>
  read_csv()

head(water_temp)

write.csv(water_temp,"dataderived/water_temp.csv", row.names = FALSE)

library(ncdf4)
library(geosphere)
library(tibble)
library(ggplot2)

nc_path <- "dataraw/cbefs_2024_v20251101.nc"
nc <- nc_open(nc_path)

# View available variable names
names(nc$var)

# View available dimension names
ls(nc$dim)

# Inspect specific dimension attributes
nc$dim$depths
nc$dim$time
nc$dim$x
nc$dim$y
# Extract coordinate grids
lon_matrix <- ncvar_get(nc, "longitude")
lat_matrix <- ncvar_get(nc, "latitude")

# Define target coordinates for Chesapeake Biological Laboratory (CBL)
cbl_lon <- -76.4533
cbl_lat <- 38.3191
  # Unroll 2D grids into a 2-column coordinate matrix
  coords_grid <- cbind(as.vector(lon_matrix), as.vector(lat_matrix))

# Compute true distances on a sphere/ellipsoid
dist_meters <- distGeo(c(cbl_lon, cbl_lat), coords_grid)
dist_matrix <- matrix(dist_meters, nrow = nrow(lon_matrix), ncol = ncol(lon_matrix))

# Locate array indices of minimum distance
nearest_idx <- which(dist_matrix == min(dist_matrix, na.rm = TRUE), arr.ind = TRUE)
target_row  <- nearest_idx[1, "row"]
target_col  <- nearest_idx[1, "col"]

# Dimensions are [336, 564, 2, 365] -> [row, col, layer, time]
# start: row, col, start_layer, start_day
# count: row_count, col_count, layer_count, day_count
cbl_temp <- ncvar_get(
  nc,
  varid = "temperature",
  start = c(target_row, target_col, 1, 1),
  count = c(1, 1, 2, 365)
)

# Always close the NetCDF file connection when finished
nc_close(nc)
  # Layer 1 = Bottom water layer, Layer 2 = Surface water layer
  cbl_df <- tibble(
    Day = rep(1:365, times = 2),
    Layer = rep(c("Layer 1 (Bottom)", "Layer 2 (Surface)"), each = 365),
    Temperature = c(cbl_temp[1, ], cbl_temp[2, ])
  )
  
  library(ncdf4)
  library(sf)
  library(rnaturalearth)
  library(ggplot2)
  library(ggspatial)
  library(tibble)
  library(dplyr)
  
  # Set the path to the NetCDF file and open it
  nc_path <- "dataraw/cbefs_2024_v20251101.nc"
  nc <- nc_open(nc_path)
  
  # Extract 2D geographic coordinate matrices
  lon_matrix <- ncvar_get(nc, "longitude")
  lat_matrix <- ncvar_get(nc, "latitude")
  
  temp_surface <-  # put your code here
    