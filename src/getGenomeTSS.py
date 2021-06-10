#! bin/python3

import pandas as pd
import numpy as np
import argparse
import os, time
from tools import write_params, run_command
from neighborhoods import count_features_for_bed, count_single_feature_for_bed 


def parseargs(required_args=True):
    class formatter(argparse.ArgumentDefaultsHelpFormatter, argparse.RawTextHelpFormatter):
        pass
    epilog = ("")
    parser = argparse.ArgumentParser(description='Selects Top 2 Most Active TSS',
            epilog=epilog,
            formatter_class=formatter)
    readable = argparse.FileType('r')
    parser.add_argument('--tss_file', required=required_args, help="tss isoform file")
    parser.add_argument('--dhs', required=required_args, help="Accessibility bam file")
    parser.add_argument('--h3k27ac', required=required_args, help="H3K27ac-seq bam file")
    parser.add_argument('--chrom_sizes', required=required_args, help="File listing chromosome size annotaions")
    parser.add_argument('--celltype', required=required_args, help="CellType")
    parser.add_argument('--gene_outf', required=required_args, help="GeneList output")
    parser.add_argument('--genetss_outf', required=required_args, help="GeneListTSS output")
    parser.add_argument('--outDir', required=required_args)
    args = parser.parse_args()
    return args 

def read_tss_file(tss_file):
    """
    Reads in TSS File
    """
    tss_df = pd.read_csv(args.tss_file, sep="\t", names=['chr', 'start', 'end', 'TargetGeneTSS', 'score', 'strand', 'start_Gene', 'end_Gene', 'TargetGene'])
    return tss_df

def filter_promoters_by_distance(promoters):
    """
    Takes in Promoter Isoforms and returns Top 2 Promoter Isoforms based on RPM 
    IF promoter start sites are 500bp from each other, otherwise, return top promoter
    """
    # ensure that promoters are at least 500bp apart
    top_promoter = promoters.iloc[0, :]
    top_promoter_index = top_promoter.name
    # if no promoter isoform exists within 500bp, just pick top promoter 
    # for now, use the distance between the promoter TSS 
    if promoters.iloc[0, 5] == '+':
        start = top_promoter[1]
    else:
        start = top_promoter[2]
    if len(promoters) > 1:
        temp = promoters.copy()
        if promoters.iloc[0, 5] == "+":
            temp['dist'] = temp['start'] - start
        else:
            temp['dist'] = temp['end'] - start
            temp = temp.iloc[1:, :]
        index = temp.loc[temp['dist'] >= 500].index.astype('int')
        if len(index) > 0:
            top_promoter = promoters.loc[[top_promoter_index, index[0]], :]
        return top_promoter
    else:    
        return promoters.loc[[top_promoter_index]]

def filter_expressed_df(expressed_tsscounts):
    gene_tss_df = None
    unique_expressed_tsscounts = expressed_tsscounts.drop_duplicates()
    #get_expressed_tsscounts = expressed_tsscounts.groupby(['TargetGene'])[['chr', 'start', 'end']].aggregate('count').reset_index()
    unique_expressed_tsscounts  = unique_expressed_tsscounts.sort_values(by=['PromoterActivityQuantile'], ascending=False) 
    for gene in unique_expressed_tsscounts['TargetGene'].drop_duplicates(): #["MYC", "C4B", "LRRC4B" ]:
        tss1kb_file_subset = unique_expressed_tsscounts.loc[unique_expressed_tsscounts['TargetGene']==gene].copy()
        # filter by activity 
        tss1kb_file_subset['PctEnriched'] = tss1kb_file_subset['PromoterActivityQuantile'] / (np.array(tss1kb_file_subset['PromoterActivityQuantile'])[0])
        sorted_tss1kb_file_subset = tss1kb_file_subset[tss1kb_file_subset['PctEnriched']>0.8]
        # ensure that distances between promoters are at least 500bp from each other
        top_two = filter_promoters_by_distance(sorted_tss1kb_file_subset)
        if gene_tss_df is None:
            gene_tss_df = top_two
        else:
            gene_tss_df = pd.concat([gene_tss_df, top_two])
    return gene_tss_df

def filter_nonexpressed_df(nonexpressed):
    nonexpressed_sorted = nonexpressed.sort_values(['PromoterActivityQuantile'], ascending=False) 
    nonexpressed_sorted_unique = nonexpressed_sorted.drop_duplicates(['TargetGene']) 
    return nonexpressed_sorted_unique 

def get_tss_region(genes):
    genes['tss'] = genes['start']
    subset = genes.loc[genes['strand']=="-"].index.astype('int')
    genes.loc[subset, 'tss'] = genes.loc[subset, 'end']
    return genes

def process_genome_tss(args):
    """
    Takes in ENSEMBL Gene List and outputs 1/2 Promoter Isoforms for each gene 
    Promoter_ID = {PromoterChr:Start-End}_{Gene_Name}
    """
    os.makedirs(os.path.join(args.outDir), exist_ok=True)
    write_params(args, os.path.join(args.outDir, "params_generateTSS.txt"))
    
    filebase = str(os.path.basename(args.tss_file)).split(".")[0]
    feature_name =  ["H3K27ac", "DHS"]
    feature_files = [args.h3k27ac, args.dhs]
    features = {key:value for key, value in zip(feature_name, feature_files)}
    tss_df = read_tss_file(args.tss_file)
    tss1kb_file = args.tss_file
    genome_sizes = args.chrom_sizes
    outdir = args.outDir

    tsscounts = count_features_for_bed(tss_df, tss1kb_file, genome_sizes, features, outdir, "Genes.TSS1kb", force=True, use_fast_count=True)
    for feature, feature_file in zip(feature_name, feature_files):
        output_file = os.path.join(args.outDir,"{}.{}.CountReads.bedgraph".format(filebase, feature))
        print("Taking in isoform TSS file and generating Counts")
        # Take in isoform file and count reads 
        tss_df_1 = count_single_feature_for_bed(tss_df, args.tss_file, args.chrom_sizes, feature_file, feature, args.outDir, "Genes.TSS1kb", skip_rpkm_quantile=False, force=False, use_fast_count=True)
    chrom_sizes = args.chrom_sizes
    tss_file = args.tss_file
    sort_command = "bedtools sort -faidx {chrom_sizes} -i {tss_file} > {tss_file}.sorted; mv {tss_file}.sorted {tss_file}".format(**locals())
    run_command(sort_command)
    print("Finished Sorting Gene TSS File")

    # Take top 2 promoters based on counts 
    tsscounts['PromoterActivityQuantile'] = ((0.0001+tsscounts['H3K27ac.RPKM.quantile'])*(0.0001+tsscounts['DHS.RPKM.quantile'])).rank(method='average', na_option="top", ascending=True, pct=True)
    print("Looping though all genes present to select out Top Two Promoters based on RPM")
    tsscounts.to_csv(os.path.join(args.outDir, "PromoterActivityQuantile.tsv"), sep="\t", index=False)
    starttime = time.time()
    print("Reading in PromoterActivityQuantile file")
    tsscounts = pd.read_csv(os.path.join(args.outDir, "PromoterActivityQuantile.tsv"), sep="\t")
    # filter for expressed genes 
    # This loop only needs to run on expressed genes
    expressed_tsscounts = tsscounts.loc[tsscounts['PromoterActivityQuantile']!=0.0].drop_duplicates()
    print("Filtering expressed tss counts")
    filtered_expressed_tsscounts = filter_expressed_df(expressed_tsscounts)
    t1 = time.time() - starttime
    print("This took {} seconds".format(t1))

    nonexpressed_dup = tsscounts.loc[tsscounts['PromoterActivityQuantile']==0.0].drop_duplicates()
    # filter for single promoter entries 
    nonexpressed_unique = filter_nonexpressed_df(nonexpressed_dup)
    gene_tss_df = pd.concat([filtered_expressed_tsscounts, nonexpressed_unique])

    print("Saving Files")
    
    gene_tss_df = get_tss_region(gene_tss_df)
    gene_tss_df[['chr', 'start', 'end', 'TargetGeneTSS', 'tss', 'score', 'strand']].to_csv(os.path.join(args.outDir, args.genetss_outf), sep="\t", index=False, header=False)
    gene_tss_df[['chr', 'start_Gene', 'end_Gene', 'TargetGene', 'score', 'strand']].to_csv(os.path.join(args.outDir, args.gene_outf), sep="\t", index=False, header=False)
    t2 =  time.time() - starttime
    print("This took {} seconds".format(t2))
    print("Finished!")

if __name__=="__main__":
    args = parseargs()
    process_genome_tss(args)
