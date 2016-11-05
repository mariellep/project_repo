#!/bin/bash 

# sub_ipl_data.sh
# Author: Marielle Pinheiro
# Version 3.2 April 22, 2016

# This script will subset the cam5 data and then interpolate it to pressure
# levels. The job will be semi-parallelized by submitting several serial jobs.
# It also runs a check for files that have a time axis of length 0 or are missing
# a corresponding h2 or h4 file

# H2 and H4 files need to be in separate directories or this code won't work!

#HOW TO RUN THE SCRIPT:
# At the command line enter:
# ./sub_ipl_data.sh   WITH THE ADDITIONAL FLAGS:
############################################################
# -------------SPECIFY THE TYPE OF JOB BEING RUN-----------#
############################################################
#Specify one or both:
# --sub
# --ipl
# Both are booleans that tell the script which part to run (defaults to false)
############################################################
# -----SPECIFY THE DIRECTORY WHERE YOUR DATA IS STORED-----#
############################################################
# --h2dir=[DIRECTORY WHERE H2 FILES STORED] 
# --h4dir=[DIRECTORY WHERE H4 FILES STORED]
############################################################
#---------SPECIFY YOUR LIST OF VARIABLES-------------------#
############################################################
# --v2list=[LIST OF H2 VARIABLE NAMES] 
# --v4list=[LIST OF H4 VARIABLE NAMES]
#  VARIABLE LIST MUST BE IN FORMAT "V1,V2,V3,V4" WITH NO SPACES IN BETWEEN VARIABLES
# If running --ipl only, don't need --v2list
############################################################
#--------------------OTHER OPTIONS-------------------------#
############################################################
# --sjname=[CUSTOMIZED NAME OF SUBSET BATCH SCRIPT]
# --ijname=[CUSTOMIZED NAME OF INTERPOLATE BATCH SCRIPT]
# --iplstring=[SEARCH PATTERN FOR FILES THAT WILL BE USED BY INTERPOLATION SCRIPT]
# --njobs=[NUMBER OF JOBS TO SPLIT FILES INTO]

#EXAMPLES:

# If only subsetting h2 variables:
# ./sub_ipl_data.sh --sub --h2dir=[DIRECTORY] --v2list=[DIRECTORY]
# If subsetting both h2 and h4 variables:
# ./sub_ipl_data.sh --sub --h2dir=[DIRECTORY] --v2list=[VARLIST] --h4dir=[DIRECTORY] --v4list=[VARLIST]

# Interpolating files: Assumes files have _sub.nc suffix
# Change search pattern if necessary using --iplstring=
# ./sub_ipl_data.sh --ipl --h2dir=[DIRECTORY] --h4dir=[DIRECTORY] --v4list=[VARLIST] --iscript=[FULL FILEPATH TO NCL SCRIPT]

VAR_LIST1=""
VAR_LIST2=""
H2DIR=""
H4DIR=""

SUB_JNAME="sub_batch"
IPL_JNAME="ipl_batch"
N_JOBS="8"
SUB_BOOL="FALSE"
IPL_BOOL="FALSE"
IPL_FILESEARCH="*_sub.nc"

IPL_SCRIPT=""

for i in "$@"; do
	case $i in
    --v2list=*)
	    VAR_LIST1="${i#*=}"
    ;;
    --v4list=*)
      VAR_LIST2="${i#*=}"
    ;;
		--h2dir=*)
			H2DIR="${i#*=}"
		;;
		--h4dir=*)
			H4DIR="${i#*=}"
		;;
		--sjname=*)
			SUB_JNAME="${i#*=}"
		;;
		--ijname=*)
			IPL_JNAME="${i#*=}"
		;;
		--njobs=*)
			N_JOBS="${i#*=}"
		;;
    --sub)
	    SUB_BOOL="TRUE"
    ;;
    --ipl)
	    IPL_BOOL="TRUE"
    ;;
    --iplstring=*)
	    IPL_FILESEARCH="${i#*=}"
    ;;
		--iscript=*)
			IPL_SCRIPT="${i#*=}"
		;;
	esac
done

MAX_N_JOBS=$((N_JOBS))

#Check that H2 and/or H4 directories have been specified
if [ "$H2DIR" == "" ] && [ "$H4DIR" == "" ]; then
	echo "Need to specify at least one directory"
	exit
fi

if [ "$VAR_LIST1" == "" ] && [ "$VAR_LIST2" == "" ]; then
	echo "Error: need to specify at least one variable."
	exit
fi

if [ "$SUB_BOOL" == "TRUE" ]; then
	#Array of directories, variables
	DIR_ARR=()
	VAR_ARR=()

	if [ "$H2DIR" != "" ]; then
	    if [ "$VAR_LIST1" == "" ]; then
	        echo "Error: H2 directory specified, but not variable names"
	    fi
	    DIR_ARR+=("$H2DIR")
	    VAR_ARR+=("$VAR_LIST1")
	fi

	if [ "$H4DIR" != "" ]; then
	    if [ "$VAR_LIST2" == "" ]; then
	        echo "Error: H4 directory specified, but not variable names"
	    fi
	    DIR_ARR+=("$H4DIR")
	    VAR_ARR+=("$VAR_LIST2")
	fi

	for d in ${DIR_ARR[@]}; do
	  i=0
	  cd $d
		SUBDIR=$d/sub
	  if [ ! -e $SUBDIR ]; then
	    mkdir -p $SUBDIR
	  fi

	  VAR_LIST="${VAR_ARR[i]}"
		if [ -e list_files.txt ]; then
			rm list_files.txt
		fi

		for f in *.nc; do
			TDIM_LEN=$(ncdump -h $f | grep "time =" | tr -dc "0-9")
			if [ $TDIM_LEN -lt 1 ]; then
				echo "$f has time dimension of length 0. Removing file."
				echo "$f" >>t0_list.txt
				rm $f
			else
				echo "$f" >> list_files.txt
			fi
		done
	  #Number of files per job
		TOT_N_FILES=$(cat list_files.txt | wc -l)
		N_FILES_PER_JOB=$(($TOT_N_FILES/$MAX_N_JOBS))
		REM_FILES=$(($TOT_N_FILES%$MAX_N_JOBS))
		if [ $REM_FILES -gt 0 ]; then
			MAX_N_JOBS=$(($MAX_N_JOBS + 1))
		fi
		#Split up the files among nodes for subsetting and interpolating
	  cat list_files.txt | sed "s:^:$(pwd)/:" | split -dl $N_FILES_PER_JOB  - $d/files_per_job
		#This outputs a series of files with the name files_per_job[#]
	
		#Now, make the batch scripts
		x=0
		for f in files_per_job*; do
		
			#Make a corresponding list of subsetted file names
			listname="comb_list$x"
			cat $f | awk '{sub(".nc",""); print $1".nc $SUBDIR/"$1"_sub.nc"}' > $listname
			batchname="$SUB_JNAME$x"
			echo "#!/bin/bash -l" > $batchname
			echo "#SBATCH -J $batchname" >> $batchname
			echo "#SBATCH -o $batchname.output " >> $batchname
			echo "#SBATCH -N 1" >> $batchname
			echo "#SBATCH -p low " >> $batchname
			echo "" >> $batchname
			echo "module load nco" >> $batchname
			echo "cd $d" >> $batchname
			echo "cat $listname | awk -v vlist=$VAR_LIST '{print \"ncks -C -v \"vlist \" \" \$1 \" \"\$2\"; EXIT_CODE=\$?; if [ \$EXIT_CODE -lt 1 ]; then rm \"\$1\"; else echo \\\"failure\\\"; fi \"}' | sh" >> $batchname
      #submit the batch file
	    sbatch $batchname
	    x=$((x+1))
		done
	    i=$((i+1))
	done
	#Change h2 and h2 directories to the subset directories (for interpolation)
	H2DIR=$H2DIR/sub
	H4DIR=$H4DIR/sub
fi

#The utility for interpolating files
if [ "$IPL_BOOL" == "TRUE" ]; then
	if [ "$IPL_SCRIPT" == "" ]; then
		echo "Error: need to specify ncl script (--iscript). Exiting."
		exit
	fi
	if [ "$VAR_LIST2" == "" ]; then
		echo "Error: Need to specify list of h4 variables."
		exit
	fi
	#Check that H2 and/or H4 directories have been specified
	if [ "$H2DIR" == "" ] || [ "$H4DIR" == "" ]; then
		echo "Error: for interpolation, need to specify both H2 and H4 directories"
		exit
	fi
	DIR_ARR=( "$H2DIR" "$H4DIR" )
	
	#Make a directory for the interpolated files
	cd $H4DIR
	IPLDIR=../../ipl
	cd $IPLDIR
	IPLDIR="$(pwd)"
	if [ ! -e $IPLDIR ]; then
		mkdir -p $IPLDIR
	fi
	
	for d in ${DIR_ARR[@]}; do	
		#List the files in each directory
		cd $d
		nfiles=$(ls $IPL_FILESEARCH 2>/dev/null | wc -l)
		if [ $nfiles -lt 1 ]; then
			echo "Check your directory. No matching files ($IPL_FILESEARCH) in $d"
			exit
		else
			ls $IPL_FILESEARCH > $d/sub_list.txt
			cat sub_list.txt | rev | cut -d "." -f 2 | rev | cut -d "_" -f 1 > $d/dates.txt
		fi
	done
	#Now list only the matched files between the two 
	cd $IPLDIR
	comm -1 -2 $H4DIR/dates.txt $H2DIR/dates.txt > common_dates.txt
	grep -F -f common_dates.txt $H4DIR/sub_list.txt > newh4.txt
	cat newh4.txt | awk '{print "$H4DIR/"$1}' > h4list.txt
	grep -F -f common_dates.txt $H2DIR/sub_list.txt > newh2.txt
	cat newh2.txt | awk '{print "$H2DIR/"$1}' > h2list.txt
	
	#Create a list of the new interpolated file names
	cat newh4.txt | awk '{sub(".nc",""); print "$IPLDIR/"$1"_ipl.nc"}' > ipl.txt
	
	#Paste the three lists together
	paste h2list.txt h4list.txt ipl.txt > combined_list.txt
	
	#Write the batch script for submitting
  #Number of files per job
	TOT_N_FILES=$(cat combined_list.txt | wc -l)
	N_FILES_PER_JOB=$(($TOT_N_FILES/$MAX_N_JOBS))
	REM_FILES=$(($TOT_N_FILES%$MAX_N_JOBS))
	if [ $REM_FILES -gt 0 ]; then
		MAX_N_JOBS=$(($MAX_N_JOBS + 1))
	fi
	#Split up the files among nodes for subsetting and interpolating
  cat combined_list.txt | split -dl $N_FILES_PER_JOB  - $IPLDIR/files_per_job
	#This outputs a series of files with the name files_per_job[#]

	#Now, make the batch scripts and submit them
	x=0
	for f in files_per_job*; do
		batchname="$IPL_JNAME$x"
		
		echo "#!/bin/bash -l" > $batchname
		echo "#SBATCH -J $batchname" >> $batchname
		echo "#SBATCH -o $batchname.output " >> $batchname
		echo "#SBATCH -N 1" >> $batchname
		echo "#SBATCH -p low " >> $batchname
		echo "" >> $batchname
		echo "module load ncl" >> $batchname
		echo "cat ipl.txt | awk '{print \"if [ -e \"\$1\" ]; then rm \"\$1\"; fi\"}"
		echo "cat $f | awk -v vlist=$VAR_LIST2 '{print \" ncl '\''h2name=\\\"\"\$1\"\\\"'\'' '\''h4name=\\\"\"\$2\"\\\"'\'' '\''vNames=\\\"\"vlist\"\\\"'\'' '\''interp_name=\\\"\"\$3\"\\\"'\'' $IPL_SCRIPT; EXIT_CODE=\$?; if [ \$EXIT_CODE -lt 1 ]; then rm \"\$1\"; rm \"\$2\"; else echo \\\"Did not successfully create \"\$3\"\\\"; fi\"}' | sh" >> $batchname
    #submit the batch file
    sbatch $batchname
    x=$((x+1))
	done
	 
fi