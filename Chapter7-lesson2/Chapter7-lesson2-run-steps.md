### 1. Create new object storage
1. [Create bucket](https://cloud.yandex.com/en/docs/storage/quickstart#the-first-bucket) for storing data.
2. [Upload files](https://cloud.yandex.com/en/docs/storage/quickstart#upload-files) to bucket.
3. [Get links](https://cloud.yandex.com/en/docs/storage/quickstart#get-link) to download files.


### 2. Change links
`backend/src/main/java/com/yandex/practicum/devops/SausageApplication.java`
![change links](/Chapter7-lesson2/01.change-links.png)


### 3. Check by bot-helper
`@practicumDevOpsHelperBot`
![check links by bot](/Chapter7-lesson2/01-1.change-links.png)


### 4. Create new static key for bucket
![service-account](/Chapter7-lesson2/02.service-account.png)  

![editor-devops](/Chapter7-lesson2/03.editor-devops.png)  

![create-new-key](/Chapter7-lesson2/04.create-new-key.png)  

### 5. Run MinIO in Docker
1. `docker pull minio/minio`  
2. `docker-compose.yml`  
```yaml
version: '2.4'
services:
  minio:
    restart: always
    image: minio/minio
    ports:
      - "9000:9000"
      - "9001:9001"
    environment:
      - MINIO_ROOT_USER=${MINIO_ROOT_USER}
      - MINIO_ROOT_PASSWORD=${MINIO_ROOT_PASSWORD}
    volumes:
      - /home/student/minio/data:/data
    command: server --address ":9001" --console-address ":9000" /data
```
3. Install direnv for secret vars  
```bash
sudo apt install direnv
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
cd minio
echo export MINIO_ROOT_USER=login_here > .envrc
echo export MINIO_ROOT_PASSWORD=password_here >> .envrc
direnv allow .
```
4. Run docker compose  
`docker-compose up -d minio`  

5. Go to browser  
`http://51.250.67.183:9000`


### 6. Install and config rclone 
`curl https://rclone.org/install.sh | sudo bash`  

```shell
rclone config
>1. New remote
>minio
>5. S3
>22. Any other
>1. Enter AWS credentials
>AWS Access key id
>AWS SecretAccess key (password)
>1. Empty region
>Endpoint: storage.yandexcloud.net
>location_constrait: <empty>
>acl: 1. Owner gets full control, no one else has access rights (default)
>
>
Configuration complete.
Options:
- type: s3
- provider: Other
- access_key_id: YCAJE<...>RrL
- secret_access_key: YCM<...>S1Si
- endpoint: storage.yandexcloud.net
- acl: private
- bucket_acl: private
Keep this "minio" remote?
y) Yes this is OK (default)
e) Edit this remote
d) Delete this remote
y/e/d> y

Current remotes:
Name                 Type
====                 ====
minio                s3
```

### 7. Copy and sync YandexCloud S3 bucket with local MinIO
1. List buckets  
`rclone lsd minio:`  
```shell
  -1 2022-08-19 15:56:22        -1 pashkov-minio-sync
  -1 2022-08-19 15:14:10        -1 pashkov-sausage-store-static
```

2. Copy files into that bucket  
`rclone copy /home/student/minio/data minio:pashkov-minio-sync`  

3. Copy files back from that bucket  
`rclone copy minio:pashkov-minio-sync /home/student/minio/data`  

4. Sync files  
`rclone --dry-run sync /home/student/minio/data minio:pashkov-minio-sync`  
`rclone sync /home/student/minio/data minio:pashkov-minio-sync`  
