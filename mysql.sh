script=$(realpath "$0")
script_name=$(dirname "$script")
source $script_name/common.sh

function_print_header "disable existing mysql module"
dnf module disable mysql -y
function_status_check $?

function_print_header "configure mysql repo"
cp mysql.repo /etc/yum.repos.d/mysql.repo
function_status_check $?

function_print_header "instal mysql server"
yum install mysql-community-server -y
function_status_check $?

function_print_header "start mysql server"
systemctl enable mysqld
systemctl start mysqld
function_status_check $?

function_print_header "update password for accessing mysql server"
mysql_secure_installation --set-root-pass RoboShop@1
function_status_check $?

