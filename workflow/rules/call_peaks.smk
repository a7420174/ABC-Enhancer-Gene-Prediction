rule call_peaks:
    input:
        DNase_BAM=config['DNase_BAM'][0],
    output:
        "results/Peaks/{}_peaks.narrowPeak".format(DNase_prefix)
    params:
        prefix=DNase_prefix,
        pval_cutoff=config["call_peaks"]["pval_cutoff"],
        call_summits="--call-summits" if config["call_peaks"]["call_summits"] else "",
    conda:
        "../envs/macs.yml"
    shell:
        "macs2 callpeak -t {input.DNase_BAM} -n {params.prefix} -f BAM -g hs "
        "-p {params.pval_cutoff} {params.call_summits} --outdir results/Peaks/"
    
rule sort_bed:
    input:
        "results/Peaks/{}_peaks.narrowPeak".format(DNase_prefix),
    output:
        "results/Peaks/{}_peaks.narrowPeak.sorted".format(DNase_prefix)
    params:
        chr_sizes=config["chr_sizes"]
    shell:
        "bedtools sort -faidx {params.chr_sizes} -i {input} > {output}"