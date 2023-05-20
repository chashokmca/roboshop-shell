script=$(realpath "$0")
script_name=$(dirname "$script")
source $script_name/common.sh
mysql_root_password=$1

if [ -z $mysql_root_password ]; then
	echo -e "missing mysql root password" &>>$log_file
	exit 1
fi

function_print_header "disable existing mysql module"
dnf module disable mysql -y &>>$log_file
function_status_check $?

function_print_header "configure mysql repo"
cp mysql.repo /etc/yum.repos.d/mysql.repo &>>$log_file
function_status_check $?

function_print_header "instal mysql server"
yum install mysql-community-server -y &>>$log_file
function_status_check $?

function_print_header "start mysql server"
systemctl enable mysqld &>>$log_file
systemctl start mysqld &>>$log_file
function_status_check $?

function_print_header "update password for accessing mysql server"
mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$log_file
function_status_check $?

