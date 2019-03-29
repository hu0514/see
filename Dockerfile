FROM centos

COPY ./files/Percona-Server-5.6.41-84.1-rb308619-el7-x86_64-bundle.tar /tmp/
RUN yum -y install epel-release
RUN yum -y install cmake  gcc gcc-c++ openssl-devel ncurses-devel mysql MySQL-python wget make unzip autoconf numactl-libs readline readline-devel gcc gcc-c++ zlib zlib-devel openssl openssl-devel sqlite-devel python-devel libaio-devel libffi-devel glib2 glib2-devel nginx redis expect vim \
    && cd /tmp \
    && wget http://ftp.gnu.org/gnu/bison/bison-2.5.1.tar.gz \
    && tar -zxvf bison-2.5.1.tar.gz \
    && cd bison-2.5.1 \
    && ./configure \
    && make \
    && make install \
    && cd /tmp \
    && wget https://github.com/myide/inception/archive/master.zip \
    && unzip master.zip \
    && mv inception-master /usr/local/ \
    && cd /usr/local/inception-master/ \
    && sh inception_build.sh builddir linux \
    && touch /etc/inc.cnf \
    && echo "[inception]">> /etc/inc.cnf \
    && echo "general_log=1">> /etc/inc.cnf \
    && echo "general_log_file=inc.log">> /etc/inc.cnf \
    && echo "port=6669">> /etc/inc.cnf \
    && echo "socket=/tmp/inc.socket">> /etc/inc.cnf \
    && echo "character-set-client-handshake=0">> /etc/inc.cnf \ 
    && echo "character-set-server=utf8">> /etc/inc.cnf \ 
    && echo "inception_remote_system_password=123456">> /etc/inc.cnf \ 
    && echo "inception_remote_system_user=root">> /etc/inc.cnf \ 
    && echo "inception_remote_backup_port=3306">> /etc/inc.cnf \ 
    && echo "inception_remote_backup_host=127.0.0.1">> /etc/inc.cnf \ 
    && echo "inception_support_charset=utf8">> /etc/inc.cnf \ 
    && echo "inception_enable_nullable=0">> /etc/inc.cnf \ 
    && echo "inception_check_primary_key=1">> /etc/inc.cnf \ 
    && echo "inception_check_column_comment=1">> /etc/inc.cnf \ 
    && echo "inception_check_table_comment=1">> /etc/inc.cnf \ 
    && echo "inception_osc_min_table_size=1">> /etc/inc.cnf \ 
    && echo "inception_osc_bin_dir=/usr/bin">> /etc/inc.cnf \ 
    && echo "inception_osc_chunk_time=0.1">> /etc/inc.cnf \ 
    && echo "inception_ddl_support=1">> /etc/inc.cnf \
    && echo "inception_enable_blob_type=1">> /etc/inc.cnf \ 
    && echo "inception_check_column_default_value=1">> /etc/inc.cnf \
    && cd /tmp \
    && wget https://codeload.github.com/Meituan-Dianping/SQLAdvisor/zip/master \
    && unzip master \
    && mv SQLAdvisor-master /usr/local/src/ \
    && ln -s /usr/lib64/libperconaserverclient_r.so.18 /usr/lib64/libperconaserverclient_r.so \
    && tar xvf Percona-Server-5.6.41-84.1-rb308619-el7-x86_64-bundle.tar \
    && yum remove mariadb-libs -y \
    && rpm -ivh Percona-Server-56-debuginfo-5.6.41-rel84.1.el7.x86_64.rpm \
    && rpm -ivh Percona-Server-shared-56-5.6.41-rel84.1.el7.x86_64.rpm \
    && rpm -ivh Percona-Server-client-56-5.6.41-rel84.1.el7.x86_64.rpm \
    && rpm -ivh Percona-Server-server-56-5.6.41-rel84.1.el7.x86_64.rpm \
    && cd /usr/local/src/SQLAdvisor-master/ \
    && cmake -DBUILD_CONFIG=mysql_release -DCMAKE_BUILD_TYPE=debug -DCMAKE_INSTALL_PREFIX=/usr/local/sqlparser ./ \
    && make && make install \
    && cd ./sqladvisor/ \
    && cmake -DCMAKE_BUILD_TYPE=debug ./ \
    && make \
    && cp sqladvisor /usr/bin/sqladvisor \
    && cd /tmp \
    && wget https://www.python.org/ftp/python/3.6.6/Python-3.6.6.tgz \
    && tar -xzf Python-3.6.6.tgz \
    && cd Python-3.6.6 \
    && ./configure --prefix=/usr/local/python3.6 --enable-shared \
    && make && make install \
    && ln -s /usr/local/python3.6/bin/python3.6 /usr/bin/python3 \
    && ln -s /usr/local/python3.6/bin/pip3 /usr/bin/pip3 \
    && ln -s /usr/local/python3.6/bin/pyvenv /usr/bin/pyvenv \ 
    && cp /usr/local/python3.6/lib/libpython3.6m.so.1.0 /usr/local/lib \
    && cd /usr/local/lib \
    && ln -s libpython3.6m.so.1.0 libpython3.6m.so \
    && echo '/usr/local/lib' >> /etc/ld.so.conf \
    && /sbin/ldconfig \
    && cd /usr/local/ \
    && /usr/local/python3.6/bin/pyvenv seevenv \
    && cd seevenv \
    && source bin/activate \
    && wget https://codeload.github.com/myide/see/zip/master \
    && unzip master \
    && rm -f master \
    && cd see-master/backend/ \
    && pip install -r requirements.txt --trusted-host mirrors.aliyun.com -i https://mirrors.aliyun.com/pypi/simple/ \
    && sed -i '783,784d' /usr/local/seevenv/lib/python3.6/site-packages/pymysql/connections.py \
    && sed -i -e '/def _request_authentication(self):/a\          self.client_flag |= CLIENT.MULTI_RESULTS' /usr/local/seevenv/lib/python3.6/site-packages/pymysql/connections.py \
    && sed -i -e "/def _request_authentication(self):/a\        elif int(self.server_version.split(\'.\',1)[0]) >= 5:\n" /usr/local/seevenv/lib/python3.6/site-packages/pymysql/connections.py \
    && sed -i -e '/def _request_authentication(self):/a\          self.client_flag |= CLIENT.MULTI_RESULTS\n' /usr/local/seevenv/lib/python3.6/site-packages/pymysql/connections.py \
    && sed -i -e "/def _request_authentication(self):/a\        if self.server_version.split(\'.\',1)[0] == \'Inception2\':\n" /usr/local/seevenv/lib/python3.6/site-packages/pymysql/connections.py \
    && mkdir -p /usr/local/SOAR/bin/ \
    && cp /usr/local/seevenv/see-master/frontend/src/files/soar /usr/local/SOAR/bin \
    && chmod +x /usr/local/SOAR/bin/soar \
    && sed -i '38,57d' /etc/nginx/nginx.conf \
    && sed -i -e "/include \/etc\/nginx\/conf.d\/\*.conf;/a\server\n  {\n listen 80;\n access_log    \/var\/log\/access.log;\n error_log    \/var\/log\/error.log;\n location \/ {\n root \/usr\/local\/seevenv\/see-master\/frontend\/dist\/;\n try_files \$uri \$uri\/ \/index.html =404; \n index  index.html;  \n  } \n location \/static\/rest_framework_swagger {\n root \/usr\/local\/seevenv\/lib\/python3.6\/site-packages\/rest_framework_swagger\/;\n  } \n location \/static\/rest_framework { \n root \/usr\/local\/seevenv\/lib\/python3.6\/site-packages\/rest_framework\/; \n } \n location \/api { \n proxy_pass http:\/\/127.0.0.1:8090; \n add_header Access-Control-Allow-Origin \*; \n add_header Access-Control-Allow-Headers Content-Type; \n add_header Access-Control-Allow-Headers \"Origin, X-Requested-With, Content-Type, Accept\"; \n add_header Access-Control-Allow-Methods \"GET, POST, OPTIONS, PUT, DELETE, PATCH\"; \n } \n }\n" /etc/nginx/nginx.conf \
    && echo "/usr/bin/mysqld_safe &" >/tmp/mysql.sh \
    && /bin/bash /tmp/mysql.sh \
    && sleep 3 \
    && mysqladmin -uroot password 123456 \
    && mysqladmin -uroot -p123456 shutdown \
    && yum clean all \
    && rm -rf /tmp/*
COPY ./files/setup.sh /mnt/
RUN chmod 755 /mnt/setup.sh \
    && sed -i 353d /usr/local/seevenv/lib/python3.6/site-packages/pymysql/cursors.py \
    && sed -i '/if not self._defer_warnings:/a\            pass' /usr/local/seevenv/lib/python3.6/site-packages/pymysql/cursors.py
ENTRYPOINT ["/mnt/setup.sh"]










    















