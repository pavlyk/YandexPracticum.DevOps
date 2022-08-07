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
