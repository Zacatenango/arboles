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

# Al estilo MATLAB, multiplicar un vector por un escalar se hace directo
vectorcillo_doble = vectorcillo * 2
vectorcillo_doble

# Las indexaciones de PANDAS provienen de R
vectorcillo[1:3]
vectorcillo[vectorcillo >= 3]
vectorcillo_doble[vectorcillo_doble >= 3]

# Los vectores pueden ser de tipos mixtos
surtido <- c(3232, "skvrn", FALSE)

# Las operaciones de matrices son como en MATLAB
cuadrado <- matricilla %*% matricilla
transpuesta <- t(matricilla)
cuadrado
transpuesta

# Matriz inversa (pero necesito otra matriz porque esta es singular)
#inversa = solve(matricilla)
#inversa

# Producto directo de vectores
prod_directo <- vectorcillo * vectorcillo

# Data frame de práctica
datos <- data.frame(
   nombre = c("Diego", "David", "Yo"),
   edad = c(25, 40, 38),
   salario = c(20000, 20000, 200000)
)
datos$scrum_master = c(FALSE, TRUE, FALSE)
datos

# Agregación
resumen1 <- aggregate(salario ~ edad, data=datos, FUN=mean)
resumen1

# R tiene ayuda inline en la consola con preguntación. En R Studio, aparece en
# la pestaña Help.
?mean
