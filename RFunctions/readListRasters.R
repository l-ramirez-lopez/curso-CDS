# Function designed to read a list of rasters in tif format
# author: Leo Ramirez-Lopez
# Pourpose: Curse UNAL 2014

readListRasters <- function(dir){
  require(raster)
  require(rgdal)
  atif <- list.files(dir, pattern =".tif")
  bcompl <- list.files(dir, pattern =".tif.")
  atif <- atif[!(atif %in% bcompl)]
  atif.dir <- paste(dir, "/",atif, sep = "")
  
  rstrs <- raster(atif.dir[1])
  for(i in 2:length(atif.dir)){
    rstrs <- stack(rstrs, raster(atif.dir[i]))
    cat("reading:", atif[i], "\n")
  }
  cat("Listo!")
  return(rstrs)
}
