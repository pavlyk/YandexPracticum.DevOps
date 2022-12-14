### 1. Update `pom.xml`
#### 1.1. Add dependencies:
```console
<dependencies>
    <dependency>
        <groupId>org.flywaydb</groupId>
        <artifactId>flyway-core</artifactId>
        <version>8.0.5</version>
    </dependency>
</dependencies>
```


#### 1.2. Configure flyway-maven-plugin:
```console
<build>
    <plugins>
        <plugin>
            <groupId>org.flywaydb</groupId>
            <artifactId>flyway-maven-plugin</artifactId>
            <version>8.0.5</version>
            <configuration>
                <locations>
                    <location>classpath:db/migration</location>
                </locations>
            </configuration>
        </plugin>
    </plugins>
</build> 
```


### 3. Make directory for SQL-scripts
`mkdir -p src/main/resources/db/migration`  


### 4. Write SQL-scripts
#### 4.1. Create tables:
`V01__create_tables.sql`  
```sql
create table order_product
(
    quantity integer not null,
    order_id bigint not null,
    product_id bigint not null

);

create table orders
(
    id bigint generated by default as identity,
    date_created date,
    status varchar(255)
);

create table product
(
    id bigint generated by default as identity,
    name varchar(255) not null,
    picture_url varchar(255),
    price double precision
);
```

#### 4.2. Change size of varchar columns:
`V02__update_table_product.sql`  
```sql
ALTER TABLE product ALTER COLUMN name TYPE varchar(20);
ALTER TABLE product ALTER COLUMN picture_url TYPE varchar(100);
```

#### 4.3. Create indexes:
`V03__create_indexes.sql`  
```sql
CREATE INDEX idx_order_product_id ON order_product (order_id);
CREATE INDEX idx_order_product_product_id ON order_product (product_id);

CREATE INDEX idx_product_id ON product (id);
CREATE INDEX idx_product_name ON product (name);
CREATE INDEX idx_product_price ON product (price);

CREATE INDEX idx_orders_id ON orders (id);
```

#### 4.4. Create roles and grant users:
`R__grant_access_new_users.sql`  
```sql
CREATE ROLE read_user;
CREATE ROLE write_user;
CREATE ROLE admin_user;

GRANT SELECT ON order_product TO read_user;
GRANT SELECT ON orders TO read_user;
GRANT SELECT ON product TO read_user;

GRANT SELECT, UPDATE, INSERT ON order_product TO write_user;
GRANT SELECT, UPDATE, INSERT ON orders TO write_user;
GRANT SELECT, UPDATE, INSERT ON product TO write_user;

GRANT ALL ON order_product TO admin_user;
GRANT ALL ON orders TO admin_user;
GRANT ALL ON product TO admin_user;
```



#### 5. Update application.properties
`backend/src/main/resources/application.properties`  
```bash
management.security.enabled=false
spring.datasource.driver-class-name=org.postgresql.Driver
spring.datasource.url=jdbc:postgresql://${PSQL_HOST}:${PSQL_PORT}/${PSQL_DB}
spring.datasource.username=${PSQL_USER}
spring.datasource.password=${PSQL_PASSWD}
spring.jpa.show-sql=false
#insted of docker-image
spring.flyway.enabled=false
#initial Flyway deployments on projects with an existing DB
flyway.baselineOnMigrate=true
```
