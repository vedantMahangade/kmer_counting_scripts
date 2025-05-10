#!/bin/sh

start=$(date +%s)

# Define paths
fasta_dir=$1
class_file=$2
output_dir=$3


# List of classes
#classes=("Bacillus" "Streptomyces" "Pseudomonas" "Lactobacillus" "Staphylococcus" \
#        "Vibrio" "Chloroplast" "Escherichia-Shigella" "Paenibacillus" "Streptococcus")
# Load list of classes from a text file
class_file="/scratch/rahlab/vedant/guided_tokenization/data/all_genera/families.txt"
mapfile -t classes < "$class_file"

# Iterate through k-mer sizes
for kmer_size in $(seq 5 100); do
    echo "## Processing k-mer size: $kmer_size"
    
    for class in "${classes[@]}"; do

        # Run KMC k-mer counting for class
        echo "### Processing k-mer counting for class: $class, for k-mer size: $kmer_size"
        class_fasta="$fasta_dir/${class}.fasta"
        class_output="$output_dir/${class}_k${kmer_size}"
        class_kmers="$class_output/kmers"
        mkdir -p "$class_output/tmpdir"


        if [ "$kmer_size" -lt 30 ]; then # skip -r for kmer size less than 30
            $kmc_bin/kmc -k${kmer_size} -ci1 -cs9999 -m70 -sm -fm -t36 -sf4 -sp8 -sr24 "$class_fasta" "$class_kmers" "$class_output/tmpdir/"
        else
            $kmc_bin/kmc -k${kmer_size} -ci1 -cs9999 -m70 -sm -r -fm -t36 -sf4 -sp8 -sr24 "$class_fasta" "$class_kmers" "$class_output/tmpdir/"
        fi
        
        # Create Operations file and use KMC tool to get class specific kmers
        echo "### Getting unique k-mers for class: $class, for k-mer size: $kmer_size"
        current_class=$class #"${classes[$i]}"
        operations_file="$output_dir/kmc_operations_${current_class}_k${kmer_size}.txt"
    
        echo "INPUT:" > "$operations_file"
        current_class_kmers="$output_dir/${current_class}_k${kmer_size}/kmers"
        echo "set1 = $current_class_kmers" >> "$operations_file"
    
        set_index=2
        op_str="$output_dir/subtract_${current_class}_k${kmer_size} = set1"
    
        for j in "${!classes[@]}"; do
            if [ "${classes[$j]}" != "$current_class" ]; then
                other_class="${classes[$j]}"
                other_class_kmers="$output_dir/${other_class}_k${kmer_size}/kmers"
                echo "set${set_index} = $other_class_kmers" >> "$operations_file"
                op_str="$op_str - set${set_index}"
                ((set_index++))
            fi
        done
    
        echo "OUTPUT:" >> "$operations_file"
        echo "$op_str" >> "$operations_file"
    
        # Execute KMC tools with complex option
        $kmc_bin/kmc_tools -t36 complex "$operations_file"

        # Convert to human-readable format
        echo "### Exporting unique k-mers for class: $class, for k-mer size: $kmer_size"
        $kmc_bin/kmc_dump "$output_dir/subtract_${class}_k${kmer_size}" "$output_dir/subtract_${class}_k${kmer_size}.txt"
        merged_output="$output_dir/unique_${class}_kmers.txt"
        cat "$output_dir/subtract_${class}_k${kmer_size}.txt" >> "$merged_output"

    
        # Cleanup temporary directories
        echo "### Cleaning temporary directories for class: $class, for k-mer size: $kmer_size"
        rm -rf "$output_dir/${class}_k${kmer_size}/tmpdir"
    done
    
    echo "## Done processing k-mer size: $kmer_size"
done

end=$(date +%s)
total_runtime=$((end - start))
echo "Total runtime for k=5 to 100: $total_runtime seconds"
