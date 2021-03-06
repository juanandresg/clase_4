# Elaborado por: Eduard F. Martinez Gonzalez
# Fecha: 2 de septiembre de 2020
# Nota: No se usan acentos ni caracteres especiales para evitar conflictos entre los diferentes sistemas operativos.

#--------------------------#
# 0. Configuración inicial #
#--------------------------#

#### 0.0 Hoy veremos...
rstudioapi::viewer(url = "Intro-clase-4.html")

#### 0.1 Limpiar la consola, el entorno y fijar directorio de trabajo
cat("\f")
rm(list=ls())
setwd("~/Dropbox/teaching/taller de R/github/Clases/Clase 4") # Cambiar este directorio
getwd()

#### 0.2 Instalar las librerias que vamos a usar en la clase de hoy
for ( paquete in c('tidyverse','plyr') ){
      if (length(grep(paquete,installed.packages()[,1])) == 0 ){ install.packages(paquete) ; print(paste0("La libreria ", "'", paquete ,"'", " ha sido instalada."))}
      else { print(paste0("La libreria ", "'", paquete ,"'", " ya esta instalada."))}
      rm(paquete)
}

#### 0.3 Llamar las librerias
library('tidyverse')

#-----------------------------------------------#
# 1. Unir bases de datos por filas y/o columnas #
#-----------------------------------------------#

#### 1.0 Veamos la intuicion primero
rstudioapi::viewer(url = "help/Help-Merge.html")

#### 1.1 Cargar bases de datos
browseURL(url = "http://microdatos.dane.gov.co/index.php/catalog/659/get_microdata", browser = getOption("browser")) # Fuente: DANE

cg_cabecera = read.csv2(file = "data/original/Cabecera - Caracteristicas generales (Personas).csv" , header = T , sep = ';')
deso_cabecera = read.csv2(file = "data/original/Cabecera - Desocupados.csv" , header = T , sep = ';')

cg_resto = read.csv2(file = "data/original/Resto - Caracteristicas generales (Personas).csv" , header = T , sep = ';')
deso_resto = read.csv2(file = "data/original/Resto - Desocupados.csv" , header = T , sep = ';')


#### 1.2 Hacer merge de las bases de datos
browseURL(url = "http://microdatos.dane.gov.co/index.php/catalog/659/data_dictionary", browser = getOption("browser")) # Chequear el diccionario de variables

#### 1.2.1 Chequear el identificador
duplicated(cg_cabecera$directorio) %>% table()

duplicated(paste0(cg_cabecera$directorio,cg_cabecera$secuencia_p)) %>% table()

duplicated(paste0(cg_cabecera$directorio,cg_cabecera$secuencia_p,cg_cabecera$orden)) %>% table() # No hay duplicados en X

duplicated(paste0(deso_cabecera$directorio,deso_cabecera$secuencia_p,deso_cabecera$orden)) %>% table() # No hay duplicados en Y

#### 1.2.2 Merge dejando todas las observaciones de caracteristicas generales
cabecera = merge(x = cg_cabecera , y = deso_cabecera , by = c('directorio','secuencia_p','orden') , all.x = T , suffixes = c('_cg','_deso'))  

resto = merge(x = cg_resto , y = deso_resto , by = c('directorio','secuencia_p','orden') , all.x = T , suffixes = c('_cg','_deso'))  
View(cg_resto) # Vamos s cambiar los nombres de las variables para poder unirlos con cabecera despues
colnames(cg_resto) = tolower(colnames(cg_resto))
colnames(deso_resto) = tolower(colnames(deso_resto))
resto = merge(x = cg_resto , y = deso_resto , by = c('directorio','secuencia_p','orden') , all.x = T , suffixes = c('_cg','_deso'))  

#### 1.3 Agregando observaciones 
nacional = plyr::rbind.fill(cabecera,resto)
  
#### 1.4 Visor de datos DANE
warning('En el Task de la clase usted podra hacer calculos con la GEIH y comparar susu resultados con los de esta app')
browseURL(url = "https://sitios.dane.gov.co/visor-geih/#/visor", browser = getOption("browser"))

#### 1.5 exportar y limpiar la base de datos
saveRDS(object = nacional , file = "data/procesados/GEIH nacional.rds")
rm(list = ls())


#------------------------------------------#
# 2. Limpieza de variables en un dataframe #
#------------------------------------------#

#### 2.1 Cargar bases de datos
browseURL(url = "https://www.dane.gov.co/index.php/estadisticas-por-tema/demografia-y-poblacion/proyecciones-de-poblacion", browser = getOption("browser")) # Fuente: DANE
dane = readRDS(file = 'data/original/proyecciones DANE.rds') %>% 
       dplyr::select(.,name_codigo , year , total_poblacion , codigo)

#### 2.2 Generar variables en un dataframe
dane$dummy = 1

dane = mutate(dane , colombia = 1 ) 

#### 2.2.1 Generar variable usando el codigo dane
nchar('Hola')

dane = mutate(dane , depto = ifelse(test = nchar(codigo) == 2 , yes = 1 , no = 0)) 

dane$mpio = ifelse(test =  nchar(dane$codigo) > 2 , yes = 1, no = 0) 

#### 2.2.2 Rellenar con el nombre del municipio
dane_mpio = subset(dane , mpio == 1)

substr(x = 'Hola' , start = 2, stop = 4) # Veamos la funcion substr()
str_locate(string = "Hola - todos" ,pattern = '-') # Veamos la funcion str_locate()

dane_mpio = mutate(dane_mpio , name = substr(x =  name_codigo ,start = 1 , stop =  str_locate(string = name_codigo,pattern = '-')))

dane_mpio <- dane_mpio %>% group_by(codigo) %>% fill(name, .direction = "down") # default rellena con el valor anterior


#### 2.2.3 Limpiar el nombre del municipio
gsub(pattern = "ol",replacement = "-",x = "Hola") # Veamos la funcion gsub()

dane_mpio = mutate(dane_mpio , name = gsub(pattern = " -",replacement = "" ,x = name))


#### 2.3 Exportar la base de datos
dane_mpio = dane_mpio[,c('codigo','name','year','total_poblacion')]
saveRDS(object = dane_mpio , file = "data/procesados/proyecciones DANE.rds")










