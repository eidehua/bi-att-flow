#!/bin/bash
cd $PBS_O_WORKDIR

WORKER_HOSTS_TASKS=${1}
shift
PS_HOSTS_TASKS=${1}
shift

CMD_ARGS=${*}


MY_HOST_NAME=$(hostname)

WORKER_HOSTS=""
PS_HOSTS=""

WHAT_AM_I=""
MY_TASK_NUMBER=""

WORKER_WAIT_TIME=20

for h in $(echo $WORKER_HOSTS_TASKS | sed "s/,/ /g")
do
    HOST_NAME=$(echo $h | cut -d ':' -f 1)
    WORKER_HOSTS="${HOST_NAME}:2222,${WORKER_HOSTS}"
    if [ ${HOST_NAME} == ${MY_HOST_NAME} ]
    then
	WHAT_AM_I='worker'
	echo "Im a worker, sleeping $WORKER_WAIT_TIME waiting for the parameter server to start up"
	sleep $WORKER_WAIT_TIME
	MY_TASK_NUMBER=$(echo $h | cut -d ':' -f 2)
    fi
done

for h in $(echo $PS_HOSTS_TASKS | sed "s/,/ /g")
do
    HOST_NAME=$(echo $h | cut -d ':' -f 1)
    PS_HOSTS="${HOST_NAME}:2222,${PS_HOSTS}"
    if [ ${HOST_NAME} == ${MY_HOST_NAME} ]
    then
	WHAT_AM_I='ps'
	MY_TASK_NUMBER=$(echo $h | cut -d ':' -f 2)
    fi
done

if [ -z "$WHAT_AM_I" ]; then
    echo "($MY_HOST_NAME) Im the throw away node, exiting gracefully"
    exit 0
fi 

WORKER_HOSTS=$(echo $WORKER_HOSTS | sed 's/,$//')
PS_HOSTS=$(echo $PS_HOSTS | sed 's/,$//')

#PY_CMD= ""  # REPLACE WITH PYTHON SCRIPT AND ARGS

echo "I am ${MY_HOST_NAME}, my job is ${WHAT_AM_I} with task id ${MY_TASK_NUMBER}. Im about to run
python job"

cd ~/bi-att-flow/

#python -m basic.cli --mode train --noload --batch_size 25 --len_opt --cluster
python -m basic.cli --mode train --noload --num_gpus 3 --batch_size 20 --len_opt --cluster
