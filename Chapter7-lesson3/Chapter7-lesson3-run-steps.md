### 1. Run dockerized Vault
```shell
docker run -d --cap-add=IPC_LOCK --name vault -p 8200:8200 -e 'VAULT_DEV_ROOT_TOKEN_ID=myroot' -e 'VAULT_SERVER=http://127.0.0.1:8200' -e 'VAULT_ADDR=http://127.0.0.1:8200' vault
```

- `-d` — чтобы запустить в фоне,
- `--cap-add=IPC_LOCK` — чтобы своп-память не сбрасывалась на диск, это небезопасно, так как там могут быть секретные данные,
- `--name vault` — называем контейнер vault,
- `-p 8200:8200` — пробрасываем порты,
- `-e 'VAULT_DEV_ROOT_TOKEN_ID=myroot'` — называем токен для входа (в режиме разработки предусмотрен упрощённый вход в хранилище Vault),
- `-e 'VAULT_SERVER=http://127.0.0.1:8200' -e 'VAULT_ADDR=http://127.0.0.1:8200'` — чтобы сервер торчал по http для простоты, а не https (в проде так делать нельзя!).  

### 2. Check Vault log
```shell
docker logs -f vault
```

```console
WARNING! dev mode is enabled! In this mode, Vault runs entirely in-memory
and starts unsealed with a single unseal key. The root token is already
authenticated to the CLI, so you can immediately begin using Vault.
You may need to set the following environment variable:
    $ export VAULT_ADDR='http://0.0.0.0:8200'
The unseal key and root token are displayed below in case you want to
seal/unseal the Vault or re-authenticate.
Unseal Key: FbYEIBoHHy2pP4K+f9sKErR2gZ69v+x1ftD+1chOh9Y=
Root Token: myroot
Development mode should NOT be used in production installations!
```

### 3. Add secrets into Vault
```bash
vault kv put secret/sausage-store spring.data.mongodb.uri=mongodb://sudmedru:strong_password@rc1b-k6kxnzzdzwda1z36.mdb.yandexcloud.net:27018/sudmedru?tls=true

vault kv put secret/sausage-store spring.datasource.password=strong_password

vault kv put secret/sausage-store spring.datasource.url=jdbc:postgresql://rc1b-rkh2fcafeufkyuw2.mdb.yandexcloud.net:6432/sudmedru

vault kv put secret/sausage-store spring.datasource.username=sudmedru
```

### 4. Make changes to files as told in task
- [backend/src/main/resources/application.properties](/Chapter7-lesson3/backend/src/main/resources/application.properties)
- [backend/src/test/resources/application.properties](/Chapter7-lesson3/backend/src/test/resources/application.properties)
- [pom.xml](/Chapter7-lesson3/backend/pom.xml)
- [.gitlab-ci.yml](/Chapter7-lesson3/backend/.gitlab-ci.yml)
- [backend_deploy.sh](/Chapter7-lesson3/backend/backend_deploy.sh)


### 5. Merge Request with changes
![Merge Request](/Chapter7-lesson3/merge_request.jpg)
