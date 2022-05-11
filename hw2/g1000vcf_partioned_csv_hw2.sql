CREATE EXTERNAL TABLE g1000vcf_partioned_csv_hw2(
  `chrm` string COMMENT 'from deserializer', 
  `start_position` bigint COMMENT 'from deserializer', 
  `end_position` bigint COMMENT 'from deserializer', 
  `reference_bases` string COMMENT 'from deserializer', 
  `alternate_bases` string COMMENT 'from deserializer', 
  `rsid` string COMMENT 'from deserializer', 
  `qual` string COMMENT 'from deserializer', 
  `filter` string COMMENT 'from deserializer', 
  `info` string COMMENT 'from deserializer')
PARTITIONED BY ( 
  `chromosome` string)
ROW FORMAT SERDE 
  'org.apache.hadoop.hive.serde2.OpenCSVSerde' 
WITH SERDEPROPERTIES ( 
  'separatorChar'=',') 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://g1000vcf/csv-data/'
TBLPROPERTIES (
  'classification'='csv', 
  'skip.header.line.count'='1');
