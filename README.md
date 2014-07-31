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
modelo_arcilla <- lmrob(formula = formula.arcilla, 
                        data = listo.calibracion[complete.cases(listo.calibracion),],
                        control = lmrob.control(k.max = 10000, rel.tol = 1e-6, cov = ".vcov.w"))
summary(modelo_arcilla)

# Remueve variables problematicas
formula.arcilla2 <- as.formula(paste("Arg ~ 1 + ", paste(nombres_covariables, collapse = "+"), "-valleydepth-valleyindex-mincurv"))

# Crea un nuevo modelo sin esas variables problematicas
modelo_arcilla2 <- lm(formula = formula.arcilla2, 
                      data = listo.calibracion[complete.cases(listo.calibracion),])

summary(modelo_arcilla2)

# Realiza una seleccion de variables basado en la tecnica step-wise
modelo_arcilla3 <- step(modelo_arcilla2)
summary(modelo_arcilla3)

#--- 5. validacion de los modelos de regresion linear multiple ----
# Lee la tabla de los datos de validacin de los modelos espaciales
validacionEspacial <- read.table(file = "Validacion_mod_espacial.txt", header = T, sep="\t")

# Extrae las covariables para los puntos de validacion
covariatesPointsVal <- extract(x = covariatesRasters, y = validacionEspacial[, c("Xc", "Yc")])
# convierte los datos a un formato especial ("data.frame")
covariatesPointsVal <- as.data.frame(covariatesPointsVal)

# reliza las predicciones para los puntos de validacion con base en el 
# modelo predictivo de arcilla y las cpvariables
prediccionArg <- predict(modelo_arcilla3, covariatesPointsVal)

# grafica lo predicho Vs lo observado
plot(validacionEspacial$Arg, prediccionArg, 
     xlab = "Arcilla observada (%)", 
     ylab = "Arcilla predicha (%)",
     ylim = c(0, 80),
     xlim = c(0, 80))
abline(a= 0, b=1, col = "red")


#--- 6. Creamos los mapas digitales de arcilla ----
# Este ejemplo es unicamente didactico
# (Los mapas son creados aunque los modelos presentan un desempeno predictivo probe)

mdarcilla <- predict(covariatesRasters, modelo_arcilla3)

# podemos entonces graficar el mapa
plot(mdarcilla)

# podemos exportar el mapa a un archivo tif
writeRaster(mdarcilla, filename = "MD_Arcilla.tif", format="GTiff")

```
