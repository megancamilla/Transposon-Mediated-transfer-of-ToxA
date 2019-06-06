###These are simple instructions on how the three files in this folder can be used to run REPET TEdenovo.

##First: You need a genome sequence in fasta format. IMPORTANT: Fasta file should be wrapped every 60 characters.

##Next in environment that contains all your executables and correct python verion run:

run_TEdenovo.sh isolate.fa

## For this to work on your own computer you need to look at the paths hard-coded into TEdenovo.sh
## TEdenovo.sh tells REPET where all the repeat databases are, where the config file is etc etc.
## Note Tedenovo_CS10.cfg is CREATED by TEdenovo.sh from a template cfg file
## Please also see https://github.com/BenjaminSchwessinger/Pst_104_E137_A-_genome for help filtering TEs.


