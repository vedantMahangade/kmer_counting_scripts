import os
import argparse
import pandas as pd
from collections import defaultdict



# Generate k-mers
def generate_kmers(sequence, k):
    return [sequence[i:i+k] for i in range(len(sequence) - k + 1)]

# K-mer counting function
def count_kmers(df, k_values):
    global_counts = defaultdict(int)
    label_counts = {0: defaultdict(int), 1: defaultdict(int)}
    
    total_rows = len(df)
    log_interval = max(1000, total_rows // 10)  # Adjust log frequency dynamically

    # with open(log_path, "a") as log_file:
    for i, (_, row) in enumerate(df.iterrows(), 1):
        sequence, label = row["sequence"], row["label"]
        
        for k in k_values:
            kmers = generate_kmers(sequence, k)
            for kmer in kmers:
                global_counts[kmer] += 1
                label_counts[label][kmer] += 1

        if i % log_interval == 0 or i == total_rows:
            print(f"Processed {i}/{total_rows} rows...\n")

    print("K-mer counting completed.\n")
    
    return global_counts, label_counts

# Extract promoter-specific k-mers
# def get_top_promoter_kmers(label_kmer_counts, threshold=9):
#     promoter_kmers = {}

#     for kmer, count in label_kmer_counts[1].items():
#         if count >= threshold and count > 3 * label_kmer_counts[0].get(kmer, 0):
#             promoter_kmers[kmer] = count
#     return promoter_kmers

def get_promoter_specific_kmers(label_kmer_counts):
    unique_promoter_kmers = {}

    for kmer, count in label_kmer_counts[1].items():
        if label_kmer_counts[0].get(kmer, 0) == 0:  # Ensure k-mer is absent in label 0
            unique_promoter_kmers[kmer] = count
    return unique_promoter_kmers


def write_dict_to_file(dictionary, file_path):
    with open(file_path, 'w') as file:
        for key, value in dictionary.items():
            file.write(f"{key}\t{value}\n")

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='Get Top frequency kmers for promoters')
    parser.add_argument('--output_path', type=str, help='Path to dataset.', default='kmer_output/')
    args = parser.parse_args()

    os.makedirs(args.output_path, exist_ok=True)

    # # Set dataset paths
    # splits = {'train': 'GUE/prom_300_tata/train.csv', 'test': 'GUE/prom_300_tata/test.csv', 'dev': 'GUE/prom_300_tata/dev.csv'}
    # dataset_path = "hf://datasets/leannmlindsey/GUE/" + splits["train"]

    # sequence1 = "CCAGGTCCCGGGAGCGCCACGGAACCTAACGGTGGCAGCGGAGGTCGCGCCCCTCAGTGCCCGCGCTCTCCCCGTCGGGAGCTTCCTGGTCGCCCCTGCGGCGGCGGCTCGGGGTGTCTGGCCGGCGCGGGGCTCGCCCAGCCTGGTCCGGGGAGAGGACTGGCTGGGCAGGGGCGCCGCCCCGCCTCGGGAGAGGCGGGCCGGGCGGGGCTGGGAGTATTTGAGGCTCGGAGCCACCGCCCCGCCGGCGCCCGCAGCACCTCCTCGCCAGCAGCCGTCCGGAGCCAGCCAACGAGCGGT"
    
    # sequence2 = 'CCGGCCGAGCTCAGCACCGAGGCGCCCCCCAACCTGCCCAGCCCCCAGCCCACCAGCCCAGCCCAGTCCCGGGGAGCCAGCTGGCCTGGGGTTCGGTCCCGGGGGGAGGGGAGTTTCGGGGGTACTGGGCGGGGTACTCGTGAGCCAGAGGGGAGGGGGCCGCGGGTTTTCATGTACCCAGCATGAGCTCCTACTTCGTCAACCCCCTGTTCTCCAAATACAAAGCCGGCGAGTCCCTGGAACCGGCCTATTACGACTGCCGGTTCCCTCAGAGCGTGGGCAGGAGCCATGCGCTGGTGT'

    sample_input = pd.DataFrame({'sequence': [sequence1,sequence2], 'label': [1,0]})
    # Load dataset
    # dataset = pd.read_csv(dataset_path)

    k_values = range(1, 256)
    global_kmer_counts, label_kmer_counts = count_kmers(sample_input[:1], k_values)


    # # print(global_kmer_counts)
    # print('\n\n')
    # print(label_kmer_counts[1])
    # label_kmer_counts.
    print('Extracting Promoter Specific Kmers')
    promoter_kmers = get_promoter_specific_kmers(label_kmer_counts)
    print('Promoter specific Kmers extracted\nSaving results...')
    # Save results
    # write_dict_to_file(global_kmer_counts, args.output_path + 'global_kmer_counts.txt')
    # write_dict_to_file(label_kmer_counts[0], args.output_path + 'negative_class_kmer_counts.txt')  # Negative class
    # write_dict_to_file(label_kmer_counts[1], args.output_path + 'positive_class_kmer_counts.txt') # Positive class
    write_dict_to_file(promoter_kmers, args.output_path + 'top_prom_kmers.txt')
    # print(label_kmer_counts.)
    print('Results saved under following path:', args.output_path)


