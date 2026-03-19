# ============================================================================
# Análisis de Datos Históricos de Acciones de Ferrari
# Demuestra: dplyr, tidyr, ggplot2 y purrr
# ============================================================================

# Cargar librerías del tidyverse
library(tidyverse)

# Leer datos
ferrari <- read_csv("Ferrari_History_Stock_Data.csv")

cat("=" |> rep(70) |> paste(collapse = ""), "\n")
cat("DATOS ORIGINALES\n")
cat("=" |> rep(70) |> paste(collapse = ""), "\n")
print(head(ferrari, 10))
cat("\nDimensiones:", nrow(ferrari), "filas x", ncol(ferrari), "columnas\n")

# ============================================================================
# 1. DPLYR: Filtrado y transformación de datos
# ============================================================================

cat("\n", "=" |> rep(70) |> paste(collapse = ""), "\n")
cat("1. DPLYR - Filtrado y Transformación\n")
cat("=" |> rep(70) |> paste(collapse = ""), "\n")

ferrari_procesado <- ferrari %>%
  # Convertir fecha y extraer componentes
  mutate(
    Date = as.Date(Date),
    Year = year(Date),
    Month = month(Date),
    Quarter = quarter(Date),
    # Calcular métricas adicionales
    Daily_Range = High - Low,
    Price_Change = Close - Open,
    Pct_Change = (Close - Open) / Open * 100,
    Volatility = Daily_Range / Open * 100
  ) %>%
  # Filtrar datos desde 2018 con volumen significativo
  filter(
    Year >= 2018,
    Volume > 100000
  ) %>%
  # Seleccionar y reordenar columnas
  select(
    Date, Year, Month, Quarter,
    Open, High, Low, Close,
    Volume, Daily_Range, Price_Change, Pct_Change, Volatility
  ) %>%
  # Ordenar por fecha
  arrange(Date)

cat("\nDatos filtrados (2018+, Volumen > 100k):\n")
print(head(ferrari_procesado, 10))
cat("\nNuevas dimensiones:", nrow(ferrari_procesado), "filas\n")

# Resumen estadístico por año
resumen_anual <- ferrari_procesado %>%
  group_by(Year) %>%
  summarise(
    Dias_Trading = n(),
    Precio_Promedio = mean(Close),
    Precio_Min = min(Low),
    Precio_Max = max(High),
    Volumen_Total = sum(Volume),
    Volatilidad_Media = mean(Volatility),
    .groups = "drop"
  )

cat("\nResumen por Año:\n")
print(resumen_anual)

# ============================================================================
# 2. TIDYR: Crear tabla dinámica (pivot)
# ============================================================================

cat("\n", "=" |> rep(70) |> paste(collapse = ""), "\n")
cat("2. TIDYR - Tabla Dinámica\n")
cat("=" |> rep(70) |> paste(collapse = ""), "\n")

# Calcular precio promedio por año y trimestre
precio_trimestral <- ferrari_procesado %>%
  group_by(Year, Quarter) %>%
  summarise(
    Precio_Promedio = round(mean(Close), 2),
    .groups = "drop"
  )

# Pivot a formato ancho (tabla dinámica)
tabla_dinamica <- precio_trimestral %>%
  pivot_wider(
    names_from = Quarter,
    values_from = Precio_Promedio,
    names_prefix = "Q"
  ) %>%
  # Calcular promedio anual
  mutate(
    Promedio_Anual = round(rowMeans(select(., starts_with("Q")), na.rm = TRUE), 2)
  )

cat("\nTabla Dinámica - Precio Promedio por Trimestre:\n")
print(tabla_dinamica)

# Otra tabla: Volumen por mes (formato largo a ancho)
volumen_mensual <- ferrari_procesado %>%
  group_by(Year, Month) %>%
  summarise(
    Volumen_Promedio = round(mean(Volume) / 1e6, 2),  # En millones
    .groups = "drop"
  ) %>%
  pivot_wider(
    names_from = Month,
    values_from = Volumen_Promedio,
    names_prefix = "Mes_"
  )

cat("\nVolumen Promedio Mensual (millones):\n")
print(volumen_mensual)

# Demostrar pivot_longer (volver a formato largo)
tabla_larga <- tabla_dinamica %>%
  select(-Promedio_Anual) %>%
  pivot_longer(
    cols = starts_with("Q"),
    names_to = "Trimestre",
    values_to = "Precio"
  ) %>%
  filter(!is.na(Precio))

cat("\nTabla en formato largo (pivot_longer):\n")
print(head(tabla_larga, 12))

# ============================================================================
# 3. GGPLOT2: Gráfico de dispersión
# ============================================================================

cat("\n", "=" |> rep(70) |> paste(collapse = ""), "\n")
cat("3. GGPLOT2 - Gráfico de Dispersión\n")
cat("=" |> rep(70) |> paste(collapse = ""), "\n")

# Gráfico de dispersión: Volumen vs Cambio de Precio
grafico_dispersion <- ggplot(ferrari_procesado, aes(x = Volume / 1e6, y = Pct_Change)) +
  geom_point(
    aes(color = factor(Year), size = Volatility),
    alpha = 0.6
  ) +
  geom_smooth(
    method = "lm",
    color = "darkred",
    linetype = "dashed",
    se = TRUE,
    alpha = 0.2
  ) +
  geom_hline(yintercept = 0, linetype = "dotted", color = "gray40") +
  scale_color_viridis_d(option = "plasma", name = "Año") +
  scale_size_continuous(name = "Volatilidad (%)", range = c(1, 5)) +
  labs(
    title = "Ferrari: Volumen de Trading vs Cambio Porcentual del Precio",
    subtitle = "Datos desde 2018 | Tamaño de punto indica volatilidad diaria",
    x = "Volumen (millones de acciones)",
    y = "Cambio de Precio (%)",
    caption = "Fuente: Datos históricos de acciones Ferrari"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(color = "gray40"),
    legend.position = "right",
    panel.grid.minor = element_blank()
  )

# Guardar gráfico
ggsave(
  "ferrari_scatter_plot.png",
  plot = grafico_dispersion,
  width = 12,
  height = 8,
  dpi = 150
)

cat("\nGráfico guardado: ferrari_scatter_plot.png\n")

# Segundo gráfico: Precio de cierre vs Rango diario por año
grafico_precio_rango <- ggplot(ferrari_procesado, aes(x = Close, y = Daily_Range)) +
  geom_point(aes(color = Volatility), alpha = 0.5, size = 2) +
  facet_wrap(~Year, scales = "free") +
  scale_color_gradient2(
    low = "blue",
    mid = "yellow",
    high = "red",
    midpoint = median(ferrari_procesado$Volatility),
    name = "Volatilidad (%)"
  ) +
  labs(
    title = "Precio de Cierre vs Rango Diario por Año",
    subtitle = "Color indica nivel de volatilidad",
    x = "Precio de Cierre (USD)",
    y = "Rango Diario (USD)"
  ) +
  theme_bw() +
  theme(
    strip.background = element_rect(fill = "darkred"),
    strip.text = element_text(color = "white", face = "bold")
  )

ggsave(
  "ferrari_faceted_plot.png",
  plot = grafico_precio_rango,
  width = 14,
  height = 10,
  dpi = 150
)

cat("Gráfico guardado: ferrari_faceted_plot.png\n")

# ============================================================================
# 4. PURRR: Aplicar funciones a listas
# ============================================================================

cat("\n", "=" |> rep(70) |> paste(collapse = ""), "\n")
cat("4. PURRR - Aplicar Funciones a Listas\n")
cat("=" |> rep(70) |> paste(collapse = ""), "\n")

# Dividir datos por año en una lista
datos_por_ano <- ferrari_procesado %>%
  group_split(Year) %>%
  set_names(unique(ferrari_procesado$Year) %>% sort())

cat("\nLista creada con", length(datos_por_ano), "elementos (uno por año)\n")

# Función personalizada para análisis
analizar_ano <- function(df) {
  tibble(
    n_observaciones = nrow(df),
    precio_inicio = first(df$Close),
    precio_final = last(df$Close),
    retorno_anual_pct = (last(df$Close) - first(df$Close)) / first(df$Close) * 100,
    max_ganancia_diaria = max(df$Pct_Change),
    max_perdida_diaria = min(df$Pct_Change),
    dias_positivos = sum(df$Price_Change > 0),
    dias_negativos = sum(df$Price_Change < 0),
    volatilidad_promedio = mean(df$Volatility),
    volumen_promedio = mean(df$Volume)
  )
}

# map: Aplicar función a cada elemento de la lista
resultados_map <- map(datos_por_ano, analizar_ano)

cat("\nResultado de map() - Análisis por año:\n")
print(resultados_map)

# map_dfr: Combinar resultados en un data frame
resultados_df <- map_dfr(datos_por_ano, analizar_ano, .id = "Year")

cat("\nResultado de map_dfr() - Data frame combinado:\n")
print(resultados_df)

# map2: Aplicar función con dos argumentos
# Calcular correlación entre volumen y cambio de precio para diferentes ventanas
ventanas <- c(30, 60, 90, 120)
nombres_ventanas <- paste0(ventanas, "_dias")

calcular_correlacion <- function(df, ventana) {
  if (nrow(df) >= ventana) {
    datos_ventana <- tail(df, ventana)
    cor(datos_ventana$Volume, datos_ventana$Pct_Change, use = "complete.obs")
  } else {
    NA_real_
  }
}

# Usar el último año para ejemplo
ultimo_ano <- datos_por_ano[[length(datos_por_ano)]]

correlaciones <- map_dbl(ventanas, ~calcular_correlacion(ultimo_ano, .x))
names(correlaciones) <- nombres_ventanas

cat("\nCorrelación Volumen-Cambio% (último año) por ventana temporal:\n")
print(correlaciones)

# map_if: Aplicar función condicionalmente
# Calcular estadísticas solo para años con más de 200 observaciones
estadisticas_condicionales <- map_if(
  datos_por_ano,
  ~nrow(.x) > 200,
  ~tibble(
    media_precio = mean(.x$Close),
    sd_precio = sd(.x$Close),
    cv = sd(.x$Close) / mean(.x$Close) * 100  # Coeficiente de variación
  ),
  .else = ~tibble(
    media_precio = NA_real_,
    sd_precio = NA_real_,
    cv = NA_real_
  )
)

cat("\nEstadísticas condicionales (map_if, solo años con >200 obs):\n")
print(map_dfr(estadisticas_condicionales, ~.x, .id = "Year"))

# walk: Aplicar función por efectos secundarios (sin retorno)
cat("\nUsando walk() para imprimir resumen de cada año:\n")
walk2(
  names(datos_por_ano),
  datos_por_ano,
  ~cat(sprintf("  Año %s: %d días, Precio promedio $%.2f\n",
               .x, nrow(.y), mean(.y$Close)))
)

# reduce: Combinar elementos de lista
# Encontrar días que aparecen en rango de precios similares entre años
precios_extremos <- map(datos_por_ano, ~c(min = min(.x$Close), max = max(.x$Close)))

cat("\nRangos de precio por año:\n")
walk2(
  names(precios_extremos),
  precios_extremos,
  ~cat(sprintf("  %s: $%.2f - $%.2f\n", .x, .y["min"], .y["max"]))
)

# pluck: Extraer elementos anidados
cat("\nUsando pluck() para extraer datos específicos:\n")
cat("  Primer precio 2020:", pluck(datos_por_ano, "2020", "Close", 1), "\n")
cat("  Último precio 2023:", pluck(datos_por_ano, "2023", "Close", nrow(datos_por_ano[["2023"]])), "\n")

# keep/discard: Filtrar elementos de lista
anos_volatiles <- keep(datos_por_ano, ~mean(.x$Volatility) > 3)
cat("\nAños con volatilidad promedio > 3%:", names(anos_volatiles), "\n")

anos_estables <- discard(datos_por_ano, ~mean(.x$Volatility) > 3)
cat("Años con volatilidad promedio <= 3%:", names(anos_estables), "\n")

# ============================================================================
# RESUMEN FINAL
# ============================================================================

cat("\n", "=" |> rep(70) |> paste(collapse = ""), "\n")
cat("RESUMEN DEL ANÁLISIS\n")
cat("=" |> rep(70) |> paste(collapse = ""), "\n")

cat("\n✓ DPLYR: Filtrado, mutación, agrupación y resumen de datos")
cat("\n✓ TIDYR: Tablas dinámicas con pivot_wider y pivot_longer")
cat("\n✓ GGPLOT2: Gráficos de dispersión con múltiples capas estéticas")
cat("\n✓ PURRR: map, map_dfr, map_dbl, map_if, walk, walk2, keep, discard, pluck")
cat("\n\nArchivos generados:")
cat("\n  - ferrari_scatter_plot.png")
cat("\n  - ferrari_faceted_plot.png\n")