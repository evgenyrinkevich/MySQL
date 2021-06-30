/*3.Написать скрипт, отмечающий несовершеннолетних пользователей как неактивных (поле is_active = false).
Предварительно добавить такое поле в таблицу profiles со значением по умолчанию = true (или 1) */ 

USE vk;

ALTER TABLE profiles ADD is_active BOOL DEFAULT true;

UPDATE profiles 
SET is_active = false
WHERE TIMESTAMPDIFF(YEAR, birthday, NOW()) < 18
