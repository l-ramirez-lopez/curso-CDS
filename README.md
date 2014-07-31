# Cartografia Digital de Suelos (Pedometria – conceptos y aplicaciones)

_Leonardo Ramirez-Lopez_

Hola, este repositoriuo contiene algunos de los archivos y ejemplos que serán utilizados durante el taller del curso de cartografía digital de suelos.
Lo primero que se debe hacer es instalar los siguientes programas los cuales son requeridos para el desarrollo del curso:
- [`R`](http://www.r-project.org/)
- [R Studio](http://www.rstudio.com/)
- [SAGA (System for Automated Geoscientific Analyses)](http://www.saga-gis.org/en/index.html)

A continuacion encontramos la rutina basica que debemos ejecutar paso a paso en clase:
```
# Instala los paquetes necesarios
install.packages("raster")
install.packages("rgdal")

require(raster)
require(rgdal)
require(robustbase)

# Define el directorio de trabajo
setwd("C:/MiCarpeta/")

#--- 1. Importa los rasters necesarios ----
# Carga la function para leer rasters tif de un directorio
source("RFunctions/readListRasters.R")

# Lee los rasters correspondientes a los atributos del terreno
# Se genera un archivo en R que contiene todos los rasters
covariatesRasters <- readListRasters(dir = "C:/MiCarpeta/ParamTerrenoTif/")

# grafica el primer raster de la lista de rasters
plot(covariatesRasters[[1]])

# grafica el raster numero 17 de la lista de rasters
plot(covariatesRasters[[17]])

#--- 2. Importa la tabla de las muestras para calibracion ----
# Lee la tabla de los datos de calibracion de los modelos espaciales
calibracionEspacial <- read.table(file = "Calibracion_mod_espacial.txt", header = T, sep="\t")

# Grafica los puntos en la tabla (coordenadas)
plot(calibracionEspacial[, c("Xc", "Yc")])


#--- 3. Extrae los valores de las covariables (rasters) en los puntos de muestreo ----
covariatesPoints <- extract(x = covariatesRasters, y = calibracionEspacial[, c("Xc", "Yc")])

# pega las valores de las variables extraidas a la tabla que contiene los datos de arcilla
listo.calibracion <- cbind(calibracionEspacial, covariatesPoints)

#--- 4.  Verificar la distribucion de valores de arcilla
hist(listo.calibracion[,"Arg"])

#--- 5. construye un modelo de regresion linear multiple ----
# define los nombres de las covariables a emplear
nombres_covariables <- colnames(covariatesPoints)

# define la equacion que vamos a usar para crear los modelos
formula.arcilla <- as.formula(paste("Arg ~ 1 + ", paste(nombres_covariables, collapse = "+")))

# ajusta el modelo
modelo_arcilla <- lmrob(formula = formula.arcilla, data = listo.calibracion[(!duplicated(listo.calibracion$ID)),])
summary(modelo_arcilla)
```
