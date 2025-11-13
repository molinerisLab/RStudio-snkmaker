# Snakemaker Examples

This directory contains example Snakemake workflows that demonstrate what the Snakemaker add-in can help you create.

## variant_calling_workflow.smk

A complete variant calling pipeline demonstrating:

1. **Read Alignment** - BWA MEM alignment of paired-end reads
2. **BAM Processing** - SAM to BAM conversion, sorting, and duplicate marking
3. **Variant Calling** - Three alternative callers shown:
   - GATK HaplotypeCaller (germline variants)
   - bcftools (simple variant calling)
   - FreeBayes (Bayesian variant detection)
4. **Variant Filtering** - GATK hard filtering
5. **Variant Annotation** - bcftools annotation
6. **Quality Control** - Variant statistics and MultiQC report

## How These Examples Relate to Snakemaker

Each rule in these example files shows what Snakemaker generates from your command history:

```
Your Command (in terminal):
  bwa mem -t 8 reference.fa sample_R1.fastq sample_R2.fastq > aligned.sam

↓ (Snakemaker converts to) ↓

Snakemake Rule:
  rule align_reads:
      input:
          ref=REFERENCE,
          r1="fastq/{sample}_R1.fastq",
          r2="fastq/{sample}_R2.fastq"
      output:
          "aligned/{sample}.sam"
      log:
          "logs/align/{sample}.log"
      threads: 8
      shell:
          "bwa mem -t {threads} {input.ref} {input.r1} {input.r2} > {output} 2> {log}"
```

## Using These Examples

1. **Install the Snakemaker add-in** in RStudio
2. **Run variant calling commands** manually to test your workflow
3. **Use Snakemaker** to convert those commands into rules like these
4. **Combine the rules** into a complete Snakefile
5. **Run the workflow**: `snakemake --cores 8`

## Note

These are **example outputs** showing what Snakemaker helps you create. The actual variant calling is performed by external tools (GATK, bcftools, FreeBayes, etc.) that you must install separately.
