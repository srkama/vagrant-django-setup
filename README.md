# vagrant-django-setup
simple vagrant django setup using Shell. 


Before running VagrantFile following values needs to configured in **install_script.sh**

* BRANCH=""                						# Name of the branch
* USERNAME=""									# Username of git or bitbucket 
* PASSWORD=""									# Password 
* GIT_REPO_NAME=apartment						# GIT Repo
* PROJECT_NAME=apartment						# what name you want to give for your project
* REPO_PROVIDER=""								# Repo provider githib / bitbucket
* REPO_GROUP=""									# Group
* DBHOST=localhost								# DB Host, default: locahost
* DBNAME=""										# Database name
* DBUSER=""										# User you want to create
* DBPASSWD=""									# Password to used 
* ROOTPASSWORD=""								# Password for root use