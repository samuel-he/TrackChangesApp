/*
-- CSCI 201L TrackChanges 
-- Database 
*/
DROP DATABASE IF EXISTS CSCI201;
CREATE DATABASE CSCI201;
USE CSCI201;

/* --------------------------- Users Data --------------------------- */
/* Stores user's personal details */
CREATE TABLE User (
	user_id VARCHAR(100) PRIMARY KEY,
	user_displayname VARCHAR(100) NOT NULL,
	user_imageurl VARCHAR(500) NOT NULL,
    user_logintimestamp VARCHAR(100) NOT NULL
);

/* Stores followers / following relationship */
CREATE TABLE Follow (
	user_id VARCHAR(100) NOT NULL,
	follower_id VARCHAR(100) NOT NULL,
	PRIMARY KEY (user_id, follower_id),
	FOREIGN KEY (user_id) REFERENCES User(user_id),
	FOREIGN KEY (follower_id) REFERENCES User(user_id)
);

/* --------------------------- Album and Song Data --------------------------- */

/* Stores the album id for identification */
CREATE TABLE Album (
	album_id VARCHAR(100) PRIMARY KEY
);

/* Stores the song id to uniquely identify the song */
CREATE TABLE Song (
	song_id VARCHAR(100) PRIMARY KEY
);

/* Tracks which users like which songs */
CREATE TABLE SongLike (
	song_id VARCHAR(100) NOT NULL,
	user_id VARCHAR(100) NOT NULL,
	PRIMARY KEY (song_id, user_id),
	FOREIGN KEY (song_id) REFERENCES Song(song_id),
	FOREIGN KEY (user_id) REFERENCES User(user_id)
);

/* --------------------------- Post Data --------------------------- */
/* Stores the content of each post and creator of post */
CREATE TABLE Post (
	post_id INT(11) AUTO_INCREMENT PRIMARY KEY,
    post_type VARCHAR(50) NOT NULL,
   	post_timestamp VARCHAR(100) NOT NULL,
	user_id VARCHAR(100) NOT NULL,
	post_message VARCHAR(500) NOT NULL,
	song_id VARCHAR(100) NOT NULL,
	album_id VARCHAR(500) NOT NULL,
	FOREIGN KEY (user_id) REFERENCES User(user_id)
);

/* Stores the number of shares of each post */
CREATE TABLE PostShare (
	post_id INT(11) NOT NULL,
	user_id VARCHAR(100) NOT NULL,
	PRIMARY KEY (post_id, user_id),
	FOREIGN KEY (post_id) REFERENCES Post(post_id),
	FOREIGN KEY (user_id) REFERENCES User(user_id)
);

/* Stores the number of likes of each post */
CREATE TABLE PostLike (
	post_id INT(11) NOT NULL,
	user_id VARCHAR(100) NOT NULL,
	PRIMARY KEY (post_id, user_id),
	FOREIGN KEY (post_id) REFERENCES Post(post_id),
	FOREIGN KEY (user_id) REFERENCES User(user_id)
);