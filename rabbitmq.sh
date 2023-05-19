script=$(realpath "$0")
script_name=$(dirname "$script")
source $script_name/common.sh

function_print_header "configure erlang repos"
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash
function_status_check $?

function_print_header "install erlang"
yum install erlang -y
function_status_check $?

function_print_header "configure Rabbit MQ repos"
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash
function_status_check $?

function_print_header "install Rabbit Mq"
yum install rabbitmq-server -y
function_status_check $?


function_print_header "start Rabbit MQ Server"
systemctl enable rabbitmq-server 
systemctl start rabbitmq-server 
function_status_check $?

function_print_header "add application in Rabbit MQ"
rabbitmqctl add_user roboshop roboshop123
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
function_status_check $?