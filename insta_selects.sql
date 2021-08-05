
-- 1.Feed
DROP PROCEDURE IF EXISTS `sp_feed`;

DELIMITER $$

CREATE PROCEDURE `sp_feed`(user_id INT)
BEGIN
	SELECT p.id, p.url, p.caption, p.latitude, p.longitude, u.id
	FROM posts p 
	JOIN users u ON u.id = p.user_id  
	WHERE u.id IN (
		SELECT leader_id
		FROM followers 
		WHERE follower_id = user_id)
	ORDER BY p.created_at DESC;

END$$

DELIMITER ;

CALL sp_feed(2);

-- 2.Post's comments
DROP PROCEDURE IF EXISTS `sp_post_comments`;

DELIMITER $$

CREATE PROCEDURE `sp_post_comments`(post_id INT)
BEGIN
	SELECT p.created_at, p.updated_at, p.url, p.caption, p.user_id, c.body, c.user_id 
	FROM comments c 
	JOIN posts p ON p.id = c.post_id 
	WHERE p.id = post_id;
	
END$$

DELIMITER ;

CALL sp_post_comments(1);
	
-- 3.User's posts' likes for 1 day
SELECT 
	pl.user_id, -- Кто поставил лайк
	pl.created_at, -- когда
	pl.post_id -- какому посту
FROM post_likes pl 
JOIN posts p ON pl.post_id = p.id 
WHERE p.user_id = 1 AND p.created_at > NOW() - INTERVAL 1 DAY 
ORDER BY pl.created_at DESC;

-- 1. Users' profiles with followers and posts counts
CREATE OR REPLACE VIEW user_profiles AS
SELECT 
	u.id, 
	u.created_at, 
	u.username, 
	u.bio, 
	(SELECT COUNT(*)
	FROM followers f 
	WHERE f.leader_id = u.id) AS followers_count,
	(SELECT COUNT(*)
	FROM posts p 
	WHERE p.user_id = u.id) AS posts_count
FROM users u;

-- 2.Tags in picture and caption in one table
CREATE OR REPLACE VIEW user_tags AS 
SELECT *
FROM caption_tags 
UNION
SELECT id, created_at, user_id, post_id 
FROM photo_tags 
ORDER BY user_id, created_at;



-- 1.Create new post procedure 
DROP PROCEDURE IF EXISTS `sp_add_post`;

DELIMITER $$

CREATE PROCEDURE `sp_add_post`(created_at TIMESTAMP, url VARCHAR(200), caption VARCHAR(240), lat FLOAT, lng FLOAT, user_id INT, caption_tagged_user_id INT, photo_tagged_user_id INT, x INT, y INT, OUT tran_result varchar(200))
BEGIN
    DECLARE `_rollback` BOOL DEFAULT 0;
   	DECLARE code VARCHAR(100);
   	DECLARE error_string VARCHAR(100);
    DECLARE last_post_id INT;

   DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
   BEGIN
    	SET `_rollback` = 1;
	GET stacked DIAGNOSTICS CONDITION 1
          code = RETURNED_SQLSTATE, error_string = MESSAGE_TEXT;
    	SET tran_result := CONCAT('Error occured. Code: ', code, '. Text: ', error_string);
    END;
        
    START TRANSACTION;
		INSERT INTO posts (created_at, url, caption, latitude, longitude, user_id)
		    VALUES (created_at, url, caption, lat, lng, user_id);
		SET  last_post_id = last_insert_id();	
	    INSERT INTO photo_tags (created_at, user_id, post_id, x, y)
		    VALUES (created_at, photo_tagged_user_id, last_post_id, x, y); 
	    INSERT INTO caption_tags (created_at, user_id, post_id)
		    VALUES (created_at, caption_tagged_user_id, last_post_id); 		 

	    IF `_rollback` THEN
	       ROLLBACK;
	    ELSE
		set tran_result := 'ok';
	       COMMIT;
	    END IF;
END$$

DELIMITER ;

CALL sp_add_post(NOW(), 'http://qwertyhglg.com/', 'srfrrtest post', 39.1, 76.1, 7, 4, 1, 51, 59, @tran_result);

SELECT @tran_result;

-- 2.Trigger doesn't allow to message yourself

DELIMITER //

CREATE TRIGGER check_messages_to_myself BEFORE INSERT ON messages
FOR EACH ROW
BEGIN
    IF NEW.from_user_id = NEW.to_user_id THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insert Canceled. Cannot message yourself!';
    END IF;
    
END//

DELIMITER ;



