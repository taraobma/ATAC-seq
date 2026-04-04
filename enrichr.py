import csv

files = {
    "cDC1": "./results/annotated_peaks_cDC1.txt",
    "cDC2": "./results/annotated_peaks_cDC2.txt",
}

for label, fname in files.items():
    genes = set()

    with open(fname, "r") as f:
        reader = csv.DictReader(f, delimiter="\t")
        for row in reader:
            gene_type = row.get("Gene Type", "").strip()
            gene_name = row.get("Gene Name", "").strip()

            if gene_type == "protein_coding" and gene_name:
                genes.add(gene_name)

    outname = f"{label}_significant_peaks_protein_coding_genes.txt"
    with open(outname, "w") as out:
        for gene in sorted(genes):
            out.write(gene + "\n")

    print(f"Wrote {len(genes)} genes to {outname}")