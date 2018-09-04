#!/bin/bash
AUTHOR='Bruno Gomez-Gil' # Laboratorio de Genomica Microbiana, CIAD.
NAME='coverage_calculator'
REV='Sept. 03, 2018'
VER='v0.0.1'
LINK='https://github.com/GenomicaMicrob/coverage_calculator'
DEP='None'

display_help(){
echo -e "
____________________ $NAME $VER ______________________________

This script will calculate the coverage of a genome assembly based
on the number of bases on a sequencing pair-end fastq file (R1.fastq)
and a genome assembly fasta file (assembly.fasta).

\e[1mUSAGE\e[0m: $NAME R1.fastq assembly.fasta

\e[1mNOTE:\e[0m the order of the files is important. Please provide
first the fastq file and then the genome assembly fasta file.
Either pair-end fastq file will work, provided these are the fastq
files used to construct the assembly. They should be already cleaned
and trimmed.

_________________________________________________________________________

"
}
if [ "$1" == "-h" ]
	then
		display_help
		exit 1
fi 	# -h is typed, displays usage

display_usage(){
echo -e "
____________________ $NAME $VER ______________________________

\e[1mERROR\e[0m: missing files

\e[1mUSAGE\e[0m: $NAME R1.fastq assembly.fasta

Please provide first the fastq file and then the genome assembly 
fasta file. Either pair-end fastq file will work.

_________________________________________________________________________

"
}
if [  $# -le 1 ] 
	then 
		display_usage
		exit 1
fi # less than 2 arguments supplied, display usage 

TOTAL_FASTQ_BASES=$(cat $1 | paste - - - - | cut -f 2 | tr -d '\n' | wc -c | awk '{print $1*2}') # Get the number of bases in the fastq file R1 and multiplies it by two
FASTQ_SEQS=$(cat $1 | echo $((`wc -l`/4))) # calculates the number of fastq sequences
TOTAL_FASTQ_SEQUENCES=$(($FASTQ_SEQS *2)) # multiplies the number of fastq sequences in one file by two
CONTIGS=$(grep -c ">" $2) # Get the number of contigs in an assembly
TOTAL_CONTIG_BASES=$(grep -v ">" $2 | wc | sed 's/ /\t/g' | rev | cut -f1 | rev) # Counts the number of bases in an assembly
COVERAGE=$(bc <<< "scale=1; $TOTAL_FASTQ_BASES / $TOTAL_CONTIG_BASES") # Calculates the coverage with one decimal
N50=$(awk '/^>/ {if (seqlen){print seqlen}; print ;seqlen=0;next; } { seqlen += length($0)}END{print seqlen}' $2 | grep -v ">" | sort -n | awk '{len[i++]=$1;sum+=$1} END {for (j=0;j<i+1;j++) {csum+=len[j]; if (csum>sum/2) {print len[j];break}}}' | sed -r ':L;s=\b([0-9]+)([0-9]{3})\b=\1,\2=g;t L') # Variable to get the N50, separated by commas
#Comma separated values
TOTAL_FASTQ_BASES2=$(echo $TOTAL_FASTQ_BASES | sed -r ':L;s=\b([0-9]+)([0-9]{3})\b=\1,\2=g;t L')
TOTAL_CONTIG_BASES2=$(echo $TOTAL_CONTIG_BASES | sed -r ':L;s=\b([0-9]+)([0-9]{3})\b=\1,\2=g;t L')
TOTAL_FASTQ_SEQUENCES2=$(echo $TOTAL_FASTQ_SEQUENCES | sed -r ':L;s=\b([0-9]+)([0-9]{3})\b=\1,\2=g;t L')
echo -e "
You have $CONTIGS contigs (N50 = $N50) with a total of $TOTAL_CONTIG_BASES2 bases
and a total of $TOTAL_FASTQ_SEQUENCES2 fastq sequences with $TOTAL_FASTQ_BASES2 total bases.
The coverage of the genome is \e[1m"$COVERAGE"X\e[0m
"
# TSV file
cat > coverage.tsv << REPORT
Assembly	$2
Number contigs	$CONTIGS
N50 $N50
Total bases	$TOTAL_CONTIG_BASES2
Total fastq sequences	$TOTAL_FASTQ_SEQUENCES2
Total fastq bases	$TOTAL_FASTQ_BASES2
Coverage	$COVERAGE
REPORT
# This is the end
