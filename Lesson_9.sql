-- 6.1 В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. 
-- Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции.

START TRANSACTION;
INSERT INTO sample.users 
	SELECT * FROM shop.users 
	WHERE id = 1;
COMMIT;

-- 6.2 Создайте представление, которое выводит название name товарной позиции из таблицы products и соответствующее название каталога name из таблицы catalogs.
 
CREATE OR REPLACE VIEW prod__catalogs AS
SELECT p.name AS prod_name, c.name AS catalog_name
FROM products p 
LEFT JOIN catalogs c ON c.id = p.catalog_id;

-- 6.3 Пусть имеется таблица с календарным полем created_at. 
-- В ней размещены разряженые календарные записи за август 2018 года '2018-08-01', '2016-08-04', '2018-08-16' и 2018-08-17. 
-- Составьте запрос, который выводит полный список дат за август, выставляя в соседнем поле значение 1, если дата присутствует в исходном таблице и 0, если она отсутствует.

USE sample;
CREATE TABLE aug_dates (
	created_at DATE
);
INSERT INTO aug_dates
VALUES
	('2018-08-02'),
	('2018-08-07'),
	('2018-08-12'),
	('2018-08-16'),
	('2018-08-27');

SELECT  
	FROM_UNIXTIME(UNIX_TIMESTAMP(CONCAT('2018-08-',n)),'%Y-%m-%d') AS Date,
	(SELECT EXISTS(SELECT * FROM aug_dates WHERE created_at = Date)) AS in_list
FROM (
        SELECT (((b4.0 << 1 | b3.0) << 1 | b2.0) << 1 | b1.0) << 1 | b0.0 AS n
                FROM  (SELECT 0 UNION ALL SELECT 1) AS b0, -- Эту часть взял с stackoverflow
                      (SELECT 0 UNION ALL SELECT 1) AS b1, -- Честно говоря не очень понимаю как создается список дат
                      (SELECT 0 UNION ALL SELECT 1) AS b2,
                      (SELECT 0 UNION ALL SELECT 1) AS b3,
                      (SELECT 0 UNION ALL SELECT 1) AS b4 ) t
        WHERE n > 0 AND n <= DAY(last_day('2018-08-31'))
ORDER BY  Date

-- 6.4  Пусть имеется любая таблица с календарным полем created_at. 
-- Создайте запрос, который удаляет устаревшие записи из таблицы, оставляя только 5 самых свежих записей.

-- Воспользуемся таблицей aug_dates из прошлого задания
INSERT INTO aug_dates
VALUES
	('2018-08-01'),
	('2018-08-04'),
	('2018-08-19'),
	('2018-08-11'),
	('2018-08-23');

SET @cutoff_date = (SELECT created_at FROM aug_dates 
					ORDER BY created_at DESC
					LIMIT 1				
					OFFSET 4);
SELECT @cutoff_date;
-- Понадобилась переменная, иначе если запрос даты переместить в WHERE 65 строки, MySQL выдает ошибку
DELETE FROM aug_dates 
WHERE created_at < @cutoff_date;


-- 7.1 Создайте двух пользователей которые имеют доступ к базе данных shop. 
-- Первому пользователю shop_read должны быть доступны только запросы на чтение данных, второму пользователю shop — любые операции в пределах базы данных shop.

DROP USER IF EXISTS shop_read@localhost;
CREATE USER shop_read@localhost;
GRANT SELECT ON shop.* TO shop_read@localhost;

DROP USER IF EXISTS shop@localhost;
CREATE USER shop@localhost;
GRANT ALL ON shop.* TO shop@localhost;

-- 7.2 Пусть имеется таблица accounts содержащая три столбца id, name, password, содержащие первичный ключ, имя пользователя и его пароль. 
-- Создайте представление username таблицы accounts, предоставляющий доступ к столбца id и name. 
-- Создайте пользователя user_read, который бы не имел доступа к таблице accounts, однако, мог бы извлекать записи из представления username.

DROP TABLE IF EXISTS accounts;
CREATE TABLE accounts (
	id SERIAL PRIMARY KEY,
	name VARCHAR(50),
	password VARCHAR(50)
);

INSERT INTO accounts VALUES
	(NULL, 'Joe', '123'),
	(NULL, 'Mary', '456'),
	(NULL, 'Jim', '789');


CREATE OR REPLACE VIEW username(user_id, name) AS
	SELECT id, name
	FROM accounts;
	
DROP USER IF EXISTS user_read@localhost;
CREATE USER user_read@localhost;
GRANT SELECT ON shop.username TO user_read@localhost;


-- 8.1 -- Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток. 
--        С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать фразу "Добрый день", 
--        с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи".


DROP PROCEDURE IF EXISTS hello;
DELIMITER //
CREATE PROCEDURE hello()  
BEGIN
	CASE
    WHEN CURTIME() BETWEEN '06-00-00'  AND '11-59-59' THEN SELECT 'Доброе утро';
    WHEN CURTIME() BETWEEN '12-00-00'  AND '17-59-59' THEN SELECT 'Добрый день';
    WHEN CURTIME() BETWEEN '18-00-00'  AND '23-59-59' THEN SELECT 'Добрый вечер';
    ELSE SELECT 'Доброй ночи';
	END CASE;

END//
DELIMITER ;

CALL hello();

-- 8.2 В таблице products есть два текстовых поля: name с названием товара и description с его описанием. 
--     Допустимо присутствие обоих полей или одно из них. Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема. 
--     Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были заполнены. 
--     При попытке присвоить полям NULL-значение необходимо отменить операцию

DROP TRIGGER IF EXISTS check_products;
DELIMITER //
CREATE TRIGGER check_products BEFORE INSERT ON products
FOR EACH ROW 
BEGIN 
	IF COALESCE(NEW.name, NEW.description) IS NULL 
	THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'INSERT canceled';
	END IF;
END//
DELIMITER ;

INSERT INTO products (name, description) VALUES (NULL, NULL);
SELECT * FROM products;

-- 8.3 Напишите хранимую функцию для вычисления произвольного числа Фибоначчи. 
--     Числами Фибоначчи называется последовательность в которой число равно сумме двух предыдущих чисел. 
--     Вызов функции FIBONACCI(10) должен возвращать число 55.

DROP FUNCTION IF EXISTS fibonacci;
DELIMITER //
CREATE FUNCTION fibonacci (value INT)
RETURNS INT DETERMINISTIC
BEGIN
	DECLARE fib1, fib2 INT DEFAULT 1;
	DECLARE fib_sum, i  INT DEFAULT 0;
	IF value IN (0, 1) THEN SET fib_sum = value;
	ELSE 
		WHILE i < value - 2 DO
			SET fib_sum = fib1 + fib2;
	    	SET fib1 = fib2;
	    	SET fib2 = fib_sum;
	    	SET i = i + 1;
	    END WHILE;
	END IF;
    RETURN fib_sum;
END//

DELIMITER ;

SELECT fibonacci(10);
