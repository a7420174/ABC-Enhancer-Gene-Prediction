rule run_neighborhoods:
    input:
        enhancer_regions="results/Peaks/{}_peaks.narrowPeak.sorted.candidateRegions.bed".format(DNase_prefix),
    output:
        'results/Neighborhoods/EnhancerList.txt',
        'results/Neighborhoods/GeneList.txt',
    params:
        DNase_BAM=','.join(config['DNase_BAM']),
        ChIP_BAM=','.join(config['ChIP_BAM']),
        expression_table=','.join(config['expression_table']),
        chr_sizes=config["chr_sizes"],
        cellType=config["cellType"],
        genes=config["run_neighborhoods"]["genes"],
        ubiquitously_expressed_genes=config["run_neighborhoods"]["ubiquitously_expressed_genes"],
        qnorm=config["run_neighborhoods"]["qnorm"],
    conda:
        "../envs/abcenv.yml"
    shell:
        "python workflow/scripts/run.neighborhoods.py --candidate_enhancer_regions {input.enhancer_regions} --DHS {params.DNase_BAM} --H3K27ac {params.ChIP_BAM} --expression_table {params.expression_table} "
        "--chrom_sizes {params.chr_sizes} --ubiquitously_expressed_genes {params.ubiquitously_expressed_genes} --genes {params.genes} --cellType {params.cellType} --outdir results/Neighborhoods/ --qnorm {params.qnorm}"
