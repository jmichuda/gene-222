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

It generated the CSV [here](./annotated_variants.csv)`
