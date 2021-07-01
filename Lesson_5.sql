-- 1.Пусть в таблице users поля created_at и updated_at оказались незаполненными. Заполните их текущими датой и временем.

USE shop;

UPDATE users
SET created_at = NOW(), updated_at = NOW();


/* 2.Таблица users была неудачно спроектирована.
     Записи created_at и updated_at были заданы типом VARCHAR и в них долгое время помещались значения в формате "20.10.2017 8:10".
     Необходимо преобразовать поля к типу DATETIME, сохранив введеные ранее значения.*/

ALTER TABLE users 
MODIFY COLUMN created_at DATETIME;

ALTER TABLE users 
MODIFY COLUMN updated_at DATETIME;
-- попробовал менять типы, данные не пропадают

/* 3.В таблице складских запасов storehouses_products в поле value могут встречаться самые разные цифры: 
     0, если товар закончился и выше нуля, если на складе имеются запасы. 
     Необходимо отсортировать записи таким образом, чтобы они выводились в порядке увеличения значения value. 
     Однако, нулевые запасы должны выводиться в конце, после всех записей. */

INSERT INTO storehouses_products (value)
VALUES
	(0), (100), (1078), (56), (0), (12), (1400), (34), (33), (0), (1009), (777), (876), (54), (90);
-- наверно предполагалось другое решение, но это тоже работает	

(SELECT *
FROM storehouses_products 
WHERE value > 0
ORDER BY value LIMIT 18446744073709551615) -- здесь без LIMIT не сортирует
UNION 
SELECT *
FROM storehouses_products 
WHERE value = 0;

/* 4.Из таблицы users необходимо извлечь пользователей, родившихся в августе и мае.
    Месяцы заданы в виде списка английских названий ('may', 'august') */

-- если используем базу из архива source03.zip, то там birthday_at в виде 'year-month-day', поэтому решил вот так:

SELECT *
FROM users
WHERE birthday_at RLIKE '^.{5}(05|08)';

/* 5.Из таблицы catalogs извлекаются записи при помощи запроса.
     SELECT * FROM catalogs WHERE id IN (5, 1, 2); Отсортируйте записи в порядке, заданном в списке IN. */

SELECT * 
FROM catalogs 
WHERE id IN (5, 1, 2)
ORDER BY FIELD(id, 5, 1, 2)  -- stackoverflow помог)

  
/* 1.Подсчитайте средний возраст пользователей в таблице users */

SELECT AVG(TIMESTAMPDIFF(YEAR, birthday_at, NOW())) AS average_age
FROM users 

/* 2.Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели. 
     Следует учесть, что необходимы дни недели текущего года, а не года рождения.*/

-- опять наверно решение не такое, как предполагалось
SELECT 
	COUNT(*), 
	DAYOFWEEK(STR_TO_DATE(CONCAT(SUBSTRING(birthday_at, 6), '-', YEAR(NOW())), '%m-%d-%Y')) AS day_of_week
	/* Отделил день и месяц рождения, соединил их с текущим годом, перевел строку в формат даты и вызвал функцию DAYOFWEEK
	 */
FROM users 
GROUP BY day_of_week
ORDER BY day_of_week;


/* 3.Подсчитайте произведение чисел в столбце таблицы
*/

SELECT 
	ROUND(EXP(SUM(LOG(id))),1)  -- опять stackoverflow
FROM catalogs
WHERE id != 0






