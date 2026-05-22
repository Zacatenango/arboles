# MLops

Es el conjunto de prácticas que combina aprendizaje machín, devops e ingeniería de datos con el fin de automatizar y estandarizar el ciclo de vida de los modelos en Prod. Está encaminado a resolver problemas de deployment y ciclo de vida: degradación silenciosa, experimentos no reproducibles, despliegues manuales frágiles, datos no trazables, funciona en Desarrollo pero no en Producción.

- MLops = machine learning + devops
- Automatización del ciclo de vida de modelos
- Reproducibilidad: que el modelo funcione en donde sea
- Monitoreo: vigilar que el modelo funcione, los recursos que consume, y sus resultados
- Escalabilidad
- CI/CD

El objetivo es **llevar modelos desde archivos de Python o Jupyler notebook hasta Producción.**

Buscamos resolver problemas comunes como:

- Funciona en local pero no en Producción
- Dependencias incompatibles (todo está hecho para RHEL 9 y tenemos RHEL 7)
- Data drift
- Modelos sin versionado
- Falta de monitoreo
- Inferencia lenta
- APIs que no escalan ()

## Niveles de madurez

1. **Manual:** notebooks manuales, sin versión, sin registro.
2. **Automatizado:** pipeline de entrenamiento con tracking, reproducible.
3. **CI/CD completo:** deploy automático, monitoreo, reentrenamiento.

## Ejemplo de pipeline básico

1. Recolección de datos
2. Entrenamiento
3. Tracking de experimentos
   - Métricas, parámetros, artefactos, versiones
   - Permite comparar modelos, reproducibilidad, auditoría
4. Registro de modelos
5. Containerización
6. Serving
7. Monitoreo

## Ciclo de vida básico

1. Datos
2. Feature engineering
3. Entrenamiento (con MLflow)
4. Evaluación
5. Despliegue (Podman, Kubernetes, Openshift...)
6. Monitoreo (Prometheus, Grafana, Splunk)
7. Reentrenamiento




# MLflow

Plataforma para administrar el ciclo de vida de ML.

Los componentes principales son tracking, proyectos, modelos y registry.

Es una herramienta web-gráfica que permite administrar el ciclo de vida del ML.

- **Tracking:** registra parámetros, métricas, artefactos y código
- **Registry:** mantiene el ciclo ode vida del modelo staging -> production -> archived, etiquetas y anotaciones, aprobaciones y transiciones, integración con CI/CD.
- **Build:** se hace un armado de imagen
- **Proyectos:** empaqueta código reproducible con dependencias
- **Modelos:** usa un formato universal para servir modelos (REST, batch, streaming)
- **UI:** la interfaz para comparar runs, ver gráficas y gestionar modelos

Para interactuar con ella, corro mis modelos con una librería que se conecta a MLflow.



# Podman

Podman es un administrador de containers compatible con imágenes Docker, rootless, 


# Serving

- **REST o gRPC:** Predicción en tiempo real, baja latencia, por request individual.
- **Batch:** corre cada cierto tiempo, con herramientas como Rundeck, Ctrl-M o cron.
- **Streaming:** Kafka o Kinesis, eventos continuos, latencia media, stateful processing

MLflow soporta servir modelos de ML en esos 3 modos.


# Errores comunes

- Dependencias incompatibles
  - MLflow maneja eso a través de especificar expresamente todas las dependencias
- Model drift
- Timeouts
  - Detectamos eso 
- Saturación de micro
- Fugas de memoria
- Alta latencia
