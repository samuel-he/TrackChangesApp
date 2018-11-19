package trackchanges;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class Artist {

	@SerializedName("Artist_Id")
	@Expose
	private String artist_id;
	
	@SerializedName("Artist_FirstName")
	@Expose
	private String artist_firstName;
	
	@SerializedName("Artist_LastName")
	@Expose
	private String artist_lastName;
	
	public String getArtistId() {
		return artist_id;
	}
	
	public void setArtistId(String artist_id) {
		this.artist_id = artist_id;
	}
	
	public String getArtistFirstName() {
		return artist_firstName;
	}
	
	public void setUserFirstName(String artist_firstName) {
		this.artist_firstName = artist_firstName;
	}
	
	public String getArtistLastName() {
		return artist_lastName;
	}
	
	public void setArtistLastName(String artist_lastName) {
		this.artist_lastName = artist_lastName;
	}
	
}
