script=$(realpath "$0")
script_name=$(dirname "$script")
source $script_name/common.sh

component=dispatch

function_golang