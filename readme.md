
建议使用2GB vps

安装docker 和 docker compose
```bash
curl -fsSL https://get.docker.com | bash

curl -L "https://github.com/docker/compose/releases/download/v2.23.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

chmod a+x /usr/local/bin/docker-compose

rm -rf which dc

ln -s /usr/local/bin/docker-compose /usr/bin/dc
```

获取 docker compose源码 同时更新v2 board源码
```bash
git clone https://github.com/hello-world-1989/v2board-docker.git

cd v2board-docker/


git submodule init
git submodule update --remote --merge
```

- 修改域名
````bash
sed -i "s/end-gfw.com/your-domain.com/" ./caddy.conf
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
````bash
dc up -d

dc exec www bash


wget https://getcomposer.org/download/2.6.5/composer.phar
php composer.phar install
php artisan v2board:install

# optional
sed -i "s/memory_limit = 128M/memory_limit = 1G/" /etc/php7/php.ini
php -r "echo ini_get('memory_limit').PHP_EOL;"

# initialize
php artisan horizon &
````

数据库地址： mysql
数据库名： v2board
数据库用户名： root
数据库密码： newpassword
