# Глава 7. Практическое задание 3

1. Разверните Vault в контейнере, добавьте в него ключи `spring.datasource.username` и `spring.datasource.password`.
2. Удалите эти параметры из файла `backend/src/main/resources/application.properties`.
3. Добавьте зависимости для работы с Vault в `pom.xml`.
4. Сделайте то же самое для MongoDB: добавьте в Vault ключ `spring.data.mongodb.uri` и удалите его из файла `application.properties`.
5. Запустите приложение, убедитесь, что оно запускается без ошибок, при том, что все данные подключения к БД лежат в Vault.
6. Закоммитьте новые `pom.xml` и `application.properties`.

В качестве ответа создайте Merge Request и ссылку на него пришлите наставнику.
