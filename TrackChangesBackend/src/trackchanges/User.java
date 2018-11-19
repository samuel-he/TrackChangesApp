package trackchanges;

import org.joda.time.DateTime;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class User {

	@SerializedName("User_Id")
	@Expose
	private String user_id;
	
	@SerializedName("User_DisplayName")
	@Expose
	private String user_displayName;
	
	@SerializedName("User_ImageUrl")
	@Expose
	private String user_imageUrl;
	
	@SerializedName("User_LoginTimeStamp")
	@Expose
	private String user_logintimestamp;
	
	@SerializedName("User_IsActive")
	@Expose
	private boolean user_isActive;
	
	public String getUserId() {
		return user_id;
	}
	
	public void setUserId(String user_id) {
		this.user_id = user_id;
	}
	
	public String getUserDisplayName() {
		return user_displayName;
	}
	
	public void setUserDisplayName(String user_displayName) {
		this.user_displayName = user_displayName;
	}
	
	public String getUserImageUrl() {
		return user_imageUrl;
	}
	
	public void setUserImageUrl(String user_imageUrl) {
		this.user_imageUrl = user_imageUrl;
	}
	
	public String getUserLoginTimeStamp() {
		return user_logintimestamp;
	}
	
	public void setUserLoginTimeStamp(String user_logintimestamp) {
		this.user_logintimestamp = user_logintimestamp;
	}
	
	public boolean getUserIsActive() {
		return user_isActive;
	}
	
	public void setUserIsActive(boolean user_isActive) {
		this.user_isActive = user_isActive;
	}
}