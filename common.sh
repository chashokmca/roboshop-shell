script=$(realpath "$0")
script_name=$(dirname "$script")
source $script_name/common.sh

function_print_header() {
	echo -e "\e[33m<<<<<<<<<<  $1 >>>>>>>>>>\e[0m"
}


function_java() {
	function_print_header "configure nodejs repos"
	yum install maven -y
	function_status_check $?
	
	function_app_config
	
	function_print_header "clean and install maven package"
	cd /app 
	mvn clean package 
	mv target/shipping-1.0.jar shipping.jar
	function_status_check $?
	
	func_schema_setup
	function_start_component
}

function_nodejs() {
	function_print_header "configure nodejs repos"
	curl -sL https://rpm.nodesource.com/setup_lts.x | bash
	function_status_check $?

	function_print_header "install nodejs"
	yum install nodejs -y
	function_status_check $?
	
	function_app_config
	
	function_print_header "download dependencies"
	npm install
	function_status_check $?
	
	func_schema_setup
	function_start_component
}

function_start_component() {
	function_print_header "copy catalogue service"
	cp ${component}.service /etc/systemd/system/${component}.service
	function_status_check $?

	function_print_header "start catalogue service"
	systemctl daemon-reload
	systemctl enable ${component} 
	systemctl start ${component}
	function_status_check $?
}

function_app_config() {
	function_print_header "add application user"
	useradd roboshop
	function_status_check $?

	function_print_header "create application directory"
	mkdir /app 
	function_status_check $?

	function_print_header "download application"
	curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip
	function_status_check $?	

	function_print_header "extract application"
	cd /app 
	unzip /tmp/${component}.zip
	function_status_check $?
}

func_schema_setup() {
	if [ ${schema_setup} == "mongo" ]; then
		function_print_header "configure mongo db repo"
		cp mongo.repo /etc/yum.repos.d/mongo.repo
		function_status_check $?

		function_print_header "install mongo db client"
		yum install mongodb-org-shell -y
		function_status_check $?

		function_print_header "configure application schema"
		mongo --host MONGODB-SERVER-IPADDRESS </app/schema/${component}.js
		function_status_check $?
	fi
	
	if [ ${schema_setup} == "mysql" ]; then
		function_print_header "install mysql db client"
		yum install mysql -y 
		function_status_check $?
		
		function_print_header "install mysql schema"
		mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pRoboShop@1 < /app/schema/shipping.sql
		function_status_check $?		
	fi
	
}


function_php() {
	
	function_print_header "install python and it's dependencies"
	yum install python36 gcc python3-devel -y
	function_status_check $?
	
	function_app_config
	
	function_print_header "install python requirements"
	cd /app 
	pip3.6 install -r requirements.txt
	function_status_check $?
	
	function_start_component
}

function_golang() {

	function_print_header "install golang"
	yum install golang -y
	function_status_check $?
	
	function_app_config
	
	function_print_header "Build application"
	cd /app 
	go mod init dispatch
	go get 
	go build
	function_status_check $?
	
	function_start_component
}

function_status_check() {
	if [ $1 -eq 0 ]; then
		echo -e "\e[32mSUCCESS\e[0m"
	else	
		echo -e "\e[32mFAILURE\e[0m"
	fi
}	