#!/bin/bash
# ============================================================
# PLINK GWAS Analysis Pipeline
# Author: dhassan24
# Description: Quality control, LD pruning, IBD, and association
#              analysis using PLINK v1.9 on the HapMap1 dataset
# ============================================================
 
set -e  # Exit immediately if any command fails
 
# ---- Configuration ----
PLINK=./plink                  # Path to PLINK binary
INPUT=hapmap1                  # Input file prefix (.ped/.map or .bed/.bim/.fam)
OUT=hapmap1_plink_results      # Output prefix for most results
PRUNED=hapmap1_plink_1000_pruned  # Output prefix for pruned dataset
 
# ============================================================
# STEP 1: Convert PED/MAP to binary BED format
# ============================================================
echo ">>> Step 1: Converting to binary format..."
$PLINK \
    --file $INPUT \
    --make-bed \
    --out $INPUT
 
# ============================================================
# STEP 2: Calculate Allele Frequencies
# ============================================================
echo ">>> Step 2: Calculating allele frequencies..."
$PLINK \
    --bfile $INPUT \
    --freq \
    --out $OUT
 
# ============================================================
# STEP 3: Quality Control Filtering + LD Pruning
#   --maf 0.01       Remove variants with minor allele freq < 1%
#   --geno 0.02      Remove variants with >2% missing genotypes
#   --mind 0.02      Remove samples with >2% missing genotypes
#   --hwe 1e-6       Remove variants failing Hardy-Weinberg test
#   --indep-pairwise 50 5 0.2   LD pruning (window=50, step=5, r2=0.2)
# ============================================================
echo ">>> Step 3: QC filtering and LD pruning..."
$PLINK \
    --bfile $INPUT \
    --maf 0.01 \
    --geno 0.02 \
    --mind 0.02 \
    --hwe 1e-6 \
    --indep-pairwise 50 5 0.2 \
    --out $OUT
 
# ============================================================
# STEP 4: Heterozygosity Check
#   Uses pruned SNP list to check for samples with unusually
#   high or low heterozygosity (possible contamination or inbreeding)
# ============================================================
echo ">>> Step 4: Checking heterozygosity..."
$PLINK \
    --bfile $INPUT \
    --extract ${OUT}.prune.in \
    --het \
    --out $OUT
 
# ============================================================
# STEP 5: IBD / Relatedness Check
#   Calculates pairwise identity-by-descent to detect
#   cryptic relatedness between samples
# ============================================================
echo ">>> Step 5: Calculating IBD (relatedness)..."
$PLINK \
    --bfile $INPUT \
    --extract ${OUT}.prune.in \
    --genome \
    --out $OUT
 
# ============================================================
# STEP 6: LD Calculation for Chromosome 22
#   Calculates pairwise r2 linkage disequilibrium for chr22
# ============================================================
echo ">>> Step 6: Calculating LD for chromosome 22..."
$PLINK \
    --bfile $INPUT \
    --chr 22 \
    --r2 \
    --out $OUT
 
# ============================================================
# STEP 7: Extract Pruned SNPs and Make New BED File
#   Creates a new binary dataset with only the pruned SNPs
# ============================================================
echo ">>> Step 7: Extracting pruned SNPs into new BED file..."
$PLINK \
    --bfile $INPUT \
    --extract ${OUT}.prune.in \
    --make-bed \
    --out $PRUNED
 
# ============================================================
# STEP 8: Convert Pruned BED back to PED/MAP
# ============================================================
echo ">>> Step 8: Converting pruned BED to PED/MAP format..."
$PLINK \
    --bfile $PRUNED \
    --recode \
    --out $PRUNED
 
# ============================================================
# STEP 9: Case/Control Association Analysis
#   Chi-squared test for each SNP
#   Output fields: CHR, SNP, BP, A1, F_A, F_U, A2, CHISQ, P, OR
#     F_A = frequency of minor allele in cases
#     F_U = frequency of minor allele in controls
#     CHISQ = chi-squared statistic (1 df)
#     P = asymptotic p-value
#     OR = odds ratio
# ============================================================
echo ">>> Step 9: Running case/control association analysis..."
$PLINK \
    --bfile $INPUT \
    --assoc \
    --out as1
 
echo ""
echo "============================================================"
echo "Analysis complete! Output files:"
echo "  Allele frequencies : ${OUT}.frq"
echo "  Pruned SNP list    : ${OUT}.prune.in / .prune.out"
echo "  Heterozygosity     : ${OUT}.het"
echo "  IBD/Relatedness    : ${OUT}.genome"
echo "  LD (chr22)         : ${OUT}.ld"
echo "  Pruned dataset     : ${PRUNED}.bed/bim/fam + .ped/map"
echo "  Association results: as1.assoc"
echo "============================================================"
