#!/bin/bash

# author: sergiop@udel.edu

read -d '' USAGE <<- EOF
    ./execExperiments.sh <conf_file>.\n
    
    For the configuration file:\n
    
    Variables formated as "export MyVAR=value":\n
    \tEXPERIMENTS_HOME: folder where the results will be stored.\n
    \tCC: compiler to use.\n
    \tACCEL_INFO: command to query the accelerator info.\n
    \tTEST: flags that will be passed to make.\n
    \tBENCHMARK_NAME: name of the benchmark folder to create.\n
    \tBENCHMARK_EXEC: prefix of the executed binary.\n
    \tBENCHMARK_FOLDER: folder where the source code (.c and .h) is located.\n
    \tDEFINES: string to be passed to make (assuming you have a DEFINES variable whithin your makefile).\n
    \tTA: architecture to use for the gpu.\n
    \tEXTRA_CFLAGS: extra flags to pass to the c compiler.\n
    \tEXTRA_CLINKFLAGS: extra flags to pass to linker.\n

    Variables formated as "MyVAR=value":\n
    \tCLASSES: list of classes to use for NAS, e.g. CLASSES=A B C.\n
    \tTHREADS: list of number of threads to use in multicore runs, e.g. THREADS=1 4.\n
    \tENV_THREADS: env variable that sets the number of threads to use in the runtime. It depends if acc (ACC_NUM_CORES) or omp (OMP_NUM_THREADS).\n
EOF

if [ "$#" -ne "1" ]; then
    echo -e $USAGE
    exit -1
fi

CONF_FILE=$1
CLASSES=()
THREADS=()
ENV_THREADS=""
FOLDER=""

echo Loading conf file
while IFS='' read -r line || [[ -n "$line" ]]; do
    # Allows simple use of comments.
    if [ "${#line}" -gt "0" -a ! "${line:0:1}" == "#" ]; then
        echo "'${line}'"
        
        # general configuration not tie-up to ACC or OMP
        if [ "${line:0:7}" == "CLASSES" ]; then
            vals=""
            for ith in `seq 0 ${#line}`; do
                letter=${line:$ith:1}
                
                if [ "$letter" == "=" ]; then
                    vals=${line:$[ith+1]}
                    break
                fi
            done
            pos=0
            for val in $vals; do 
                CLASSES[$[pos++]]=$val
            done
        # multicore configurations
        elif [ "${line:0:7}" == "THREADS" ]; then
            vals=""
            for ith in `seq 0 ${#line}`; do
                letter=${line:$ith:1}
                
                if [ "$letter" == "=" ]; then
                    vals=${line:$[ith+1]}
                    break
                fi
            done
            pos=0
            for val in $vals; do 
                THREADS[$[pos++]]=$val
            done
        elif [ "${line:0:11}" == "ENV_THREADS" ]; then
            val=""
            for ith in `seq 0 ${#line}`; do
                letter=${line:$ith:1}
                
                if [ "$letter" == "=" ]; then
                    val=${line:$[ith+1]}
                    break
                fi
            done
            ENV_THREADS=$val
        else
            eval ${line}
        fi
    fi
done < "$CONF_FILE"


if [ "$ENV_THREADS" == "" ]; then 
    # running non-multicore
    (./singleExperiment.sh "${CLASSES[*]}") 2>&1 | tee -a logExperiments.txt
else
    # running multicore
    # number of threads to use
    if [ "${#THREADS[@]}" -gt "0" ]; then 
        
        for th in ${THREADS[@]}; do
            export EXTRAS="ENV_THREADS=$ENV_THREADS":"NUM_THREADS=$th"
            #export $ENV_THREADS=$th
            (./singleExperiment.sh "${CLASSES[*]}" $ENV_THREADS $th) 2>&1 | tee -a logExperiments.txt
        done
    else
        echo "ERROR: please set the THREADS option in your config file. e.g. THREADS=1 2 4"
    fi
fi


