script=$(realpath "$0")
script_name=$(dirname "$script")
source $script_name/common.sh
mysql_root_user=$1

component=shipping
schema_setup=mysql

if [ -z $mysql_root_user ]; then
	echo -e "Missing mysql root user" &>>$log_file
	exit 1
fi

function_java






