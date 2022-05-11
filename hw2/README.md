# HW2

## Q1
After running the cromwell pipeline and uploading the results into bigquery, I used the following query to perform the annotation:
```
SELECT 
  V.reference_name,
  V.start_position,
  V.end_position,
  V.reference_bases,
  V.alternate_bases,
  V.ID,
  V.QUAL,
  A2.exonCount,
  A2.cdsStart,
  A2.cdsEnd,
  A1.genename,
  A1.Ensembl_geneid
FROM `gene222-hw2-349119.hw2.Mutect2_chr17` as V
JOIN (SELECT * FROM `gbsc-gcp-class-gene222-spr22.hw2.hg38_UCSC_RefGene`) as A2
ON
  V.start_position<=A2.end_position
  AND A2.start_position<=V.end_position
  AND V.reference_name = A2.reference_name
JOIN (SELECT * from `gbsc-gcp-class-gene222-spr22.hw2.hg38_dbNSFP_35a`) as A1
ON
  V.start_position=A1.start_position
  AND V.end_position=A1.end_position
  AND V.alternate_bases=A1.alternate_bases
  AND V.reference_name = A1.reference_name;
```

It generated the CSV [here](./annotated_variants.tsv)

## Q2 


| Query | Query |  Runtime and Data Scanned | Cost |
| - | - | -| -| 
| A | SELECT * FROM "test1000vcf_oneCSV_hw2" WHERE rsid='rs9939609'| Run time: 3.13 sec Data scanned: 12.68 GB | 6.3 cents |
| B | SELECT * FROM "g1000vcf_partioned_csv_hw2" WHERE rsid='rs9939609'| Run time: 4.59 sec Data scanned: 12.68 GB | 6.3 cents |
| C | SELECT * FROM "g1000vcf_parquet_hw2" WHERE rsid='rs9939609'| Run time: 3.689 sec Data scanned: 784.69 MB | .3 cents |
| D | SELECT * FROM "test1000vcf_oneCSV_hw2" WHERE chrm='16' and start_position=53820526| Run time: 2.415 sec Data scanned: 12.68 GB | 6 cents | 
| E | SELECT * FROM "g1000vcf_partioned_csv_hw2" WHERE chromosome='16' AND start_position=53820526; | Run time: 2.27 sec Data scanned: 413.20 MB | .2 cents|
| F | SELECT * FROM "g1000vcf_parquet_hw2" WHERE chromosome='16' AND start_position=53820526;| Run time: 2.409 sec Data scanned: 122.03 MB | .06 cents| 

## Q3
The first cloud function to unload the VCF into BigQuery is available [here](./import_vcf.py)

The second cloud function to annotate the VCF once it is triggered by pubsub is [here](./annotate_vcf.py)

The final annotated output is available [here](./1000g_APC-apc-gene-annotations.txt)

And the requirements.txt for both cloud functions is [here](./requirements.txt)




