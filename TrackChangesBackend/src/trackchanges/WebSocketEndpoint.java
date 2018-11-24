package trackchanges;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Logger;

import javax.websocket.OnClose;
import javax.websocket.OnError;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;
import javax.xml.bind.DatatypeConverter;

import org.apache.tomcat.util.codec.binary.Base64;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonElement;
import com.google.gson.JsonParser;

@ServerEndpoint (value="/endpoint")
public class WebSocketEndpoint {

	private static Map<String, WorkerThread> sessions = Collections.synchronizedMap(new HashMap<String, WorkerThread>());
	private static Map<String, String> clientSessionId = Collections.synchronizedMap(new HashMap<String, String>());
	private static final Logger log = Logger.getLogger("TrackChanges");
	private static final JSONParser parser = new JSONParser(); 

	@OnOpen
	public void onOpen(Session session) {
		sessions.put(session.getId(), new WorkerThread(session));
		System.out.println("onOpen:: " + session.getId());        
		log.info("Connection openend by id: " + session.getId());
	}

	@OnClose
	public void close(Session session) {
		synchronized(sessions) {
			sessions.remove(session.getId());
			synchronized(clientSessionId) {
				for(String sessionId : clientSessionId.values()) {
					if(sessionId.equals(session.getId())) {
						clientSessionId.remove(session.getId());
					}
				}
			}
		}
		System.out.println("onClose:: " + session.getId());	
		log.info("Connection closed by id: " + session.getId());
	}

	@OnMessage
	public void onMessage (byte[] b, Session session) {

		if(sessions.get(session.getId()) != null) {
			boolean parseSuccess = false;
			String base64Encoded = Base64.encodeBase64String(b);
			byte[] base64Decoded = DatatypeConverter.parseBase64Binary(base64Encoded);
			String parsedJson = new String(base64Decoded);
			try {
				JSONObject json = (JSONObject) parser.parse(parsedJson);
				String request = (String) json.get("request");
				System.out.println("");
				for(int i = 0; i < 50; i++) {
					System.out.print("-");
				}
				System.out.println("");
				System.out.println("Request: " + request);

				// Sends request and body to handler to call Application.java functions
				parseSuccess = sessions.get(session.getId()).handleRequest(request, json);

			} catch (ParseException pe) {
				System.out.println("pe: " + pe.getMessage());
			} finally {
				try {
					if(parseSuccess) {
						session.getBasicRemote().sendText("success");
					} else {
						session.getBasicRemote().sendText("failure");
					}
				} catch (IOException ioe) {
					System.out.println("ioe: " + ioe.getMessage());
				}

			}
		}

	}

	@OnError
	public void onError(Throwable e) {
		System.out.println("onError::" + e.getMessage());

	}

	class WorkerThread extends Thread {

		private Session clientSession;
		private String user_id = null;

		public String getUserId() {
			return user_id;
		}

		public WorkerThread(Session clientSession) {
			this.clientSession = clientSession;
			this.start();
		}

		/*
		 * Handles the request received from iOS client
		 */
		@SuppressWarnings("unchecked")
		public boolean handleRequest(String request, JSONObject json) {
			
			Gson gson = new GsonBuilder().setPrettyPrinting().create();
			JsonParser jp = new JsonParser();
			
			Application app = new Application();
			boolean handleSuccess = false;
			if(request.equals("add_user")) {
				
				if(clientSessionId.get((String)json.get("user_id")) == null) {
					this.user_id = (String)json.get("user_id");
					synchronized(clientSessionId) {
						clientSessionId.put(this.user_id, this.clientSession.getId());
					}
				}

				User newUser = new User();
				newUser.setUserId((String)json.get("user_id"));
				newUser.setUserDisplayName((String)json.get("user_displayname"));
				newUser.setUserImageUrl((String)json.get("user_imageurl"));
				newUser.setUserLoginTimeStamp((String)json.get("user_logintimestamp"));
				handleSuccess = app.addUser(newUser);

			} else if(request.equals("is_following")) {
				
				String user_id = (String)json.get("user_id");
				String follower_id = (String)json.get("follower_id");
				
				// debugging
				System.out.println("user_id: " + user_id);
				System.out.println("follower_id: " + follower_id);
				
				handleSuccess = app.isFollowing(user_id, follower_id);
				JSONObject response = new JSONObject();
				
				// check this jeff
				response.put("response", "is_following");
				response.put("is_following", handleSuccess);
				
				// Debug output
				JsonElement je = jp.parse(response.toJSONString());
				String prettyJsonString = gson.toJson(je);
				System.out.println(prettyJsonString);
				
				sendToSession(this.clientSession, response.toString().getBytes());

			}else if(request.equals("follow")) {
				
				String user_id = (String)json.get("user_id");
				String follower_id = (String)json.get("follower_id");
				System.out.println("user_id: " + user_id);
				System.out.println("follower_id: " + follower_id);
				handleSuccess = app.follow(user_id, follower_id);

			} else if(request.equals("unfollow")) {
				
				String user_id = (String)json.get("user_id");
				String follower_id = (String)json.get("follower_id");
				System.out.println("user_id: " + user_id);
				System.out.println("follower_id: " + follower_id);
				handleSuccess = app.unfollow(user_id, follower_id);

			} else if(request.equals("get_followers")) {
				
				String user_id = (String)json.get("user_id");
				ArrayList<User> followers = app.getFollowers(user_id);
				System.out.println("List of Followers for " + user_id + ": ");
				if(followers != null) {
					for(User follower : followers) {
						System.out.println("\t" + follower.getUserId());
					}
				} else {
					System.out.println("\t None");
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
				
				// Debug output
				JsonElement je = jp.parse(response.toJSONString());
				String prettyJsonString = gson.toJson(je);
				System.out.println(prettyJsonString);
				
				sendToSession(this.clientSession, response.toString().getBytes());
				handleSuccess = true;

			} else if(request.equals("get_followings")) {

				String user_id = (String)json.get("user_id");
				ArrayList<User> followings = app.getFollowings(user_id);
				System.out.println("List of Followings for " + user_id + ": ");
				if(followings != null) {
					for(User following : followings) {
						System.out.println("\t" + following.getUserId());
					}
				} else {
					System.out.println("\t None");
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
				
				// Debug output
				JsonElement je = jp.parse(response.toJSONString());
				String prettyJsonString = gson.toJson(je);
				System.out.println(prettyJsonString);
				
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
				
				String post_user_id = (String)json.get("post_user_id");
				String post_type = (String)json.get("post_type");
				String post_message = (String)json.get("post_message");
				String post_timestamp = (String)json.get("post_timestamp");
				String post_song_id = (String)json.get("post_song_id");
				String post_album_id = (String)json.get("post_album_id");
				
				// Debugging output
				System.out.println("Add Post Parameters Received: ");
				System.out.println("\t" + post_user_id);
				System.out.println("\t" + post_type);
				System.out.println("\t" + post_message);
				System.out.println("\t" + post_timestamp);
				System.out.println("\t" + post_song_id);
				System.out.println("\t" + post_album_id);
				
				Post newPost = new Post();
				newPost.setPostUserId(post_user_id);
				newPost.setPostType(post_type);
				newPost.setPostMessage(post_message);
				newPost.setPostTimeStamp(post_timestamp);
				newPost.setPostSongId(post_song_id);
				newPost.setPostAlbumId(post_album_id);
				int post_id = app.addPost(newPost);
				
				Post post = app.getPost(post_id);
				JSONObject response = new JSONObject();
				response.put("response", "post_added");
				response.put("post_id", post.getPostId());
				response.put("post_type", post.getPostType());
				response.put("post_timestamp", post.getPostTimeStamp());
				response.put("post_user_id", post.getPostUserId());
				response.put("post_message", post.getPostMessage());
				response.put("post_song_id", post.getPostSongId());
				response.put("post_album_id", post.getPostAlbumId());
				
				// Debug output
				JsonElement je = jp.parse(response.toJSONString());
				String prettyJsonString = gson.toJson(je);
				System.out.println(prettyJsonString);
				
				sendToSession(this.clientSession, response.toString().getBytes());
				
				// Notify all of the user's followers that a new post has been added
				updateFeeds(app.getFollowers((String)json.get("post_user_id")), response.toString().getBytes());
				
				handleSuccess = true;

			} else if(request.equals("get_posts")) {

				ArrayList<Post> posts = new ArrayList<Post>();
				String user_id = (String)json.get("user_id");
				posts = app.getPosts(user_id);
				JSONArray jsonFeedArray = new JSONArray();
				for(Post post : posts) {
					JSONObject jsonPost = new JSONObject();
					jsonPost.put("post_id", post.getPostId());
					jsonPost.put("post_type", post.getPostType());
					jsonPost.put("post_timestamp", post.getPostTimeStamp());
					jsonPost.put("post_user_id", post.getPostUserId());
					jsonPost.put("post_message", post.getPostMessage());
					jsonPost.put("post_song_id", post.getPostSongId());
					jsonPost.put("post_album_id", post.getPostAlbumId());
					jsonFeedArray.add(jsonPost);
				}

				JSONObject response = new JSONObject();
				response.put("response", "feed");
				response.put("feed", jsonFeedArray);
				
				// Debug output
				JsonElement je = jp.parse(response.toJSONString());
				String prettyJsonString = gson.toJson(je);
				System.out.println(prettyJsonString);
				
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
					jsonPost.put("post_type", post.getPostType());
					jsonPost.put("post_timestamp", post.getPostTimeStamp());
					jsonPost.put("post_user_id", post.getPostUserId());
					jsonPost.put("post_message", post.getPostMessage());
					jsonPost.put("post_song_id", post.getPostSongId());
					jsonPost.put("post_album_id", post.getPostAlbumId());
					jsonFeedArray.add(jsonPost);
				}

				JSONObject response = new JSONObject();
				response.put("response", "feed");
				response.put("feed", jsonFeedArray);
				
				// Debug output
				JsonElement je = jp.parse(response.toJSONString());
				String prettyJsonString = gson.toJson(je);
				System.out.println(prettyJsonString);
				
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
				response.put("post_type", post.getPostType());
				response.put("post_timestamp", post.getPostTimeStamp());
				response.put("post_user_id", post.getPostUserId());
				response.put("post_message", post.getPostMessage());
				response.put("post_song_id", post.getPostSongId());
				response.put("post_album_id", post.getPostAlbumId());
				
				// Debug output
				JsonElement je = jp.parse(response.toJSONString());
				String prettyJsonString = gson.toJson(je);
				System.out.println(prettyJsonString);
				
				updateFeeds(app.getFollowers(user_id), response.toString().getBytes());

			} else if(request.equals("delete_post")) {

				String post_id = (String)json.get("post_id");
				handleSuccess = app.deletePost(post_id);

			}else if(request.equals("search_users")) {

				String search_input = (String)json.get("search_term");
				System.out.println("Search Term: " + search_input);
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
				
				// Debug output
				JsonElement je = jp.parse(response.toJSONString());
				String prettyJsonString = gson.toJson(je);
				System.out.println(prettyJsonString);
				
				sendToSession(this.clientSession, response.toString().getBytes());
				handleSuccess = true;

			}
			
			return handleSuccess;
		}

		/*
		 * Function that sends data in byte array to the specified Client Session
		 */
		private void sendToSession(Session session, byte[] data) {

			try {
				ByteBuffer tobeSent = ByteBuffer.wrap(data);
				this.clientSession.getBasicRemote().sendBinary(tobeSent);

			} catch(IOException ioe) {
				System.out.println("ioe: " + ioe.getMessage());
			}

		}

		private void updateFeeds(ArrayList<User> followers, byte[] data) {

			synchronized(sessions) {

				for(User follower : followers) {

					if(clientSessionId.get(follower.getUserId()) != null) {

						sendToSession(sessions.get(clientSessionId.get(follower.getUserId())).clientSession, data);

					} else {
						
						System.out.println(follower.getUserDisplayName() + " is not online.");
						
					}

				}

			}

		}

		/*
		 * Overrides run() method because we inherit from Thread class
		 */
		@SuppressWarnings("unchecked")
		public void run() {

			JSONObject response = new JSONObject();
			response.put("response", "connection");
			response.put("status", "iOS client thread " + this.clientSession.getId() + " has started!");
			sendToSession(this.clientSession, response.toString().getBytes());

		}

	}


}