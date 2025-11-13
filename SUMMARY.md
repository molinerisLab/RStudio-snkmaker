# Summary: Finding Variant Calling Code in RStudio-snkmaker

## Your Question
You were looking for "a part of the code that does variant calling" in this repository.

## What I Found

**This repository does NOT contain variant calling code.** 

Instead, RStudio-snkmaker is a tool that:
- Monitors your R and Bash command history in RStudio
- Uses AI (Large Language Models) to convert those commands into Snakemake workflow rules
- Helps you build reproducible bioinformatics pipelines

## Where Variant Calling Happens

Variant calling happens in **your commands**, not in Snakemaker's code. Here's the workflow:

1. **You run variant calling commands** (e.g., in RStudio terminal):
   ```bash
   gatk HaplotypeCaller -R reference.fa -I sample.bam -O variants.vcf
   ```

2. **Snakemaker captures this from your history**

3. **Snakemaker converts it to a Snakemake rule**:
   ```python
   rule call_variants:
       input:
           ref="reference.fa",
           bam="sample.bam"
       output:
           "variants.vcf"
       shell:
           "gatk HaplotypeCaller -R {input.ref} -I {input.bam} -O {output}"
   ```

## How Snakemaker Works Internally

The relevant code in this repository:

### 1. addin.R (lines 48-124)
```r
generate_rule <- function(input_text, model) {
  # Takes your command and sends it to an LLM
  # The LLM converts it to a Snakemake rule
  # Returns the generated rule
}
```

This function:
- Takes your variant calling command as input
- Sends it to an AI model (GROQ, OpenAI, or NVIDIA)
- The AI converts it to a Snakemake rule
- Returns the rule to be inserted in your document

### 2. server.R (lines 320-340)
```r
observeEvent(input$insert, {
  # When you click "Generate rule"
  # Triggers the rule generation process
})
```

This handles the "Generate rule" button that processes your selected command.

### 3. The LLM Prompt (addin.R, lines 71-89)
```r
content = paste0("
Convert the following command into a valid Snakemake rule.
Automatically deduce whether the command is written in R or Bash.
...")
```

This is the instruction sent to the AI that tells it how to convert your variant calling commands into Snakemake rules.

## What I Created for You

Since variant calling workflows are a common use case, I created:

1. **VARIANT_CALLING_GUIDE.md** - Complete guide on using Snakemaker for variant calling
2. **examples/variant_calling_workflow.smk** - Full example workflow with:
   - BWA alignment
   - SAMtools BAM processing
   - GATK variant calling
   - bcftools variant calling
   - FreeBayes variant calling
   - Variant filtering and annotation
   - QC with MultiQC

3. **examples/README.md** - Explanation of how these examples work with Snakemaker

## Key Takeaway

**Snakemaker doesn't do variant calling.** It's a workflow automation tool that:
- Watches what variant calling commands you run
- Helps convert them into reproducible Snakemake workflows
- Makes it easy to rerun your analysis on new data

The actual variant calling is done by tools like:
- GATK
- bcftools
- FreeBayes
- Mutect2
- VarScan
- etc.

These tools are separate software that you install and run, and Snakemaker helps organize them into automated workflows.
