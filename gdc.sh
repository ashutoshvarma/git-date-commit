#!/usr/bin/env bash
#set -ex
#: Title        : Git Date Commit 
#: Author       : Ashutosh Varma (ashutoshvarma11@live.com)
#  License      : MIT
#: Version      : 1.0

VERSION="1.0"

# https://github.com/fearside/ProgressBar/
# 1.1 Input is currentState($1) and totalState($2)
function progress_bar {
    # Process data
        let _progress=(${1}*100/${2}*100)/100
        let _done=(${_progress}*4)/10
        let _left=40-$_done
    # Build progressbar string lengths
        _fill=$(printf "%${_done}s")
        _empty=$(printf "%${_left}s")

    # 1.2 Build progressbar strings and print the ProgressBar line
    # 1.2.1 Output example:
    # 1.2.1.1 Progress : [########################################] 100%
    printf "\rProgress : [${_fill// /\#}${_empty// /-}] ${_progress}%%"
}


## COLORS
# Only use colors if connected to a terminal
if [ -t 1 ]; then
    RED=$(printf '\033[31m')
    GREEN=$(printf '\033[32m')
    YELLOW=$(printf '\033[33m')
    BLUE=$(printf '\033[34m')
    BOLD=$(printf '\033[1m')
    RESET=$(printf '\033[m')
else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    BOLD=""
    RESET=""
fi

function log_error() { echo "${BOLD}${RED}[ERROR] : ${@}${RESET}"; }
function log_info() { echo "${BOLD}${YELLOW}[INFO] : ${@}${RESET}"; }
function log_success() { echo "${BOLD}${GREEN}[SUCCESS] : ${@}${RESET}"; }


## HELP

function print_help()
{
    echo "Usage: $(basename "$0") [optional] -x COMMAND -s START_DATE"
    echo
    echo "  -x COMMAND          command/script to execute before every commit. Any"
    echo "  --execute           'eval' compatible command is supported. Also you can"
    echo "                      use day and date placeholders."
    echo
    echo "  -s START_DATE       date to start commits. (all GNU 'date' compatible dates"
    echo "  --start             string are supported. Example-'2020/08/04')"
    echo
    echo "  -e END_DATE         date of last commit."
    echo "  --end"
    echo
    echo "  -c MSG              commit message. Placeholders for day and date is supported."
    echo "  --commit_msg"
    echo
    echo "  -n NUMBER           no of commits per day."
    echo "  --commit_count"
    echo
    echo "  -q                  no progess bar."
    echo "  --no_progressbar"
    echo
    echo "  -v                  version"
    echo "  --version"
    echo
    echo "  -h                  help message"
    echo "  --help"
    echo
    echo
    echo "Placeholders:-"
    echo "Two placeholders for current processing date '\${date}' and current day count"
    echo "'\${day}' and current day commit number '\${commit_count}' are provided for "
    echo "use in COMMAND and COMMIT_MSG. NOTE that placeholder syntax is exactly similar"
    echo "to bash variable so make sure to use SINGLE QUOTES while assigning them in shells."
    echo
    echo "Examples:-"
    echo "Run custom script with date and day as args before commits ranging from date"
    echo "2020/08/04 to 2020/12/31."
    echo "  $ $(basename "$0") -s '2020/08/04' -e '2020/12/31' -x './myscript.sh \${date} \${day}'"
    echo "Note the single quotes in -x to prevent variable substitution for placeholders"
}

function print_version()
{
    echo "$(basename "$0") v${VERSION}"
    echo "Copyright (C) $(date +'%Y') Ashutosh Varma"
}

## Handle Argumnets

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -s|--start)
    DATE1="$2"
    shift # past argument
    shift # past value
    ;;
    -e|--end)
    DATE2="$2"
    shift # past argument
    shift # past value
    ;;
    -x|--execute)
    EXECUTE="$2"
    shift # past argument
    shift # past value
    ;;
    -m|--commit_msg)
    COMMIT_MSG="$2"
    shift # past argument
    shift # past value
    ;;
    -n|--commit_count)
    COMMITS_PER_DAY=$2
    shift # past argument
    shift # past value
    ;;
    -q|--no_progressbar)
    NO_BAR=1
    shift # past argument
    ;;
    -h|--help)
    print_help
    exit 0
    shift # past argument
    ;;
    -v|--version)
    print_version
    exit 0
    shift # past argument
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters


# checks
if [ -z ${DATE1+x} ]; then
    log_error "No start date specified. See --help."
    exit 1
fi

if [ -z ${DATE2+x} ]; then
    log_info "No end date is given. Assuming same as start date."
    DATE2="$DATE1"
fi

if [ -z ${EXECUTE+x} ]; then
    log_error "No command provided. see --help."
    exit 1
fi

if [ -z ${COMMIT_MSG+x} ]; then
    COMMIT_MSG='syncing ${date}, revision ${commit_count}'
fi

## DEFAULT VARIABLES
MAX_DAYS=1460
COMMITS_PER_DAY=${COMMITS_PER_DAY:=1}

#verify dates
if ! START_DATE=$(date -d "$DATE1" +%Y%m%d) ;then
    log_error "first date is invalid"
    exit 1
fi
if ! END_DATE=$(date -d "$DATE2" +%Y%m%d) ;then
    log_error "second date is invalid"
    exit 1
fi


function git_commit()
{
    if [ -z "$(git status --short)" ]; then
        log_info "No changes to commit"
        return
    fi
    msg=$(date=$1 day=$2 commit_count=$3 envsubst <<< "$COMMIT_MSG")
    GIT_AUTHOR_DATE=$(date -d "$1") GIT_COMMITTER_DATE="$GIT_AUTHOR_DATE" git add . >/dev/null
    GIT_AUTHOR_DATE=$(date -d "$1") GIT_COMMITTER_DATE="$GIT_AUTHOR_DATE" git commit -a -m "$msg" >/dev/null
}

function run_command()
{
    eval $(date=$1 day=$2 commit_count=$3 envsubst <<< "$EXECUTE")
}

function process_days()
{
    total_days=$(( ($(date --date="$END_DATE" +%s) - $(date --date="$START_DATE" +%s) )/(60*60*24) + 1))
    log_info "Total Days - ${total_days}"

    current_date=$START_DATE
    days_count=0
    while [[ $current_date -le $END_DATE && $days_count -lt $MAX_DAYS ]]
    do
        days_count=$(($days_count + 1))

        for ((i=1;i<=COMMITS_PER_DAY;i++)); do
            run_command $current_date $days_count $i
            git_commit $current_date $days_count $i
        done

        if [ -z $NO_BAR ]; then
            progress_bar $days_count $total_days
        fi

        current_date=$(date -d"$current_date + 1 day" +"%Y%m%d")
    done
}

process_days
# progeessbar does not append newline at end
echo
log_success DONE




