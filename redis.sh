script=$(realpath "$0")
script_name=$(dirname "$script")
source $script_name/common.sh

function_print_header "Install Redis Repos"
yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y
function_status_check $?

function_print_header "Enable Redis Module"
dnf module enable redis:remi-6.2 -y
function_status_check $?

function_print_header "Install Redis"
yum install redis -y 
function_status_check $?

#update listen address 127.0.0.1 to 0.0.0.0 in vim /etc/redis.conf & vim /etc/redis/redis.conf

function_print_header "update redis host to 0.0.0.0"
sed -i -e "s|127.0.0.1|0.0.0.0|" /etc/redis.conf
function_status_check $?

function_print_header "start Redis"
systemctl enable redis 
systemctl start redis
function_status_check $?