/* 2.Написать скрипт, возвращающий список имен (только firstname) пользователей без повторений в алфавитном порядке*/

USE vk;

SELECT DISTINCT firstname
FROM users
ORDER BY firstname