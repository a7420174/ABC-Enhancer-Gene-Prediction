rule predict:
    input:
        enhancers='results/Neighborhoods/EnhancerList.txt',
        genes='results/Neighborhoods/GeneList.txt',
    output:
        "results/Predictions/EnhancerPredictions.txt",
        "results/Predictions/EnhancerPredictionsFull.txt",
        "results/predictions/EnhancerPredictions.bedpe",
        "results/Predictions/EnhancerPredictionsAllPutative.ForVariantOverlap.shrunk150bp.txt.gz",
        "results/Predictions/EnhancerPredictionsAllPutative.txt.gz",
        "results/Predictions/EnhancerPredictionsAllPutativeNonExpressedGenes.txt.gz",
        "results/Predictions/parameters.predict.txt",
    params:
        HiCdir=config["HiCdir"],
        chr_sizes=config["chr_sizes"],
        cellType=config["cellType"],
        hic_resolution=config["predict"]["hic_resolution"],
        threshold=config["predict"]["threshold"],
        scale_hic_using_powerlaw="--scale_hic_using_powerlaw" if config["predict"]["scale_hic_using_powerlaw"] else "",
        make_all_putative="--make_all_putative" if config["predict"]["make_all_putative"] else "",
    shell:
        "python scripts/predict.py --enhancers {input.enhancers} --genes {input.genes} --HiCdir {params.HiCdir} --hic_resolution {params.hic_resolution} "
        "--chrom_sizes {params.chr_sizes} --threshold {params.threshold} --cellType {params.cellType} --outDir results/Predictions/ {params.scale_hic_using_powerlaw} {params.make_all_putative}"
