# Глава 8. Практическое задание 2

## Обязательное задание
Необходимо доработать приложение сосисочной:  
1) Добавить в `docker-compose.yml` из предыдущих уроков контейнер Nginx вместо фронтенда и настроить его как балансировщик. При этом должна быть возможность масштабировать бэкенд, а конфигурационный файл Nginx должен формироваться динамически в зависимости от количества работающих экземпляров бекэнда. Шаблон конфига будет лежать по пути `/app/nginx.tmpl`.  

Файл шаблона:
```yaml
{{ range $host, $containers := groupBy $ "Env.VIRTUAL_HOST" }}
upstream {{ $host }} {

{{ range $index, $value := $containers }}
    {{ with $address := index $value.Addresses 0 }}
    server {{ $value.Hostname }}:{{ $address.Port }};
    {{ end }}
{{ end }}

}

server {

  listen 80;

  location / {
    root   /usr/share/nginx/html;
    index  index.html;
    try_files $uri $uri/ /index.html;
  }

  location /api {
      proxy_pass http://{{ $host }};
  }
}
{{ end }} 
```

Если вы хотите потренироваться в работе с Nginx — выполните бонусное задание и ваше приложение обретёт домен и сертификат.  

## **Бонусное задание**
1) Настройте кэширование на Nginx.
2) Выберите для приложения доменное имя.
3) Настройте DNS-адресацию для полученного имени.
4) Настройте SSL на Nginx. Для это необходимо использовать **certbot**, которым через сервис **LetsEncrypt** можно выпустить и подписать ssl-сертификат.
5) Автоматизируйте перевыпуск сертификата (по умолчанию на бесплатном аккаунте он выпускается на 3 месяца).  

Задача на обновление сертификата должна выглядеть примерно так:
```bash
@daily certbot renew --pre-hook "docker-compose -f path/to/docker-compose.yml down" --post-hook "docker-compose -f path/to/docker-compose.yml up -d"
```
