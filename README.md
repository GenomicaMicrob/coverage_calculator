# coverage_calculator
A simple bash script to calculate the coverage of a genome assembly.

This script will calculate the coverage of a genome assembly based
on the number of bases on a sequencing pair-end fastq file (R1.fastq)
and a genome assembly fasta file (assembly.fasta). Either pair-end fastq file will work.

## Installation

Just download the script and make it executable: `chmod +x coverage_calculator.v0.0.1.sh`

## Usage

`coverage_calculator.v0.0.1.sh R1.fastq assembly.fasta`

It will present the results in Stdout but also make a report called `coverage.tsv` with the following data:
* Assembly file used
* Number contigs
* N50
* Total bases in the assembly
* Total fastq sequences
* Total fastq bases
* Coverage
