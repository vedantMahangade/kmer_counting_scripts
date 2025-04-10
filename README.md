# KMC-Based Unique K-mer Extraction Pipeline

This script automates the process of generating **unique k-mers** for multiple classes using [KMC](https://github.com/refresh-bio/KMC), a fast and memory-efficient k-mer counting tool. It iterates through a range of k-mer sizes (default: 1 to 100) and identifies class-specific k-mers by subtracting common k-mers across other classes.

---

## Usage

```bash
chmod +x kmc_kmer_pipeline.sh
./kmc_kmer_pipeline.sh <fasta_dir> <output_dir>
```

- `<fasta_dir>`: Path to the directory containing class-specific FASTA files.
- `<output_dir>`: Path where output files and intermediate results will be saved.

> Modify the script directly to set the path to the KMC binary (`kmc_bin`) if not already defined in your environment.

---

## Prerequisites

- [KMC3](https://github.com/refresh-bio/KMC) must be installed and compiled.
- FASTA files for each bacterial class must be named in the format:
  ```
  <ClassName>_16s_v3v4.fasta
  ```

---

## Bacterial Classes Processed

The script is configured to process the following bacterial groups:

- Bacillus
- Streptomyces
- Pseudomonas
- Lactobacillus
- Staphylococcus
- Vibrio
- Chloroplast
- Escherichia-Shigella
- Paenibacillus
- Streptococcus

> You can customize the `classes` array in the script to use different groups or categories (e.g., promoters vs. non-promoters).

---

## Output

For each `k-mer` size and class:

- Unique k-mers are extracted and stored in:
  ```
  <output_dir>/unique_<class>_kmers.txt
  ```
- Intermediate KMC databases and temporary files are saved per class and k-size.

---

## Cleanup

Temporary directories used by KMC are automatically removed at the end of each `k-mer` size iteration.

---

## Example

```bash
./kmc_kmer_pipeline.sh ./input_fastas ./kmc_output
```

Generates unique k-mers for each class between k-mer sizes 1 and 100 using the FASTA files in `./input_fastas`.

---

## Notes

- Script assumes 16S V3V4 regions as inputs. Adjust FASTA naming and preprocessing if using different gene regions.
- Heavy disk I/O and memory usage may occur depending on the size of your FASTA files and `k-mer` sizes.

