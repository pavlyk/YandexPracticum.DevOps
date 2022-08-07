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
