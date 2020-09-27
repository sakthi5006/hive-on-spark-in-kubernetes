#!/bin/sh

export MY_NAMESPACE=my-namespace
export tempDirectory=~/temp/spark;
mkdir -p ${tempDirectory};

cd ${tempDirectory};

# download spark tar file from google drive.
# https://drive.google.com/file/d/1_hpk6p_mgQ3gCA3ZV_cSUuEdt_yZlAaX/view?usp=sharing
SPARK_FILE_NAME=spark-3.0.0-bin-custom-spark
fileId=1_hpk6p_mgQ3gCA3ZV_cSUuEdt_yZlAaX
fileName=${SPARK_FILE_NAME}.tgz

curl -sc /tmp/cookie "https://drive.google.com/uc?export=download&id=${fileId}" > /dev/null
code="$(awk '/_warning_/ {print $NF}' /tmp/cookie)"
curl -Lb /tmp/cookie "https://drive.google.com/uc?export=download&confirm=${code}&id=${fileId}" -o ${fileName}



# download spark thrift server jar file from google drive.
# https://drive.google.com/file/d/1U8-Tlp2783psK-AR_m1TC6CFA4eSeiDL/view?usp=sharing
SPARK_THRIFT_SERVER_FILE_NAME=spark-thrift-server-1.0.0-SNAPSHOT-spark-job
fileId=1U8-Tlp2783psK-AR_m1TC6CFA4eSeiDL
fileName=${SPARK_THRIFT_SERVER_FILE_NAME}.jar

curl -sc /tmp/cookie "https://drive.google.com/uc?export=download&id=${fileId}" > /dev/null
code="$(awk '/_warning_/ {print $NF}' /tmp/cookie)"
curl -Lb /tmp/cookie "https://drive.google.com/uc?export=download&confirm=${code}&id=${fileId}" -o ${fileName}


# download delta core jar file from google drive.
# https://drive.google.com/file/d/1WCzSnwXEYc3Q8VkvvJ5nuidq9yGYDIsa/view?usp=sharing
DELTA_CORE_FILE_NAME=delta-core-shaded-assembly_2.12-0.1.0
fileId=1WCzSnwXEYc3Q8VkvvJ5nuidq9yGYDIsa
fileName=${DELTA_CORE_FILE_NAME}.jar

curl -sc /tmp/cookie "https://drive.google.com/uc?export=download&id=${fileId}" > /dev/null
code="$(awk '/_warning_/ {print $NF}' /tmp/cookie)"
curl -Lb /tmp/cookie "https://drive.google.com/uc?export=download&confirm=${code}&id=${fileId}" -o ${fileName}



# download hive delta file from google drive.
# https://drive.google.com/file/d/1PcSraIo9Fc5sKIuDmDfFytcE8i5DcgN_/view?usp=sharing
HIVE_DELTA_FILE_NAME=hive-delta_2.12-0.1.0
fileId=1PcSraIo9Fc5sKIuDmDfFytcE8i5DcgN_
fileName=${HIVE_DELTA_FILE_NAME}.jar

curl -sc /tmp/cookie "https://drive.google.com/uc?export=download&id=${fileId}" > /dev/null
code="$(awk '/_warning_/ {print $NF}' /tmp/cookie)"
curl -Lb /tmp/cookie "https://drive.google.com/uc?export=download&confirm=${code}&id=${fileId}" -o ${fileName}

# install spark.
mkdir -p spark;
tar zxvf ${SPARK_FILE_NAME}.tgz -C spark/;
cd spark/;
cp -R ${SPARK_FILE_NAME}/* .;
rm -rf ${SPARK_FILE_NAME};

# set spark home.
SPARK_HOME=${tempDirectory}/spark;
PATH=$PATH:$SPARK_HOME/bin;


cd ${tempDirectory};

# submit spark thrift server job.
MASTER=k8s://{{ masterUrl }};
NAMESPACE=${MY_NAMESPACE};
ENDPOINT=https://s3-endpoint;
BUCKET=mykidong;
HIVE_METASTORE=metastore:9083;

spark-submit \
--master $MASTER \
--deploy-mode cluster \
--name spark-thrift-server \
--class io.mykidong.hive.SparkThriftServerRunner \
--packages com.amazonaws:aws-java-sdk-s3:1.11.375,org.apache.hadoop:hadoop-aws:3.2.0 \
--conf spark.kubernetes.driver.volumes.persistentVolumeClaim.checkpointpvc.mount.path=/checkpoint \
--conf spark.kubernetes.driver.volumes.persistentVolumeClaim.checkpointpvc.mount.subPath=checkpoint \
--conf spark.kubernetes.driver.volumes.persistentVolumeClaim.checkpointpvc.mount.readOnly=false \
--conf spark.kubernetes.driver.volumes.persistentVolumeClaim.checkpointpvc.options.claimName=spark-driver-pvc \
--conf spark.kubernetes.executor.volumes.persistentVolumeClaim.checkpointpvc.mount.path=/checkpoint \
--conf spark.kubernetes.executor.volumes.persistentVolumeClaim.checkpointpvc.mount.subPath=checkpoint \
--conf spark.kubernetes.executor.volumes.persistentVolumeClaim.checkpointpvc.mount.readOnly=false \
--conf spark.kubernetes.executor.volumes.persistentVolumeClaim.checkpointpvc.options.claimName=spark-exec-pvc \
--conf spark.kubernetes.driver.volumes.persistentVolumeClaim.spark-local-dir-localdirpvc.mount.path=/localdir \
--conf spark.kubernetes.driver.volumes.persistentVolumeClaim.spark-local-dir-localdirpvc.mount.readOnly=false \
--conf spark.kubernetes.driver.volumes.persistentVolumeClaim.spark-local-dir-localdirpvc.options.claimName=spark-driver-localdir-pvc \
--conf spark.kubernetes.executor.volumes.persistentVolumeClaim.spark-local-dir-localdirpvc.mount.path=/localdir \
--conf spark.kubernetes.executor.volumes.persistentVolumeClaim.spark-local-dir-localdirpvc.mount.readOnly=false \
--conf spark.kubernetes.executor.volumes.persistentVolumeClaim.spark-local-dir-localdirpvc.options.claimName=spark-exec-localdir-pvc \
--conf spark.kubernetes.file.upload.path=s3a://${BUCKET}/spark-thrift-server \
--conf spark.kubernetes.container.image.pullPolicy=Always \
--conf spark.kubernetes.namespace=$NAMESPACE \
--conf spark.kubernetes.container.image=mykidong/spark:v3.0.0 \
--conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
--conf spark.hadoop.hive.metastore.client.connect.retry.delay=5 \
--conf spark.hadoop.hive.metastore.client.socket.timeout=1800 \
--conf spark.hadoop.hive.metastore.uris=thrift://${HIVE_METASTORE} \
--conf spark.hadoop.hive.server2.enable.doAs=false \
--conf spark.hadoop.hive.server2.thrift.http.port=10002 \
--conf spark.hadoop.hive.server2.thrift.port=10016 \
--conf spark.hadoop.hive.server2.transport.mode=binary \
--conf spark.hadoop.metastore.catalog.default=spark \
--conf spark.hadoop.hive.execution.engine=spark \
--conf spark.hadoop.hive.input.format=io.delta.hive.HiveInputFormat \
--conf spark.hadoop.hive.tez.input.format=io.delta.hive.HiveInputFormat \
--conf spark.sql.warehouse.dir=s3a:/${BUCKET}/apps/spark/warehouse \
--conf spark.hadoop.fs.defaultFS=s3a://${BUCKET} \
--conf spark.hadoop.fs.s3a.access.key=my-access-key \
--conf spark.hadoop.fs.s3a.secret.key=my-secret-key \
--conf spark.hadoop.fs.s3a.connection.ssl.enabled=true \
--conf spark.hadoop.fs.s3a.endpoint=$ENDPOINT \
--conf spark.hadoop.fs.s3a.impl=org.apache.hadoop.fs.s3a.S3AFileSystem \
--conf spark.hadoop.fs.s3a.fast.upload=true \
--conf spark.hadoop.fs.s3a.path.style.access=true \
--conf spark.driver.extraJavaOptions="-Divy.cache.dir=/tmp -Divy.home=/tmp" \
--conf spark.executor.instances=2 \
--conf spark.executor.memory=2G \
--conf spark.executor.cores=1 \
--conf spark.driver.memory=1G \
--conf spark.jars=${tempDirectory}/${DELTA_CORE_FILE_NAME}.jar,${tempDirectory}/${HIVE_DELTA_FILE_NAME}.jar \
file://${tempDirectory}/${SPARK_THRIFT_SERVER_FILE_NAME}.jar \
> /dev/null 2>&1 &

PID=$!
echo "$PID" > pid

# wait for spark thrift server driver being run.
while [[ $(kubectl get pods -n ${MY_NAMESPACE} -l spark-role=driver -o jsonpath={..status.phase}) != *"Running"* ]]; do echo "waiting for driver being run" && sleep 2; done

# kill current spark submit process.
kill $(cat pid);

# create service.
kubectl apply -f spark-thrift-server-service.yaml;

unset SPARK_HOME;






