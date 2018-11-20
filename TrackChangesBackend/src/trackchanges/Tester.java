package trackchanges;

import java.util.ArrayList;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

public class Tester {

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		Application app = new Application();
		// This JSON object will act as the JSON recieved from the iOS client. 
		JSONObject test = new JSONObject();
		
		//Adding Users
		test.put("request", "add_user");
		test.put("user_id", "1");
		test.put("user_displayname", "Jeff Chen");
		test.put("user_image_url", "test");
		test.put("user_logintimestamp", "test");
		if(handleRequest((String) test.get("request"), test));
		{
			System.out.println("Successfully added " + test.get("user_displayname"));
			test.clear();
		}
		test.put("request", "add_user");
		test.put("user_id", "2");
		test.put("user_displayname", "PJ Hernandez");
		test.put("user_image_url", "test");
		test.put("user_logintimestamp", "test");
		if(handleRequest((String) test.get("request"), test));
		{
			System.out.println("Successfully added " + test.get("user_displayname"));
			test.clear();
		}
		
		test.put("request", "add_user");
		test.put("user_id", "3");
		test.put("user_displayname", "Pavly Habashy");
		test.put("user_image_url", "test");
		test.put("user_logintimestamp", "test");
		if(handleRequest((String) test.get("request"), test));
		{
			System.out.println("Successfully added " + test.get("user_displayname"));
			test.clear();
		}
		
		
		
		
	}
	
	public static boolean handleRequest(String request, JSONObject json) {
		Application app = new Application();
		boolean handleSuccess = false;
		if(request.equals("add_user")) {
			
			User newUser = new User();
			newUser.setUserId((String)json.get("user_id"));
			newUser.setUserDisplayName((String)json.get("user_displayname"));
			newUser.setUserImageUrl((String)json.get("user_imageurl"));
			newUser.setUserLoginTimeStamp((String)json.get("user_logintimestamp"));
			handleSuccess = app.addUser(newUser);

		} else if(request.equals("follow")) {

			String user_id = (String)json.get("user_id");
			String follower_id = (String)json.get("follower_id");
			handleSuccess = app.follow(user_id, follower_id);

		} else if(request.equals("unfollow")) {

			String user_id = (String)json.get("user_id");
			String follower_id = (String)json.get("follower_id");
			handleSuccess = app.unfollow(user_id, follower_id);

		} else if(request.equals("get_followers")) {
			
			System.out.println((String)json.get("user_id"));
			String user_id = (String)json.get("user_id");
			ArrayList<User> followers = app.getFollowers(user_id);
			for(User follower : followers) {
				System.out.println(follower.getUserId());
			}
			JSONArray jsonFollowersArray = new JSONArray();
			for(User follower : followers) {
				JSONObject jsonFollower = new JSONObject();
				jsonFollower.put("user_id", follower.getUserId());
				jsonFollower.put("user_displayname", follower.getUserDisplayName());
				jsonFollower.put("user_imageurl", follower.getUserImageUrl());
				jsonFollower.put("user_logintimestamp", follower.getUserLoginTimeStamp());
				jsonFollowersArray.add(jsonFollower);
			}
			JSONObject response = new JSONObject();
			response.put("response", "followers");
			response.put("followers", jsonFollowersArray);
			sendToSession(this.clientSession, response.toString().getBytes());
			handleSuccess = true;

		} else if(request.equals("get_followings")) {

			String user_id = (String)json.get("user_id");
			ArrayList<User> followings = app.getFollowings(user_id);
			for(User following : followings) {
				System.out.println(following.getUserId());
			}
			JSONArray jsonFollowingsArray = new JSONArray();
			for(User following : followings) {
				JSONObject jsonFollowing = new JSONObject();
				jsonFollowing.put("user_id", following.getUserId());
				jsonFollowing.put("user_displayname", following.getUserDisplayName());
				jsonFollowing.put("user_imageurl", following.getUserImageUrl());
				jsonFollowing.put("user_logintimestamp", following.getUserLoginTimeStamp());
				jsonFollowingsArray.add(jsonFollowing);
			}
			JSONObject response = new JSONObject();
			response.put("response", "followings");
			response.put("followings", jsonFollowingsArray);
			sendToSession(this.clientSession, response.toString().getBytes());
			handleSuccess = true;

		} else if(request.equals("add_album")) {

			String album_id = (String)json.get("album_id");
			handleSuccess = app.addAlbum(album_id);

		} else if(request.equals("delete_album")) {

			String album_id = (String)json.get("album_id");
			handleSuccess = app.deleteAlbum(album_id);

		} else if(request.equals("add_song")) {

			String song_id = (String)json.get("song_id");
			handleSuccess = app.addSong(song_id);

		} else if(request.equals("delete_song")) {

			String song_id = (String)json.get("song_id");
			handleSuccess = app.deleteSong(song_id);

		} else if(request.equals("like_song")) {

			String song_id = (String)json.get("song_id");
			String user_id = (String)json.get("user_id");
			handleSuccess = app.likeSong(song_id, user_id);

		} else if(request.equals("unlike_song")) {

			String song_id = (String)json.get("song_id");
			String user_id = (String)json.get("user_id");
			handleSuccess = app.unlikeSong(song_id, user_id);

		} else if(request.equals("add_post")) {

			Post newPost = new Post();
			newPost.setPostTimeStamp((String)json.get("post_timestamp"));
			newPost.setPostUserId((String)json.get("post_user_id"));
			System.out.println("1");
			System.out.println((String)json.get("post_user_id"));
			System.out.println("2");
			newPost.setPostMessage((String)json.get("post_message"));
			newPost.setPostSongId((String)json.get("post_song_id"));
			newPost.setPostAlbumId((String)json.get("post_album_id"));
			int post_id = app.addPost(newPost);
			if(handleSuccess) {
				Post post = app.getPost(post_id);
				JSONObject response = new JSONObject();
				response.put("response", "post_added");
				response.put("post_id", post.getPostId());
				response.put("post_timestamp", post.getPostTimeStamp());
				response.put("user_id", post.getPostUserId());
				response.put("post_message", post.getPostMessage());
				response.put("song_id", post.getPostSongId());
				response.put("album_id", post.getPostAlbumId());
				sendToSession(this.clientSession, response.toString().getBytes());
			}
			handleSuccess = true;

		} else if(request.equals("get_posts")) {

			ArrayList<Post> posts = new ArrayList<Post>();
			String user_id = (String)json.get("user_id");
			posts = app.getPosts(user_id);
			JSONArray jsonFeedArray = new JSONArray();
			for(Post post : posts) {
				JSONObject jsonPost = new JSONObject();
				jsonPost.put("post_id", post.getPostId());
				jsonPost.put("post_timestamp", post.getPostTimeStamp());
				jsonPost.put("user_id", post.getPostUserId());
				jsonPost.put("post_message", post.getPostMessage());
				jsonPost.put("song_id", post.getPostSongId());
				jsonPost.put("album_id", post.getPostAlbumId());
				jsonFeedArray.add(jsonPost);
			}

			JSONObject response = new JSONObject();
			response.put("response", "feed");
			response.put("feed", jsonFeedArray);
			sendToSession(this.clientSession, response.toString().getBytes());
			handleSuccess = true;

		} else if(request.equals("get_feed")) {

			ArrayList<Post> posts = new ArrayList<Post>();
			String user_id = (String)json.get("user_id");
			posts = app.getFeed(user_id);
			JSONArray jsonFeedArray = new JSONArray();
			for(Post post : posts) {
				JSONObject jsonPost = new JSONObject();
				jsonPost.put("post_id", post.getPostId());
				jsonPost.put("post_timestamp", post.getPostTimeStamp());
				jsonPost.put("user_id", post.getPostUserId());
				jsonPost.put("post_message", post.getPostMessage());
				jsonPost.put("song_id", post.getPostSongId());
				jsonPost.put("album_id", post.getPostAlbumId());
				jsonFeedArray.add(jsonPost);
			}

			JSONObject response = new JSONObject();
			response.put("response", "feed");
			response.put("feed", jsonFeedArray);
			sendToSession(this.clientSession, response.toString().getBytes());
			handleSuccess = true;

		} else if(request.equals("like_post")) {

			String user_id = (String)json.get("user_id");
			String post_id = (String)json.get("post_id");
			handleSuccess = app.likePost(post_id, user_id);

		} else if(request.equals("unlike_post")) {

			String user_id = (String)json.get("user_id");
			String post_id = (String)json.get("post_id");
			handleSuccess = app.unlikePost(post_id, user_id);

		} else if(request.equals("share_post")) {

			String user_id = (String)json.get("user_id");
			int post_id = (int)json.get("post_id");
			String timestamp = (String)json.get("timestamp");

			handleSuccess = app.sharePost(post_id, user_id, timestamp);
			Post post = app.getPost(post_id);
			JSONObject response = new JSONObject();
			response.put("response", "post_added");
			response.put("post_id", post.getPostId());
			response.put("post_timestamp", post.getPostTimeStamp());
			response.put("user_id", post.getPostUserId());
			response.put("post_message", post.getPostMessage());
			response.put("song_id", post.getPostSongId());
			response.put("album_id", post.getPostAlbumId());
			updateFeeds(app.getFollowers(user_id), response.toString().getBytes());

		} else if(request.equals("delete_post")) {

			String post_id = (String)json.get("post_id");
			handleSuccess = app.deletePost(post_id);

		}else if(request.equals("search_users")) {

			String search_input = (String)json.get("search_term");
			ArrayList<User> searchResults = app.search(search_input);
			JSONArray jsonSearchResults = new JSONArray();
			for(User user : searchResults) {
				JSONObject userObject = new JSONObject();
				userObject.put("user_id", user.getUserId());
				userObject.put("user_displayname", user.getUserDisplayName());
				userObject.put("user_imageurl", user.getUserImageUrl());
				userObject.put("user_logintimestamp", user.getUserLoginTimeStamp());
				jsonSearchResults.add(userObject);
			}
			JSONObject response = new JSONObject();
			response.put("response", "search_results");
			response.put("search_results", jsonSearchResults);
			sendToSession(this.clientSession, response.toString().getBytes());
			handleSuccess = true;

		}
		
		return handleSuccess;
	}

}