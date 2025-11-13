# Variant Calling with Snakemaker

## Understanding Snakemaker's Role

**Important**: This repository (RStudio-snkmaker) does NOT contain variant calling code. Instead, it's a tool that helps you create Snakemake workflow rules from your command history.

## What is Snakemaker?

Snakemaker is an RStudio add-in that:
- Monitors your R and Bash command history
- Uses Large Language Models (LLMs) to convert commands into Snakemake rules
- Helps automate the creation of reproducible bioinformatics workflows

## How Variant Calling Would Work

If you want to create a variant calling workflow using Snakemaker, you would:

### 1. Run Your Variant Calling Commands

First, execute your variant calling commands in the RStudio terminal or R console. For example:

**Bash commands:**
```bash
# Align reads with BWA
bwa mem -t 8 reference.fa sample_R1.fastq sample_R2.fastq > aligned.sam

# Convert SAM to BAM
samtools view -b aligned.sam > aligned.bam

# Sort BAM file
samtools sort aligned.bam -o aligned.sorted.bam

# Mark duplicates with Picard
picard MarkDuplicates I=aligned.sorted.bam O=marked.bam M=metrics.txt

# Call variants with GATK
gatk HaplotypeCaller -R reference.fa -I marked.bam -O variants.vcf

# Or with bcftools
bcftools mpileup -f reference.fa marked.bam | bcftools call -mv -o variants.vcf

# Or with FreeBayes
freebayes -f reference.fa marked.bam > variants.vcf
```

**R commands (using Bioconductor):**
```r
# Using VariantAnnotation
library(VariantAnnotation)
vcf <- readVcf("variants.vcf", "hg38")
filtered_vcf <- filterVcf(vcf, "hg38", "filtered.vcf")
```

### 2. Use Snakemaker to Generate Rules

Once you've run these commands:
1. Open the Snakemaker add-in in RStudio
2. Select the commands from your history (R or Bash)
3. Click "Generate rule" to create a Snakemake rule

### 3. Snakemaker Will Generate Something Like:

```python
rule variant_calling:
    input:
        bam="aligned.sorted.bam",
        ref="reference.fa"
    output:
        vcf="variants.vcf"
    log:
        "logs/variant_calling.log"
    shell:
        "gatk HaplotypeCaller -R {input.ref} -I {input.bam} -O {output.vcf} 2> {log}"
```

## Common Variant Calling Tools

While Snakemaker doesn't perform variant calling itself, it helps you create workflows for these tools:

### DNA Variant Callers
- **GATK HaplotypeCaller** - Gold standard for germline variants
- **GATK Mutect2** - Somatic variant calling
- **FreeBayes** - Bayesian genetic variant detector
- **bcftools call** - Simple variant caller from SAMtools
- **VarScan** - Variant detection in massively parallel sequencing
- **Strelka2** - Fast and accurate variant calling

### RNA Variant Callers
- **GATK RNA-seq Best Practices** - Variant calling from RNA-seq
- **BCFtools** - Can be used with RNA-seq data

### Structural Variant Callers
- **Manta** - Structural variant and indel caller
- **DELLY** - Integrated structural variant prediction
- **LUMPY** - General probabilistic framework for SV discovery

## Example Workflow

Here's how you might use Snakemaker to build a complete variant calling pipeline:

1. **Run commands manually** to test your workflow
2. **Generate rules** for each step using Snakemaker:
   - Alignment (BWA, STAR)
   - BAM processing (sorting, marking duplicates)
   - Variant calling (GATK, FreeBayes, etc.)
   - Variant filtering and annotation

3. **Combine rules** into a complete Snakefile
4. **Run the workflow** with Snakemake: `snakemake --cores 8`

## Where Variant Calling Code Lives

In the context of this tool:
- **Snakemaker repository**: Contains the add-in code for generating rules (you are here)
- **Your Snakefile**: Will contain the actual variant calling commands as Snakemake rules
- **Variant calling tools**: Installed separately (GATK, bcftools, FreeBayes, etc.)

## Finding Variant Calling in Snakemaker's Code

If you're looking for where variant calling would be **mentioned** in this codebase:

1. **addin.R (lines 48-124)**: The `generate_rule()` function that converts any command (including variant calling) into Snakemake rules
2. **server.R (lines 320-340)**: Handles the "Generate rule" button that processes your variant calling commands
3. The LLM prompt (lines 71-89 in addin.R) that instructs the AI how to convert your variant calling command into a rule

## Summary

**This repository does not contain variant calling code.** It's a tool that helps you:
- Record your variant calling commands from history
- Convert them into reusable Snakemake rules
- Build reproducible bioinformatics workflows

The actual variant calling is done by external tools (GATK, bcftools, FreeBayes, etc.) that you run in your terminal or R console, and Snakemaker helps you organize these commands into a workflow.
