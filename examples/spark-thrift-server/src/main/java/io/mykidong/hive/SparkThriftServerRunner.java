package io.mykidong.hive;

public class SparkThriftServerRunner {

    public static void main(String[] args) {
        org.apache.spark.sql.hive.thriftserver.HiveThriftServer2.main(args);
    }
}
