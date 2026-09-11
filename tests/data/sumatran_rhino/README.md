# Sumatran rhinoceros data set

Tiny test data set from GenErode pipeline (https://github.com/NBISweden/GenErode).

## Test data reference genome

`sumatran_rhino.fasta` is a reference fasta file with a short scaffold from the Sumatran rhinoceros reference genome (accession number GCA_014189135.1).

## Test data for whole-genome resequencing data processing and analyses

`S03_14_L7.BH252YCCXY.R1.fastq.gz` and `S03_14_L7.BH252YCCXY.R1.fastq.gz` are fastq files with Illumina paired-end reads of a modern Sumatran rhinoceros sample (accession number ERR3677656).
    
> Fastq files were generated as follows: reads from whole genome re-sequencing of the modern sample were mapped to the full Sumatran rhinoceros reference genome with bwa mem and default settings. The test scaffold was extracted from the BAM files and converted to fastq format (containing only mapped paired-end reads). 
