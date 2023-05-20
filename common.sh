app_user=roboshop
script=$(realpath "$0")
script_name=$(dirname "$script")
log_file=/tmp/${app_user}.log
#source $script_name/common.sh

function_print_header() {
	echo -e "\e[33m<<<<<<<<<<  $1 >>>>>>>>>>\e[0m"
	echo -e "\e[33m<<<<<<<<<<  $1 >>>>>>>>>>\e[0m" &>>$log_file
}


function_java() {
	function_print_header "configure nodejs repos"
	yum install maven -y &>>$log_file
	function_status_check $?
	
	function_app_config
	
	function_print_header "clean and install maven package"
	cd /app 
	mvn clean package &>>$log_file
	mv target/shipping-1.0.jar shipping.jar &>>$log_file
	function_status_check $?
	
	func_schema_setup
	function_start_component
}

function_nodejs() {
	function_print_header "configure nodejs repos"
	curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$log_file
	function_status_check $?

	function_print_header "install nodejs"
	yum install nodejs -y &>>$log_file
	function_status_check $?
	
	function_app_config
	
	function_print_header "download dependencies"
	npm install &>>$log_file
	function_status_check $?
	
	func_schema_setup
	function_start_component
}

function_start_component() {
	function_print_header "copy catalogue service"
	cp ${script_name}/${component}.service /etc/systemd/system/${component}.service &>>$log_file
	function_status_check $?

	function_print_header "start catalogue service"
	systemctl daemon-reload &>>$log_file
	systemctl enable ${component} &>>$log_file
	systemctl start ${component} &>>$log_file
	function_status_check $?
}

function_app_config() {
	function_print_header "add application user"
	id ${app_user} &>>$log_file
	if [ $? -ne 0 ]; then
		useradd ${app_user} &>>$log_file
	else
		echo -e "user exists!" &>>$log_file
	fi
	
	function_status_check $?

	function_print_header "create application directory"
	rm -rf /app &>>$log_file
	mkdir /app &>>$log_file
	function_status_check $?

	function_print_header "download application"
	curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>$log_file
	function_status_check $?	

	function_print_header "extract application"
	cd /app &>>$log_file
	unzip /tmp/${component}.zip &>>$log_file
	function_status_check $?
}

func_schema_setup() {
	if [ ${schema_setup} == "mongo" ]; then
		function_print_header "configure mongo db repo"
		cp ${script_name}/mongo.repo /etc/yum.repos.d/mongo.repo &>>$log_file
		function_status_check $?

		function_print_header "install mongo db client"
		yum install mongodb-org-shell -y &>>$log_file
		function_status_check $?

		function_print_header "configure application schema"
		mongo --host mongodb-dev.adevops72.online </app/schema/${component}.js &>>$log_file
		function_status_check $?
	fi
	
	if [ ${schema_setup} == "mysql" ]; then
		function_print_header "install mysql db client"
		yum install mysql -y &>>$log_file
		function_status_check $?
		
		function_print_header "install mysql schema"
		mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pRoboShop@1 < /app/schema/shipping.sql &>>$log_file
		function_status_check $?		
	fi
	
}


function_php() {
	
	function_print_header "install python and it's dependencies"
	yum install python36 gcc python3-devel -y &>>$log_file
	function_status_check $?
	
	function_app_config
	
	function_print_header "install python requirements"
	cd /app &>>$log_file
	pip3.6 install -r requirements.txt &>>$log_file
	function_status_check $?
	
	function_start_component
}

function_golang() {

	function_print_header "install golang"
	yum install golang -y &>>$log_file
	function_status_check $?
	
	function_app_config
	
	function_print_header "Build application"
	cd /app &>>$log_file
	go mod init dispatch &>>$log_file
	go get &>>$log_file
	go build &>>$log_file
	function_status_check $?
	
	function_start_component
}

function_status_check() {
	if [ $1 -eq 0 ]; then
		echo -e "\e[32mSUCCESS\e[0m"
	else	
		echo -e "\e[32mFAILURE\e[0m"
		echo -e "please refer ${log_file} for more information"
	fi
}	