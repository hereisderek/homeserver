#!/bin/bash


# ./docker-compose.sh -p derek -f docker-compose.util.yml up -d
# ./docker-compose.sh -p derek -f docker-compose.media.yml up -d
# ./docker-compose.sh -p derek -f docker-compose.player.yml up -d
# ./docker-compose.sh -p derek -f docker-compose.yml -f docker-compose.downloader.yml up -d

# ./docker-compose.sh -p derek -f docker-compose.yml -f docker-compose.downloader.yml -f docker-compose.media.yml -f docker-compose.player.yml -f docker-compose.util.yml  up -d

# set -x
set -e

cd "$(dirname "$0")"
SELF_NAME=`basename "$0"`
VERSION="0.1"
ENV_FILE=".env"

mkdir -p "./tmp"
# ENV_TEMP=$(mktemp ./tmp/${SELF_NAME}_XXXXXXXXX.env)


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

DEBUG=false
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


## beginning of the actual script



function help() {
    cat << EOF
VERSION:${VERSION}
Usage: -p <profile> (-f <docker-compose.yml>) [docker command]

E.g:
    ${SELF_NAME} -p derek up -d

Note: 
    * <docker-compose>.override.yml will be loaded automatically
    * when -f is used with -p, specified docker-compose file (and its override) will also be looked under the <profile>
    * if -f is omitted, it will apply all the yml files
    * when command is omitted, it will run "up -d"
    * does ${UNDERLINE}NOT${COLOR_RESET} support wildcard filename such as "docker-compose.*.yml"

    
    e.g. ${SELF_NAME} -p derek -f serivce1.yml config will include the following yml files (if exists)
        service1.yml
        service1.override.yml
        profile/derek/service1.yml
        profile/derek/service1.override.yml

EOF
}


function err() {
    echo -e "${RED}${@}${COLOR_RESET}"
}

function out() {
    echo -e "$@"
}

color()(set -o pipefail;"$@" 2>&1>&3|sed $'s,.*,\e[31m&\e[m,'>&2)3>&1

function evaluate() {
    echo -e "evaluating [${GREEN}${@}${COLOR_RESET}]"
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
    sort -u -t '=' -k 1,1 $(echo "${filtered_files}"|tr ' ' '\n'|tac|tr '\n' ' ')>${output}
}

function docker_yml_params() {
    local files=$@
    [[ $DEBUG -eq true ]] && {
        printf "docker_yml_params merging files:$files \n"
    }

    local files_param=""
    for file in $files; do
        local filename="${file%.*}"
        local extension="${file##*.}"

        [[ " ${exclude_yaml_files[*]} " =~ " ${file} " ]]&&continue

        local local_file=${file}
        [[ -f $local_file ]] && files_param+=" -f ${local_file} ";

        # override file
        local_file="${filename}.override.${extension}"
        [[ -f $local_file ]] && files_param+=" -f ${local_file} ";

        # profile
        local_file="${profile}/${file}"
        [[ -f $local_file ]] && files_param+=" -f ${local_file} ";

        # profile override
        local_file="${profile}/${filename}.override.${extension}"
        [[ -f $local_file ]] && files_param+=" -f ${local_file} ";
    done
    merged_compose_files_param=$files_param
    out "files_param: $files_param"
}


profile="default_profile" 
yaml_files=
exclude_yaml_files=
remaining_command=
default_command=

while getopts ":h?p:f:x:d" option
do 
    case "${option}" in
        d)
            default_command="up -d";;
        p)
            profile="profiles/${OPTARG}" ;;
        f)  
            yaml_files+="$OPTARG ";;
        x)  
            exclude_yaml_files+="$OPTARG ";;
        h|\?)
            help;exit 0;;
    esac
done

shift $((OPTIND-1))
[ "${1:-}" = "--" ] && shift

remaining_command=$@

[[ $DEBUG -eq true ]] && {
    printf "DEBUG --- profile:[$profile] yaml_files:[$yaml_files] exclude_yaml_files:[${exclude_yaml_files}] remaining_command:[${remaining_command}] default_command:[${default_command}]\n"
}


([[ -z $remaining_command ]]&&[[ -z $default_command ]])&& {
    err "no command supplied"
    exit 1;
}

out "Using profile:$profile ..."

[[ -d ${profile} ]] || {
    err "unable to find profile dir:${profile}, exiting ..."; exit 2;
}

ENV_TEMP=$(mktemp ./tmp/${SELF_NAME}_XXXXXXXXX.env)&&[[ $DEBUG -eq true ]]&&printf "created env file:$ENV_TEMP\n"

mergeEnv ${ENV_TEMP} "$ENV_FILE" "${profile}/${ENV_FILE}"

[[ ${#yaml_files} -eq 0 ]] && yaml_files=$(ls *docker-compose*.yml|sort -r)

unset merged_compose_files_param&&docker_yml_params ${yaml_files}

echo "merged_compose_files_param:$merged_compose_files_param"
ymal_files_param="${merged_compose_files_param}"

echo "ymal_files_param:${ymal_files_param}"

evaluate "docker-compose ${ymal_files_param} --env-file ${ENV_TEMP} $remaining_command $default_command"

rm ${ENV_TEMP}