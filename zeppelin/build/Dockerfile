FROM containers.intersystems.com/iscinternal/iris:2021.3.0XDBC.199.0

# Here is our real image. This is the universe we are going to stay on. 
FROM apache/zeppelin:0.10.0

# Now we can extract those jar files from universe 0, and bring them into our universe... ;)
# Let's bring the ODBC driver as well
#COPY --from=0 /usr/irissys/dev/java/lib/JDK1.8/*.jar /custom/lib/
# As of 2021.3.0XDBC.199.0
COPY --from=0 /usr/irissys/dev/java/lib/1.8/*.jar /custom/lib/
COPY --from=0 /usr/irissys/bin/libirisodbc35.so /usr/lib/

EXPOSE 9090

# HADOOP
#ENV HADOOP_VERSION 2.7.7
ENV HADOOP_VERSION 3.2.0
ENV HADOOP_HOME /opt/zeppelin/hadoop-$HADOOP_VERSION
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV PATH $PATH:$HADOOP_HOME/bin
RUN curl -sL --retry 3 \
  "http://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz" \
  | gunzip \
  | tar -x -C /opt/zeppelin/ \
 && rm -rf $HADOOP_HOME/share/doc 

ENV SPARK_VERSION 3.0.2
ENV SPARK_PACKAGE spark-${SPARK_VERSION}-bin-without-hadoop
ENV SPARK_HOME /opt/zeppelin/spark-${SPARK_VERSION}
ENV SPARK_DIST_CLASSPATH="$HADOOP_HOME/etc/hadoop/*:$HADOOP_HOME/share/hadoop/common/lib/*:$HADOOP_HOME/share/hadoop/common/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/hdfs/lib/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/yarn/lib/*:$HADOOP_HOME/share/hadoop/yarn/*:$HADOOP_HOME/share/hadoop/mapreduce/lib/*:$HADOOP_HOME/share/hadoop/mapreduce/*:$HADOOP_HOME/share/hadoop/tools/lib/*"
ENV PATH $PATH:${SPARK_HOME}/bin
ENV SPARK_OPTS --driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info
RUN curl -sL --retry 3 \
  "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/${SPARK_PACKAGE}.tgz" \
  | gunzip \
  | tar x -C //opt/zeppelin/ \
 && mv /opt/zeppelin/$SPARK_PACKAGE $SPARK_HOME 
