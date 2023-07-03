version 1.0

workflow amr_analysis {
    input {
        Array[File] fastqFiles
        Array[Array[File]] pairedReads
        File resfinderDB
    }

    scatter (fastqFile in fastqFiles) {
       call fastqc as fastqcRaw {
           input: 
               fastqFile = fastqFile
       }
    }
    
    call multiqc as multiqcRaw {
       input: 
           input_files = fastqcRaw.outZip
    }
    
    scatter (pairRead in pairedReads) {
        call cutadapt {
            input: read1 = pairRead[0], read2 = pairRead[1]
        }
    }
    

    scatter (fastqFileTrimmed in flatten([cutadapt.outFwd, cutadapt.outRev])) {
       call fastqc as fastqcTrim {
           input: 
               fastqFile = fastqFileTrimmed
       }
    }
    Array[File] fastqcTrimzip = fastqcTrim.outZip
    
    call multiqc as multiqcTrim {
       input: 
           input_files = fastqcTrimzip
    }
    
    call buildDatabase as resFinder{
       input:
           database = resfinderDB,
           referenceName = "resfinder"
           
    }

    scatter (i in range(length(pairedReads))){
        call Bowtie2 as resfinderBowtie2{
            input:
                R1 = cutadapt.outFwd[i],
                R2 = cutadapt.outRev[i],
                database = resFinder.outFile,
                indexPrefix = resFinder.indexPrefix
        }
        call filterBam as resfinderfilterBam{
            input:
                samFile = resfinderBowtie2.alignment,
                indexPrefix = resFinder.indexPrefix
        }
        call SortandIndexBam as resfinderSortandIndex{
            input:
                bamFile = resfinderfilterBam.bamFile, 
                referenceName = resFinder.indexPrefix
        }
    }

    call CombineResults1 as resfindercombineResults1{
            input:
                sortedBam = resfinderSortandIndex.sortedBam[0],
                referenceName = resFinder.indexPrefix,
        }

    scatter (samples in resfinderSortandIndex.sortedBam){
        call CombineResults2 as resfindercombineResults2{
            input:
                sortedReads = samples,
                referenceName = resFinder.indexPrefix,
        }
        call AddSampleNames as resfindersampleNames{
            input:
                sample = resfindercombineResults2.out,
                referenceName =resFinder.indexPrefix
        }
    }

    call Create_ARG_Genemat{
        input:
            geneNames = resfindercombineResults1.out,
            renamedSampleCounts = resfindersampleNames.renamedSampleCount,
            referenceName = resFinder.indexPrefix
    }
 
}

task fastqc {

    input {
        File fastqFile
    }

    Int numCores = 8
    String dockerImage = "quay.io/staphb/fastqc:0.11.9"

    command <<<
        set -euo pipefail

        fastqc -o . ~{fastqFile}
    >>>

    output {
        File outHtml = basename(fastqFile, ".fastq.gz") + "_fastqc.html"
        File outZip = basename(fastqFile, ".fastq.gz") + "_fastqc.zip"
    }

    runtime {
        docker: dockerImage
        disks: "local-disk 500 HDD"
        cpu: numCores
        memory: "16 GB"
    }
}

task multiqc {
    input {
        Array[File]     input_files 

        Boolean         force = false
        Boolean         full_names = false
        String?         title
        String?         comment
        String?         file_name
        String          out_dir = "./multiqc-output"
        String?         template
        String?         tag
        String?         ignore_analysis_files
        String?         ignore_sample_names
        File?           sample_names
        Array[String]?  exclude_modules
        Array[String]?  module_to_use
        Boolean         data_dir = false
        Boolean         no_data_dir = false
        String?         output_data_format
        Boolean         zip_data_dir = false
        Boolean         export = false
        Boolean         flat = false
        Boolean         interactive = true
        Boolean         lint = false
        Boolean         pdf = false
        Boolean         megaQC_upload = false # Upload generated report to MegaQC if MegaQC options are found
        File?           config  # directory
        String?         config_yaml

        String          docker = "quay.io/biocontainers/multiqc:1.8--py_2"
    }

    # get the basename in all wdl use the filename specified (sans ".html" extension, if specified)
    String report_filename = if (defined(file_name)) then basename(select_first([file_name]), ".html") else "multiqc"

    command {
        set -ex -o pipefail

        echo "${sep='\n' input_files}" >  input-filename.txt
        echo "" >>  input-filename.txt

        multiqc \
        --file-list  input-filename.txt \
        --dirs \
        --outdir "${out_dir}" \
        ${true="--force" false="" force} \
        ${true="--fullnames" false="" full_names} \
        ${"--title " + title} \
        ${"--comment " + comment} \
        ${"--filename " + file_name} \
        ${"--template " + template} \
        ${"--tag " + tag} \
        ${"--ignore " + ignore_analysis_files} \
        ${"--ignore-samples" + ignore_sample_names} \
        ${"--sample-names " + sample_names} \
        ${true="--exclude " false="" defined(exclude_modules)}${sep=' --exclude ' select_first([exclude_modules,[]])} \
        ${true="--module " false="" defined(module_to_use)}${sep=' --module ' select_first([module_to_use,[]])} \
        ${true="--data-dir" false="" data_dir} \
        ${true="--no-data-dir" false="" no_data_dir} \
        ${"--data-format " + output_data_format} \
        ${true="--zip-data-dir" false="" zip_data_dir} \
        ${true="--export" false="" export} \
        ${true="--flat" false="" flat} \
        ${true="--interactive" false="" interactive} \
        ${true="--lint" false="" lint} \
        ${true="--pdf" false="" pdf} \
        ${false="--no-megaqc-upload" true="" megaQC_upload} \
        ${"--config " + config} \
        ${"--cl-config " + config_yaml }

        if [ -z "${file_name}" ]; then
            mv "${out_dir}/${report_filename}_report.html" "${out_dir}/${report_filename}.html"
        fi

        tar -c "${out_dir}/${report_filename}_data" | gzip -c > "${report_filename}_data.tar.gz"
    }

    output {
        File multiqc_report            = "${out_dir}/${report_filename}.html"
        File multiqc_data_dir_tarball  = "${report_filename}_data.tar.gz"
    }

    runtime {
        memory: "16 GB"
        cpu: 8
        docker: "${docker}"
        disks: "local-disk 500 HDD"
        dx_instance_type: "mem1_ssd1_v2_x2"
    }
}

task cutadapt {
    input {
        File read1
        File read2
    }

    Int numCores = 8
    String dockerImage = "pegi3s/cutadapt"
    String outfw = basename(read1, "001.fastq.gz") + "trimmed.fastq.gz"
    String outrv = basename(read2, "001.fastq.gz") + "trimmed.fastq.gz"

    command {
        set -euo pipefail
        
        cutadapt -a CTGTCTCTTATACACATCT -A CTGTCTCTTATACACATCT -O 10 -m 30 -q 20 ~{read1} ~{read2} -o ~{outfw} -p ~{outrv}
    }

    output {
        File outFwd = outfw
        File outRev = outrv
        File outlog = stdout()
    }

    runtime {
        docker: dockerImage
        disks: "local-disk 500 HDD"
        cpu: numCores
        memory: "16 GB"
    }
}

task buildDatabase{
    input{
        File database
        String referenceName
    }
   
    command{
        bowtie2-build ~{database} ${referenceName}
    }
    output {
        Array[File] outFile = glob("~{referenceName}.*.bt2")
        String indexPrefix = referenceName
    }

    runtime {
        docker: "quay.io/biocontainers/bowtie2:2.4.2--py38h1c8e9b9_1"
    }
}

task Bowtie2 {
    input {
        File R1
        File R2
        Array[File] database
        String indexPrefix
    }
     String outFile = "${indexPrefix}_alignment.sam"

    command {
        for f in ~{sep=" " database}; do cp $f .; done
        bowtie2 -x ~{indexPrefix} -1 ~{R1} -2 ~{R2} \
            -D 20 -R 3 -N 1 -L 20 -i S,1,0.50 --threads 6 | \
            samtools view -Sb - > ~{outFile}
        
    }

    output {
        File alignment = outFile
    }

    runtime {
        docker: "ummidock/innuca"
    }
}

task filterBam {
    input {
        File samFile
        String indexPrefix
    }

    String outfile = basename(samFile, ".sam") + "_filtered.bam"
    command <<<
        samtools view -h ~{samFile} | gawk 'BEGIN {{FS="\t"; OFS="\t"}} \
            {{if (/^@/ && substr($2, 3, 1)==":") {{print}} \
            else if (($7!="=" || $7=="=") && and($2, 0x40)) {{print}}}}' | \
            samtools view -Shu - > ~{outfile}
    >>>

    output {
        File bamFile = outfile
    }

    runtime {
        docker:"quay.io/staphb/samtools:1.15"
    }
}

task SortBam {
    input {
        File bamFile
        String referenceName
    }

    String outFile = basename(bamFile, "_filtered.bam")+ "sorted.bam"
    

    command {
        samtools sort -o ~{outFile} ~{bamFile}
    }

    output {
        File sortedBam = outFile
    }

    runtime {
        docker: "quay.io/staphb/samtools:1.15"
    }
}
# follow https://hcc.unl.edu/docs/applications/app_specific/bioinformatics_tools/data_manipulation_tools/samtools/running_samtools_commands/
task IndexBam{
    input{
        File bamFile
        String referenceName
    }
    String outBai = basename(bamFile, "sorted.bam") +".bai"

    command{
         samtools index -b ~{bamFile} ~{outBai}
    }
    output{
        File baiIndex = outBai
    }
    runtime{
       docker: "quay.io/staphb/samtools:1.15"
    }

}

task SortandIndexBam{
    input{
        File bamFile
        String referenceName
    }

    String outFile = basename(bamFile, "_filtered.bam")+ "sorted.bam"
    command<<<
        samtools sort -o ~{outFile} ~{bamFile}
        samtools index ~{outFile}

    >>>

    output{
        File sortedBam = outFile
    }

    runtime{
       docker: "quay.io/staphb/samtools:1.15"
    }
}
task CombineResults1{
    input{
        File sortedBam
        String referenceName
    }
    String outFile = basename(sortedBam, ".bam") + "gene_names.txt"
    command<<<
        samtools view -F 4 ~{sortedBam} |
        awk -F '\t' '!/\*/ && !seen[$3]++ { print $3 }' |
        sed '1 i\GENE' > ~{outFile}
    >>>
 
    output{
        File out = outFile
    }
    runtime {
        docker: "quay.io/staphb/samtools:1.15"
    }
}

task CombineResults2{
    input{
        File sortedReads
        String referenceName
    }
    String outFile =  basename(sortedReads, ".bam")+ "_counts.txt"
    command<<<
        samtools view -F 4 ~{sortedReads} | awk -F '\t' '!/\*/ { count[$3]++ } END { for (i in count) print i }' > ~{outFile}
    >>>
    output{
        File out = outFile
    }
    runtime {
        docker: "quay.io/staphb/samtools:1.15"
    }
}


task AddSampleNames {
    input {
        File sample
        String referenceName
    }
    String baseName = basename(sample, "_counts")
    String outFile = basename(sample, "_counts") + "renamed_counts.txt"

    command {
        sed '1 i\${baseName}' ~{sample} > ~{outFile}
    }

    output {
        File renamedSampleCount = outFile
    }

}

task Create_ARG_Genemat {
    input {
        File geneNames
        Array[File] renamedSampleCounts
        String referenceName
    }

    File outFile = "${referenceName}_ARG_genemat.txt"

    command <<< 
        echo "-- Creating ARG_genemat --"
        paste ${geneNames} ${sep=' '} ${renameSampleCounts.join(" ")} > ${outFile}
    >>>
    output {
        File ARG_genemat = outFile
    }
}