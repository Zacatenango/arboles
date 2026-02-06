# Asignación de variables: puede ser con = como en todos los lenguajes,
# o con la bien conocida flechita. Se vale usar el igual, pero la costumbre
# y práctica establecida en la comunidad R es usar la flecha.
skvrn = 10
prvych <- "raer"

# Como en MATLAB, se puede tirar el contenido de una variable con mencionarla.
skvrn
prvych

# En R todo es un vector, al estilo MATLAB.
# Hay vectores, listas, matrices, dataframes y factores (variables categóricas)
# Las listas son tablas de haxix como los diccionarios de Python
vectorcillo = c(1,2,3,4)
listilla = list(nombre="Juan", edad=25, ciudad="DF")
matricilla = matrix(1:9, nrow=3, ncol=3)
PANDAS = data.frame(Nombre=c("Ana", "Luis"), Edad=c(25,30))
factorcillo = factor(c("bajo", "medio", "alto"))

# En R los índices son de base 1; sin embargo, hay un índice 0 especial,
# el cual dice el tipo de datos de la variable.
vectorcillo[0]
vectorcillo[1]

# Para indizar un elemento de un diccionario, uso el signo de peso
listilla$nombre

# Las matrices son internamente vectores de vectores
matricilla
matricilla[2]
