# TASK 4.3

## 1. Edit `backend/.gitlab-ci.yml`
```console
deploy:
  stage: deploy
  before_script:
    #устанавливаем ssh-agent для удобства аутентификации по ssh
    - 'command -v ssh-agent >/dev/null || ( apt-get update && apt-get install -y openssh-client)'
    - eval $(ssh-agent -s)
    #сохраняем сгенеренный ранее приватный ключ для раннера
    - echo "$SSH_PRIVATE_KEY" | tr -d '\r' | ssh-add -
    - mkdir -p ~/.ssh
    - chmod 600 ~/.ssh
    - echo "$SSH_KNOWN_HOSTS" >> ~/.ssh/known_hosts
    - chmod 644 ~/.ssh/known_hosts
  script:
    - scp ./backend/sausage-store-backend.service ${DEV_USER}@${DEV_HOST}:/home/${DEV_USER}/sausage-store-backend.service
    - ssh ${DEV_USER}@${DEV_HOST} "export \"CURRENT_VERSION=${VERSION}\"; export \"VERSION=${VERSION}\"; export \"DEV_HOST=${DEV_HOST}\";export \"NEXUS_REPO_URL=${NEXUS_REPO_URL}\"; export \"NEXUS_REPO_USER=${NEXUS_REPO_USER}\"; export \"NEXUS_REPO_PASS=${NEXUS_REPO_PASS}\"; setsid /bin/bash -s" < ./backend/deploy.sh
```
```yaml
+++  environment:
+++    name: backend/${CI_COMMIT_REF_SLUG}
```


## 2. Edit `frontend/.gitlab-ci.yml`
```console
deploy:
  stage: deploy
  before_script:
    - 'command -v ssh-agent >/dev/null || ( apt-get update && apt-get install -y openssh-client)'
    - eval $(ssh-agent -s)
    - echo "$SSH_PRIVATE_KEY" | tr -d '\r' | ssh-add -
    - mkdir -p ~/.ssh
    - chmod 600 ~/.ssh
    - echo "$SSH_KNOWN_HOSTS" >> ~/.ssh/known_hosts
    - chmod 644 ~/.ssh/known_hosts
  script:
    - scp ./frontend/sausage-store-frontend.service ${DEV_USER}@${DEV_HOST}:/home/${DEV_USER}/sausage-store-frontend.service
    - ssh ${DEV_USER}@${DEV_HOST} "export \"CURRENT_VERSION=${VERSION}\"; export \"VERSION=${VERSION}\"; export \"DEV_HOST=${DEV_HOST}\"; export \"NEXUS_REPO_URL=${NEXUS_REPO_URL}\"; export \"NEXUS_REPO_USER=${NEXUS_REPO_USER}\"; export \"NEXUS_REPO_PASS=${NEXUS_REPO_PASS}\"; setsid /bin/bash -s" < ./frontend/deploy.sh
```
```yaml
+++  environment:
+++    name: frontend/${CI_COMMIT_REF_SLUG}
```
