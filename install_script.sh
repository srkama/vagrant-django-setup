#! /bin/bash
#utils...
URLENCODE() {
    # urlencode <string>
    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            *) printf '%%%02X' "'$c"
        esac
    done
}

#-------------------------------------------------------------------------------

BRANCH=""                					# Name of the branch
USERNAME=""									# Username 
PASSWORD=""									# Password 
GIT_REPO_NAME=apartment						# GIT Repo
PROJECT_NAME=apartment						# what name you want to give for your project
REPO_PROVIDER=""							# Repo provider githib / bitbucket
OWNER=""									# Owner of the Repo
DBHOST=localhost							# DB Host, default: locahost
DBNAME=""									# Database name
DBUSER=""									# User you want to create
DBPASSWD=""									# Password to used 
ROOTPASSWORD=""								# Password for root use


PASSWORD=$(URLENCODE $PASSWORD)				# URL encoded password, when it has special chars
GIT_REPO_URL=https://$USERNAME:$PASSWORD@$REPO_PROVIDER/$OWNER/$GIT_REPO_NAME.git  #Complete Repo URL 


#-------------------------------------------------------------------------------

#function for cloning the git repo
GIT_CLONE() {
	echo "Git clone"
	if [[ ! -z $GIT_REPO_URL ]]; then
		echo "cloning from" $GIT_REPO_URL
		git clone $GIT_REPO_URL
	else
		echo "Git URL not set not cloning"
	fi
}


#function for checking out the branch for bit
GIT_BRANCH() {
	if [[ ! -z $1 ]]; then
		echo "checking out branch" $1
		git checkout $1
	else
		echo "No branch is not specified"
	fi
}

#-------------------------------------------------------------------------------

echo "Installing packages Python, setuptools, nginx, git, supervisor, gunicorn"
add-apt-repository ppa:fkrull/deadsnakes-python2.7
sudo apt-get update 
sudo apt-get install -y python2.7 python-setuptools python-pip
sudo apt-get install -y python-dev libmysqlclient-dev libpq-dev libffi-dev
sudo apt-get install -y git nginx supervisor gunicorn python-mysqldb

echo "Installing mysql"
echo "mysql-server mysql-server/root_password password $ROOTPASSWORD" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $ROOTPASSWORD" | debconf-set-selections
sudo apt-get install -y mysql-server

#-------------------------------------------------------------------------------

echo -e "\n--- Setting up our MySQL user and db ---\n"
mysql -uroot -p$ROOTPASSWORD -e "CREATE DATABASE $DBNAME"
mysql -uroot -p$ROOTPASSWORD -e "grant all privileges on *.* to '$DBUSER'@'localhost' identified by '$DBPASSWD'"


cd /src/website/
echo "clonig the git repo"
GIT_CLONE
echo "chaning to git working directory"
cd $PROJECT_NAME
echo "checkout the branch"
GIT_BRANCH $BRANCH
echo "Installing all required packages"
sudo pip install -r requirements.txt

#-------------------------------------------------------------------------------
echo "Copying supervisor config.."
sudo cp /src/website/$PROJECT_NAME/bin/supervisor.conf /etc/supervisor/conf.d/
echo "Re reading and restarting supervisor"
sudo supervisord
#sudo supervisorctl reread
#sudo supervisorctl update
#sudo supervisorctl restart all
sudo supervisorctl status
echo "Copying nginx config to defaul nginx conf and restarting"
sudo cp /src/website/$PROJECT_NAME/bin/nginx.conf /etc/nginx/sites-available/default
sudo service nginx configtest
sudo service nginx restart
sudo service nginx status

#------------------------------------------------------------------------------

echo "Synching up the databases"
python manage.py syncdb --noinput

echo "user python manage.py createsuperuser to create the admin user account"