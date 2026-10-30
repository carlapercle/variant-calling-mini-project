#!/usr/bin/env bash
# Pipeline básico de alineamiento y variant calling germinal (datos Illumina paired-end).
# Uso: bash pipeline.sh referencia.fa R1.fastq.gz R2.fastq.gz MUESTRA [region]
# Ejemplo de región: chr20:1-5000000 (para acelerar pruebas)

set -euo pipefail

if [ "$#" -lt 4 ]; then
  echo "Uso: bash pipeline.sh referencia.fa R1.fastq.gz R2.fastq.gz MUESTRA [region]" >&2
  exit 1
fi

REF=$1
R1=$2
R2=$3
SAMPLE=$4
REGION=${5:-}
THREADS=${THREADS:-4}
OUT=results/${SAMPLE}
mkdir -p "${OUT}"

# 0. Índices de la referencia
[ -f "${REF}.bwt" ] || bwa index "${REF}"
[ -f "${REF}.fai" ] || samtools faidx "${REF}"
[ -f "${REF%.*}.dict" ] || gatk CreateSequenceDictionary -R "${REF}"

# 1. Alineamiento y ordenación
bwa mem -t "${THREADS}" \
  -R "@RG\tID:${SAMPLE}\tSM:${SAMPLE}\tPL:ILLUMINA\tLB:lib1" \
  "${REF}" "${R1}" "${R2}" \
  | samtools sort -@ "${THREADS}" -o "${OUT}/${SAMPLE}.sorted.bam" -
samtools index "${OUT}/${SAMPLE}.sorted.bam"

# 2. Marcado de duplicados
gatk MarkDuplicates \
  -I "${OUT}/${SAMPLE}.sorted.bam" \
  -O "${OUT}/${SAMPLE}.dedup.bam" \
  -M "${OUT}/${SAMPLE}.dup_metrics.txt"
samtools index "${OUT}/${SAMPLE}.dedup.bam"

# 3. Control de calidad
samtools flagstat "${OUT}/${SAMPLE}.dedup.bam" > "${OUT}/${SAMPLE}.flagstat.txt"
samtools coverage "${OUT}/${SAMPLE}.dedup.bam" > "${OUT}/${SAMPLE}.coverage.txt"

# 4. Variant calling (gVCF) y genotipado (VCF)
INTERVAL=()
if [ -n "${REGION}" ]; then INTERVAL=(-L "${REGION}"); fi

gatk HaplotypeCaller \
  -R "${REF}" \
  -I "${OUT}/${SAMPLE}.dedup.bam" \
  -O "${OUT}/${SAMPLE}.g.vcf.gz" \
  -ERC GVCF \
  "${INTERVAL[@]}"

gatk GenotypeGVCFs \
  -R "${REF}" \
  -V "${OUT}/${SAMPLE}.g.vcf.gz" \
  -O "${OUT}/${SAMPLE}.vcf.gz" \
  "${INTERVAL[@]}"

# 5. Resumen de variantes
bcftools stats "${OUT}/${SAMPLE}.vcf.gz" > "${OUT}/${SAMPLE}.vcf.stats.txt"

echo "Hecho. Resultados en ${OUT}/"
