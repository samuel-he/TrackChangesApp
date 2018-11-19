package trackchanges;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class Song {

	@SerializedName("Song_Id")
	@Expose
	private String song_id;
	
//	@SerializedName("Artist_Id")
//	@Expose
//	private String artist_id;
	
	public String getSongId() {
		return song_id;
	}
	
	public void setSongId(String song_id) {
		this.song_id = song_id;
	}
	
//	public String getArtistId() {
//		return artist_id;
//	}
//	
//	public void setArtistId(String artist_id) {
//		this.artist_id = artist_id;
//	}
	
}
