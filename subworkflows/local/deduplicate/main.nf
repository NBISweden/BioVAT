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
    enable

    main:
    if ( duplicate_marker == 'picard' ) {
        PICARD_MARKDUPLICATES(
            ch_sample_alignments_indexed.map { meta, alignment, _index -> [ meta, alignment ] },
            ch_reference_and_fai
        )
        ch_deduplicated_alignments = PICARD_MARKDUPLICATES.out.bam.mix(PICARD_MARKDUPLICATES.out.cram)
        SAMTOOLS_INDEX(
            ch_deduplicated_alignments
        )
        ch_deduplicated_alignments_indexed = ch_deduplicated_alignments
            .join(SAMTOOLS_INDEX.out.index)
        ch_deduplication_metrics           = PICARD_MARKDUPLICATES.out.metrics
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
        ch_deduplication_metrics           = SAMTOOLS_SORMADUP.out.metrics
        ch_multiqc_files = ch_multiqc_files
            .mix(SAMTOOLS_SORMADUP.out.metrics.map { _meta, file -> file })
    }

    // DEDUPLICATE:ALIGNMENT_QC
    outputs_deduplicated_flagstat = channel.empty()
    outputs_deduplicated_riker    = channel.empty()
    outputs_deduplicated_qualimap = channel.empty()
    if ( enable.align_qc ) {
        ALIGNMENT_QC(
            ch_deduplicated_alignments_indexed,
            ch_reference_and_fai,
            enable,
            'markdup'
        )
        ch_multiqc_files = ch_multiqc_files
            .mix(
                ALIGNMENT_QC.out.flagstat_outputs.map{ _meta, file -> file },
                ALIGNMENT_QC.out.riker_outputs.map{ _meta, file -> file },
                ALIGNMENT_QC.out.qualimap_outputs.map{ _meta, file -> file }
            )
        outputs_deduplicated_flagstat = ALIGNMENT_QC.out.flagstat_outputs
        outputs_deduplicated_riker    = ALIGNMENT_QC.out.riker_outputs
        outputs_deduplicated_qualimap = ALIGNMENT_QC.out.qualimap_outputs
    }

    emit:
    ch_deduplicated_alignments_indexed
    ch_deduplication_metrics
    ch_multiqc_files
    outputs_deduplicated_flagstat
    outputs_deduplicated_riker
    outputs_deduplicated_qualimap

}
