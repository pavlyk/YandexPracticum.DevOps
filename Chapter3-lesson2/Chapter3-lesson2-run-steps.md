# TASK 3.2

## 1. 
`lsof -a +L1 /`  

```console
Exception in thread "main" java.lang.UnsupportedClassVersionError: com/yandex/practicum/devops/SausageApplication has been compiled by a more recent version of the Java Runtime (class file version 60.0), this version of the Java Runtime only recognizes class file versions up to 55.0
55 = Java 11
60 = Java 16
```

#### check default Java version
`java -version`  
```shell
    openjdk version "11.0.13" 2021-10-19
    OpenJDK Runtime Environment (build 11.0.13+8-Ubuntu-0ubuntu1.20.04)
    OpenJDK 64-Bit Server VM (build 11.0.13+8-Ubuntu-0ubuntu1.20.04, mixed mode, sharing)
```

#### check other versions if installed
`sudo update-alternatives --config java`  
```shell
    There are 2 choices for the alternative java (providing /usr/bin/java).

    Selection    Path                                         Priority   Status
    ------------------------------------------------------------
    0            /usr/lib/jvm/java-16-openjdk-amd64/bin/java   1611      auto mode
  * 1            /usr/lib/jvm/java-11-openjdk-amd64/bin/java   1111      manual mode
    2            /usr/lib/jvm/java-16-openjdk-amd64/bin/java   1611      manual mode
```
#### # выбрать вариант 2


### 2.
`sudo vi /etc/systemd/system/sausage-store-frontend.service`  
```console
[Unit]
Description=Sausage store frontend daemon
After=syslog.target

[Service]
WorkingDirectory=/var/www-data/
ExecStart=http-server ./dist/frontend/ -p 443 --proxy http://localhost:8888
User=front-user
Type=simple
RestartSec=5s
StartLimitBurst=5
Environment="REPORT_PATH=/var/www-data/htdocs"
Environment="LOG_PATH=/var/jarservice/"
StandardOutput=append:/logs/out.log
StandardError=append:/logs/out.log
KillMode=process
Restart=always

[Install]
WantedBy=multi-user.target
```

`sudo systemctl start sausage-store-frontend.service && sudo systemctl start sausage-store-backend.service`  
`sudo systemctl status sausage-store-frontend.service`  
`sudo systemctl stop sausage-store-frontend.service`  
`sudo systemctl daemon-reload`  
`sudo systemctl restart sausage-store-frontend.service`  
`sudo systemctl start sausage-store-frontend.service`  
`cd /var/www-data && sudo http-server /var/www-data/dist/frontend/ -p 443 --proxy http://localhost:8888`  
`sudo -i -u front-user http-server /var/www-data/dist/frontend/ -p 443 --proxy http://localhost:8888`  


`sudo sysctl net.ipv4.ip_unprivileged_port_start=443`

### **Is there a way for non-root processes to bind to "privileged" ports on Linux?**
#### [sysctl method](https://stackoverflow.com/questions/413807/is-there-a-way-for-non-root-processes-to-bind-to-privileged-ports-on-linux)
```console
As of late, updating the kernel is no longer required.
You can now set
`sysctl net.ipv4.ip_unprivileged_port_start=80`

Or to persist
`sysctl -w net.ipv4.ip_unprivileged_port_start=80`  
`sudo vi /etc/sysctl.conf`  

And if that yields an error, simply edit /etc/sysctl.conf with nano and set the parameter there for persistence across reboots.
or via procfs
echo 80 | sudo tee /proc/sys/net/ipv4/ip_unprivileged_port_start
```


### 3. ACL
При помощи acl установите по дефолту права на чтение и исполнение для пользователя front-user для новых файлов в директории /var/www-data/htdocs, чтобы созданные файлы были доступны пользователям веб-сервиса.  
`sudo setfacl -m default:u:front-user:rx /var/www-data/htdocs`  


### Бонусное задание 1
#### Бонусное задание 1.1.
Запишите в файл /opt/bonus_right.txt список команд, которые позволят создать 10 новых пользователей alex0-alex9, объединить их в новую группу alex, выдать им права на просмотр всех системных логов, не меняя их текущих владельцев и сохранять список всех расширенных прав в файл /opt/saved_rights.  
`sudo groupadd alex`  
`for i in alex{0..9}; do sudo useradd $i -G alex; done`  
`sudo setfacl -R -L -m g:alex:rx,d:g:alex:rx /var/log/`  
`getfacl /var/log | sudo tee /opt/saved_rights`  


#### Бонусное задание 1.2. 
Дополните файл /opt/bonux_right.txt командами, которые будут использовать неименованные каналы, чтобы записать в файл /tmp/size_log.txt информацию о размере всех лог-файлов бэкенда сосисочной, отсортированных от большего к меньшему.  
`ls -lS | tee /tmp/size_log.txt`  


### 4. 
Проверьте на своей виртуальной машине, под каким пользователем работает и какой порт использует наше бэкенд приложение
`sudo fuser -v 443/tcp`  
```console
                     USER        PID ACCESS COMMAND
443/tcp:             front-user    557 F.... http-server
--------------------------
sudo fuser -v 8888/tcp
                     USER        PID ACCESS COMMAND
8888/tcp:            jarservice    616 F.... java
```

`echo "jarservice:8888" > /opt/java_application.txt`  
`cat java_application.txt`  
```console
jarservice:8888
```

### 5. iptables
#### 5.1. Разрешите в iptables входящее подключение на порт 443 для интерфейса eth0 и всех подсетей. Используйте протокол TCP.
`sudo iptables -A INPUT -i eth0 -p TCP --dport 443 -j ACCEPT`  

#### 5.2. Запретите в iptables входящее подключение на порт 8080 для интерфейса eth0 и всех подсетей. Используйте протокол TCP.
`sudo iptables -A INPUT -i eth0 -p TCP --dport 8080 -j DROP`  

`sudo apt install iptables-persistent`  
`sudo service netfilter-persistent reload`  
`sudo netfilter-persistent save`  
`sudo netfilter-persistent reload`  
`iptables-save > /etc/iptables.rules`  
`sudo iptables -L --line-numbers -v`  


### 6. 
#### 6.1. Добавьте пользователю jarservice свой публичный ключ и настройте доступ по ключу. 
`sudo mkdir -p /home/jarservice/.ssh && sudo touch /home/jarservice/.ssh/authorized_keys`  
`sudo vim /home/jarservice/.ssh/authorized_keys`  
```console
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIESmJ5L8clQT621E1PvEn5tYrCTAVp7HYlS1BW+MFh/7 pashkov.dmitriy@gmail.com
```
`sudo chmod 700 /home/jarservice/.ssh && sudo chmod 600 /home/jarservice/.ssh/authorized_keys`  
`sudo chown -R jarservice:jarservice /home/jarservice/.ssh`  

#### 6.1. Закройте ssh-доступ под пользователем root.
`sudo vi /etc/ssh/sshd_config`
```console
    PermitRootLogin no
```
`sudo systemctl restart sshd`  


### 7.
#### 7.1. Посмотрите на сервере, какой IP-адрес у используемого нами DNS-сервера, и запишите в файл /opt/dns_server.txt, в формате: 192.168.10.10.
`systemd-resolve --status | grep 'Current DNS' | awk '{print $4}' | sudo tee /opt/dns_server.txt`
```console
10.128.0.2
```


#### 7.2. Посмотрите с сервера, в какой IPv4-адрес резолвится доменное имя refactoring.guru, и запишите в файл /opt/resolv_server.txt в формате (вообще без пробелов): 192.168.10.10,192.168.10.11,192.168.10.12.
`dig +short refactoring.guru | sudo tee /opt/resolv_server.txt`  
```console
104.21.25.25,172.67.222.11
```


### 8.
**Подмонтируйте директорию /var/www/images, находящуюся на машине 178.154.212.255, локально в директорию /mnt/images, и не забудьте добавить монтирование в автозагрузку.**  
`sudo mkdir images`  
`sudo mount -t nfs 178.154.212.255:/var/www/images /mnt/images`  

`sudo vi /etc/fstab`  
```console
178.154.212.255:/var/www/images /mnt/images  nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
```


### Бонусное задание 2.
**Разверните у себя на виртуальной машине NFS-сервер**  
`sudo apt install nfs-kernel-server`  
`rpcinfo -p | grep nfs`
```console
    100003    3   tcp   2049  nfs
    100003    4   tcp   2049  nfs
    100003    3   udp   2049  nfs
```

`sudo systemctl enable nfs-server`  
`sudo systemctl status nfs-server`  

`sudo vi /etc/exports`  
```console
    /mnt/pets 10.128.0.60/24(rw,sync,no_subtree_check)
```
