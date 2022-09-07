# Глава 8. Практическое задание 1

Внимание: перед выполнением работы зайдите в [бота](https://t.me/practicumDevOpsHelperBot), выберите 8 глава и нажмите кнопку Отправить изменения для 1 урока.  

В результате коммита в вашем репозитории появится директория с исходным кодом для сервиса отчётов — **backend-report**. Сервис написан на том же фреймворке, что и основной бэкенд нашего приложения. Процесс сборки микросервиса отчётов вы можете посмотреть в файле **backend-report/Dockerfile**.  

## Задание 1
1) После того как бот накатит изменения в ваш репозиторий, создайте ветку `microservices` и все изменения производите в ней.
2) Добавьте необходимые для работы с `Vault` настройки в `application.properties` сервиса `backend-report`.  
3) Сформируйте `docker-compose.yml` файл для запуска **sausage-store**:
    * `docker-compose.yml` должен содержать описание сервисов: `backend`, `backend-report`, `frontend`;
    * сервисы должны располагаться в единой `bridge` сети;
    * для сервиса отчётов `backend-report` используйте сборку образа: в блок `build` передайте контекст сборки и путь к `Dockerfile`;
    * сервисам `backend` и `backend-report` должны быть переданы необходимые для работы приложения переменные окружения.

В файле `docker-compose.yml` переменные окружения для сервиса указываются в блоке `environment` в формате `<ИМЯ_ПЕРЕМЕННОЙ>: <ЗНАЧЕНИЕ>` или передаются директивой [env_file](https://docs.docker.com/compose/environment-variables/#the-env_file-configuration-option) с указанием содержащего переменные файла:
```yaml
---
<...>
  backend-report:
    <...>
    environment:
      # Имя переменной         Имя переменной
      # внутри запущенного       для получения значения
      # контейнера              из текущего окружения при запуске docker-compose
      VAULT_DEV_ROOT_TOKEN_ID: "${VAULT_DEV_ROOT_TOKEN_ID}"
      <...> 
```

Подробнее о такой интерполяции переменных можете посмотреть [по этой ссылке](https://docs.docker.com/compose/environment-variables/).  

При локальном тестировании вы можете создать файл с набором таких переменных и экспортировать его перед запуском (`source test.env`):
```bash
# test.env
# тестовое окружение для примера, выполните source перед запуском docker-compose build/up
export VERSION=1.0.123
export SPRING_DATASOURCE_URL=jdbc:postgresql://<postgresql server ip>:5432/sausagestore
export SPRING_DATASOURCE_USERNAME="postgres"
export SPRING_DATA_MONGODB_URI="mongodb://user:pass@monga.mdb.yandexcloud.net:27018/my_db?tls=true"

export SPRING_CLOUD_VAULT_TOKEN=my_token 
```

4) Используя сформированный `docker-compose.yml`, запустите контейнеры локально или на выданной вам виртуальной машине.  
Убедитесь в работоспособности приложения. Используйте `docker-compose logs` и `docker inspect` в случае возникновения проблем.  


## Задание 2
1) Создайте конвейер сборки и доставки нового компонента `backend-report`. За основу можно взять `.gitlab-ci.yml` бэкенда, так как сервисы реализованы с помощью одного фреймворка.
2) Адаптируйте сформированный в первом задании `docker-compose.yml`. файл для запуска сервисов на виртуальной машине и поместите его в корень репозитория `sausage-store`. Используйте [CI/CD переменные проекта](https://docs.gitlab.com/ee/ci/variables/) для формирования и передачи необходимых переменных окружения запускаемых контейнеров.
3) Измените задачи стадии `deploy` и скрипты развёртывания сервисов, реализовав:
    * доставку на виртуальную машину файла `docker-compose.yml`;
    * обновление Docker образов и запуск сервисов `backend`, `backend-report`, `frontend` средствами `docker-compose`.  

Обратите внимание на команду `docker-compose up` — у неё есть множество опций, позволяющих запускать сервисы в фоновом режиме, пересоздавать и запускать контейнеры по-отдельности и много чего ещё.  

Сервисы `backend-report` и `backend` читают конфигурацию из Vault. В силу того, что Vault запускается в [«dev» режиме](https://www.vaultproject.io/docs/concepts/dev-server), вся конфигурация находится только в памяти и при перезапуске контейнера данные будут утрачены.  

Попробуйте написать скрипт заполнения Vault нужными данными при старте контейнера в `deploy.sh`. Если возникнут сложности, воспользуйтесь примером из подсказки.  
**Подсказка**:
```bash
#!/bin/sh
cat <<EOF | docker exec -i vault ash
  sleep 10;
  vault login ${VAULT_DEV_ROOT_TOKEN_ID}

  vault secrets enable -path=secret kv

  vault kv put secret/sausage-store spring.datasource.password="${SPRING_DATASOURCE_PASSWORD}" spring.data.mongodb.uri="mongodb://${SPRING_DATA_MONGODB_USERNAME}:${SPRING_DATA_MONGODB_PASSWORD}@${SPRING_DATA_MONGODB_HOST}:${SPRING_DATA_MONGODB_PORT}/${SPRING_DATA_MONGODB_DATABASE}?tls=true"
EOF 
```

4) Сохраните все изменения в ветке `microservices`, создайте Merge Request и отправьте ссылку на него наставнику в качестве решения.

## **Бонусное задание**
Реализуйте `deploy` сервисов без доставки `docker-compose.yml` файла на удалённый хост. Используйте возможности `docker context` и руководствуйтесь [статьей](https://www.docker.com/blog/how-to-deploy-on-remote-docker-hosts-with-docker-compose/) из официального блога Docker.  
**Подсказка**:
1) Для выполнения задания необходимо в задаче стадии `deploy` использовать образ [Docker-in-docker](https://hub.docker.com/layers/docker/library/docker/20.10.12-dind/images/sha256-af0ce9eee4461072754e6f35f18c219ca6981a16c0042c92bbb4823ce753faa2?context=explore).
2) В блоке `before_script` добавить [шаги установки](https://docs.docker.com/compose/install/#alternative-install-options) `Docker-compose` (напомним о том, что Docker-in-Docker образ собран на базе Alpine Linux).
3) В блоке `script` добавить шаги создания `context` и запуска сервисов.
