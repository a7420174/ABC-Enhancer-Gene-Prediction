#################################################################################
## Get list of files from ENCODE Portal for ABC predictions
# review of fastq and bam 

backup_dir=$(date +'%m/%d/%Y')
echo $backup_dir
# download all experiments, only file that possesses 
curl -L -u '3WWN6YZV:ek623s3asgxmgq4b' -o all_experiments.tsv "https://www.encodeproject.org/report.tsv?type=Experiment"
grep -E "H3K27ac|DNase-seq|ATAC-seq" all_experiments.tsv > rel_experiments.tsv
grep "hg19" rel_experiments.tsv > hg19_rel_experiments.tsv
grep "GRCh28" rel_experiments.tsv > hg38_rel_experiments.tsv

## Download metadata files from ENCODE portal
curl -L -u '3WWN6YZV:ek623s3asgxmgq4b' -o bam_hg19_DHS.tsv "https://www.encodeproject.org/metadata/?type=Experiment&status=released&files.file_type=bam&assembly=hg19&assay_title=DNase-seq&audit.ERROR.category%21=extremely+low+spot+score&aud%5Cit.ERROR.category%21=extremely+low+read+depth&audit.NOT_COMPLIANT.category%21=insufficient+read+depth%5C&files.status=released&files.assembly=hg19" 
curl -L -u '3WWN6YZV:ek623s3asgxmgq4b' -o bam_hg19_ATAC.tsv "https://www.encodeproject.org/metadata/?type=Experiment&files.file_type=bam&assembly=hg19&assay_title=ATAC-seq&files.assembly=hg19&&audit.ERROR.category%21=extremely+low+spot+score&aud%5Cit.ERROR.category%21=extremely+low+read+depth&audit.NOT_COMPLIANT.category%21=insufficient+read+depth%5C&files.status=released" 
curl -L -u '3WWN6YZV:ek623s3asgxmgq4b' -o bam_hg19_H3K27ac.tsv "https://www.encodeproject.org/metadata/?type=Experiment&status=released&files.file_type=bam&assembly=hg19&assay_title=Histone+ChIP-seq&target.label=H3K27ac&audit.ERROR.category%21=extremely+low+spot+score&aud%5Cit.ERROR.category%21=extremely+low+read+depth&audit.NOT_COMPLIANT.category%21=insufficient+read+depth%5C&files.status=released&files.assembly=hg19"

# downloading fastq files 
curl -L -u '3WWN6YZV:ek623s3asgxmgq4b' -o fastq_hg19_DHS.tsv "https://www.encodeproject.org/metadata/?type=Experiment&status=released&assembly=hg19&assay_title=DNase-seq&files.file_type=fastq"
curl -L -u '3WWN6YZV:ek623s3asgxmgq4b' -o fastq_hg19_ATAC.tsv "https://www.encodeproject.org/metadata/?type=Experiment&status=released&assembly=hg19&assay_title=ATAC-seq&files.file_type=fastq"
curl -L -u '3WWN6YZV:ek623s3asgxmgq4b' -o fastq_hg19_H3K27ac.tsv "https://www.encodeproject.org/metadata/?type=Experiment&status=released&assembly=hg19&assay_title=Histone+ChIP-seq&target.label=H3K27ac&files.file_type=fastq"

curl -L -u '3WWN6YZV:ek623s3asgxmgq4b' -o bam_GRCh38_DHS.tsv "https://www.encodeproject.org/metadata/?type=Experiment&status=released&files.file_type=bam&assembly=GRCh38&assay_title=DNase-seq&audit.ERROR.category%21=extremely+low+spot+score&aud%5Cit.ERROR.category%21=extremely+low+read+depth&audit.NOT_COMPLIANT.category%21=insufficient+read+depth%5C&files.status=released" 
curl -L -u '3WWN6YZV:ek623s3asgxmgq4b' -o bam_GRCh38_ATAC.tsv "https://www.encodeproject.org/metadata/?type=Experiment&status=released&files.file_type=bam&assembly=GRCh38&assay_title=ATAC-seq&audit.ERROR.category%21=extremely+low+spot+score&aud%5Cit.ERROR.category%21=extremely+low+read+depth&audit.NOT_COMPLIANT.category%21=insufficient+read+depth%5C&files.status=released" 
curl -L -u '3WWN6YZV:ek623s3asgxmgq4b' -o bam_GRCh38_H3K27ac.tsv "https://www.encodeproject.org/metadata/?type=Experiment&status=released&files.file_type=bam&assembly=GRCh38&assay_title=Histone+ChIP-seq&target.label=H3K27ac&audit.ERROR.category%21=extremely+low+spot+score&aud%5Cit.ERROR.category%21=extremely+low+read+depth&audit.NOT_COMPLIANT.category%21=insufficient+read+depth%5C&files.status=released"

# downloading fastq files
curl -L -u '3WWN6YZV:ek623s3asgxmgq4b' -o fastq_GRCh38_DHS.tsv "https://www.encodeproject.org/metadata/?type=Experiment&status=released&assembly=GRCh38&assay_title=DNase-seq&files.file_type=fastq"
curl -L -u '3WWN6YZV:ek623s3asgxmgq4b' -o fastq_GRCh38_ATAC.tsv "https://www.encodeproject.org/metadata/?type=Experiment&status=released&assembly=GRCh38&assay_title=ATAC-seq&files.file_type=fastq"
curl -L -u '3WWN6YZV:ek623s3asgxmgq4b' -o fastq_GRCh38_H3K27ac.tsv "https://www.encodeproject.org/metadata/?type=Experiment&status=released&assembly=GRCh38&assay_title=Histone+ChIP-seq&target.label=H3K27ac&files.file_type=fastq"
