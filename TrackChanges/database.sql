/*
-- CSCI 201L TrackChanges 
-- Database 
*/
DROP DATABASE IF EXISTS TrackChanges;
CREATE DATABASE TrackChanges;
USE TrackChanges;

CREATE TABLE User (
	user_id VARCHAR(100) PRIMARY KEY,
	user_email VARCHAR(100) NOT NULL,
    user_firstname VARCHAR(100) NOT NULL,
    user_lastname VARCHAR(100) NOT NULL
);

CREATE TABLE Artiste (
	artiste_id VARCHAR(100) PRIMARY KEY,
    artiste_firstname VARCHAR(100) NOT NULL,
    artiste_lastname VARCHAR(100) NOT NULL
);
                    
CREATE TABLE Follow (
    user_id VARCHAR(100) NOT NULL,
    follower_id VARCHAR(100) NOT NULL,
    PRIMARY KEY (user_id, follower_id),
	FOREIGN KEY Follow_user_id (user_id) REFERENCES User(user_id),
    FOREIGN KEY Follow_follower_id (follower_id) REFERENCES User(user_id)
);

CREATE TABLE Post (
	post_id VARCHAR(100) PRIMARY KEY,
    post_timestamp TIMESTAMP NOT NULL,
    user_id VARCHAR(100) NOT NULL,
    post_content VARCHAR(500) NOT NULL,
	FOREIGN KEY Post_user_id (user_id) REFERENCES User(user_id)
);

CREATE TABLE PostUpvote (
	post_upvote_id VARCHAR(100) PRIMARY KEY,
    post_id VARCHAR(100) NOT NULL,
    user_id VARCHAR(100) NOT NULL,
	FOREIGN KEY PostUpvote_post_id (post_id) REFERENCES Post(post_id),
    FOREIGN KEY PostUpvote_user_id (user_id) REFERENCES User(user_id)
);

CREATE TABLE PostDownvote (
	post_downvote_id VARCHAR(100) PRIMARY KEY,
    post_id VARCHAR(100) NOT NULL,
    user_id VARCHAR(100) NOT NULL,
	FOREIGN KEY PostDownvote_post_id (post_id) REFERENCES Post(post_id),
    FOREIGN KEY PostDownvote_user_id (user_id) REFERENCES User(user_id)
);
  
CREATE TABLE Song (
	song_id VARCHAR(100) PRIMARY KEY,
    song_timestamp TIMESTAMP NOT NULL,
    artiste_id VARCHAR(100) NOT NULL,
    song_upvote_id VARCHAR(100) NOT NULL,
    song_downvote_id VARCHAR(100) NOT NULL,
	FOREIGN KEY Song_artiste_id (artiste_id) REFERENCES Artiste(artiste_id)
);

CREATE TABLE SongUpvote (
	song_upvote_id VARCHAR(100) PRIMARY KEY,
    song_id VARCHAR(100) NOT NULL,
    user_id VARCHAR(100) NOT NULL,
	FOREIGN KEY SongUpvote_song_id (song_id) REFERENCES Song(song_id),
    FOREIGN KEY SongUpvote_user_id (user_id) REFERENCES User(user_id)
);

CREATE TABLE SongDownvote (
	song_downvote_id VARCHAR(100) PRIMARY KEY,
    song_id VARCHAR(100) NOT NULL,
    user_id VARCHAR(100) NOT NULL,
	FOREIGN KEY SongDownvote_song_id (song_id) REFERENCES Song(song_id),
    FOREIGN KEY SongDownvote_user_id (user_id) REFERENCES User(user_id)
);

CREATE TABLE UserSong (
	usersong_id VARCHAR(100) PRIMARY KEY,
    song_id VARCHAR(100) NOT NULL,
    user_id VARCHAR(100) NOT NULL,
	FOREIGN KEY UserSong_song_id (song_id) REFERENCES Song(song_id),
    FOREIGN KEY UserSong_user_id (user_id) REFERENCES User(user_id)
);
