# TASK 4.1

### 1. Edit backend/pom.xml
```xml
--- <version>0.0.1-SNAPSHOT</version>
+++ <version>${VERSION}</version>
+++ <distributionManagement>
+++         <repository>
+++             <id>sausage-store</id>
+++             <name>sausage-store</name>
+++             <url>${env.NEXUS_REPO_URL}/sausage-store-pashkov-dmitriy-backend/</url>
+++         </repository>
+++ </distributionManagement>
```

### 2. Add backend/settings.xml
```xml
<settings xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.1.0 http://maven.apache.org/xsd/settings-1.1.0.xsd"
      xmlns="http://maven.apache.org/SETTINGS/1.1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <servers>
      <server>
        <id>sausage-store</id>
        <username>${env.NEXUS_REPO_USER}</username>
        <password>${env.NEXUS_REPO_PASS}</password>
      </server>
    </servers>
  </settings>
```

### 3. Edit .gitlab-ci.yml
```yaml
stages:
  - build
  - test
  - release

variables:
    VERSION: 1.0.${CI_PIPELINE_ID}
    MAVEN_REPO_PATH: ${CI_PROJECT_DIR}/.m2/repository

include:
  - template: Security/SAST.gitlab-ci.yml


build-frontend-code-job:
  stage: build   # этап build
  script:        # объявление скрипта
    - echo "ARTIFACT_JOB_ID=${CI_JOB_ID}" > CI_JOB_ID.txt  # сохранение номера задачи в файл, чтобы в дальнейшем использовать для копирования артефакта
    - echo "sausage-store-${VERSION}"
    - cd frontend
    - npm install # загрузка всех сторонних зависимостей
    - npm run build # запуск сборки кода
    - cd .. 
    - mkdir sausage-store-${VERSION}  # создание директории, в которую копируются артефакты. Это нужно для организации удобной структуры архива
    - mv frontend/dist/frontend sausage-store-${VERSION}/public_html # копирование собранного фронтэнда
  artifacts:
    paths:
      - sausage-store-${VERSION}/public_html  # сохранение собранного фронтэнда как артефакт
      - ${CI_PROJECT_DIR}/.m2/ # сохранение зависимостей для SAST 
    reports:
      dotenv: CI_JOB_ID.txt # сохранение файла с переменными как артефакт


build-backend-code-job:
  stage: build
#  only:
#    changes:
#      - backend/*
  script:
    - echo "ARTIFACT_JOB_ID=${CI_JOB_ID}" > CI_JOB_ID.txt
    - cd backend
    - mvn package -Dmaven.repo.local=${CI_PROJECT_DIR}/.m2/repository -Dversion.application=${VERSION}
#    - mv backend/target/sausage-store-${VERSION}.jar sausage-store-${VERSION}/sausage-store-${VERSION}.jar
  artifacts:
    paths:
      - backend/target/sausage-store-${VERSION}.jar
      - ${CI_PROJECT_DIR}/.m2/ 


spotbugs-sast:
  stage: test
  variables:
    COMPILE: "false"
    MAVEN_REPO_PATH: ${CI_PROJECT_DIR}/.m2/repository


sonarqube-backend-sast:
  stage: test
  image: maven:3.8-openjdk-16 # тот самый docker-образ, о котором мы все узнаем в будущем
  script:
    - cd backend
    - >
      mvn verify sonar:sonar 
      -Dversion.application=${VERSION} 
      -Dsonar.qualitygate.wait=true 
      -Dsonar.projectKey=${SONAR_PROJECT_KEY_BACK}
      -Dsonar.host.url=${SONARQUBE_URL}
      -Dsonar.login=${SONAR_LOGIN} 


sonarqube-frontend-sast:
  stage: test
  image: sonarsource/sonar-scanner-cli:latest
  script:
    - cd frontend
    - >
      sonar-scanner
      -Dsonar.qualitygate.wait=true
      -Dsonar.projectKey=${SONAR_PROJECT_KEY_FRONT}
      -Dsonar.sources=. 
      -Dsonar.host.url=${SONARQUBE_URL}
      -Dsonar.login=${SONAR_LOGIN}


# added
upload-backend-release:
  stage: release
#  only:
#    changes:
#      - backend/*
  needs:
    - build-backend-code-job
  script:
    - cd backend
    - mvn -Dmaven.repo.local=${CI_PROJECT_DIR}/.m2/repository -s settings.xml -Dversion.application=${VERSION} -DskipTests deploy


# added
upload-frontend-release:
  stage: release
#  only:
#    changes:
#    - frontend/*
  needs:
    - build-frontend-code-job
  script:
    - echo "Get artifact from job ${ARTIFACT_JOB_ID}" 
#    - cd frontend/dist
    - cd sausage-store-${VERSION}
#    - tar czvf sausage-store-${VERSION}.tar.gz frontend
    - tar czvf sausage-store-${VERSION}.tar.gz public_html
    - curl -v -u "${NEXUS_REPO_USER}:${NEXUS_REPO_PASS}" --upload-file sausage-store-${VERSION}.tar.gz ${NEXUS_REPO_URL}/sausage-store-pashkov-dmitriy-frontend/${VERSION}/sausage-store-${VERSION}.tar.gz


slack-message: # уведомляем в Slack
  stage: .post
  script:
    - echo "Send notify to Slack"
    - >
      curl -X POST -H 'Content-type: application/json' --data "{\"blocks\":[{\"type\":\"section\",\"text\":{\"type\":\"mrkdwn\",\"text\":\"Вышла новая версия сосисочной - ${VERSION}.\"}},{\"type\":\"section\",\"text\":{\"type\":\"mrkdwn\",\"text\":\"Frontend:\n*<${NEXUS_REPO_URL}/sausage-store-pashkov-dmitriy-frontend/${VERSION}/sausage-store-${VERSION}.tar.gz|Download :arrow-down:>*\"}},{\"type\":\"section\",\"text\":{\"type\":\"mrkdwn\",\"text\":\"Backend:\n*<${NEXUS_REPO_URL}/sausage-store-pashkov-dmitriy-backend/com/yandex/practicum/devops/sausage-store/${VERSION}/sausage-store-${VERSION}.jar|Download :arrow-down:>*\"}},{\"type\":\"divider\"},{\"type\":\"context\",\"elements\":[{\"type\":\"mrkdwn\",\"text\":\":eyes: <@U02Q4RKK18R>\"}]}]}" https://hooks.slack.com/services/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
  when: on_success
```

