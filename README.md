# 内容
[オリジナル](https://github.com/intersystems-community/irisdemo-demo-readmission.git)のIRIS, spark, zeppelinのバージョンを上げ、IRIS, Spark, zeppelinの部分だけを抽出し、大幅に簡略化したもの。

# 起動方法
```bash
$ docker-compose up -d
```
# 停止方法
```bash
$ ./stop.sh
```

# 主なURL

|URL|用途|クレデンシャル|
|:--|:--|:--|
|http://irishost:9094/csp/sys/UtilHome.csp|IRIS管理ポータル|SuperUser / SYS|
|http://irishost:8080/|Spark Master UI||
|http://irishost:4040|Spark context Web UI||
|http://irishost:10000/#/|Zeppeline||

# 実行手順
## sparkmaster環境へのログイン
```bash
$ docker-compose exec sparkmaster bash
root@sparkmaster:/opt/bitnami/spark#
```
## テスト用のCSVを取得

テスト用のCSVを取得。このCSVからテーブルを作成する。/sharedはSpark master/slave間で共有されているフォルダ(hdfsの代わり)。
1000件程度の縮小版も作成。
```bash
root@sparkmaster:/opt/bitnami/spark# curl https://s3.amazonaws.com/nyc-tlc/trip+data/green_tripdata_2016-01.csv | sed  '/^.$/d' > /shared/green_tripdata_2016-01.csv
root@sparkmaster:/opt/bitnami/spark# head -n 1000 /shared/green_tripdata_2016-01.csv > /shared/green_tripdata_2016-01.min.csv
root@sparkmaster:/opt/bitnami/spark# spark-shell
```

## DFのIRISへの書き込み及び読み出し(spark connector)
```scala
case class GreenTrip (
  VendorID: Int,
  lpep_pickup_datetime: java.sql.Timestamp,
  Lpep_dropoff_datetime: java.sql.Timestamp,
  Store_and_fwd_flag: String,
  RateCodeID: Int,
  Pickup_longitude: Double,
  Pickup_latitude: Double,
  Dropoff_longitude: Double,
  Dropoff_latitude: Double,
  Passenger_count: Int,
  Trip_distance: Double,
  Fare_amount: Double,
  Extra: Double,
  MTA_tax: Double,
  Tip_amount: Double,
  Tolls_amount: Double,
  Ehail_fee: Double,
  improvement_surcharge: Double,
  Total_amount: Double,
  Payment_type: Int,
  Trip_type : String
)

val trips = spark.read.schema(Seq[GreenTrip]().toDF.schema).option("header", "true").csv("file:///shared/green_tripdata_2016-01.min.csv")
trips.groupBy(trips("Passenger_count")).count.show
```
下記は、実行結果の出力。
```
+---------------+-----+
|Passenger_count|count|
+---------------+-----+
|              5|   63|
|              3|   22|
|              1|  819|
|              6|   21|
|              4|    6|
|              2|   68|
+---------------+-----+
```

```scala
#IRISへの書き出し

trips.write.format("iris").option("dbtable","zeppelin.GreenTrip").mode("OVERWRITE").option("isolationlevel","NONE").save()

# IRISに保存したデータを取得する
val trips2=spark.read.format("iris").option("dbtable","zeppelin.GreenTrip").load
trips2.groupBy(trips2("Passenger_count")).count.show
```
下記は、実行結果の出力。
```
+---------------+-----+
|Passenger_count|count|
+---------------+-----+
|              5|   63|
|              3|   22|
|              1|  819|
|              6|   21|
|              4|    6|
|              2|   68|
+---------------+-----+
```

| 本操作はzeppelinでspark masterとしてlocal[*]使用すれば、zeppelinでも実行可能。  

下記は、デフォルト値を上書き指定する方法の例。
```scala
val df = spark.read.format("iris").option("dbtable","zeppelin.GreenTrip").option("url","IRIS://riskengine:1972/USER").option("user","SuperUser").option("password","SYS").load
```


## jdbcでのアクセス
先ほどロードしたデータをJDBCで取得します。
```scala
val df = spark.read.format("jdbc").option("driver","com.intersystems.jdbc.IRISDriver").option("dbtable","zeppelin.GreenTrip").option("url","jdbc:IRIS://riskengine:1972/USER").option("user","SuperUser").option("password","SYS").load()
```
| 本操作はzeppelinでも実行可能。    

# 関連ドキュメント

https://docs.intersystems.com/irislatest/csp/docbookj/DocBook.UI.Page.cls?KEY=PAGE_spark
https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=BSPK_intro
