script=$(realpath "$0")
script_name=$(dirname "$script")
source $script_name/common.sh

function_print_header "install mgnix"
yum install nginx -y
function_status_check $?

function_print_header "create reverse proxy configuration file"
cp roboshop.conf /etc/nginx/default.d/roboshop.conf
function_status_check $?

function_print_header "remove default content from ngnix"
rm -rf /usr/share/nginx/html/*
function_status_check $?

function_print_header "download frontend web content"
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip
function_status_check $?

function_print_header "unzip frontend web content"
cd /usr/share/nginx/html 
unzip /tmp/frontend.zip
function_status_check $?

function_print_header "enable and start ngnix service"
systemctl enable nginx 
systemctl start nginx 
function_status_check $?