# Mini-proyecto: de lecturas NGS a variantes (variant calling)

Proyecto personal **en curso** para actualizar y poner en práctica lo aprendido en el Máster en Bioinformática (Universitat de València): alineamiento, formatos BAM/VCF, control de calidad y llamada de variantes germinales.

## Objetivo

Construir un pipeline reproducible, desde lecturas FASTQ de una muestra pública hasta un VCF con variantes, y clasificar unas pocas variantes siguiendo los criterios ACMG.

## Datos

Muestra pública de referencia (por ejemplo, una región pequeña de una muestra de Genome in a Bottle) y genoma de referencia humano. Se indicará aquí la fuente exacta y el identificador usados.

## Herramientas

BWA-MEM, samtools, GATK (MarkDuplicates, HaplotypeCaller, GenotypeGVCFs) y bcftools.

## Pasos

1. Indexado de la referencia.
2. Alineamiento con BWA-MEM y ordenación con samtools (BAM).
3. Marcado de duplicados con GATK.
4. Control de calidad: porcentaje de lecturas alineadas, cobertura y duplicados (samtools flagstat y coverage).
5. Llamada de variantes con GATK HaplotypeCaller (gVCF) y genotipado (VCF).
6. Resumen de variantes con bcftools stats.
7. **Pendiente:** anotación y clasificación de 3-5 variantes (frecuencia poblacional, predictores in silico, ACMG) con VarSome o InterVar.

## Uso

```bash
# Entorno (conda)
conda create -n varcall -c bioconda -c conda-forge bwa samtools bcftools gatk4
conda activate varcall

# Ejecución
bash pipeline.sh referencia.fa muestra_R1.fastq.gz muestra_R2.fastq.gz MUESTRA [region]
```

## Estado

- [x] Estructura del repositorio y pipeline inicial
- [ ] Ejecución sobre datos públicos y resultados de QC
- [ ] Anotación y clasificación de variantes
- [ ] Documentación de resultados

## Autora

Carla Perpiñá Clérigues
