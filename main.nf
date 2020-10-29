nextflow.preview.dsl=2

//////////////////////////////////////////////////////
//  Import sub-workflows from the modules:

include { SC__BWAMAPTOOLS__BWA_MEM_PE; } from './processes/mapping.nf' params(params)
include { SC__BWAMAPTOOLS__INDEX_BAM; } from './processes/index.nf' params(params)
include { SC__BWAMAPTOOLS__ADD_BARCODE_TAG; } from './processes/add_barcode_as_tag.nf' params(params)


//////////////////////////////////////////////////////
// Define the workflow

workflow BWA_MAPPING_PE {

    take:
        data // a channel of [val(sampleId), path(fastq_PE1), path(fastq_PE2)]

    main:
        /* 
           1) create a channel linking bwa index files from genome.fa in params, and
           2) combine this channel with the items in the data channel
        */
        bwa_inputs = Channel.fromPath(params.sc.atac.bwamaptools.index)
                            .combine(data)

        bam = SC__BWAMAPTOOLS__BWA_MEM_PE(bwa_inputs)

        bam_with_tag = SC__BWAMAPTOOLS__ADD_BARCODE_TAG(bam)

        bam_index = SC__BWAMAPTOOLS__INDEX_BAM(bam_with_tag)

        // join bam index into the bam channel:
        bamout = bam_with_tag.join(bam_index)
        
    emit:
        bamout

}

