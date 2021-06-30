-- 4.Написать скрипт, удаляющий сообщения «из будущего» (дата больше сегодняшней)

USE vk;

DELETE FROM messages
WHERE created_at > NOW()