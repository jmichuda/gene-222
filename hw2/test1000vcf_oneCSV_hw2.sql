CREATE EXTERNAL TABLE IF NOT EXISTS test1000vcf_oneCSV_hw2 (
  `chrm` string,
  `start_position` int,
  `end_position` int,
  `reference_bases` string,
  `alternate_bases` string,
  `rsID` string,
  `qual` string,
  `filter` string,
  `info` string 
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe'
WITH SERDEPROPERTIES (
  'serialization.format' = ',',
  'field.delim' = ','
) LOCATION 's3://g1000vcf/one-csv'
TBLPROPERTIES ('has_encrypted_data'='false');
