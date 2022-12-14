# Глава 5. Практическое задание 3

В уроке 3 Главы 4 мы проходили Continuous Delivery и там описывали команды для развёртывания сосисочной. Теперь надо переложить это на Ansible.  

1. Создайте проект `infrastructure` в GitLab, если его ещё нет.  
2. Создайте в этом проекте каталог `ansible`.  
3. Установите Ansible на своей виртуальной машине.  
4. Используя terraform-скрипты из прошлого урока, создайте новую виртуальную машину.  
5. Создайте inventory-файл и добавьте туда запись о новой виртуальной машине.  
6. Создайте файловую структуру роли установки и настройки бэкенда в `roles/backend` и добавьте задачи установки зависимостей, копирования файлов бэкенда и запуска сервиса. Выполнение из-под **супер пользователя** должно быть только в тех шагах, где это оправдано.  
7. Создайте файловую структуру роли установки и настройки фронтенда в `roles/frontend` и добавьте задачи установки зависимостей, копирования файлов фронтенда и запуска сервиса. Выполнение из-под **супер пользователя** должно быть только в тех шагах, где это оправдано.  
8. Задачи для бекенда включают в себя:  
* установку пакета `openjdk-16-jdk`,  
* создание сервисного пользователя,  
* скачивание артефактов бэкенда из Nexus,  
* создание systemd-юнита для сервиса,  
* запуск бэкенда.  
9. Задачи для фронтенда включают в себя:  
* установку пакетов `npm`, `nodejs`. Примечание: для установки `nodejs` используйте [инструкцию](https://github.com/nodesource/distributions/blob/master/README.md),  
* создание сервисного пользователя `www-data`,  
* создание директории `/var/www-data` с правами `0755 www-data:www-data`,  
* загрузка артефактов из Nexus — параметризуйте номера версий,  
* создание systemd-юнита для сервиса,  
* запуск фронтенда.  
10. Создайте в каталоге `ansible` файл конфигурации `ansible.cfg`, в котором укажите настройки таймаута подключения к виртуальным машинам в 30 секунд и дефолтную папку для ролей `roles`.  
11. Создайте в каталоге `ansible` плейбук `playbook.yaml`, который выполнит следующее:  
* подключится к виртуальной машине под пользователем `ansible`,  
* запустит роли `backend` и `frontend`.  
12. Запустите плейбук и убедитесь что сосисочная установится на виртуальную машину.  
13. С помощью terraform-скриптов удалите созданную виртуальную машину.  
14. Создайте Merge Request в ветку `main` (или `master`) и отправьте наставнику ссылку с MR на проверку. Помните, что все плейбуки ждут обращения на английском.  
