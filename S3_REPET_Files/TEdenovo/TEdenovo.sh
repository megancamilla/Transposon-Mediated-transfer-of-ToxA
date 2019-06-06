#!/bin/bash
#this is a simple bash script to run TEdenovo

set -vx

source activate funannotate

#get the folder and directories we are are in

CURDIR=$PWD
echo $CURDIR

genome=$1
len=${#genome}
PNAME=${genome:0:len-3}

REPSCOUT=${CURDIR}/${PNAME}_RepeatScoutConsensus.fa

TEDENOVOCFG=Tedenovo_${PNAME}.cfg

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
cp /home/benjamin/anaconda3/envs/funannotate/REPET_linux-x64-2.5/config/TEdenovo.cfg.tmp .

#source the REPET config file to set up the environment
source /home/benjamin/anaconda3/envs/funannotate/REPET_linux-x64-2.5/config/setEnv.sh

#fix up the TEdenovo.cfg file
cat TEdenovo.cfg.tmp |  sed "s/P_NAME/$PNAME/" | sed  's|P_DIR|'$CURDIR'|' | sed  's|P_dir_RepScout|'$REPSCOUT'|' > ${TEDENOVOCFG}
rm TEdenovo.cfg.tmp 


#before we start the whole pipeline run the repeatscout

/home/benjamin/anaconda3/envs/funannotate/REPET_linux-x64-2.5/bin/LaunchRepeatScout.py -i $genome

#now run the whole pipeline

TEdenovo.py -P ${PNAME} -C ${TEDENOVOCFG} -S 1
TEdenovo.py -P ${PNAME} -C ${TEDENOVOCFG} -S 2 -s Blaster
TEdenovo.py -P ${PNAME} -C ${TEDENOVOCFG} -S 2 --struct
TEdenovo.py -P ${PNAME} -C ${TEDENOVOCFG} -S 3 -s Blaster -c Grouper
TEdenovo.py -P ${PNAME} -C ${TEDENOVOCFG} -S 3 -s Blaster -c Recon
TEdenovo.py -P ${PNAME} -C ${TEDENOVOCFG} -S 3 -s Blaster -c Piler
TEdenovo.py -P ${PNAME} -C ${TEDENOVOCFG} -S 3 --struct
TEdenovo.py -P ${PNAME} -C ${TEDENOVOCFG} -S 4 -s Blaster -c Grouper -m Map
TEdenovo.py -P ${PNAME} -C ${TEDENOVOCFG} -S 4 -s Blaster -c Recon -m Map
TEdenovo.py -P ${PNAME} -C ${TEDENOVOCFG} -S 4 -s Blaster -c Piler -m Map
TEdenovo.py -P ${PNAME} -C ${TEDENOVOCFG} -S 4 --struct -m Map
TEdenovo.py -P ${PNAME} -C ${TEDENOVOCFG} -S 5 -s Blaster -c GrpRecPil -m Map --struct
TEdenovo.py -P ${PNAME} -C ${TEDENOVOCFG} -S 6 -s Blaster -c GrpRecPil -m Map --struct
TEdenovo.py -P ${PNAME} -C ${TEDENOVOCFG} -S 7 -s Blaster -c GrpRecPil -m Map --struct
TEdenovo.py -P ${PNAME} -C ${TEDENOVOCFG} -S 8 -s Blaster -c GrpRecPil -m Map -f Blastclust --struct
TEdenovo.py -P ${PNAME} -C ${TEDENOVOCFG} -S 8 -s Blaster -c GrpRecPil -m Map -f MCL --struct

#done now


