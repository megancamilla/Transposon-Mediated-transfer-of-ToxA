#!/bin/bash
#this is a simple bash script to run TEdenovo

set -vx

source activate funannotate

#get the folder and directories we are are in

CURDIR=$PWD
echo $CURDIR

########CHANGE THE INPUT TEdenovo database before staring off########
denovoTElib=/home/benjamin/Megan/REPET2/combined_TEs/six_TEs_without_Redundancy_ToxA.fa

########THIS SHALL BE THE MYSQL TABELS THAT ARE USED TO CLASSIFY ALL THE REPEATS OF all Tedenovolibs######
########INCASE YOU COMBINED MULIPLE TEDENOVO DATABASES BY 'HAND' YOU NEED TO GENERATE THE RESPECTIVE MYSQL TABLE  'HAND'####
CLASSIF_TABLE=six_TEs_without_Redundancy_ToxA_consensus_classif

genome=$1
len=${#genome}
PNAME=${genome:0:len-3}
TEANO0CFG=Teano0_${PNAME}.cfg
TEannotmp=TEannot.cfg.tmp

#get the genome size which is required later on for post analysis
gsize="$(grep -v '^>' $genome | wc -m)"

#check if PNAME is less than 15 characters
if [ $len -gt 17 ]
then
	echo "Shorten your genome fasta file name to less than 17 characters"
	exit
fi

#soft link all the databases
ln -s ~/anaconda3/envs/funannotate/REPET_linux-x64-2.5/db/repbase20.05_aaSeq_cleaned_TE.fa .
ln -s ~/anaconda3/envs/funannotate/REPET_linux-x64-2.5/db/repbase20.05_ntSeq_cleaned_TE.fa .
ln -s /home/benjamin/anaconda3/envs/funannotate/REPET_linux-x64-2.5/db/ProfilesBankForREPET_Pfam27.0_GypsyDB.hmm .
ln -s /home/benjamin/anaconda3/envs/funannotate/REPET_linux-x64-2.5/db/SILVA_132_XSURef_tax_silva_trunc.fasta .
cp /home/benjamin/anaconda3/envs/funannotate/REPET_linux-x64-2.5/config/${TEannotmp} .
cp ${denovoTElib} ${PNAME}_refTEs.fa


#source the REPET config file to set up the environment
source /home/benjamin/anaconda3/envs/funannotate/REPET_linux-x64-2.5/config/setEnv.sh

#fix up the TEdenovo.cfg file
cat ${TEannotmp} |  sed "s/P_NAME/$PNAME/" | sed  's|P_DIR|'$CURDIR'|' | sed  's|CLASSIF_TABLE|'$CLASSIF_TABLE'|' > ${TEANO0CFG}
rm ${TEannotmp} 




#now run the whole pipeline
TEannot.py -P ${PNAME} -C ${TEANO0CFG} -S 1
TEannot.py -P ${PNAME} -C ${TEANO0CFG} -S 2 -a BLR
TEannot.py -P ${PNAME} -C ${TEANO0CFG} -S 2 -a CEN
TEannot.py -P ${PNAME} -C ${TEANO0CFG} -S 2 -a RM
TEannot.py -P ${PNAME} -C ${TEANO0CFG} -S 2 -a BLR -r
TEannot.py -P ${PNAME} -C ${TEANO0CFG} -S 2 -a CEN -r
TEannot.py -P ${PNAME} -C ${TEANO0CFG} -S 2 -a RM -r
TEannot.py -P ${PNAME} -C ${TEANO0CFG} -S 3 -c BLR+RM+CEN
TEannot.py -P ${PNAME} -C ${TEANO0CFG} -S 6 -b tblastx
TEannot.py -P ${PNAME} -C ${TEANO0CFG} -S 6 -b blastx
TEannot.py -P ${PNAME} -C ${TEANO0CFG} -S 7
TEannot.py -P ${PNAME} -C ${TEANO0CFG} -S 8 -o GFF3


srptCreateTable.py -f ${PNAME}_refTEs.fa -n ${PNAME}_refTEs -t fasta -c ${TEANO0CFG}

mkdir postanalysis
cp ${PNAME}_refTEs.fa postanalysis/.
cd postanalysis


#
#now do post analysis

PostAnalyzeTELib.py -p ${PNAME}_chr_allTEs_path -s ${PNAME}_refTEs_seq -i ${PNAME}_refTEs.fa -g ${gsize}
PostAnalyzeTELib.py -a 2 -t ${PNAME}_refTEs.fa_blastclust.tab

PostAnalyzeTELib.py -a 3 -p ${PNAME}_chr_allTEs_path -s ${PNAME}_refTEs_seq -g ${gsize}
GetSpecificTELibAccordingToAnnotation.py -i ${PNAME}_chr_allTEs_path.annotStatsPerTE.tab -t ${PNAME}_refTEs_seq
PostAnalyzeTELib.py -a 3 -p ${PNAME}_chr_allTEs_nr_join_path -s ${PNAME}_refTEs_seq -g ${gsize}
GetSpecificTELibAccordingToAnnotation.py -i ${PNAME}_chr_allTEs_nr_join_path.annotStatsPerTE.tab -t ${PNAME}_refTEs_seq

PostAnalyzeTELib.py -a 3 -p ${PNAME}_chr_bankBLRx_path -s repbase2005_aaSeq_cleaned_TE -g ${gsize}
GetSpecificTELibAccordingToAnnotation.py -i ${PNAME}_chr_bankBLRx_path.annotStatsPerTE.tab -t repbase2005_aaSeq_cleaned_TE

PostAnalyzeTELib.py -a 3 -p ${PNAME}_chr_bankBLRtx_path -s repbase2005_ntSeq_cleaned_TE -g ${gsize}
GetSpecificTELibAccordingToAnnotation.py -i ${PNAME}_chr_bankBLRtx_path.annotStatsPerTE.tab -t repbase2005_ntSeq_cleaned_TE

#now do the second round of TE annotation

#denovoTElib1=${CURDIR}/${PNAME}_chr_allTEs_nr_join_path.annotStatsPerTE_FullLengthFrag.fa

#mkdir TEanno_full
#cd TEanno_full

#now set new variables
#CURDIR=$PWD
#genome1="$(echo $genome | sed 's/a0/a1/')"
#len1=${#genome1}
#PNAME1=${genome1:0:len1-3}
#TEANO1CFG=Teano1_${PNAME1}.cfg



#soft link all the databases
#ln -s ~/anaconda3/envs/funannotate/REPET_linux-x64-2.5/db/repbase20.05_aaSeq_cleaned_TE.fa .
#ln -s ~/anaconda3/envs/funannotate/REPET_linux-x64-2.5/db/repbase20.05_ntSeq_cleaned_TE.fa .
#cp /home/benjamin/anaconda3/envs/funannotate/REPET_linux-x64-2.5/config/${TEannotmp} .
#cp ${denovoTElib1} ${PNAME1}_refTEs.fa
#cp ../${genome} ${genome1}


#fix up the TEannot.cfg file
#cat ${TEannotmp} |  sed "s/P_NAME/$PNAME1/" | sed  's|P_DIR|'$CURDIR'|' | sed  's|CLASSIF_TABLE|'$CLASSIF_TABLE'|' > ${TEANO1CFG}
#rm ${TEannotmp}

#now run the second round of annotation

#now run the whole pipeline
#TEannot.py -P ${PNAME1} -C ${TEANO1CFG} -S 1
#TEannot.py -P ${PNAME1} -C ${TEANO1CFG} -S 2 -a BLR
#TEannot.py -P ${PNAME1} -C ${TEANO1CFG} -S 2 -a CEN
#TEannot.py -P ${PNAME1} -C ${TEANO1CFG} -S 2 -a RM
#TEannot.py -P ${PNAME1} -C ${TEANO1CFG} -S 2 -a BLR -r
#TEannot.py -P ${PNAME1} -C ${TEANO1CFG} -S 2 -a CEN -r
#TEannot.py -P ${PNAME1} -C ${TEANO1CFG} -S 2 -a RM -r
#TEannot.py -P ${PNAME1} -C ${TEANO1CFG} -S 3 -c BLR+RM+CEN
#TEannot.py -P ${PNAME1} -C ${TEANO1CFG} -S 4 -s TRF
#TEannot.py -P ${PNAME1} -C ${TEANO1CFG} -S 4 -s Mreps
#TEannot.py -P ${PNAME1} -C ${TEANO1CFG} -S 4 -s RMSSR
#TEannot.py -P ${PNAME1} -C ${TEANO1CFG} -S 5
#TEannot.py -P ${PNAME1} -C ${TEANO1CFG} -S 6 -b tblastx
#TEannot.py -P ${PNAME1} -C ${TEANO1CFG} -S 6 -b blastx
#TEannot.py -P ${PNAME1} -C ${TEANO1CFG} -S 7
#TEannot.py -P ${PNAME1} -C ${TEANO1CFG} -S 8 -o GFF3

#now to the full post analysis in new folder

#mkdir postanalysis
#cp ${PNAME1}_refTEs.fa postanalysis/.
#cd postanalysis

#PostAnalyzeTELib.py -p ${PNAME1}_chr_allTEs_path -s ${PNAME1}_refTEs_seq -i ${PNAME1}_refTEs.fa -g ${gsize}
#PostAnalyzeTELib.py -a 2 -t ${PNAME1}_refTEs.fa_blastclust.tab
#
#PostAnalyzeTELib.py -a 3 -p ${PNAME1}_chr_allTEs_path -s ${PNAME1}_refTEs_seq -g ${gsize}
#GetSpecificTELibAccordingToAnnotation.py -i ${PNAME1}_chr_allTEs_path.annotStatsPerTE.tab -t ${PNAME1}_refTEs_seq
#PostAnalyzeTELib.py -a 3 -p ${PNAME1}_chr_allTEs_path -s ${PNAME1}_refTEs_seq -g ${gsize}
#PostAnalyzeTELib.py -a 3 -p ${PNAME1}_chr_allTEs_nr_noSSR_join_path -s ${PNAME1}_refTEs_seq -g ${gsize}
#GetSpecificTELibAccordingToAnnotation.py -i ${PNAME1}_chr_allTEs_nr_noSSR_join_path.annotStatsPerTE.tab -t ${PNAME1}_refTEs_seq
#
#PostAnalyzeTELib.py -a 3 -p ${PNAME1}_chr_bankBLRx_path -s repbase2005_aaSeq_cleaned_TE -g ${gsize}
#GetSpecificTELibAccordingToAnnotation.py -i ${PNAME1}_chr_bankBLRx_path.annotStatsPerTE.tab -t repbase2005_aaSeq_cleaned_TE
#
#PostAnalyzeTELib.py -a 3 -p ${PNAME1}_chr_bankBLRtx_path -s repbase2005_ntSeq_cleaned_TE -g ${gsize}
#GetSpecificTELibAccordingToAnnotation.py -i ${PNAME1}_chr_bankBLRtx_path.annotStatsPerTE.tab -t repbase2005_ntSeq_cleaned_TE

