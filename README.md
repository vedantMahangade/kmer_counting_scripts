# KMC-Based Unique K-mer Extraction Pipeline

This script automates the process of generating **unique k-mers** for multiple classes using [KMC](https://github.com/refresh-bio/KMC), a fast and memory-efficient k-mer counting tool. It iterates through a range of k-mer sizes (default: 1 to 100) and identifies class-specific k-mers by subtracting common k-mers across other classes.

---

## Usage

```bash
chmod +x kmc_kmer_pipeline.sh
./kmc_kmer_pipeline.sh <fasta_dir> <class_file> <output_dir>
```

- `<fasta_dir>`: Path to the directory containing class-specific FASTA files.
- `<class_file>`: Text file containing list of classes.
- `<output_dir>`: Path where output files and intermediate results will be saved.

> Modify the script directly to set the path to the KMC binary (`kmc_bin`) if not already defined in your environment.

---

## Prerequisites

- [KMC3](https://github.com/refresh-bio/KMC) must be installed and compiled.
- FASTA files for each class must be named in the format:
  ```
  <ClassName>.fasta
  ```

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

## Notes

- Script is specifically for kmer counting and extracting class-specific kmers.
- Heavy disk I/O and memory usage may occur depending on the size of your FASTA files and `k-mer` sizes.

