


## allelic mapping using STAR
if aligner == "STAR":
    if paired:
        rule STAR_allele:
            input:
                r1 = fastq_dir+"/{sample}"+reads[0]+".fastq.gz",
                r2 = fastq_dir+"/{sample}"+reads[1]+".fastq.gz",
                index = star_index_allelic
            output:
                temp(aligner+"/{sample}.sorted.bam")
            params:
                alignerOptions = str(alignerOptions or ''),
                gtf = genes_gtf,
                prefix = aligner+"/{sample}/{sample}.",
                samsort_memory = '2G',
                idx = os.path.dirname(star_index_allelic),
                sample_dir = aligner+"/{sample}"
            benchmark:
                aligner+"/.benchmark/STAR.{sample}.benchmark"
            threads: 12
            conda: CONDA_RNASEQ_ENV
            shell: """
                MYTEMP=$(mktemp -d ${{TMPDIR:-/tmp}}/snakepipes.XXXXXXXXXX);
                ( [ -d {params.sample_dir} ] || mkdir -p {params.sample_dir} )
                STAR {params.alignerOptions} \
                    --runThreadN {threads} \
                    --genomeDir {params.idx} \
                    --sjdbGTFfile {params.gtf} \
                    --sjdbOverhang 100 \
                    --readFilesCommand zcat \
                    --readFilesIn {input.r1} {input.r2} \
                    --outFileNamePrefix {params.prefix} \
                    --outSAMunmapped Within \
                    --alignEndsType EndToEnd \
                    --outSAMattributes NH HI NM MD \
                    --outSAMtype BAM Unsorted \
                    --outStd BAM_Unsorted \
                    --outFilterMultimapNmax 20 \
                    --alignSJoverhangMin 8 \
                    --alignSJDBoverhangMin 1 \
                    --outFilterMismatchNmax 999 \
                    --alignIntronMin 1 \
                    --alignIntronMax 1000000 \
                    --alignMatesGapMax 1000000 \
                | samtools sort -m {params.samsort_memory} -T $MYTEMP/{wildcards.sample} -@ {threads} -O bam -o {output} -;
                rm -rf $MYTEMP
                """
    else:
        rule STAR_allele:
            input:
                r1 = fastq_dir+"/{sample}.fastq.gz",
                index = star_index_allelic
            output:
                temp(aligner+"/{sample}.sorted.bam")
            params:
                alignerOptions = str(alignerOptions or ''),
                gtf = genes_gtf,
                idx = os.path.dirname(star_index_allelic),
                prefix = aligner+"/{sample}/{sample}.",
                samsort_memory = '2G',
                sample_dir = aligner+"/{sample}"
            benchmark:
                aligner+"/.benchmark/STAR.{sample}.benchmark"
            threads: 12
            conda: CONDA_RNASEQ_ENV
            shell: """
                MYTEMP=$(mktemp -d ${{TMPDIR:-/tmp}}/snakepipes.XXXXXXXXXX);
                ( [ -d {params.sample_dir} ] || mkdir -p {params.sample_dir} )
                STAR {params.alignerOptions} \
                    --runThreadN {threads} \
                    --genomeDir {params.idx} \
                    --sjdbGTFfile {params.gtf} \
                    --sjdbOverhang 100 \
                    --readFilesCommand zcat \
                    --readFilesIn {input} \
                    --outFileNamePrefix {params.prefix} \
                    --outSAMunmapped Within \
                    --alignEndsType EndToEnd \
                    --outSAMattributes NH HI NM MD  \
                    --outSAMtype BAM Unsorted \
                    --outStd BAM_Unsorted \
                    --outFilterMultimapNmax 20 \
                    --alignSJoverhangMin 8 \
                    --alignSJDBoverhangMin 1 \
                    --outFilterMismatchNmax 999 \
                    --alignIntronMin 1 \
                    --alignIntronMax 1000000 \
                    --alignMatesGapMax 1000000 \
                | samtools sort -m {params.samsort_memory} -T $MYTEMP/{wildcards.sample} -@ {threads} -O bam -o {output} -;
                rm -rf $MYTEMP
                """
else:
    print("Only STAR is implemented for Allele-specific mapping")
