rule assembly_stats:
    input:
        rules.medaka_consensus.output.consensus
    output:
        "results/assembly_stats/{id}.tsv"
    conda:
        "../envs/assembly-stats.yaml"
    log:
        "results/log/assembly_stats/{id}.log"
    shell:
        """
        assembly-stats -s {input} | cut -f2- > {output} 2> {log}
        """

rule checkm:
    input:
        rules.medaka_consensus.output.consensus
    output:
        tmpout = temp("results/.tmp/checkm/{id}/{id}.fasta"),
        out1 =  "results/checkm/Bacteria_{id}/storage/bin_stats_ext.tsv",
        faa =  "results/checkm/Bacteria_{id}/bins/{id}/genes.faa"
    conda:
        "../envs/checkm.yaml"
    params:
        ext = "fasta",
        rank = "domain",
        taxon = "Bacteria",
    threads: 2
    log:
        "results/log/checkm/{id}.log"
    message:
        "Running checkm on sample {wildcards.sample}"
    shell:
        """
        cp {input} {output.tmpout}
        
        tmpdir=$(dirname {output.tmpout})
        outdir=$(dirname $(dirname {output.out1}))

        checkm taxonomy_wf -t {threads} -x {params.ext} \
         {params.rank} \
         {params.taxon} \
         $tmpdir \
         $outdir &> {log}
        """