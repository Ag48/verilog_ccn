#!/bin/bash -eu

#============================
# SUB ROUTINE
#============================
usage_exit() {
  echo "Usage: $0" >&2
  exit 1
}

print_div() {
  echo "--------------------------------------------------------------------------------"
}

print_fence() {
  print_div
  echo -e  "   $0 : $1 ($SECONDS sec)"
  print_div
}

prep_dir() {
  for d in $@; do
    if [ ! -e $d ]; then
      echo "[$0] mkdir $d"
      mkdir -p $d
    fi
  done
}

get_opts() {
  eval local -a opts=$1
  while getopts "r:" OPT; do
    case ${OPT} in 
      "r" ) RANGE="$OPTARG";;
    esac
  done
}

#============================
# VARIABLES
#============================
SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE}); pwd)
RANDNAME=$(cat /dev/urandom | tr -dc [:alnum:] | head -c 15)
GREP_KEYWORDS="-e IfStatement: -e Lor: -e Land: -e Case: " 

#============================
# MAIN ROUTINE
#============================
# 0. setup
if [ $# -le 0 ]; then
  usage_exit
fi
get_opts "$@"
shift $(($OPTIND-1))

arr_nl_always=($(grep -n "Always:" $1 | cut -d ':' -f 1 | tr '\n' ' '))
arr_sed_range=()

for n in $(seq 0 $((${#arr_nl_always[@]}-2))); do
  arr_sed_range=("${arr_sed_range[@]}" "${arr_nl_always[$n]},$((${arr_nl_always[$(($n+1))]} -1))")
done
arr_sed_range=("${arr_sed_range[@]}" "${arr_nl_always[-1]},\$")

echo "range: ${arr_sed_range[@]}"

# get ccn
i=0
arr_always=($(grep "Always:" $1 | tr -d ' ') )
for e in ${arr_sed_range[@]}; do
  ccn=$(sed -n "${e}p" $1 | grep  ${GREP_KEYWORDS} | echo "$(wc -l) + 1" | bc)
  echo "${arr_always[$i]} ($e): $ccn"
  i=$(($i+1))
done

