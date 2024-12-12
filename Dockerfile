FROM openjdk:17-jdk-slim AS builder

# Variables de entorno
ENV SCALA_VERSION=2.12 \
    SPARK_VERSION=3.5.3 \
    HADOOP_VERSION=3 \
    SPARK_HOME=/opt/spark

# Instalar dependencias:
# - curl, tar: para descargar e instalar Spark
# - python3: necesario para PySpark
# - procps: proporciona el comando 'ps' y otras utilidades
RUN apt-get update && apt-get install -y curl tar python3 procps && rm -rf /var/lib/apt/lists/*

# Descarga e instalación de Spark
RUN curl -fSL https://dlcdn.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz -o /tmp/spark.tgz \
    && mkdir -p ${SPARK_HOME} \
    && tar -xvf /tmp/spark.tgz -C /opt \
    && mv /opt/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}/* ${SPARK_HOME} \
    && rm /tmp/spark.tgz

# Añadir las dependencias de Iceberg
RUN curl -fSL https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-3.5_2.12/1.6.1/iceberg-spark-runtime-3.5_2.12-1.6.1.jar -o ${SPARK_HOME}/jars/iceberg-spark-runtime-3.5_2.12-1.6.1.jar \
    && curl -fSL https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-extensions-3.5_2.12/1.6.1/iceberg-spark-extensions-3.5_2.12-1.6.1.jar -o ${SPARK_HOME}/jars/iceberg-spark-extensions-3.5_2.12-1.6.1.jar

# Crear usuario sin privilegios y asignar permisos
RUN useradd -m sparkuser \
    && mkdir -p /opt/data \
    && chown -R sparkuser:sparkuser ${SPARK_HOME} \
    && chown -R sparkuser:sparkuser /opt/data

USER sparkuser
WORKDIR ${SPARK_HOME}

VOLUME /opt/data

ENV PATH=${SPARK_HOME}/bin:${SPARK_HOME}/sbin:$PATH

CMD ["bash"]
