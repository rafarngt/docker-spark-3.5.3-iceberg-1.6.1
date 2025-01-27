# Spark 3.5.3 with Iceberg and OpenJDK 17

This project provides a Dockerized environment for Apache Spark 3.5.3, OpenJDK 17.0.12, Scala 2.12, and Iceberg libraries. It includes:
- `org.apache.iceberg:iceberg-spark-runtime-3.5_2.12:1.6.1`
- `org.apache.iceberg:iceberg-spark-extensions-3.5_2.12:1.6.1`

## Features
- Ready-to-use Apache Spark environment.
- Iceberg dependencies pre-configured for Spark.
- Data volume (`/data`) for storage and persistence.

## Requirements
- Docker
- Docker Compose

## Setup

### Step 1: Clone the Repository
Clone this repository or copy the files into a directory:
```bash
git clone <repository-url>
cd <repository>
```

### Step 2: Build the Docker Image
```bash
docker compose build
```

### Step 3: Run the Container
```bash
docker compose up -d
```

### Step 4: Access Spark
- Open Spark Shell:
```bash
docker exec -it spark_iceberg_container bash

```

### Data Volume
The /data directory is mounted as a volume. Place your data in the data folder in the project directory to make it available inside the container.

### Spark Configuration
The Iceberg libraries are pre-installed. To use Iceberg in Spark:

```bash
spark = SparkSession \
    .builder \
    .appName("parquetToIceberg") \
	.config('spark.jars.packages', 'org.apache.iceberg:iceberg-spark-runtime-3.5_2.12-1.6.1') \
    .config("spark.sql.extensions", "org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions") \
    .config("spark.sql.catalog.local", "org.apache.iceberg.spark.SparkCatalog") \
    .config("spark.sql.catalog.local.type", "hadoop") \
    .config("spark.sql.catalog.local.warehouse", "/opt/data/warehouse") \
	.config("spark.sql.catalog.iceberg_catalog.cache-enabled", "false") \
    .getOrCreate()
sc = spark.sparkContext
Context = SQLContext(sc)

```


### Create User table

```bash
spark.sql("""
  CREATE TABLE local.ldm.users (
    id INT,
    nombre STRING,
    edad INT
  ) USING iceberg""")
```

### Insert Data into User Table

```bash
spark.sql("""
  INSERT INTO local.ldm.users VALUES
    (1, 'Pablo', 30),
    (2, 'Marce', 25),
    (3, 'Fede', 35)""")
```

### Query 
```bash
spark.sql(""" SELECT * FROM local.ldm.users""").show()
```

### Update table
```bash
spark.sql(""" UPDATE local.ldm.users set nombre='Juan' where id=1""")
```


### Check table
```bash
spark.sql(""" SELECT * FROM local.ldm.users""").show()
```

### Exit Spark shell
```bash
quit()
```

### Exit Docker 
ctl + D
