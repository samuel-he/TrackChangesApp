package trackchanges;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class Album {

	@SerializedName("Album_Id")
	@Expose
	private String album_id;
	
//	@SerializedName("Artist_Id")
//	@Expose
//	private String artist_id;
	
	public String getAlbumId() {
		return album_id;
	}
	
	public void setAlbumId(String album_id) {
		this.album_id = album_id;
	}
	
//	public String getArtistId() {
//		return artist_id;
//	}
//	
//	public void setArtistId(String artist_id) {
//		this.artist_id = artist_id;
//	}
	
}
