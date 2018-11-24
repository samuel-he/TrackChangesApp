package trackchanges;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class Post {

	@SerializedName("Post_Id")
	@Expose
	private String post_id;
	
	@SerializedName("Post_Type")
	@Expose
	private String post_type;
	
	@SerializedName("Post_Timestamp")
	@Expose
	private String post_timestamp;
	
	@SerializedName("Post_User_Id")
	@Expose
	private String post_user_id;
	
	@SerializedName("Post_Message")
	@Expose
	private String post_message;
	
	@SerializedName("Post_Song_Id")
	@Expose
	private String post_song_id;
	
	@SerializedName("Post_Album_Id")
	@Expose
	private String post_album_id;
	
	public String getPostId() {
		return post_id;
	}
	
	public void setPostId(String post_id) {
		this.post_id = post_id;
	}
	
	public String getPostType() {
		return post_type;
	}
	
	public void setPostType(String post_type) {
		this.post_type = post_type;
	}
	
	public String getPostTimeStamp() {
		return post_timestamp;
	}
	
	public void setPostTimeStamp(String post_timeStamp) {
		this.post_timestamp = post_timeStamp;
	}
	
	public String getPostUserId() {
		return post_user_id;
	}
	
	public void setPostUserId(String post_userId) {
		this.post_user_id = post_userId;
	}
	
	public String getPostMessage() {
		return post_message;
	}
	
	public void setPostMessage(String post_message) {
		this.post_message = post_message;
	}
	
	public String getPostSongId() {
		return post_song_id;
	}
	
	public void setPostSongId(String post_songId) {
		this.post_song_id = post_songId;
	}
	
	public String getPostAlbumId() {
		return post_album_id;
	}
	
	public void setPostAlbumId(String post_albumId) {
		this.post_album_id = post_albumId;
	}
	
}
