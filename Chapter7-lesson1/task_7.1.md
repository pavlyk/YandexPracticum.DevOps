# Глава 7. Практическое задание 1

**Приложения нужно запускать в виде отдельных контейнеров, без использования systemd.**  
Для примера дан сниппет из .gitlab-ci для бэкенда, cвязанный с контейнеризацией. Остальная часть CI у вас есть:
```yaml

# В нашем Gitlab для сборки контейнеров воспользуемся Докером в Докере :)  
# https://docs.gitlab.com/ee/ci/docker/using_docker_build.html#use-the-kubernetes-executor-with-docker-in-docker
# Для сборки образов с использованием Docker-in-Docker:
# добавить в код Downstream пайплайнов в секцию include подготовленный шаблон, содержащий необходимые настройки:
#  https://gitlab.praktikum-services.ru/templates/ci/-/blob/main/DockerInDockerTemplate.yml
# использовать в задачах сборки в качестве образа стабильную версию образа Docker:dind docker:20.10.12-dind-rootless
#
include:
  - project: 'templates/ci'
    file: 'DockerInDockerTemplate.yml'
    
stages:
  - build
  - release
  - deploy

build-backend:
  stage: build
  image: docker:20.10.12-dind-rootless
  before_script:
    - until docker info; do sleep 1; done
    # переменные CI_REGISTRY_USER, CI_REGISTRY_PASSWORD, CI_REGISTRY генерятся Гитлабом, их задавать не надо
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
  script:
    - cd backend
    - >
      docker build
      --build-arg VERSION=$VERSION
      --tag $CI_REGISTRY_IMAGE/sausage-backend:$CI_COMMIT_SHA
      .
    - docker push $CI_REGISTRY_IMAGE/sausage-backend:$CI_COMMIT_SHA

upload-backend-latest:
  variables:
    GIT_STRATEGY: none
  image: docker:20.10.12-dind-rootless
  stage: release
  before_script:
    - until docker info; do sleep 1; done
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
  script:
    - docker pull $CI_REGISTRY_IMAGE/sausage-backend:$CI_COMMIT_SHA
    # если образ прошел проверки в CI (сканирование, тесты и т.д), то тегаем latest
    - docker tag $CI_REGISTRY_IMAGE/sausage-backend:$CI_COMMIT_SHA $CI_REGISTRY_IMAGE/sausage-backend:latest
    - docker push $CI_REGISTRY_IMAGE/sausage-backend:latest

deploy-backend:
  stage: deploy
  image: alpine:3.15.0
  # если хотим сделать деплой по кнопке
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
      when: manual
    - if: '$CI_COMMIT_BRANCH == "master"'
      when: manual
  before_script:
    - apk add openssh-client bash
    - eval $(ssh-agent -s)
    - echo "$SSH_PRIVATE_KEY" | tr -d '\r' | ssh-add -
    - mkdir -p ~/.ssh
    - chmod 700 ~/.ssh
    - echo "$SSH_KNOWN_HOSTS" >> ~/.ssh/known_hosts
    - chmod 644 ~/.ssh/known_hosts
  script:
    - ssh ${DEV_USER}@${DEV_HOST}
      "export "VERSION=${VERSION}";
       export "SPRING_DATASOURCE_URL=${PSQL_DATASOURCE}";
       export "SPRING_DATASOURCE_USERNAME=${PSQL_USER}";
       export "SPRING_DATASOURCE_PASSWORD=${PSQL_PASSWORD}";
       export "SPRING_DATA_MONGODB_URI=${MONGO_DATA}";
      /bin/bash -s " < ./backend/backend_deploy.sh
```
`backend_deploy.sh`  
```bash
#!/bin/bash
set +e
cat > .env <<EOF
SPRING_DATASOURCE_URL=${SPRING_DATASOURCE_URL}
SPRING_DATASOURCE_USERNAME=${SPRING_DATASOURCE_USERNAME}
SPRING_DATASOURCE_PASSWORD=${SPRING_DATASOURCE_PASSWORD}
SPRING_DATA_MONGODB_URI=${SPRING_DATA_MONGODB_URI}
EOF
docker network create -d bridge sausage_network || true
docker pull <реестр Gitlab Registry>/sausage-store/sausage-backend:latest
docker stop backend || true
docker rm backend || true
set -e
docker run -d --name backend \
    --network=sausage_network \
    --restart always \
    --pull always \
    --env-file .env \
    <реестр Gitlab Registry>/sausage-store/sausage-backend:latest
```

## Задание 1
1. Оптимизируйте Dockerfile сборки фронтенда:
* используйте оптимальный базовый образ и минимально необходимый набор компонентов, зависимостей и утилит;  
* минимизируйте количество создаваемых слоёв образа Вы также можете использовать [multi-stage](https://docs.docker.com/develop/develop-images/multistage-build/) сборку, в приручении которой поможет [подробное руководство](https://nodejs.org/ru/docs/guides/nodejs-docker-webapp/) по сборке NodeJS приложений в Docker.  
2. По аналогии с приведённым скриптом backend_deploy.sh напишите скрипт развёртывания фронтенда.  

## Задание №2
Доработайте CI/CD конвейеры бэкенда и фронтенда:  
1. На стадии `build` реализуйте сборку, упаковку приложений в Docker образы, тегирование и загрузку образов в GitLab Container Registry.  
2. На стадии `release` замените задачи по загрузке артефактов в Nexus: присвойте образам тег latest и загрузите образы в GitLab Container Registry.
3. Для стадии `deploy` реализуйте:
* генерацию и передачу переменных окружения для загрузки образов и запуска контейнеров;
* запуск скриптов развёртывания контейнеров.  
4. Помните про тесты — задачи стадии `test` должны присутствовать в конвейерах.  

По завершению практических заданий в вашем репозитории должны быть следующие файлы:  
* `backend/Dockerfile`, `frontend/Dockerfile`.
* обновлённые `.gitlab-ci.yml` и скрипты деплоя. 
* В Container Registry вашего проекта должно быть минимум 2 образа (бэкенд и фронтенд) с тегом `latest`.  

Как только выполните все задания, создайте Merge Request и ссылку на него отправьте наставнику в качестве решения.
