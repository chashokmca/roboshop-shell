script=$(realpath "$0")
script_name=$(dirname "$script")
source $script_name/common.sh

if [ -z $rabbitmq_appuser_password ]; then
	echo -e "Missing rabbitmq root user password" &>>$log_file
	exit 1
fi

component=dispatch

function_golang