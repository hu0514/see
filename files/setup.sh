#!/bin/bash
#nohup /usr/local/inception-master/builddir/mysql/bin/Inception --defaults-file=/etc/inc.cnf &

#mysql
if [ -z $MYSQL_HOST ];then
   MYSQL_HOST='127.0.0.1'
   /usr/bin/mysqld_safe &
   sleep 3
fi
sed -i "s/'HOST':'127.0.0.1',/'HOST':'$MYSQL_HOST',/g" /usr/local/seevenv/see-master/backend/sqlweb/settings.py
sed -i "s/inception_remote_backup_host=127.0.0.1/inception_remote_backup_host=$MYSQL_HOST/g" /etc/inc.cnf

if [ -z $MYSQL_USER ];then
   MYSQL_USER='root'
fi
sed -i "s/'USER': 'root',/'USER': '$MYSQL_USER',/g" /usr/local/seevenv/see-master/backend/sqlweb/settings.py
sed -i "s/inception_remote_system_user=root/inception_remote_system_user=$MYSQL_USER/g" /etc/inc.cnf

if [ -z $MYSQL_PASSWORD ];then
   MYSQL_PASSWORD='123456'
fi
sed -i "s/'PASSWORD': '123456',/'PASSWORD': '$MYSQL_PASSWORD',/g" /usr/local/seevenv/see-master/backend/sqlweb/settings.py
sed -i "s/inception_remote_system_password=123456/inception_remote_system_password=$MYSQL_PASSWORD/g" /etc/inc.cnf

if [ -z $MYSQL_PORT ];then
   MYSQL_PORT='3306'
fi
sed -i "s/'PORT':'3306',/'PORT':'$MYSQL_PORT',/g" /usr/local/seevenv/see-master/backend/sqlweb/settings.py
sed -i "s/inception_remote_backup_port=3306/inception_remote_backup_port=$MYSQL_PORT/g" /etc/inc.cnf

#redis
if [ -z $REDIS_HOST ];then
   REDIS_HOST='127.0.0.1'  
   /usr/bin/redis-server &
fi
sed -i "s/'host': '127.0.0.1',/'host': '$REDIS_HOST',/g" /usr/local/seevenv/see-master/backend/sqlweb/settings.py

if [ -z $REDIS_PORT ];then
   REDIS_PORT='6379'
fi
sed -i "s/'port': 6379,/'port': $REDIS_PORT,/g" /usr/local/seevenv/see-master/backend/sqlweb/settings.py
sed -i "s/BROKER_URL = 'redis:\/\/127.0.0.1:6379\/0'/BROKER_URL = 'redis:\/\/$REDIS_HOST:$REDIS_PORT\/0'/g" /usr/local/seevenv/see-master/backend/sqlweb/settings.py
sed -i "s/CELERY_RESULT_BACKEND = 'redis:\/\/127.0.0.1:6379\/1'/CELERY_RESULT_BACKEND = 'redis:\/\/$REDIS_HOST:$REDIS_PORT\/1'/g" /usr/local/seevenv/see-master/backend/sqlweb/settings.py

#mail
if [ -z $SMTP_HOST ];then
   SMTP_HOST='smtp.163.com'
fi
sed -i "s/'smtp_host': 'smtp.163.com',/'smtp_host': '$SMTP_HOST',/g" /usr/local/seevenv/see-master/backend/sqlweb/settings.py

if [ -z $SMTP_PORT ];then
   SMTP_PORT='465'
fi
sed -i "s/'smtp_port': 465,/'smtp_port': $SMTP_PORT,/g" /usr/local/seevenv/see-master/backend/sqlweb/settings.py

if [ -z $MAIL_USER ];then
   MAIL_USER='sql_see@163.com'
fi
sed -i "s/'mail_user': 'sql_see@163.com',/'mail_user': '$MAIL_USER',/g" /usr/local/seevenv/see-master/backend/sqlweb/settings.py

if [ -z $MAIL_PASS ];then
   MAIL_PASS='see123'
fi
sed -i "s/'mail_pass': 'see123',/'mail_pass': '$MAIL_PASS',/g" /usr/local/seevenv/see-master/backend/sqlweb/settings.py

if [ -z $SEE_ADDR ];then
   SEE_ADDR='http://xxx.xxx.xxx.xxx:81'
fi
sed -i "s/'see_addr': 'http:\/\/xxx.xxx.xxx.xxx:81',/'see_addr': 'http:\/\/$SEE_ADDR',/g" /usr/local/seevenv/see-master/backend/sqlweb/settings.py

nohup /usr/local/inception-master/builddir/mysql/bin/Inception --defaults-file=/etc/inc.cnf &
mysql -h $MYSQL_HOST -P$MYSQL_PORT -u$MYSQL_USER -p$MYSQL_PASSWORD -e "create database If Not Exists sqlweb CHARACTER SET utf8;"
source /usr/local/seevenv/bin/activate
cd /usr/local/seevenv/see-master/backend

python manage.py makemigrations
sleep 10
python manage.py migrate
sleep 30
nohup python manage.py celery worker -c 10 -B --loglevel=info &
gunicorn -c sqlweb/gunicorn_config.py sqlweb.wsgi

superuser=`mysql -uroot -p123456 -e "select is_superuser from sqlweb.account_user;"|grep -vE '0|is_superuser'|wc -l`
if [ $superuser -eq 0 ];then
password=Hu224514
expect << EOF
spawn python manage.py createsuperuser --username admin --email admin@domain.com
expect "Password:"
send "${password}\r"
expect "Password (again):"
send "${password}\r"
expect eof;
EOF
fi
exec /usr/sbin/nginx -g "daemon off;"
