rule flye:
    input:
        os.path.join(config["input_folder"], "{id}")
    output:
        "results/flye/{id}/assembly.fasta"
    conda:
        "../envs/flye.yaml"
    log:
        "results/log/flye/{id}.log"
    threads: 8
    params:
        polish_iter = 8
    shell:
        """
        outdir=$(dirname {output})

        flye --nano-raw {input}/* \
        	--out-dir $outdir \
        	--threads {threads} \
        	--trestle --plasmids \
        	-i {params.polish_iter} \
            --plasmids &> {log}
        """


rule medaka_consensus:
    input:
        reads = os.path.join(config["input_folder"], "{id}"),
        assem = rules.flye.output
    output:
        tmp_fastq = temp("results/.tmp_fastq/{id}.fastq"),
        consensus = "results/medaka/{id}/consensus.fasta"
    conda:
        "../envs/medaka.yaml"
    log:
        "results/log/medaka_consensus/{id}.log"
    threads: 8
    params:
        model = config["medaka_model"]
    shell:
        """
        outdir=$(dirname {output.consensus})

        cat {input.reads}/* > {output.tmp_fastq}

        medaka_consensus -m {params.model} \
        	-i {output.tmp_fastq} \
        	-d {input.assem} \
        	-t {threads} \
        	-o $outdir &> {log}
        """
