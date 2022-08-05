### 1. Add variable `ENV_BACKEND` (type file) to gitlab 

```shell
export PSQL_USER=sudmedru
export PSQL_PASSWORD=strong_password_here
export PSQL_HOST=rc1b-rkh2fcafeufkyuw2.mdb.yandexcloud.net
export PSQL_PORT=6432
export PSQL_DB=sudmedru
export MONGO_HOST=rc1b-k6kxnzzdzwda1z36.mdb.yandexcloud.net
export MONGO_DATABASE=sudmedru
export MONGO_USER=sudmedru
export MONGO_PASSWORD=strong_password_here
```


### 2. Add envsubst in `sausage-store/backend/deploy.sh` instead of COPY unit file

```shell
#sudo cp -rf sausage-store-backend.service /etc/systemd/system/sausage-store-backend.service
source .ENV_BACKEND
envsubst < sausage-store-backend.service | sudo tee /etc/systemd/system/sausage-store-backend.service > /dev/null
sudo rm -f .ENV_BACKEND || true
```


### 3. Add vars in `sausage-store/backend/sausage-store-backend.service`

```shell
[Unit]
Description=Sausage Store Backend Service
After=syslog.target

[Service]
Type=simple
WorkingDirectory=/home/jarservice/
ExecStart=/usr/bin/java -jar /home/jarservice/sausage-store.jar \
--server.port=8888 \
--spring.datasource.url='jdbc:postgresql://$PSQL_HOST:$PSQL_PORT/$PSQL_DB' \
--spring.datasource.username=$PSQL_USER \
--spring.datasource.password=$PSQL_PASSWORD \
--spring.data.mongodb.uri='mongodb://$MONGO_USER:$MONGO_PASSWORD@$MONGO_HOST:27018/$MONGO_DATABASE?tls=true&replicaSet=rs01'
User=jarservice
Restart=always
RestartSec=5s
StartLimitBurst=5
Environment="REPORT_PATH=/var/www-data/htdocs"
Environment="LOG_PATH=/var/jarservice/"
SuccessExitStatus=143

[Install]
WantedBy=multi-user.target
```


### 4. Connecting to MongoDb with SSL from JAVA app
#### 4.1. Search `cacerts`
`sudo find / -type f -name cacerts`  
```shell
/etc/ssl/certs/java/cacerts
```

`ll /etc/ssl/certs/java/cacerts`  
```shell
-rw-r--r-- 1 root root 153797 Aug  3 21:53 /etc/ssl/certs/java/cacerts
```

#### 4.2. Access MongoDB server and retrieve certificates
#### [InstallCert.java](https://github.com/escline/InstallCert)
`java InstallCert rc1b-k6kxnzzdzwda1z36.mdb.yandexcloud.net:27018`  
* Accept certificate 1 as rc1b-k6kxnzzdzwda1z36.mdb.yandexcloud.net.cer
* Accept certificate 2 as YandexCLCA.cer
* Accept certificate 3 as YandexInternalRootCA.cer

#### 4.3. Import certificates into system keystore
```shell
sudo keytool -importcert -trustcacerts -noprompt -file rc1b-k6kxnzzdzwda1z36.mdb.yandexcloud.net.cer -alias rc1b-k6kxnzzdzwda1z36.mdb.yandexcloud.net_cer -cacerts -storepass changeit
sudo keytool -importcert -trustcacerts -noprompt -file YandexCLCA.cer -alias YandexCLCA_cer -cacerts -storepass changeit
sudo keytool -importcert -trustcacerts -noprompt -file YandexInternalRootCA.cer -alias YandexInternalRootCA_cer -cacerts -storepass changeit
```

#### 4.4. List serts in keystore
`keytool -list -v -cacerts -storepass changeit`  


### 5. Check if MongoDB receives reports
`mongosh --norc --tls --tlsCAFile /usr/local/share/ca-certificates/Yandex/YandexInternalRootCA.crt --host 'rs01/rc1b-k6kxnzzdzwda1z36.mdb.yandexcloud.net:27018' -u sudmedru -p strong_password_here sudmedru`  

```shell
Current Mongosh Log ID: 62ecd1a93d068bd8b0705cd6
Connecting to:          mongodb://rc1b-k6kxnzzdzwda1z36.mdb.yandexcloud.net:27018/sudmedru?replicaSet=rs01&appName=mongosh+1.1.9
Using MongoDB:          5.0.8
Using Mongosh:          1.1.9

For mongosh info see: https://docs.mongodb.com/mongodb-shell/

rs01 [primary] sudmedru> db.stats()
{
  db: 'sudmedru',
  collections: 1,
  views: 0,
  objects: 174,
  avgObjSize: 105.70689655172414,
  dataSize: 18393,
  storageSize: 45056,
  indexes: 1,
  indexSize: 36864,
  totalSize: 81920,
  scaleFactor: 1,
  fsUsedSize: 559157248,
  fsTotalSize: 63142932480,
  ok: 1,
  '$clusterTime': {
    clusterTime: Timestamp({ t: 1659687330, i: 2 }),
    signature: {
      hash: Binary(Buffer.from("11f92b0f065f9725a679427f6b8d1b612cc0af94", "hex"), 0),
      keyId: Long("7125093879249895429")
    }
  },
  operationTime: Timestamp({ t: 1659687330, i: 2 })
}
rs01 [primary] sudmedru> db.getCollectionNames();
[ 'report' ]
rs01 [primary] sudmedru> db.report.find()
[
  {
    _id: '1311',
    name: '8dcp2',
    quantity: '220',
    _class: 'com.yandex.practicum.devops.model.Report'
  },
  {
    _id: '4605',
    name: 'e2zo8',
    quantity: '306',
    _class: 'com.yandex.practicum.devops.model.Report'
  },
  {
    _id: '4478',
    name: 'ifrfc',
    quantity: '224',
    _class: 'com.yandex.practicum.devops.model.Report'
  },
<...>
```


### 6. Fix java code as told in the task
`backend/src/main/java/com/yandex/practicum/devops/task/ReportSaverTask.java`  
```java
---    @Scheduled(fixedDelay = 60000)
+++    @Scheduled(fixedDelay = 300000)
    public void saveReport() {
        log.info("Saving report");
        Report report =
                restTemplate.getForObject("https://d5d5ae9uc621vcf2cphm.apigw.yandexcloud.net/report", Report.class);
```


### 7. Add variable `SPRING_FLYWAY_ENABLED=false` into file `sausage-store/backend/sausage-store-backend.service`

```shell
[Unit]
Description=Sausage Store Backend Service
After=syslog.target

[Service]
Type=simple
WorkingDirectory=/home/jarservice/
ExecStart=/usr/bin/java -jar /home/jarservice/sausage-store.jar \
--server.port=8888 \
--spring.datasource.url='jdbc:postgresql://$PSQL_HOST:$PSQL_PORT/$PSQL_DB' \
--spring.datasource.username=$PSQL_USER \
--spring.datasource.password=$PSQL_PASSWORD \
--spring.data.mongodb.uri='mongodb://$MONGO_USER:$MONGO_PASSWORD@$MONGO_HOST:27018/$MONGO_DATABASE?tls=true&replicaSet=rs01'
User=jarservice
Restart=always
RestartSec=5s
StartLimitBurst=5
Environment="SPRING_FLYWAY_ENABLED=false"
Environment="REPORT_PATH=/var/www-data/htdocs"
Environment="LOG_PATH=/var/jarservice/"
SuccessExitStatus=143

[Install]
WantedBy=multi-user.target
```
