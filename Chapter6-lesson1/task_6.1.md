# Глава 6. Практическое задание 1

БД Postgres:  
```console
psql "host=rc1b-rkh2fcafeufkyuw2.mdb.yandexcloud.net \
      port=6432 \
      sslmode=verify-full \
      dbname=(Ваш имейл) \
      user=(Ваш имейл)\
      password=(Ваш пароль) \
      target_session_attrs=read-write"
```
Сертификат:  
```console
mkdir -p ~/.postgresql && \
wget "https://storage.yandexcloud.net/cloud-certs/CA.pem" -O ~/.postgresql/root.crt && \
chmod 0600 ~/.postgresql/root.crt
```

1. Подключитесь с ВМ и изучите структуру всех таблиц с помощью команд `\dt` и `\d`.  

2. Запустите запрос и посмотрите, насколько быстро он выполнится:  
```sql
select COUNT(*) from orders o INNER JOIN order_product op ON o.id = op.order_id INNER JOIN product p ON op.product_id = p.id WHERE p.id = 4;
```

3. Постройте подходящие индексы и замерьте время выполнения запроса:  
```sql
select COUNT(*) from orders o INNER JOIN order_product op ON o.id = op.order_id INNER JOIN product p ON op.product_id = p.id WHERE p.id = 2;
```

4. В репозитории infrastructure создайте ветку database.  
5. Добавьте в README.md, какие индексы в итоге сделали.  
6. Создайте Merge Request и отправьте наставнику.  
