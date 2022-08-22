### 1. Create new object storage
1. [Create bucket](https://cloud.yandex.com/en/docs/storage/quickstart#the-first-bucket) for storing data.
2. [Upload files](https://cloud.yandex.com/en/docs/storage/quickstart#upload-files) to bucket.
3. [Get links](https://cloud.yandex.com/en/docs/storage/quickstart#get-link) to download files.


### 2. Change links
`backend/src/main/java/com/yandex/practicum/devops/SausageApplication.java`
```console
https://storage.yandexcloud.net/pashkov-sausage-store-static/1.jpg
https://storage.yandexcloud.net/pashkov-sausage-store-static/2.jpg
https://storage.yandexcloud.net/pashkov-sausage-store-static/3.jpg
https://storage.yandexcloud.net/pashkov-sausage-store-static/4.jpg
https://storage.yandexcloud.net/pashkov-sausage-store-static/5.jpg
https://storage.yandexcloud.net/pashkov-sausage-store-static/6.jpg
```

![change links](/Chapter7-lesson2/01.change-links.png)


### 3. Check by bot-helper
`@practicumDevOpsHelperBot`
![check links by bot](/Chapter7-lesson2/01-1.change-links.png)


### 4. Create new static key for bucket
![service-account](/Chapter7-lesson2/02.service-account.png)  

![editor-devops](/Chapter7-lesson2/03.editor-devops.png)  

![create-new-key](/Chapter7-lesson2/04.create-new-key.png)  

### 5. Install and start MinIO in Docker
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
`docker logs minio_minio_1`
```console
MinIO Object Storage Server
Copyright: 2015-2022 MinIO, Inc.
License: GNU AGPLv3 <https://www.gnu.org/licenses/agpl-3.0.html>
Version: RELEASE.2022-08-13T21-54-44Z (go1.18.5 linux/amd64)

Status:         1 Online, 0 Offline.
API: http://172.24.0.2:9001  http://127.0.0.1:9001
Console: http://172.24.0.2:9000 http://127.0.0.1:9000

Documentation: https://docs.min.io
```

5. Go to browser  
`http://51.250.67.183:9000`  
and add a bucket and the service account.


### 6. Install and configure rclone  
6.1. Install:  
**`curl https://rclone.org/install.sh | sudo bash`**  

6.2. Configure rclone for YandexCloud Storage  
**`rclone config`**
```shell
New remote> yandex-cloud
type> S3
provider> Any other
access_key_id> YCAJE<...>RrL
secret_access_key> YCM<...>S1Si
region> empty
Endpoint> storage.yandexcloud.net
location_constrait> empty
acl> owner gets full control, no one else has access rights
bucket_acl> private

Current remotes:
Name                 Type
====                 ====
yandex-cloud         s3
```

Which makes the config file look like this:  
`cat ~/.config/rclone/rclone.conf`
```console
[yandex-cloud]
type = s3
provider = Other
access_key_id = YCAJE<...>RrL
secret_access_key = YCM<...>S1Si
endpoint = storage.yandexcloud.net
acl = private
bucket_acl = private
```

6.3. Config rclone for MinIO in Docker  
**`rclone config`**
```console
New remote> docker-minio
type> S3
provider> Minio
access_key_id> DeWsdE<...>RrLf
secret_access_key> 26p0iq<...>cmABXZk
region> empty
Endpoint> http://51.250.67.183:9001
location_constrait> empty
acl> owner gets full control, no one else has access rights
bucket_acl> private

Current remotes:
Name                 Type
====                 ====
docker-minio         s3
yandex-cloud         s3
```

Which makes the config file look like this:  
`cat ~/.config/rclone/rclone.conf`
```console
[yandex-cloud]
type = s3
provider = Other
access_key_id = YCAJE<...>RrL
secret_access_key = YCM<...>S1Si
endpoint = storage.yandexcloud.net
acl = private
bucket_acl = private

[docker-minio]
type = s3
provider = Minio
access_key_id = DeWsdE<...>RrLf
secret_access_key = 26p0iq<...>cmABXZk
acl = private
endpoint = http://51.250.67.183:9001
```


### 7. Copy and sync YandexCloud bucket and local MinIO bucket
7.1. List buckets  
- `rclone lsd yandex-cloud:`  
```shell
  -1 2022-08-19 15:56:22        -1 pashkov-minio-sync
  -1 2022-08-19 15:14:10        -1 pashkov-sausage-store-static
```
- `rclone lsd docker-minio:`  
```shell
  -1 2022-08-21 21:48:03        -1 docker-minio
```

7.2. List files in buckets  
```bash
rclone ls docker-minio:docker-minio
rclone ls yandex-cloud:pashkov-minio-sync
```

7.3. Copy files into yandexcloud bucket  
```bash
rclone copy docker-minio:docker-minio yandex-cloud:pashkov-minio-sync
```

7.4. Copy files back from yandexcloud  
```bash
rclone copy yandex-cloud:pashkov-minio-sync docker-minio:docker-minio
```

7.5. Sync files from local to cloud  
```bash
rclone -v --dry-run sync docker-minio:docker-minio yandex-cloud:pashkov-minio-sync
rclone sync -v docker-minio:docker-minio yandex-cloud:pashkov-minio-sync
```

7.6. Sync files from cloud to local  
```bash
rclone -v --dry-run sync yandex-cloud:pashkov-minio-sync docker-minio:docker-minio
rclone sync -v yandex-cloud:pashkov-minio-sync docker-minio:docker-minio
```

**8. Add sync task to cron**  
8.1. `vi /home/student/minio/backup.sh`
```bash
rclone sync -v --create-empty-src-dirs docker-minio:docker-minio yandex-cloud:pashkov-minio-sync
```
8.2. `chmod +x /home/student/minio/backup.sh`  

8.3. `crontab -e`  
```bash
29 * * * * /home/student/minio/backup.sh
```
