#!/bin/bash


# ./docker-compose.sh -p derek -f docker-compose.util.yml up -d
# ./docker-compose.sh -p derek -f docker-compose.media.yml up -d
# ./docker-compose.sh -p derek -f docker-compose.player.yml up -d
# ./docker-compose.sh -p derek -f docker-compose.util.yml up -d

# set -x
set -e

cd "$(dirname "$0")"
SELF_NAME=`basename "$0"`
VERSION="0.1"
ENV_FILE=".env"

mkdir -p "./tmp"
ENV_TEMP=$(mktemp ./tmp/${SELF_NAME}_XXXXXXXXX.env)


# colors
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
LIME_YELLOW=$(tput setaf 190)
YELLOW=$(tput setaf 3)
POWDER_BLUE=$(tput setaf 153)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
BRIGHT=$(tput bold)
NORMAL=$(tput sgr0)
BLINK=$(tput blink)
REVERSE=$(tput smso)
UNDERLINE=$(tput smul)
COLOR_RESET="$(tput sgr0)"
OPTIND=1




# options
LOG_FILE=tmp/service.log
LOG=true

# DEBUG=false
DEBUG=${DEBUG:-false}


[[ $DEBUG -eq true ]] && {
    exec  1> >(tee -ia ${LOG_FILE})
    exec  2> >(tee -ia ${LOG_FILE} >& 2)
    # Notice no leading $
    exec {FD}> ${LOG_FILE}
    # If you want to append instead of wiping previous logs
    # exec {FD}>> bash.log
    export BASH_XTRACEFD="$FD"
    set -x
}


[[ $DEBUG -eq true ]] && printf "created env file:$ENV_TEMP\n"


## beginning of the actual script



function help() {
    cat << EOF
VERSION:${VERSION}
Usage: -p <profile> (-f <docker-compose.yml>) [docker command]

E.g:
    ${SELF_NAME} -p derek up -d
EOF
}


function err() {
    # echo -e "${RED}${@}${COLOR_RESET}"
    echo -e "Error ${@} "
}

function out() {
    echo -e "$@"
}

color()(set -o pipefail;"$@" 2>&1>&3|sed $'s,.*,\e[31m&\e[m,'>&2)3>&1

function evaluate() {
    echo "evaluating [$@] ..."
    # color eval $@  2>&1 | tee $LOG_FILE
    eval docker-compose $@  2>&1 | tee $LOG_FILE
}

function mergeEnv() {
    output=$1
    local env_files="${@:2}"
    local filtered_files=()

    for env in ${env_files}; do 
        [[ -f $env ]] && filtered_files+="$env "
    done

    echo "merging into ${output} for env files: ${filtered_files}, original env_files:$env_files"
    # sort -u -t '=' -k 1,1 $(echo "${@:2}"|tr ' ' '\n'|tac|tr '\n' ' ')>${output}
    sort -u -t '=' -k 1,1 $(echo "${filtered_files}"|tr ' ' '\n'|tac|tr '\n' ' ')>${output}
    [[ $DEBUG -eq true ]] && {
        printf "displaying merged env file: \n"
        cat $ENV_TEMP
    }
    
}

function docker_yml_params() {
    local files=$@
    [[ $DEBUG -eq true ]] && {
        printf "docker_yml_params merging files:$files \n"
    }
    local files_param=""
    for file in $files; do
        [[ -f $file ]] && files_param+=" -f ${file} ";
        # files_param+=" -f ${file} ";
    done
    merged_compose_files_param=$files_param
    echo "files_param: $files_param"
}


profile="default_profile" 
yaml_files=
remaining_command=

while getopts ":h?p:f:" option
do 
    case "${option}" in
        p)
            profile="profiles/${OPTARG}" ;;
        f)  
            yaml_files+="$OPTARG ";;
        h|\?)
            help;exit 0;;
    esac
done

shift $((OPTIND-1))
[ "${1:-}" = "--" ] && shift

remaining_command=$@


[[ $DEBUG -eq true ]] && {
    printf "DEBUG --- profile:[$profile] yaml_files:[$yaml_files] remaining_command:[${remaining_command}] \n"
}


[[ -z $remaining_command ]]&& {
    err "no command supplied"
    exit 1;
}

out "Using profile:$profile ..."

[[ -d ${profile} ]] || {
    err "unable to find profile dir:${profile}, exiting ..."; exit 2;
}

mergeEnv ${ENV_TEMP} "$ENV_FILE" "${profile}/${ENV_FILE}"

unset merged_compose_files_param

[[ ${#yaml_files[@]} -eq 0 ]] && {
    docker_yml_params "docker-compose.yml" "docker-compose.override.yml" "${profile}/docker-compose.yml" "${profile}/docker-compose.override.yml" 
} || {
    docker_yml_params ${yaml_files} "docker-compose.override.yml" "${profile}/docker-compose.yml" "${profile}/docker-compose.override.yml" "$yaml_files"
}

docker_yml_params "docker-compose.yml" "docker-compose.override.yml" "${profile}/docker-compose.yml" "${profile}/docker-compose.override.yml" "$yaml_files"
echo "merged_compose_files_param:$merged_compose_files_param"
ymal_files_param="${merged_compose_files_param}"

echo "ymal_files_param:${ymal_files_param}"

evaluate "docker-compose ${ymal_files_param} --env-file ${ENV_TEMP} $remaining_command"

rm ${ENV_TEMP}
# echo nation:$nation code:$code profile:$profile leftovers: $@