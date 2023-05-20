script=$(realpath "$0")
script_name=$(dirname "$script")
source $script_name/common.sh
rabbit_mq_user=$1

if [ -z $rabbit_mq_password ]; then
	echo -e "Missing rabbitmq root user password" &>>$log_file
	exit 1
fi

function_print_header "configure erlang repos"
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>>$log_file
function_status_check $?

function_print_header "install erlang"
yum install erlang -y &>>$log_file
function_status_check $?

function_print_header "configure Rabbit MQ repos"
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>>$log_file
function_status_check $?

function_print_header "install Rabbit Mq"
yum install rabbitmq-server -y &>>$log_file
function_status_check $?


function_print_header "start Rabbit MQ Server"
systemctl enable rabbitmq-server &>>$log_file
systemctl start rabbitmq-server &>>$log_file
function_status_check $?

function_print_header "add application in Rabbit MQ"
rabbitmqctl add_user roboshop ${rabbit_mq_password} &>>$log_file
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$log_file
function_status_check $?