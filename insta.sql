#Instagram-like database creation script

DROP DATABASE IF EXISTS instagram;
 CREATE DATABASE instagram;
 USE instagram;

CREATE TABLE users (
	id INT PRIMARY KEY AUTO_INCREMENT,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	username VARCHAR(50) NOT NULL,
	bio VARCHAR(400),
	avatar_url VARCHAR(200),
	phone VARCHAR(25),
	email VARCHAR(50),
	password VARCHAR(50),
	status VARCHAR(15),  -- online, offline, busy e.t.c.
	CHECK(COALESCE(phone, email) IS NOT NULL)   -- must enter at least one
);

CREATE TABLE posts (
	id INT PRIMARY KEY AUTO_INCREMENT,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	url VARCHAR(200) NOT NULL,
	caption VARCHAR(240),    -- текст поста
	latitude FLOAT CHECK(latitude IS NULL OR (latitude >= -90 AND latitude <= 90)),  -- location
	longitude FLOAT CHECK(longitude IS NULL OR (longitude >= -180 AND longitude <= 180)), -- should be correct if entered
	user_id INT NOT NULL,
	FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
);

CREATE TABLE comments (
	id INT PRIMARY KEY AUTO_INCREMENT,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	body VARCHAR(240) NOT NULL,
	user_id INT NOT NULL,
	FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
	post_id INT NOT NULL,
	FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
);

CREATE TABLE post_likes (
	id INT PRIMARY KEY AUTO_INCREMENT,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	user_id INT NOT NULL,
	FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
	post_id INT,
	FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
	UNIQUE(user_id, post_id) -- only one like per post for one user 
);

CREATE TABLE comment_likes (
	id INT PRIMARY KEY AUTO_INCREMENT,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	user_id INT NOT NULL,
	FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
	comment_id INT,
	FOREIGN KEY (comment_id) REFERENCES comments(id) ON DELETE CASCADE,
	UNIQUE(user_id, comment_id) 
);

CREATE TABLE photo_tags (
	id INT PRIMARY KEY AUTO_INCREMENT,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	user_id INT NOT NULL,
	FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
	post_id INT NOT NULL,
	FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
	x INT NOT NULL,  -- where ON the pic the tag is
	y INT NOT NULL,
	UNIQUE(user_id, post_id)  -- only 1 tag of user is allowed ( can be multiple, but ONLY 1 record in DB
);							  -- ex: not to send mulptiple notifications to user, tagged in a post)

CREATE TABLE caption_tags (   -- tags in caption
	id INT PRIMARY KEY AUTO_INCREMENT,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	user_id INT NOT NULL,
	FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
	post_id INT NOT NULL,
	FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
	UNIQUE(user_id, post_id) 
);

CREATE TABLE hashtags (
	id INT PRIMARY KEY AUTO_INCREMENT,
	title VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE hashtags_posts (
	id INT PRIMARY KEY AUTO_INCREMENT,
	hashtag_id INT NOT NULL,
	FOREIGN KEY (hashtag_id) REFERENCES hashtags(id) ON DELETE CASCADE,
	post_id INT NOT NULL,
	FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
	UNIQUE(hashtag_id, post_id) -- one tag is enough FOR DB
);

CREATE TABLE followers (
	id INT PRIMARY KEY AUTO_INCREMENT,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	leader_id INT NOT NULL,
	FOREIGN KEY (leader_id) REFERENCES users(id) ON DELETE CASCADE,
	follower_id INT NOT NULL,
	FOREIGN KEY (follower_id) REFERENCES users(id) ON DELETE CASCADE,
	UNIQUE(leader_id, follower_id) -- can only subscribe once
);

CREATE TABLE messages (
    id SERIAL PRIMARY KEY,
    from_user_id INT NOT NULL,
    to_user_id INT NOT NULL,
    body TEXT,
    created_at DATETIME DEFAULT NOW(), 

    FOREIGN KEY (from_user_id) REFERENCES users(id)  ON DELETE CASCADE,
    FOREIGN KEY (to_user_id) REFERENCES users(id)  ON DELETE CASCADE
);
