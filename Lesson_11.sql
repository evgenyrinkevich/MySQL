-- 1.Создайте таблицу logs типа Archive. 
-- Пусть при каждом создании записи в таблицах users, catalogs и products в таблицу logs помещается время и дата создания записи, 
-- название таблицы, идентификатор первичного ключа и содержимое поля name.


DROP TABLE IF EXISTS logs;
CREATE TABLE logs (
  id BIGINT,
  table_name VARCHAR(55),
  name VARCHAR(255),
  created_at DATETIME
)  ENGINE=Archive;


DROP TRIGGER IF EXISTS log_users;
DELIMITER //
CREATE TRIGGER log_users AFTER INSERT ON users
FOR EACH ROW 
BEGIN 
	INSERT INTO logs (id, table_name, name, created_at)
	VALUES (NEW.id, 'users', NEW.name, NOW());
END//

DROP TRIGGER IF EXISTS log_catalogs//
CREATE TRIGGER log_catalogs AFTER INSERT ON catalogs
FOR EACH ROW 
BEGIN 
	INSERT INTO logs (id, table_name, name, created_at)
	VALUES (NEW.id, 'catalogs', NEW.name, NOW());
END//

DROP TRIGGER IF EXISTS log_products//
CREATE TRIGGER log_products AFTER INSERT ON products
FOR EACH ROW 
BEGIN 
	INSERT INTO logs (id, table_name, name, created_at)
	VALUES (NEW.id, 'products', NEW.name, NOW());
END//

DELIMITER ;

INSERT INTO users (name, birthday_at)
VALUES ('Joe', '2000-01-02');

INSERT INTO catalogs (name)
VALUES ('SSD');

INSERT INTO products (name, description)
VALUES ('M1', 'new Apple processor');

SELECT * FROM logs;

-- 2. Создайте SQL-запрос, который помещает в таблицу users миллион записей.

DROP PROCEDURE IF EXISTS million;

DELIMITER $$
CREATE PROCEDURE million()
BEGIN
	DECLARE x  BIGINT;
        
	SET x = 0;
        
	loop_label:  LOOP
		IF  x > 1000000 THEN 
			LEAVE  loop_label;
		END  IF;
            
		SET  x = x + 1;
		INSERT INTO users (name, birthday_at)
		VALUES (CONCAT('user', x), '1980-01-01' + INTERVAL x DAY);
	END LOOP;
END$$

DELIMITER ;

-- CALL million();
-- SELECT * FROM users
-- ORDER BY created_at DESC
-- LIMIT 10;
