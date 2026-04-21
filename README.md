# PLINK GWAS Pipeline: Haplotype Analysis & LD Studies

A reproducible command-line pipeline for genome-wide association studies (GWAS) using PLINK v1.9, with a focus on haplotype analysis and linkage disequilibrium (LD) studies. Demonstrated using the HapMap1 dataset.

---

## Overview

This pipeline performs end-to-end GWAS quality control and analysis, including:

- Conversion of genotype data to binary PLINK format
- Allele frequency estimation
- Multi-step quality control (missingness, MAF, HWE filtering)
- LD-based SNP pruning
- Heterozygosity and cryptic relatedness (IBD) checks
- Linkage disequilibrium (r²) calculation
- Case/control association analysis

---

## Requirements

- [PLINK v1.9](https://www.cog-genomics.org/plink/1.9/)
- Linux/macOS (64-bit)
- Input data in PED/MAP or BED/BIM/FAM format

---

## Dataset

This pipeline is demonstrated using the **HapMap1** dataset, which includes:
- 89 individuals (HapMap Phase I)
- 83,534 SNPs across all autosomes
- Case/control phenotype assignments

---

## Pipeline Steps

| Step | Description | Key Flags |
|------|-------------|-----------|
| 1 | Convert PED/MAP → BED/BIM/FAM | `--make-bed` |
| 2 | Allele frequency estimation | `--freq` |
| 3 | QC filtering + LD pruning | `--maf`, `--geno`, `--mind`, `--hwe`, `--indep-pairwise` |
| 4 | Heterozygosity check | `--het` |
| 5 | IBD / relatedness check | `--genome` |
| 6 | LD calculation (chr22) | `--r2` |
| 7 | Extract pruned SNPs | `--extract`, `--make-bed` |
| 8 | Convert pruned BED → PED/MAP | `--recode` |
| 9 | Case/control association test | `--assoc` |

---

## Usage

```bash
# Clone the repository
git clone https://github.com/dhassan24/Plink_GWAS.git
cd Plink_GWAS

# Make the script executable
chmod +x plink_gwas_analysis.sh

# Run the full pipeline
./plink_gwas_analysis.sh
```

Edit the configuration variables at the top of `plink_gwas_analysis.sh` to point to your own input files:

```bash
PLINK=./plink       # Path to PLINK binary
INPUT=hapmap1       # Input file prefix
OUT=hapmap1_plink_results
PRUNED=hapmap1_plink_1000_pruned
```

---

## QC Parameters

| Filter | Threshold | Flag |
|--------|-----------|------|
| Minor allele frequency | > 1% | `--maf 0.01` |
| SNP missingness | < 2% | `--geno 0.02` |
| Sample missingness | < 2% | `--mind 0.02` |
| Hardy-Weinberg equilibrium | p > 1×10⁻⁶ | `--hwe 1e-6` |
| LD pruning | r² < 0.2 | `--indep-pairwise 50 5 0.2` |

---

## Output Files

| File | Description |
|------|-------------|
| `.frq` | Allele frequencies |
| `.prune.in / .prune.out` | LD-pruned SNP lists |
| `.het` | Per-sample heterozygosity |
| `.genome` | Pairwise IBD estimates |
| `.ld` | Pairwise r² LD values |
| `.assoc` | Association test results (CHR, SNP, OR, P-value) |

---

## Association Output Fields

The `.assoc` file contains the following columns:

- **CHR** — Chromosome
- **SNP** — SNP identifier
- **BP** — Base pair position
- **A1** — Minor allele
- **F_A / F_U** — Allele frequency in cases / controls
- **A2** — Major allele
- **CHISQ** — Chi-squared statistic (1 df)
- **P** — Asymptotic p-value
- **OR** — Odds ratio

---

## References

- Purcell S, et al. (2007). PLINK: A toolset for whole-genome association and population-based linkage analysis. *American Journal of Human Genetics*, 81(3), 559–575.
- [PLINK v1.9 Documentation](https://www.cog-genomics.org/plink/1.9/)
- [HapMap Project](https://www.genome.gov/10001688/international-hapmap-project)

---

## Author

**Hassan** — [@dhassan24](https://github.com/dhassan24)
