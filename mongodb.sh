script=$(realpath "$0")
script_name=$(dirname "$script")
source $script_name/common.sh

function_print_header "copy mongo db Repo"
cp mongo.repo /etc/yum.repos.d/mongo.repo
function_status_check $?

function_print_header "install mongo db"
yum install mongodb-org -y
function_status_check $?

function_print_header "change IP to available all hosts"
sed -i -e 's|127.0.0.1|0.0.0.0|' /etc/mongod.conf
function_status_check $?

function_print_header "start mongo DB Server"
systemctl enable mongod
systemctl restart mongod
function_status_check $?