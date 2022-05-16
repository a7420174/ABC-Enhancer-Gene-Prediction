###### Config file ######
configfile: "config/config.yaml"

container: "continuumio/miniconda3:latest"

DNase_prefix = config['DNase_BAM'][0].split('/')[-1].replace('bam', 'macs2')