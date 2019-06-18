
gitlab地址：https://github.com/myide/see
生产镜像
docker build -t see:test .

运行容器
docker run -d \
        --restart always \
        --name see \
        --network=lnmp_net \
        --log-opt max-size=100m \
        --log-opt max-file=5 \
        -v /etc/timezone:/etc/timezone \
        -v /etc/localtime:/etc/localtime \
        -e "MYSQL_HOST=lnmp-mysql-5.7" \
        -e "MYSQL_PORT=3306" \
        -e "MYSQL_USER=root" \
        -e "MYSQL_PASSWORD=*********" \
        -e "SMTP_HOST=smtp.qiye.aliyun.com" \
        -e "SMTP_PORT=465" \
        -e "MAIL_USER=admin@runxsports.com" \
        -e "MAIL_PASS=*********" \
        -e "SEE_ADDR=see.runxsports.com" \
        18817810841/see:test
如需连接外部服务器及配置邮箱 添加相关环境变量
example： -e "MYSQL_HOST=**.**.**.**"

环境变量
mysql 
    MYSQL_HOST #mysql IP地址
    MYSQL_PORT #mysql 服务端口
    MYSQL_USER #登陆用户
    MYSQL_PASSWORD #登陆密码

redis
    REDIS_HOST #redis ip地址 
    REDIS_PORT #redis 服务端口
邮箱
    SMTP_HOST #邮箱smtp地址
    SMTP_PORT #邮箱smtp端口
    MAIL_USER #邮箱账号
    MAIL_PASS #邮箱密码
    SEE_ADDR #see访问地址（一般是服务器地址,不要带http: 只写域名a.b.com）

系统设置

平台设置-Inception设置
inception_enable_identifer_keyword 开启 （检查在SQL语句中，是不是有标识符被写成MySQL的关键字，默认值为报警。）
inception_enable_column_charset 开启 （允许列自己设置字符集）
inception_merge_alter_table 关闭 （在多个改同一个表的语句出现是，报错，提示合成一个）
inception_check_column_default_value  关闭 （检查在建表、修改列、新增列时，新的列属性是不是要有默认值）
inception_enable_nullable 开启 （创建或者新增列时如果列为NULL，是不是报错）

修改update最大行数
在 /etc/inc.cnf中添加 inception_max_update_rows=1000000

修改nginx上传大小
在/etc/nginx/nginx.conf的server中添加client_max_body_size 20M;

访问see **.**.**.**:80 
初始账号密码 admin/Hu224514
mysql 初始账号密码 root/123456
