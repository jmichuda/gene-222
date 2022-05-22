#!/bin/bash

export READS=20000
export BWA_THREADS=2

if [ ! -f ./ERR194159_1.fastq.gz]
then
    echo "Downloading file from GCS, this will take a while"
    gsutil cp gs://genomics-public-data/platinum-genomes/fastq/ERR194159_1.fastq.gz ./
else
    echo "File found. Skipping download"
fi

if [ ! -f ./ERR194159_2.fastq.gz]
then
    echo "Downloading file from GCS, this will take a while"
    gsutil cp gs://genomics-public-data/platinum-genomes/fastq/ERR194159_2.fastq.gz ./
else
    echo "File found. Skipping download"
fi

echo "Downsampling FASTQ file"
seqtk sample -s100 ERR194159_1.fastq.gz $READS > downsampled_file1.fastq
seqtk sample -s100 ERR194159_2.fastq.gz $READS > downsampled_file2.fastq

gsutil cp downsampled_file1.fastq  gs://gene222-final-project/fastq_$READS_$BWA_THREADS/downsampled_file1.fastq
gsutil cp downsampled_file2.fastq  gs://gene222-final-project/fastq_$READS_$BWA_THREADS/downsampled_file2.fastq

# Enable exit on error
set -o errexit

# Step 1:
dsub --provider google-v2 --project gene222-final-project --zones "us-central1-*" --logging gs://gene222-final-project/Logging_$READS --input-recursive FASTQ_INPUT=gs://gene222-final-project/fastq_$READS_$BWA_THREADS --input-recursive REFERENCE=gs://gene222_datasets_references/REFERENCE_GRCH37 --output OUTPUT_FILE=gs://gene222-final-project/output/OUTPUT_BWA_$READS_$BWA_THREADS/* --machine-type n1-standard-$BWA_THREADS --image pegi3s/bwa --command 'bwa mem -t 4 -M -R "@RG\\tID:0\\tLB:Library\\tPL:Illumina\\tSM:" "${REFERENCE}"/GRCh37-lite.fa "${FASTQ_INPUT}"/downsampled_file1.fastq "${FASTQ_INPUT}"/downsampled_file2.fastq > "$(dirname ${OUTPUT_FILE})"/bwa-sam.sam' --wait


#Step 2 - convert the SAM file to a BAM file:
dsub --provider google-v2 --project gene222-final-project  --zones "us-central1-*" --logging gs://gene222-final-project/Logging_$READS --input SAM_INPUT=gs://gene222-final-project/output/OUTPUT_BWA_$READS_$BWA_THREADS/bwa-sam.sam --output OUTPUT_FILE=gs://gene222-final-project/output/OUTPUT_BWA_$READS_$BWA_THREADS/* --machine-type n1-standard-$BWA_THREADS --image broadinstitute/gatk --boot-disk-size 20 --command 'samtools view -bS "${SAM_INPUT}" > "$(dirname ${OUTPUT_FILE})"/output_bwa.bam' --wait

#Step 3 - BAM file needs to be reheadered:
dsub --provider google-v2 --project gene222-final-project  --zones "us-central1-*" --logging gs://gene222-final-project/Logging_$READS --input BAM_INPUT=gs://gene222-final-project/output/OUTPUT_BWA_$READS_$BWA_THREADS/output_bwa.bam --output OUTPUT_FILE=gs://gene222-final-project/output/OUTPUT_BWA_$READS_$BWA_THREADS/* --machine-type n1-standard-2 --image broadinstitute/gatk --boot-disk-size 20 --command 'samtools view -H "${BAM_INPUT}" | sed -e 's/SM/SM:ERR194159/' | samtools reheader - "${BAM_INPUT}" > "$(dirname ${OUTPUT_FILE})"/output_bwa_reheadered.bam' --wait

#Step 4 - SortSam:
dsub --provider google-v2 --project gene222-final-project  --zones "us-central1-*" --logging gs://gene222-final-project/Logging_$READS --input BAM_INPUT=gs://gene222-final-project/output/OUTPUT_BWA_$READS_$BWA_THREADS/output_bwa_reheadered.bam --output OUTPUT_FILE=gs://gene222-final-project/output/OUTPUT_BWA_$READS_$BWA_THREADS/* --machine-type n1-standard-2 --image broadinstitute/gatk --boot-disk-size 20 --command 'gatk SortSam INPUT="${BAM_INPUT}" OUTPUT="$(dirname ${OUTPUT_FILE})"/output_picard_sorted.bam SORT_ORDER="queryname" CREATE_MD5_FILE=true CREATE_INDEX=true TMP_DIR=`pwd`/tmp' --wait

#Step 5 - MarkDuplicates:
dsub --provider google-v2 --project gene222-final-project  --zones "us-central1-*" --logging gs://gene222-final-project/Logging_$READS --input BAM_INPUT=gs://gene222-final-project/output/OUTPUT_BWA_$READS_$BWA_THREADS/output_picard_sorted.bam --output OUTPUT_FILE=gs://gene222-final-project/output/OUTPUT_BWA_$READS_$BWA_THREADS/* --machine-type n1-standard-2 --image broadinstitute/gatk --boot-disk-size 20 --command 'gatk MarkDuplicates -I "${BAM_INPUT}" -M "$(dirname ${OUTPUT_FILE})"/metrics_md -O "$(dirname ${OUTPUT_FILE})"/output_dedup_bam.bam --VALIDATION_STRINGENCY SILENT --OPTICAL_DUPLICATE_PIXEL_DISTANCE 2500 --TMP_DIR `pwd`/tmp' --wait

#Step 6 - dedup bam:
dsub --provider google-v2 --project gene222-final-project  --zones "us-central1-*" --logging gs://gene222-final-project/Logging_$READS --input BAM_INPUT=gs://gene222-final-project/output/OUTPUT_BWA_$READS_$BWA_THREADS/output_dedup_bam.bam --output OUTPUT_FILE=gs://gene222-final-project/output/OUTPUT_BWA_$READS_$BWA_THREADS/* --machine-type n1-standard-2 --image broadinstitute/gatk --boot-disk-size 20 --command 'gatk SortSam -INPUT "${BAM_INPUT}" -OUTPUT "$(dirname ${OUTPUT_FILE})"/output_dedup_sorted.bam -SORT_ORDER coordinate -CREATE_MD5_FILE true -TMP_DIR `pwd`/tmp -CREATE_INDEX true' --wait

#Step 7 - BaseRecalibrator:
dsub --provider google-v2 --project gene222-final-project  --zones "us-central1-*" --logging gs://gene222-final-project/Logging_$READS --input BAM_INPUT=gs://gene222-final-project/output/OUTPUT_BWA_$READS_$BWA_THREADS/output_dedup_sorted.bam --input-recursive REFERENCE_GR=gs://gene222_datasets_references/REFERENCE_GRCH37 --input-recursive REFERENCE_DB=gs://gene222_datasets_references/REFERENCE_DBSNP --input-recursive REFERENCE_MI=gs://gene222_datasets_references/REFERENCE_MILLS --output OUTPUT_FILE=gs://gene222-final-project/output/OUTPUT_BWA_$READS_$BWA_THREADS/* --machine-type n1-standard-2 --image broadinstitute/gatk --boot-disk-size 20 --command 'gatk BaseRecalibrator -I "${BAM_INPUT}" -R "${REFERENCE_GR}"/GRCh37-lite.fa --known-sites "${REFERENCE_DB}"/dbSNP.b150.GRCh37p13.All_20170710.vcf.gz --known-sites "${REFERENCE_MI}"/Mills_and_1000G_gold_standard.indels.b37.vcf -O "$(dirname ${OUTPUT_FILE})"/recal_data.table' --wait

#Step 8 - ApplyBQSR:
dsub --provider google-v2 --project gene222-final-project  --zones "us-central1-*" --logging gs://gene222-final-project/Logging_$READS --input BAM_INPUT=gs://gene222-final-project/output/OUTPUT_BWA_$READS_$BWA_THREADS/output_dedup_sorted.bam --input RECAL=gs://gene222-final-project/output/OUTPUT_BWA_$READS_$BWA_THREADS/recal_data.table --input-recursive REFERENCE_GR=gs://gene222_datasets_references/REFERENCE_GRCH37 --output OUTPUT_FILE=gs://gene222-final-project/output/OUTPUT_BWA_$READS_$BWA_THREADS/* --machine-type n1-standard-2 --image broadinstitute/gatk --boot-disk-size 20 --command 'gatk ApplyBQSR -I "${BAM_INPUT}" -R "${REFERENCE_GR}"/GRCh37-lite.fa --bqsr-recal-file "${RECAL}" -O "$(dirname ${OUTPUT_FILE})"/output_recal_bam.bam' --wait

#Step 9 - HaplotypeCaller:
dsub --provider google-v2 --project gene222-final-project  --zones "us-central1-*" --logging gs://gene222-final-project/Logging_$READS --input-recursive BAM_INPUT=gs://gene222-final-project/output/OUTPUT_BWA_$READS_$BWA_THREADS --input-recursive REFERENCE_GR=gs://gene222_datasets_references/REFERENCE_GRCH37 --output OUTPUT_FILE=gs://gene222-final-project/output/OUTPUT_BWA_$READS_$BWA_THREADS/* --machine-type n1-standard-2 --image broadinstitute/gatk --boot-disk-size 20 --command 'gatk HaplotypeCaller -R "${REFERENCE_GR}"/GRCh37-lite.fa -I "${BAM_INPUT}"/output_recal_bam.bam -O "$(dirname ${OUTPUT_FILE})"/output_vcf.vcf' --wait

