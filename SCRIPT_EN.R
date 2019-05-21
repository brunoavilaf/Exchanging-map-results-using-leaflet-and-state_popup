# Lib Load ####
if ("install.load" %in% row.names(installed.packages())  == FALSE) 
  install.packages("install.load") 
require(install.load)
install.load::install_load(
  "rgdal"
  , "gdata"
  , "dplyr"
  , "leaflet"
)

# Make Shape File ####
# Get Files
shp <- readOGR(file.choose(new = T), stringsAsFactors=FALSE, encoding="UTF-8")
BASE_AUX_MAP_MG <- read.csv(file.choose(new = T), sep = ";", dec = ",")
shp <- merge(shp,BASE_AUX_MAP_MG)

shp$NM_MUNICIP = NULL
shp <- rename.vars(shp, c("NM_MUNICIP_2"), c("NM_MUNICIP"))

BASE <- read.csv(file.choose(new = T), sep=";",dec=",")

BASE<- merge(BASE, BASE_AUX_MAP,by.x = "CITY", by.y = "NM_MUNICIP_2" )

BASE$CITY = NULL

BASE<-BASE %>% select(CD_GEOCMU, everything())

# BASE <- as.data.frame(BASE) # BASE is already of class data.frame

DATA <- merge(shp,BASE, by.x = "CD_GEOCMU", by.y = "CD_GEOCMU")

proj4string(DATA) <- CRS("+proj=longlat +datum=WGS84 +no_defs")

DATA$QUANTITY_MEDICAL[is.na(DATA$QUANTITY_MEDICAL)] <- 0

DATA$QUANTITY_MEDICAL <- ifelse(DATA$QUANTITY_MEDICAL==0,NA,DATA$QUANTITY_MEDICAL)

DATA$EXAMS[is.na(DATA$EXAMS)] <- 0

DATA$EXAMS <- ifelse(DATA$EXAMS==0,NA,DATA$EXAMS)

# Leaflet ####
pal <- colorBin(
  "Blues"
  , domain = DATA$QUANTITY_MEDICAL,bins = c(1, 1000, 5000, 10000, 50000,100000,300000)
  , na.color = NA
  ) 

state_popup <- paste0("<strong>CITY: </strong>", 
                      DATA$CITY, 
                      "<br><strong> QUANTITY OF MEDICAL CONSULTATION: </strong>", 
                      DATA$QUANTITY_MEDICAL)

leaflet(data = DATA) %>%
    addProviderTiles("CartoDB.Positron") %>%
    addPolygons(fillColor = ~pal(QUANTITY_MEDICAL), 
                fillOpacity = 0.7, 
                color = "#BDBDC3", 
                weight = 1, 
                popup = state_popup) %>%
    addLegend("topright","bottomright", pal = pal, values = ~ DATA$QUANTITY_MEDICAL,
              title = " QUANTITY OF MEDICAL CONSULTATION ",
              opacity = 1)


