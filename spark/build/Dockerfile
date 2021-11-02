# 現時点で未リリースのドライバを使用
FROM containers.intersystems.com/iscinternal/iris:2021.3.0XDBC.199.0

# Standaloneクラスタを組みたいので、ビルド済みのコンテナイメージを使用。
# spark-shell内で、カーソル移動できない(編集出来ない。リコール出来ない)という問題あり。user:root指定で回避中。
# Hadoop 3.2.0 同梱
FROM bitnami/spark:3.0.2
# $ pyspark
#>>> sc._gateway.jvm.org.apache.hadoop.util.VersionInfo.getVersion()
#'3.2.0'

#FROM bitnami/spark:3.1.1
# 3.1.1, 3.1.2 causes a error...
# java.lang.NoSuchMethodError: org.apache.spark.sql.execution.datasources.jdbc.JdbcUtils$.schemaString(Lorg/apache/spark/sql/Dataset;Ljava/lang/String;Lscala/Option;)Ljava/lang/String;

#FROM bitnami/spark:3.2.0
#csvからのdf作成が失敗する。
#scala> trips.groupBy(trips("Passenger_count")).count.show
#com.fasterxml.jackson.databind.JsonMappingException: Scala module 2.12.3 requires Jackson Databind version >= 2.12.0 and < 2.13.0

# As of 2021.3.0XDBC.199.0
COPY --from=0 /usr/irissys/dev/java/lib/1.8/*.jar /custom/lib/

EXPOSE 7001-7005 7077 6066

ENV PYTHONIOENCODING UTF-8
ENV PIP_DISABLE_PIP_VERSION_CHECK 1

ADD ./conf/spark-defaults.conf $SPARK_HOME/conf/spark-defaults.conf
