#!/bin/sh
# Define paths
# kmc_bin=$1
fasta_dir=$1
output_dir=$2

# List of classes
classes=("Bacillus" "Streptomyces" "Pseudomonas" "Lactobacillus" "Staphylococcus" \
        "Vibrio" "Chloroplast" "Escherichia-Shigella" "Paenibacillus" "Streptococcus")
# classes=("promoter" "non_promoter")


# Iterate through k-mer sizes 20 to 20
for kmer_size in $(seq 1 100); do
    echo "### Processing k-mer size: $kmer_size"
    
    for class in "${classes[@]}"; do
        echo "# Processing class: $class"
        class_fasta="$fasta_dir/${class}_16s_v3v4.fasta"
        class_output="$output_dir/${class}_k${kmer_size}"
        class_kmers="$class_output/kmers"
        mkdir -p "$class_output/tmpdir"

        # Run KMC k-mer counting for class
        $kmc_bin/kmc -k${kmer_size} -ci1 -cs9999 -b -m70 -fm "$class_fasta" "$class_kmers" "$class_output/tmpdir/"
    done


    for i in "${!classes[@]}"; do
        current_class="${classes[$i]}"
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
        $kmc_bin/kmc_tools complex "$operations_file"
    done

    
    # Convert to human-readable format
    for class in "${classes[@]}"; do
        $kmc_bin/kmc_dump "$output_dir/subtract_${class}_k${kmer_size}" "$output_dir/subtract_${class}_k${kmer_size}.txt"
        merged_output="$output_dir/unique_${class}_kmers.txt"
        cat "$output_dir/subtract_${class}_k${kmer_size}.txt" >> "$merged_output"
    done
    
    # Cleanup temporary directories
    for class in "${classes[@]}"; do
        rmdir "$output_dir/${class}_k${kmer_size}/tmpdir"
    done
    
    echo "### Done processing k-mer size: $kmer_size"
done
