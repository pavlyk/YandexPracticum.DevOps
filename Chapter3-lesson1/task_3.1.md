# Глава 3. Практическая работа 1

**Инструкция по сдаче домашних заданий**: после того, как будут выполнены все задания на этой странице, отправьте IP-адрес виртуальной машины наставнику через `http://`.  

### **Задание 1**
1. Зайдите на свою виртуальную машину, используя данные, которые были отправлены вам на почту.
2. Создайте пользователя `jarservice` c домашней директорией и группу `jarusers`. Создайте пользователя `front-user`.
3. Добавьте пользователя `jarservice` в группу `jarusers`.
4. Скопируйте jar-файл из домашней директории пользователя `admin` в папку `/var/jarservice`.
5. Из папки `/var/jarservice` запустите бэкенд (с помощью `java -jar <имя файла>`) из-под суперадминистратора.  
*Убедитесь, что приложение запустилось, затем остановите приложение, изучите созданные файлы рядом с jar-файлом. Посмотрите, какие папки создал запуск приложения. Запомните переменные в именах этих файлов.*  
#### **Если всё пропало**
Если вы потеряли доступ к `sudo`, не расстраивайтесь — это более чем нормально. Чтобы вернуть доступ, вам нужно:
1. Запустить два сеанса `ssh`.
2. В первом сеансе запустить `echo $$`.
3. Во втором сеансе запустить `pkttyagent --process <PID ПРОЦЕССА С ПРЕДЫДУЩЕГО ШАГА>`.
4. Вернуться в первый терминал и запустить `pkexec visudo`.

### **Задание 2**
1. В папке `/var/www-data` вы найдёте файлы фронтенда.
2. Соберите фронтенд, руководствуясь инструкциями из **README** сосисочной — учтите, что компиляция приложения наверняка потребует прав суперадминистратора.
3. Откройте сессию **screen** с именем `front` и запустите под суперадминистратором фронтенд.
4. Откройте браузер, введите IP-адрес и убедитесь, что фронтенд поднялся. Так как бэкенд остановлен, вы получите при обращении на сайт ошибку «На сайте ведутся технические работы. Приходите позже!».

### **Задание 3**
1. Напишите юнит-файл с именем сервиса `sausage-store-backend.service`, запускающий jar-файл от суперадминистратора (пользователя `root`). Расположите его в `/etc/systemd/system/`.
2. Настройте юнит-файл для автоматического старта при загрузке ОС и для автоподнятия при любой остановке.
3. Репорты должны писаться в директорию `/var/www-data/htdocs/`. Сконфигурировать это можно указанием пути в специальной переменной, с которой вы разобрались в Задании 1.
4. Логи должны записываться в `/var/jarservice/logs`. Сконфигурировать это можно указанием пути в специальной переменной, с которой вы разобрались в Задании 1.
5. Убедитесь, что сосисочная работает. Можете зайти на сайт и купить что-нибудь.

### **Задание 4**
1. Убедитесь, что всё свободное место закончилось и остановите бэкенд сосисочной. Удалите логи сосисочной, чтобы освободить место.
2. Создайте на своей виртуальной машине 2 диска, по 1 ГБ каждый.

```
Ремарка
Диски находятся в облаке и уже добавлены к вашей виртуальной машине. Просто воспользуйтесь ими.
```
3. Создайте виртуальную группу под названием `log_vg` и включите туда `PV` для обоих созданных дисков.
4. Создайте виртуальный раздел `lvm log_vol` на 100% группы `log_vg`.
5. Создайте файловую систему **ext4** на `log_vol` и примонтируйте её в раздел `/logs`.
6. Пропишите монтирование в `/etc/fstab`, чтобы не потерялось при перезапуске виртуалки.


### **Задание 5**
Добавьте оставшееся место на диске в `log_vol`. Расширьте файловую систему, запустите `df -h` и убедитесь, что она действительно расширилась.


### **Задание 6**
1. Настройте юнит-файл бэкенда сосисочной из Задания 3 так, чтобы логи jar-файла записывались в директорию `/logs`. Сконфигурируйте их путь в специальной переменной окружения, с которой вы разобрались в Задании 1.
2. Вывод приложения с помощью системных настроек сервис-файла перенаправьте в `/logs/out.log`.
3. Запустите бэкенд сосисочной и убедитесь, что приложение работает и можно что-то купить.
4. Убедитесь, что на виртуальной машине, где запущен бэкенд, логи пишутся на виртуальный раздел, который был создан вами в Задании 4.