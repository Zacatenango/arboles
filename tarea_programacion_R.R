# Cargar librerías del tidyverse
library(tidyverse)

# Leer datos
# Fuente: https://www.kaggle.com/datasets/alehcleal/ferrari-stock-data-2015-2026
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

# ============================================================================
# RESUMEN FINAL
# ============================================================================

cat("\n", "=" |> rep(70) |> paste(collapse = ""), "\n")
cat("RESUMEN DEL ANÁLISIS\n")
cat("=" |> rep(70) |> paste(collapse = ""), "\n")

cat("\n[OK] DPLYR: Filtrado, mutación, agrupación y resumen de datos")
cat("\n[OK] TIDYR: Tablas dinámicas con pivot_wider y pivot_longer")
cat("\n[OK] GGPLOT2: Gráficos de dispersión con múltiples capas estéticas")
cat("\n[OK] PURRR: map, map_dfr, map_dbl, map_if, walk, walk2, keep, discard, pluck")
cat("\n\nArchivos generados:")
cat("\n  - ferrari_scatter_plot.png")
