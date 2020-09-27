package io.mykidong.spark.examples;

import io.mykidong.util.StringUtils;
import joptsimple.OptionParser;
import joptsimple.OptionSet;
import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.Row;
import org.apache.spark.sql.SaveMode;
import org.apache.spark.sql.SparkSession;

import java.util.Arrays;

public class DeltaLakeExample {

    public static void main(String[] args) throws Exception {

        OptionParser parser = new OptionParser();
        parser.accepts("master").withRequiredArg().ofType(String.class);

        OptionSet options = parser.parse(args);

        String master = (String) options.valueOf("master");

        SparkConf sparkConf = new SparkConf().setAppName(DeltaLakeExample.class.getName());
        sparkConf.setMaster(master);

        // delta lake log store for s3.
        sparkConf.set("spark.delta.logStore.class", "org.apache.spark.sql.delta.storage.S3SingleDriverLogStore");

        SparkSession spark = SparkSession
                .builder()
                .config(sparkConf)
                .enableHiveSupport()
                .getOrCreate();


        // read json.
        String json = StringUtils.fileToString("data/test.json");
        String lines[] = json.split("\\r?\\n");
        Dataset<Row> df = spark.read().json(new JavaSparkContext(spark.sparkContext()).parallelize(Arrays.asList(lines)));

        df.show(10);

        // write delta to ceph.
        df.write().format("delta")
                .option("path", "s3a://mykidong/test-delta")
                .mode(SaveMode.Overwrite)
                .save();

        // create delta table.
        spark.sql("CREATE TABLE IF NOT EXISTS test_delta USING DELTA LOCATION 's3a://mykidong/test-delta'");

        // read delta from ceph.
        Dataset<Row> delta = spark.sql("select * from test_delta");

        delta.show(10);

        // create persistent parquet table with external path.
        delta.write().format("parquet")
                .option("path", "s3a://mykidong/test-parquet")
                .mode(SaveMode.Overwrite)
                .saveAsTable("test_parquet");

        // read parquet from table.
        Dataset<Row> parquet = spark.sql("select * from test_parquet");

        parquet.show(10);
    }
}
