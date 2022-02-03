rule call_candidates:
    input:
        sorted_bed="results/Peaks/{}_peaks.narrowPeak.sorted".format(DNase_prefix)
        DNase_BAM=config['DNase_BAM'][0],
    output:
        "results/Peaks/{}_peaks.narrowPeak.candidateRegions.bed".format(DNase_prefix)
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

    
python workflow/scripts/makeCandidateRegions.py \
--narrowPeak results/Peaks/wgEncodeUwDnaseK562AlnRep1.chr22.macs2_peaks.narrowPeak.sorted \
--bam example_chr22/input_data/Chromatin/wgEncodeUwDnaseK562AlnRep1.chr22.bam \
--outDir results/Peaks/ \
--chrom_sizes example_chr22/reference/chr22 \
--regions_blocklist reference/wgEncodeHg19ConsensusSignalArtifactRegions.bed \
--regions_includelist example_chr22/reference/RefSeqCurated.170308.bed.CollapsedGeneBounds.TSS500bp.chr22.bed \
--peakExtendFromSummit 250 \
--nStrongestPeaks 3000 