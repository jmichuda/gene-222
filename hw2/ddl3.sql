CREATE TABLE `g1000vcf_parquet_hw2`(
  `chrm` string, 
  `start_position` bigint, 
  `end_position` bigint, 
  `reference_bases` string, 
  `alternate_bases` string, 
  `rsid` string, 
  `qual` string, 
  `filter` string, 
  `info` string)
PARTITIONED BY ( 
  `chromosome` string)
ROW FORMAT SERDE 
  'org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat'
LOCATION
  's3://g1000vcf/parquet-data'
TBLPROPERTIES (
  'classification'='parquet', 
  'transient_lastDdlTime'='1617852408');
