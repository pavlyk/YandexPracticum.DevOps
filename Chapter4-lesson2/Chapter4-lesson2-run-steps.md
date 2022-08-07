# TASK 4.2

### 1. Edit `.gitlab-ci.yml`
```yaml
stages:
  - module-pipelines

frontend:
  stage: module-pipelines
  trigger:
    include:
      - "/frontend/.gitlab-ci.yml"
    strategy: depend # depend нужен, если какой-нибудь дочерний пайплайн свалился, мы знали, что общий пайплайн тоже идёт с ошибкой
  only:
    changes: # как только происходит изменение в папке frontend, запускается дочерний пайплайн, который лежит в этой папке
      - frontend/**/*

backend:
  stage: module-pipelines
  trigger:
    include:
      - "/backend/.gitlab-ci.yml"
    strategy: depend
  only:
    changes:  # как только происходит изменение в папке backend, запускается дочерний пайплайн, который лежит в этой папке
      - backend/**/*
```


### 2. Add `backend/.gitlab-ci.yml`
```yaml
cache:
  paths:
    - ${CI_PROJECT_DIR}/.m2/repository

variables:
   VERSION: 1.0.${CI_PIPELINE_ID}
   MAVEN_REPO_PATH: ${CI_PROJECT_DIR}/.m2/repository
   JAVA_OPTS: -XX:MaxRAMPercentage=90 # для того, чтобы Maven не съел всю свободную оперативку
   #JAVA_OPTS: -Xmx2500M
   #KUBERNETES_MEMORY_REQUEST: 2Gi

include:
  - template: Security/SAST.gitlab-ci.yml

stages:
   - build
   - test
   - release
   - deploy

build-backend-code-job:
   stage: build
   script:
      - echo "ARTIFACT_JOB_ID=${CI_JOB_ID}" > CI_JOB_ID.txt
      - cd backend
      - mvn package -Dversion.application=${VERSION} -Dmaven.repo.local=${MAVEN_REPO_PATH}
      - cd .. 
      - mkdir sausage-store-${VERSION}
      - mv backend/target/sausage-store-${VERSION}.jar sausage-store-${VERSION}/sausage-store-${VERSION}.jar
   artifacts:
    paths:
      - ${CI_PROJECT_DIR}/.m2/
      - sausage-store-${VERSION}/sausage-store-${VERSION}.jar 
    reports:
      dotenv: CI_JOB_ID.txt
   rules: # rules и only в данных случаях взаимозаменяемы
      - changes:
           - backend/**/*

spotbugs-sast:
  stage: test
  dependencies:
    - build-backend-code-job
  variables:
    COMPILE: "false"

sonarqube-backend-sast:
  stage: test
  image: maven:3.8-openjdk-16 # тот самый docker-образ, о котором мы все узнаем в будущем
  cache:
    key: ${CI_JOB_NAME}
    paths:
      - .sonar/cache
  script:
    - cd backend
    - >
      mvn verify sonar:sonar 
      -Dversion.application=${VERSION} 
      -Dsonar.qualitygate.wait=true 
      -Dsonar.projectKey=${SONAR_PROJECT_KEY_BACK}
      -Dsonar.host.url=${SONARQUBE_URL}
      -Dsonar.login=${SONAR_LOGIN}
  rules:
    - changes:
      - backend/**/*

release:
   stage: release
   script:
      - cd backend
      - mvn deploy -DskipTests -Dversion.application=${VERSION} -Dmaven.repo.local=${MAVEN_REPO_PATH} -s settings.xml
   rules:
      - changes:
           - backend/**/*

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

slack-message: # уведомляем в Slack
  stage: .post
  script:
    - echo "Send notify to Slack"
    - >
      curl -X POST -H 'Content-type: application/json' --data "{\"blocks\":[{\"type\":\"section\",\"text\":{\"type\":\"mrkdwn\",\"text\":\"Вышла новая версия сосисочной - ${VERSION}.\"}},{\"type\":\"section\",\"text\":{\"type\":\"mrkdwn\",\"text\":\"Backend: *<${NEXUS_REPO_URL}/sausage-store-pashkov-dmitriy-backend/com/yandex/practicum/devops/sausage-store/${VERSION}/sausage-store-${VERSION}.jar|Download :arrow-down:>*\"}},{\"type\":\"divider\"},{\"type\":\"context\",\"elements\":[{\"type\":\"mrkdwn\",\"text\":\":eyes: <@U03FRG969C6>\"}]}]}" https://hooks.slack.com/services/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
  when: on_success
```  


### 3. Add `frontend/.gitlab-ci.yml`
```yaml
cache:
  paths:
    - frontend/dist/frontend

variables:
  VERSION: 1.0.${CI_PIPELINE_ID}

include:
  - template: Security/SAST.gitlab-ci.yml

stages:
   - build
   - test
   - release
   - deploy

build-frontend-code-job:
  stage: build
  script:
    - echo "ARTIFACT_JOB_ID=${CI_JOB_ID}" > CI_JOB_ID.txt
    - cd frontend
    - npm install
    - npm run build
    - cd ..
    - mkdir sausage-store-${VERSION}  # создание директории, в которую копируются артефакты. Это нужно для организации удобной структуры архива
    - mv frontend/dist/frontend sausage-store-${VERSION}/public_html # копирование собранного фронтэнда
  artifacts:
    paths:
      - sausage-store-${VERSION}/public_html  # сохранение собранного фронтэнда как артефакт
      - ${CI_PROJECT_DIR}/.m2/ # сохранение зависимостей для SAST 
    reports:
      dotenv: CI_JOB_ID.txt  
  only:
     changes:
     - frontend/**/*

sonarqube-frontend-sast:
  stage: test
  image:
    name: sonarsource/sonar-scanner-cli:latest
  cache:
    key: "${CI_JOB_NAME}"
    paths:
      - .sonar/cache
  script:
    - cd frontend
    - >
      sonar-scanner
      -Dsonar.qualitygate.wait=true
      -Dsonar.projectKey=${SONAR_PROJECT_KEY_FRONT}
      -Dsonar.sources=. 
      -Dsonar.host.url=${SONARQUBE_URL}
      -Dsonar.login=${SONAR_LOGIN}
  rules:
    - changes:
      - frontend/**/*

upload-frontend-release:
  stage: release
  needs:
    - build-frontend-code-job
  script:
     - tar czvf sausage-store-${VERSION}.tar.gz sausage-store-${VERSION}
     - >
       curl -v -u "${NEXUS_REPO_USER}:${NEXUS_REPO_PASS}" --upload-file sausage-store-${VERSION}.tar.gz ${NEXUS_REPO_URL}/sausage-store-pashkov-dmitriy-frontend/${VERSION}/sausage-store-${VERSION}.tar.gz
  only:
     changes:
     - frontend/**/*

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

slack-message: # уведомляем в Slack
  stage: .post
  script:
    - echo "Send notify to Slack"
    - >
      curl -X POST -H 'Content-type: application/json' --data "{\"blocks\":[{\"type\":\"section\",\"text\":{\"type\":\"mrkdwn\",\"text\":\"Вышла новая версия сосисочной - ${VERSION}.\"}},{\"type\":\"section\",\"text\":{\"type\":\"mrkdwn\",\"text\":\"Frontend:\n*<${NEXUS_REPO_URL}/sausage-store-pashkov-dmitriy-frontend/${VERSION}/sausage-store-${VERSION}.tar.gz|Download :arrow-down:>*\"}},{\"type\":\"context\",\"elements\":[{\"type\":\"mrkdwn\",\"text\":\":eyes: <@U03FRG969C6>\"}]}]}" https://hooks.slack.com/services/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
  when: on_success
```


### 4. Add `backend/deploy.sh`
```bash
#!/bin/bash

#Если свалится одна из команд, рухнет и весь скрипт
set -xe

#Перезаливаем дескриптор сервиса на ВМ для деплоя
sudo cp -rf sausage-store-backend.service /etc/systemd/system/sausage-store-backend.service
sudo rm -f /home/jarservice/sausage-store.jar || true

#Скачиваем артефакт
cd /tmp
curl -u ${NEXUS_REPO_USER}:${NEXUS_REPO_PASS} -o sausage-store-${VERSION}.jar ${NEXUS_REPO_URL}/sausage-store-pashkov-dmitriy-backend/com/yandex/practicum/devops/sausage-store/${VERSION}/sausage-store-${VERSION}.jar

#Переносим артефакт в нужную папку
sudo cp ./sausage-store-${VERSION}.jar /home/jarservice/sausage-store.jar || true #"jar||true" говорит, если команда обвалится — продолжай

#Обновляем конфиг systemd с помощью рестарта
sudo systemctl daemon-reload

#Перезапускаем сервис сосисочной
sudo systemctl restart sausage-store-backend
```


### 5. Add `backend/sausage-store-backend.service`
```shell
[Unit]
Description=Sausage Store Backend Service
After=syslog.target

[Service]
Type=simple
WorkingDirectory=/home/jarservice/
ExecStart=/usr/bin/java -jar /home/jarservice/sausage-store.jar --server.port=8888
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


### 6. Add `frontend/deploy.sh`
```bash
#!/bin/bash

#Если свалится одна из команд, рухнет и весь скрипт
set -xe

#Перезаливаем дескриптор сервиса на ВМ для деплоя
sudo cp -rf sausage-store-frontend.service /etc/systemd/system/sausage-store-frontend.service
sudo rm -f /var/www-data/dist/frontend/* || true

#Скачиваем артефакт
cd /tmp
curl -u ${NEXUS_REPO_USER}:${NEXUS_REPO_PASS} -o sausage-store-${VERSION}.tar.gz ${NEXUS_REPO_URL}/sausage-store-pashkov-dmitriy-frontend/${VERSION}/sausage-store-${VERSION}.tar.gz

#Переносим артефакт в нужную папку
sudo mkdir -p /tmp/sausage-store-frontend-${VERSION}
sudo tar -xzvf sausage-store-${VERSION}.tar.gz -C /tmp/sausage-store-frontend-${VERSION}
YES | sudo cp -rf /tmp/sausage-store-frontend-${VERSION}/sausage-store-${VERSION}/public_html/. /var/www-data/dist/frontend/ || true

#Обновляем конфиг systemd с помощью рестарта
sudo systemctl daemon-reload

#Перезапускаем сервис сосисочной
sudo systemctl restart sausage-store-frontend
```


### 7. Add `frontend/sausage-store-frontend.service`
```shell
[Unit]
Description=Sausage Store Frontend Service
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
