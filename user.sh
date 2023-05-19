script=$(realpath "$0")
script_name=$(dirname "$script")
source $script_name/common.sh

component=user
schema_setup=mongo

function_nodejs