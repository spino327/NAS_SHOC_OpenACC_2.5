#!/bin/bash
# author sergiop@udel.edu


USAGE="./singleExperiment.sh \"CLASS_LETTER[ CLASS_LETTER...]\" <threads_env_variable> <number of threads> . E.g. ./singleExperiment.sh \"A B C\" 4 "

if [ "$#" -lt "1" ]; then
    echo $USAGE
    exit -1
fi

# getting the arguments
INPUT1=$1
CLASSES=(${INPUT1[@]})

# running on multicore
if [ "$#" -ge "2" ]; then
    ENV_THREADS=$2
    NUM_THREADS=$3

    #if [ "$ENV_THREADS" == "ACC_NUM_CORES" ]; then
    #    export ACC_NUM_CORES=$NUM_THREADS
    #elif [ "$ENV_THREADS" == "OMP_NUM_THREADS" ]; then
    #    export OMP_NUM_THREADS=$NUM_THREADS
    #fi
    export $ENV_THREADS=$NUM_THREADS
    echo Running multicore with $ENV_THREADS=$NUM_THREADS

    RECORD_CPU=1
    RECORD_APP=$PWD/record_cpu.sh
fi

EXEC_DATE=$(date +%m%d%y_%H%M%S)

BASE_FOLDER=$EXPERIMENTS_HOME/$BENCHMARK_NAME

if [ -n "$NUM_THREADS" ]; then
    FOLDER=$BENCHMARK_NAME"_nth"$NUM_THREADS"_"$EXEC_DATE
else
    FOLDER=$BENCHMARK_NAME"_"$EXEC_DATE
fi

echo creating exp folder $BASE_FOLDER/$FOLDER

mkdir -p $BASE_FOLDER/$FOLDER

LOG="tee -a $BASE_FOLDER/$FOLDER/log.txt"

echo Executing experiment on $EXEC_DATE... | $LOG
echo Configuration | $LOG
echo --------------------------------  | $LOG
echo CC=$CC | $LOG
echo ACCEL_INFO=$ACCEL_INFO | $LOG
echo CLASSES=${CLASSES[@]} | $LOG
echo BENCHMARK_NAME=$BENCHMARK_NAME | $LOG
echo BENCHMARK_FOLDER=$BENCHMARK_FOLDER | $LOG
echo BENCHMARK_EXEC=$BENCHMARK_EXEC | $LOG
echo RESULTS_FOLDER=$BASE_FOLDER/$FOLDER | $LOG
echo EXPERIMENTS_HOME=$EXPERIMENTS_HOME | $LOG
echo DEFINES=$DEFINES | $LOG
echo EXTRAS=$EXTRAS | $LOG
echo -------------------------------- | $LOG

if [ -z "$EXPERIMENTS_HOME" ]; then
    echo "Setting EXPERIMENTS_HOME to pwd" | $LOG
    EXPERIMENTS_HOME=$PWD
fi

echo saving node info | $LOG
(echo ACCELERATOR; $ACCEL_INFO; echo && echo CPU; lscpu; echo && echo HOSTNAME; hostname) 2>&1 | tee -a $BASE_FOLDER/$FOLDER/node_info.txt

echo CDing into benchmark folder \'$BENCHMARK_FOLDER\' | $LOG
cd $BENCHMARK_FOLDER

echo Compiling again... | $LOG
cd ../sys
make clean | $LOG

cd $BENCHMARK_FOLDER
make clean | $LOG

if [ "$BENCHMARK_TYPE" == "cuda" ]; then
    echo "Executing CUDA benchmark" | $LOG
    (make $TEST) 2>&1 | tee -a $BASE_FOLDER/$FOLDER/compile.txt 
else
    for CLASS in ${CLASSES[@]}; do
        (make CC=$CC CLASS=$CLASS DEFINES="$DEFINES" $TEST) 2>&1 | tee -a $BASE_FOLDER/$FOLDER/compile$CLASS.txt 
    done
fi

echo Running experiments... $(date +%m%d%y_%H%M%S) | $LOG

for CLASS in ${CLASSES[@]}; do
    if [ "$RECORD_CPU" == "1" ]; then 
        $RECORD_APP $BENCHMARK_EXEC.$CLASS.x $BASE_FOLDER/$FOLDER/cpu$CLASS.txt&
    fi
    
    if [ "$BENCHMARK_TYPE" == "cuda" ]; then
        (time ./$BENCHMARK_EXEC $CLASS) 2>&1 | tee -a $BASE_FOLDER/$FOLDER/res$CLASS.txt 
    else
        (time ./$BENCHMARK_EXEC.$CLASS.x) 2>&1 | tee -a $BASE_FOLDER/$FOLDER/res$CLASS.txt 
    fi
    
    if [ "$RECORD_CPU" == "1" ]; then echo "1" > .cpu_test; kill -9 $!; fi
done

echo Finishing experiments... $(date +%m%d%y_%H%M%S) | $LOG

