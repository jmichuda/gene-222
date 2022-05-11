# HW2

## Q1
#### Part A:
I was able to successfully run the cromwell pipeline. It produced the [VCF file here](./output_tumor-filtered.vcf)

#### Part B:

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

#### Part A
I obtained access to the datasets

#### Part B:
The DDL for the following three tables are here:
- [One csv table](./test1000vcf_oneCSV_hw2.sql)
- [Partitioned csv table](./g1000vcf_partioned_csv_hw2.sql)
- [Partitioned parquet table](./g1000vcf_parquet_hw2.sql)


#### Parts C and D

| Query | Query |  Runtime and Data Scanned | Cost |
| - | - | -| -| 
| A | SELECT * FROM "test1000vcf_oneCSV_hw2" WHERE rsid='rs9939609'| Run time: 3.13 sec Data scanned: 12.68 GB | 6.3 cents |
| B | SELECT * FROM "g1000vcf_partioned_csv_hw2" WHERE rsid='rs9939609'| Run time: 4.59 sec Data scanned: 12.68 GB | 6.3 cents |
| C | SELECT * FROM "g1000vcf_parquet_hw2" WHERE rsid='rs9939609'| Run time: 3.689 sec Data scanned: 784.69 MB | .3 cents |
| D | SELECT * FROM "test1000vcf_oneCSV_hw2" WHERE chrm='16' and start_position=53820526| Run time: 2.415 sec Data scanned: 12.68 GB | 6 cents | 
| E | SELECT * FROM "g1000vcf_partioned_csv_hw2" WHERE chromosome='16' AND start_position=53820526; | Run time: 2.27 sec Data scanned: 413.20 MB | .2 cents|
| F | SELECT * FROM "g1000vcf_parquet_hw2" WHERE chromosome='16' AND start_position=53820526;| Run time: 2.409 sec Data scanned: 122.03 MB | .06 cents| 

#### Part D: (calculate the cost of each query) 
It in the table above. It assumes that the cost is $5/tb data scanned as reported on the Athena website.

#### Part E
We can make two inferences. First, the use of parquet format reduces the amount of data scanned in all cases because it’s a more efficient encoding than CSVs. Second, using chromosome as a partition reduces the amount of data that is scanned when we include `chromosome` in the query, but not when we are querying for `rsid`.



## Q3

#### Part A: 
The first cloud function to unload the VCF into BigQuery is available [here](./import_vcf.py)

The second cloud function to annotate the VCF once it is triggered by pubsub is [here](./annotate_vcf.py)

The final annotated output is available [here](./1000g_APC-apc-gene-annotations.txt)

And the requirements.txt for both cloud functions is [here](./requirements.txt)

#### Part B:
The main drawback is that we cloud functions are supposed to be fast acting. By default they timeout after 9 minutes. Also, while cloud functions supports many environments, it does not offer the same flexibility to create an environment as Docker does.

#### Part C:
If we have a function that is long-running, we should decompose it into shorter, more modular steps and make each of the steps its own cloud function. This also allows us to optimize each step's hardware requirements individually, potentially saving costs. If we have a process that has a complicated environment, we should consider building a containerized workflow and using a PubSub to launch the workflow on GKE or some other source of compute. 

