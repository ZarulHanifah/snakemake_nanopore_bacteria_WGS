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