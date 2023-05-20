script=$(realpath "$0")
script_name=$(dirname "$script")
source $script_name/common.sh

function_print_header "install mgnix"
yum install nginx -y &>>$log_file
function_status_check $?

function_print_header "create reverse proxy configuration file"
cp roboshop.conf /etc/nginx/default.d/roboshop.conf &>>$log_file
function_status_check $?

function_print_header "remove default content from ngnix"
rm -rf /usr/share/nginx/html/* &>>$log_file
function_status_check $?

function_print_header "download frontend web content"
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip &>>$log_file
function_status_check $?

function_print_header "unzip frontend web content"
cd /usr/share/nginx/html &>>$log_file
unzip /tmp/frontend.zip &>>$log_file
function_status_check $?

function_print_header "enable and start ngnix service"
systemctl enable nginx &>>$log_file
systemctl start nginx &>>$log_file
function_status_check $?