# RiboSeq

This pipeline is designed to process Ribo-seq reads originating from ~28 nt fragments isolated from polysomes. Libraries must have been prepared via the method used by Juntawong et al. (2015) or similar, a common protocol used for ribosome profiling modified from small RNA library preparations. Alternative library preparations (such as Illumina Ribo-seq) may encounter issues using this pipeline.
All sequencing data used with this pipeline is deposited at:
https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE211494

This pipeline has been modified from total RNA and small RNA pipelines developed by Peter Crisp. 

## Workflow

This pipeline takes as input compressed FASTQ files (<sample>.fastq.gz). These reads are trimmed for both quality and adapter content using cutadapt, followed by mapping using bowtie2. Quality control is performed using FASTQC prior to and following trimming. 
  
Following mapping, the data can be processed using the standard RNA-seq pipeline (e.g. generation of bigWigs for viewing on IGV, or read summarisation using featureCounts). 

---
### 01 - Quality control (FASTQC)

```
usage: 01-runner.sh <number of threads>
```
This step is NOT included in this repository, it is found in NGS-pipelines/RNAseqPipe3

---
### 02 - Trimming (cutadapt)


```
usage: 02-runner.sh <number of threads> <minimum length> <maximum error rate>
```

This will trim reads until average quality is phred 20 in a sliding window. It will also look for and remove the adapter sequence CTGTAGGCACCATCAAT, representing the Universal miRNA cloning linker used during library preparation. Reads that lack the adapter will be written to a separate file. A second trimming step is carried out after adapter removal. 
