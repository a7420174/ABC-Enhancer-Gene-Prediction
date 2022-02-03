rule call_candidates:
    input:
        sorted_bed="results/Peaks/{}_peaks.narrowPeak.sorted".format(DNase_prefix),
        DNase_BAM=config['DNase_BAM'][0],
    output:
        "results/Peaks/{}_peaks.narrowPeak.sorted.candidateRegions.bed".format(DNase_prefix)
    params:
        chr_sizes=config["chr_sizes"],
        regions_includelist=config["call_candidates"]["regions_includelist"],
        regions_blocklist=config["call_candidates"]["regions_blocklist"],
        peakExtendFromSummit=config["call_candidates"]["peakExtendFromSummit"],
        nStrongestPeaks=config["call_candidates"]["nStrongestPeaks"],
    conda:
        "../envs/abcenv.yml"
    shell:
        "python workflow/scripts/makeCandidateRegions.py --narrowPeak {input.sorted_bed} --bam {input.DNase_BAM} --outDir results/Peaks/ --chrom_sizes {params.chr_sizes} "
        "--regions_blocklist {params.regions_blocklist} --regions_includelist {params.regions_includelist} --peakExtendFromSummit {params.peakExtendFromSummit} --nStrongestPeaks {params.nStrongestPeaks}"