# [机场联盟 技术交流电报群](https://t.me/EndGFWUnion)

## 通过担保解决支付问题保护机场主

## 通过担保解决机场跑路问题，诚信长期经营

## 使用Docker 5分钟快速搭建v2board


### 使用 >=2GB VPS, 否则面板卡顿

- 安装docker 和 docker compose

```bash
curl -fsSL https://get.docker.com | bash

curl -L "https://github.com/docker/compose/releases/download/v2.23.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

chmod a+x /usr/local/bin/docker-compose

rm -rf which dc

ln -s /usr/local/bin/docker-compose /usr/bin/dc
```

- 获取 docker compose源码 同时更新v2 board源码
```bash
git clone https://github.com/hello-world-1989/v2board-docker.git

cd v2board-docker/


git submodule init
#v2board v1.7.4
git submodule update
```

- 修改域名
````bash
sed -i "s/http:\/\/end-gfw.com/http:\/\/your-domain.com/" ./caddy.conf
````

- 替换newpassword修改MySql密码
````bash
sed -i "s/v2boardisbest/newpassword/" ./docker-compose.yaml
````

- 开机自动启动 docker并运行网站， 北京时间每天4点半重启
```
echo '@reboot cd /root/v2board-docker && dc start' >> /etc/crontab
echo '30 20 * * * root sudo reboot' >> /etc/crontab
```

- 启动并进入容器，执行初始化
```bash
dc up -d
```

- 进入docker 容器
```
dc exec www bash

#cp /tmp/php-fpm.conf /etc/php7/php-fpm.d/www.conf
#cp /tmp/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

wget https://getcomposer.org/download/2.6.5/composer.phar
php composer.phar install
php artisan v2board:install
```

数据库地址： mysql
数据库名： v2board
数据库用户名： root
数据库密码： newpassword

````bash
# optional
sed -i "s/memory_limit = 128M/memory_limit = 256M/" /etc/php7/php.ini
php -r "echo ini_get('memory_limit').PHP_EOL;"

php artisan horizon &

netstat -tuln
#如果能看到80端口表明服务运行正常
#should see port 80 which indicate services run successfully

#------------------End----------------------------
# /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf &

#exit
#dc restart
#dc exec www bash

````
记得在 系统设置 -> 站点 强制HTTPS开启, 需要等10分钟生效


### 备份数据库
```
dc exec mysql bash

#容器中执行inside docker container 
mysqldump -u root -pnewpassword v2board > backup.sql
exit

#主机中执行inside host
dc cp mysql:/backup.sql .
```

如果你运行在AWS 上， 你可以备份到S3

apt install awscli

# 更新IAM Role -> S3 Access 

aws s3 cp backup.sql s3://{s3uri}


# 从S3下载 

aws s3 cp s3://{s3uri} backup.sql 

# 导入数据库
```
#主机中执行inside host
dc cp backup.sql mysql:/backup.sql
dc exec mysql bash

#容器中执行inside docker container
mysql -u root -pnewpassword v2board < /backup.sql
```

docker-compose ps -q | xargs docker stats
