include { PICARD_MARKDUPLICATES } from '../../../modules/nf-core/picard/markduplicates/main'
include { SAMTOOLS_SORMADUP     } from '../../../modules/nf-core/samtools/sormadup/main'
include { SAMTOOLS_INDEX        } from '../../../modules/nf-core/samtools/index/main'
include { ALIGNMENT_QC          } from '../alignment_qc/main'

workflow DEDUPLICATE {

    take:
    duplicate_marker
    ch_sample_alignments_indexed
    ch_reference_and_fai
    ch_multiqc_files

    main:
    if ( duplicate_marker == 'picard' ) {
        PICARD_MARKDUPLICATES(
            ch_sample_alignments_indexed.map { meta, alignment, _index -> [ meta, alignment ] },
            ch_reference_and_fai
        )
        SAMTOOLS_INDEX(
            PICARD_MARKDUPLICATES.out.bam
                .mix(PICARD_MARKDUPLICATES.out.cram)
        )
        ch_deduplicated_alignments_indexed = PICARD_MARKDUPLICATES.out.bam
            .mix(PICARD_MARKDUPLICATES.out.cram)
            .join(SAMTOOLS_INDEX.out.index)
        ch_multiqc_files = ch_multiqc_files
            .mix(PICARD_MARKDUPLICATES.out.metrics.map { _meta, file -> file })
    } else if ( duplicate_marker == 'samtools' ) {
        SAMTOOLS_SORMADUP(
            ch_sample_alignments_indexed.map { meta, alignment, _index -> [ meta, alignment ] },
            ch_reference_and_fai
        )
        ch_bam  = SAMTOOLS_SORMADUP.out.bam.join(SAMTOOLS_SORMADUP.out.csi)
        ch_cram = SAMTOOLS_SORMADUP.out.cram.join(SAMTOOLS_SORMADUP.out.crai)
        ch_deduplicated_alignments_indexed = ch_bam.mix(ch_cram)
        ch_multiqc_files = ch_multiqc_files
            .mix(SAMTOOLS_SORMADUP.out.metrics.map { _meta, file -> file })
    }

    emit:
    ch_deduplicated_alignments_indexed
    ch_multiqc_files

}
