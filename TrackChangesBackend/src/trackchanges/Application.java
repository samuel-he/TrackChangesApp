package trackchanges;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashSet;

import org.joda.time.DateTime;

public class Application {

	private static final long serialVersionUID = 1L;

	// Variables:
	/*
	 * This contains the function will store the global url we will 
	 * use to connect to the SQL database that is storing all the data 
	 * necessary for the application, for example:  
	 * “jdbc:mysql://localhost:3306/CalendarApp?user=root&password=&useSSL=false”;
	 */
	private static final String DATABASE_CONNECTION_URL = "jdbc:mysql://localhost:3306/CSCI201?user=root&password=peejay1997&useSSL=false";
	private static final String SQL_DRIVER_CLASS = "com.mysql.cj.jdbc.Driver";

	// search
	// check in user_id and user_displayname columns 
	// see if variables in these columns contain the search_input
	public ArrayList<User> search(String search_input) {
		// "SELECT f.follower_id FROM Follow f WHERE f.user_id = '" + user_id + "';"
		// "SELECT * from Follow WHERE follower_id=" + user_id

		/*
		 * if(!userName.toLowerCase().contains(list.get(i).toLowerCase())) {
		    			  continue;
		   }
		 */
		Connection conn = null;
		Statement st = null;
		ResultSet rs = null;
		PreparedStatement ps = null;

		HashSet<String> duplicates = new HashSet<String>();
		ArrayList<User> ret = new ArrayList<User>();

		try {
			Class.forName(SQL_DRIVER_CLASS);
			conn = DriverManager.getConnection(DATABASE_CONNECTION_URL);
			ps = conn.prepareStatement(
					"SELECT * from User");
			rs = ps.executeQuery();
			while(rs.next()) {

				String tempUserId = rs.getString("user_id");
				if(!tempUserId.toLowerCase().contains(search_input.toLowerCase())) {
					continue;
				}

				duplicates.add(tempUserId.toLowerCase());
				User newUser = new User();
				newUser.setUserId(rs.getString("user_id"));
				newUser.setUserDisplayName(rs.getString("user_displayname"));
				newUser.setUserImageUrl(rs.getString("user_imageurl"));
				newUser.setUserLoginTimeStamp(rs.getString("user_logintimestamp"));
				ret.add(newUser);
			}

			ps = conn.prepareStatement(
					"SELECT * from User");
			rs = ps.executeQuery();

			while(rs.next()) {

				String tempUserDisplay = rs.getString("user_displayname");
				String tempUserId = rs.getString("user_id");
				if(duplicates.contains(tempUserId.toLowerCase())) {
					continue;
				}
				if(!tempUserDisplay.toLowerCase().contains(search_input.toLowerCase())) {
					continue;
				}

				duplicates.add(tempUserId.toLowerCase());
				User newUser = new User();
				newUser.setUserId(rs.getString("user_id"));
				newUser.setUserDisplayName(rs.getString("user_displayname"));
				newUser.setUserImageUrl(rs.getString("user_imageurl"));
				newUser.setUserLoginTimeStamp(rs.getString("user_logintimestamp"));
				ret.add(newUser);
			}
		} catch (SQLException sqle) {
			System.out.println("sqle: " + sqle.getMessage());
		} catch (ClassNotFoundException cnfe) {
			System.out.println("cnfe: " + cnfe.getMessage());
		} finally {
			// You always need to close the connection to the database
			try {
				if (rs != null) {
					rs.close();
				}
				if (st != null) {
					st.close();
				}
				if (conn != null) {
					conn.close();
				}
			} catch(SQLException sqle) {
				System.out.println("sqle closing error: " + sqle.getMessage());
			}
		}
		return ret;
	}



	// Functions:
	/*
	 * This function will be responsible for adding new users into 
	 * the database with “INSERT” statements after a connection using 
	 * the JDBC DriverManager is established. Insertion will also be 
	 * surrounded by Try, Catch blocks to ensure a minimum level of 
	 * error handling. Function will return “True” if user is successfully 
	 * added and “False” otherwise.
	 */
	public boolean addUser(User newUser) {
		Connection conn = null;
		Statement st = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		boolean result = false;
		try {
			Class.forName(SQL_DRIVER_CLASS);
			conn = DriverManager.getConnection(DATABASE_CONNECTION_URL);
			ps = conn.prepareStatement(
					"INSERT INTO User ("
							+ "user_id, "
							+ "user_displayname, "
							+ "user_logintimestamp, "
							+ "user_imageurl"
							+ ") VALUES ('" 
							+ newUser.getUserId() + "', '"
							+ newUser.getUserDisplayName() + "', '"
							+ newUser.getUserLoginTimeStamp() + "', '"
							+ newUser.getUserImageUrl()
							+ "');");
			result = ps.execute();
		} catch (SQLException sqle) {
			System.out.println("sqle: " + sqle.getMessage());
		} catch (ClassNotFoundException cnfe) {
			System.out.println("cnfe: " + cnfe.getMessage());
		} finally {
			// You always need to close the connection to the database
			try {
				if (rs != null) {
					rs.close();
				}
				if (st != null) {
					st.close();
				}
				if (conn != null) {
					conn.close();
				}
			} catch(SQLException sqle) {
				System.out.println("sqle closing error: " + sqle.getMessage());
			}
		}
		return result;
	}
	
	
	// isFollowing
	public boolean isFollowing(String user_id, String follower_id) {
		Connection conn = null;
		Statement st = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		boolean result = false;
		
		try {
			Class.forName(SQL_DRIVER_CLASS);
			conn = DriverManager.getConnection(DATABASE_CONNECTION_URL);
			ps = conn.prepareStatement(
					"SELECT * FROM Follow WHERE user_id = '" + user_id + "' AND " + "follower_id = '" + follower_id + "';");
			rs = ps.executeQuery();
			
			// check if rs.next is empty to set result to false when no following/follower relationship
			result = rs.next();
			/*
			if(rs.getString("user_id") != null) {
				result = true;
			}
			else {
				result = false;
			}*/
		} catch (SQLException sqle) {
			System.out.println("sqle: " + sqle.getMessage());
		} catch (ClassNotFoundException cnfe) {
			System.out.println("cnfe: " + cnfe.getMessage());
		} finally {
			// You always need to close the connection to the database
			try {
				if (rs != null) {
					rs.close();
				}
				if (st != null) {
					st.close();
				}
				if (conn != null) {
					conn.close();
				}
			} catch(SQLException sqle) {
				System.out.println("sqle closing error: " + sqle.getMessage());
			}
		}
		System.out.println(result);
		return result;
	}
	
	
	/*
	 * This function will be responsible for adding a new follower relationship 
	 * into the database with “INSERT” statements after a connection using the 
	 * JDBC DriverManager is established. Insertion will also be surrounded by Try, 
	 * Catch blocks to ensure a minimum level of error handling. Function will return 
	 * “True” if follower is successfully added and “False” otherwise.
	 */
	public boolean follow(String user_id, String follower_id) {
		Connection conn = null;
		Statement st = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		boolean result = false;
		try {
			Class.forName(SQL_DRIVER_CLASS);
			conn = DriverManager.getConnection(DATABASE_CONNECTION_URL);
			ps = conn.prepareStatement(
					"INSERT INTO Follow (user_id, "
							+ "follower_id) VALUES ('" 
							+ user_id + "', '"  
							+ follower_id + "');");
			result = ps.execute();
		} catch (SQLException sqle) {
			System.out.println("sqle: " + sqle.getMessage());
		} catch (ClassNotFoundException cnfe) {
			System.out.println("cnfe: " + cnfe.getMessage());
		} finally {
			// You always need to close the connection to the database
			try {
				if (rs != null) {
					rs.close();
				}
				if (st != null) {
					st.close();
				}
				if (conn != null) {
					conn.close();
				}
			} catch(SQLException sqle) {
				System.out.println("sqle closing error: " + sqle.getMessage());
			}
		}
		return result;
	}

	/*
	 * This function will be responsible for deleting a follower relationship permanently 
	 * using the â€œDELETEâ€� statement after a connection using the JDBC DriverManager is 
	 * established. Deletion will also be surrounded by Try, Catch blocks to ensure a 
	 * minimum level of error handling. Function will return â€œTrueâ€� if relationship is 
	 * successfully deleted and â€œFalseâ€� otherwise.
	 */
	public boolean unfollow(String user_id, String follower_id) {
		Connection conn = null;
		Statement st = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		boolean result = false;
		try {
			Class.forName(SQL_DRIVER_CLASS);
			conn = DriverManager.getConnection(DATABASE_CONNECTION_URL);
			// not sure how to delete based off two parameters
			
			ps = conn.prepareStatement(
					"DELETE FROM Follow WHERE user_id = '" + user_id  + "' AND " + "follower_id = '" +  follower_id + "';");
			result = ps.execute();
		} catch (SQLException sqle) {
			System.out.println("sqle: " + sqle.getMessage());
		} catch (ClassNotFoundException cnfe) {
			System.out.println("cnfe: " + cnfe.getMessage());
		} finally {
			// You always need to close the connection to the database
			try {
				if (rs != null) {
					rs.close();
				}
				if (st != null) {
					st.close();
				}
				if (conn != null) {
					conn.close();
				}
			} catch(SQLException sqle) {
				System.out.println("sqle closing error: " + sqle.getMessage());
			}
		}
		return result;
	}

	/*
	 * This function will be responsible for retrieving all the followers of a user 
	 * using the â€œSELECTâ€� statement after a connection using the JDBC DriverManager 
	 * is established. Deletion will also be surrounded by Try, Catch blocks to ensure 
	 * a minimum level of error handling. Function will return an array of â€œuser_idâ€�(s) 
	 * corresponding to each follower. Size of array will be the number of followers a user has.
	 */
	public ArrayList<User> getFollowers(String user_id) {
		Connection conn = null;
		Statement st = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		ArrayList<String> result = new ArrayList<String>(); 
		
		try {
			Class.forName(SQL_DRIVER_CLASS);
			conn = DriverManager.getConnection(DATABASE_CONNECTION_URL);
			ps = conn.prepareStatement("SELECT f.follower_id FROM Follow f WHERE f.user_id = '" + user_id + "';");
			rs = ps.executeQuery();
			if(!rs.next()) {
				return new ArrayList<User>();
			} else {
				rs.beforeFirst();
				while(rs.next()) {
					result.add(rs.getString("follower_id"));		
				}
			}
		} catch (SQLException sqle) {
			System.out.println("sqle: " + sqle.getMessage());
		} catch (ClassNotFoundException cnfe) {
			System.out.println("cnfe: " + cnfe.getMessage());
		} finally {
			// You always need to close the connection to the database
			try {
				if (rs != null) {
					rs.close();
				}
				if (st != null) {
					st.close();
				}
				if (conn != null) {
					conn.close();
				}
			} catch(SQLException sqle) {
				System.out.println("sqle closing error: " + sqle.getMessage());
			}
		}

		ArrayList<User> followers = new ArrayList<User>();
		for(String follower : result) {
			try {
				Class.forName(SQL_DRIVER_CLASS);
				conn = DriverManager.getConnection(DATABASE_CONNECTION_URL);
				ps = conn.prepareStatement("SELECT "
						+ "u.user_id, "
						+ "u.user_displayname, "
						+ "u.user_imageurl, "
						+ "u.user_logintimestamp "
						+ "FROM User u "
						+ "WHERE u.user_id = '" + follower + "';");
				rs = ps.executeQuery();
				while(rs.next()){
					User followerUser = new User();
					followerUser.setUserId(rs.getString("user_id"));
					followerUser.setUserDisplayName(rs.getString("user_displayname"));
					followerUser.setUserImageUrl(rs.getString("user_imageurl"));
					followerUser.setUserLoginTimeStamp(rs.getString("user_logintimestamp"));
					followers.add(followerUser);
				}
			} catch (SQLException sqle) {
				System.out.println("sqle: " + sqle.getMessage());
			} catch (ClassNotFoundException cnfe) {
				System.out.println("cnfe: " + cnfe.getMessage());
			} finally {
				// You always need to close the connection to the database
				try {
					if (rs != null) {
						rs.close();
					}
					if (st != null) {
						st.close();
					}
					if (conn != null) {
						conn.close();
					}
				} catch(SQLException sqle) {
					System.out.println("sqle closing error: " + sqle.getMessage());
				}
			}
		}

		return followers;
	}

	/*
	 * This function will be responsible for retrieving all the users that the current 
	 * user is following using the â€œSELECTâ€� statement after a connection using the JDBC 
	 * DriverManager is established. Deletion will also be surrounded by Try, Catch blocks 
	 * to ensure a minimum level of error handling. Function will return an array of â€œuser_idâ€�(s) 
	 * corresponding to each user the current user is following. Size of array will be the 
	 * number of users the user specified is following.
	 */
	public ArrayList<User> getFollowings(String user_id) {
		Connection conn = null;
		Statement st = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		ArrayList<String> result = new ArrayList<String>(); 
		try {
			Class.forName(SQL_DRIVER_CLASS);
			conn = DriverManager.getConnection(DATABASE_CONNECTION_URL);
			ps = conn.prepareStatement("SELECT f.user_id FROM Follow f WHERE f.follower_id = '" + user_id + "';");
			rs = ps.executeQuery();
			if(!rs.next()) {
				return new ArrayList<User>();
			} else {
				rs.beforeFirst();
				while(rs.next()) {
					result.add(rs.getString("user_id"));		
				}
			}
		} catch (SQLException sqle) {
			System.out.println("sqle: " + sqle.getMessage());
		} catch (ClassNotFoundException cnfe) {
			System.out.println("cnfe: " + cnfe.getMessage());
		} finally {
			// You always need to close the connection to the database
			try {
				if (rs != null) {
					rs.close();
				}
				if (st != null) {
					st.close();
				}
				if (conn != null) {
					conn.close();
				}
			} catch(SQLException sqle) {
				System.out.println("sqle closing error: " + sqle.getMessage());
			}
		}

		ArrayList<User> followings = new ArrayList<User>();
		for(String following : result) {
			try {
				Class.forName(SQL_DRIVER_CLASS);
				conn = DriverManager.getConnection(DATABASE_CONNECTION_URL);
				ps = conn.prepareStatement("SELECT "
						+ "u.user_id, "
						+ "u.user_displayname, "
						+ "u.user_imageurl, "
						+ "u.user_logintimestamp "
						+ "FROM User u "
						+ "WHERE u.user_id = '" + following + "';");
				rs = ps.executeQuery();
				while(rs.next()){
					User followingUser = new User();
					followingUser.setUserId(rs.getString("user_id"));
					followingUser.setUserDisplayName(rs.getString("user_displayname"));
					followingUser.setUserImageUrl(rs.getString("user_imageurl"));
					followingUser.setUserLoginTimeStamp(rs.getString("user_logintimestamp"));
					followings.add(followingUser);
				}
			} catch (SQLException sqle) {
				System.out.println("sqle: " + sqle.getMessage());
			} catch (ClassNotFoundException cnfe) {
				System.out.println("cnfe: " + cnfe.getMessage());
			} finally {
				// You always need to close the connection to the database
				try {
					if (rs != null) {
						rs.close();
					}
					if (st != null) {
						st.close();
					}
					if (conn != null) {
						conn.close();
					}
				} catch(SQLException sqle) {
					System.out.println("sqle closing error: " + sqle.getMessage());
				}
			}
		}

		return followings;
	}

	/*
	 * This function will be responsible for adding new albums, album artist(s), and 
	 * all the songs in it  into the database with â€œINSERTâ€� statements after a connection 
	 * using the JDBC DriverManager is established. Insertion will also be surrounded by 
	 * Try, Catch blocks to ensure a minimum level of error handling. Function will return 
	 * â€œTrueâ€� if album is successfully added and â€œFalseâ€� otherwise.
	 */
	public boolean addAlbum(String album_id) {

		Connection conn = null;
		Statement st = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		boolean result = false;
		try {
			Class.forName(SQL_DRIVER_CLASS);
			conn = DriverManager.getConnection(DATABASE_CONNECTION_URL);
			ps = conn.prepareStatement("INSERT INTO Album (album_id) VALUES ('" + album_id+ "');");
			result = ps.execute();
		} catch (SQLException sqle) {
			System.out.println("sqle: " + sqle.getMessage());
		} catch (ClassNotFoundException cnfe) {
			System.out.println("cnfe: " + cnfe.getMessage());
		} finally {
			// You always need to close the connection to the database
			try {
				if (rs != null) {
					rs.close();
				}
				if (st != null) {
					st.close();
				}
				if (conn != null) {
					conn.close();
				}
			} catch(SQLException sqle) {
				System.out.println("sqle closing error: " + sqle.getMessage());
			}
		}
		return result;
	}

	/*
	 * This function will be responsible for deleting existing albums, and all posts that 
	 * included those albums and the songs inside the album from the database permanently 
	 * using the â€œDELETEâ€� statement after a connection using the JDBC DriverManager is 
	 * established. Deletion will also be surrounded by Try, Catch blocks to ensure a 
	 * minimum level of error handling. Function will return â€œTrueâ€� if album is successfully 
	 * deleted and â€œFalseâ€� otherwise.
	 */
	public boolean deleteAlbum(String album_id) {
		Connection conn = null;
		Statement st = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		boolean result = false;
		try {
			Class.forName(SQL_DRIVER_CLASS);
			conn = DriverManager.getConnection(DATABASE_CONNECTION_URL);

			ps = conn.prepareStatement(
					"DELETE FROM Album WHERE album_id=?");
			ps.setString(1,  album_id);
			result = ps.execute();

		} catch (SQLException sqle) {
			System.out.println("sqle: " + sqle.getMessage());
		} catch (ClassNotFoundException cnfe) {
			System.out.println("cnfe: " + cnfe.getMessage());
		} finally {
			// You always need to close the connection to the database
			try {
				if (rs != null) {
					rs.close();
				}
				if (st != null) {
					st.close();
				}
				if (conn != null) {
					conn.close();
				}
			} catch(SQLException sqle) {
				System.out.println("sqle closing error: " + sqle.getMessage());
			}
		}
		return result;
	}

	/*
	 * This function will be responsible for adding new songs and its corresponding artist(s), 
	 * as well as the updating the â€œAlbumSongâ€� relationship (storing the fact that the song 
	 * belongs to the album whose â€œalbum_idâ€� is specified) in the database with â€œINSERTâ€� 
	 * statements after a connection using the JDBC DriverManager is established. Insertion 
	 * will also be surrounded by Try, Catch blocks to ensure a minimum level of error 
	 * handling. Function will return â€œTrueâ€� if song is successfully added and â€œFalseâ€� otherwise.
	 */
	public boolean addSong(String song_id) {
		Connection conn = null;
		Statement st = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		boolean result = false;
		try {
			Class.forName(SQL_DRIVER_CLASS);
			conn = DriverManager.getConnection(DATABASE_CONNECTION_URL);
			ps = conn.prepareStatement("INSERT INTO Song (song_id) VALUES ('" + song_id+ "');");
			result = ps.execute();
		} catch (SQLException sqle) {
			System.out.println("sqle: " + sqle.getMessage());
		} catch (ClassNotFoundException cnfe) {
			System.out.println("cnfe: " + cnfe.getMessage());
		} finally {
			// You always need to close the connection to the database
			try {
				if (rs != null) {
					rs.close();
				}
				if (st != null) {
					st.close();
				}
				if (conn != null) {
					conn.close();
				}
			} catch(SQLException sqle) {
				System.out.println("sqle closing error: " + sqle.getMessage());
			}
		}
		return result;
	}


	/*
	 * This function will be responsible for tracking which users like a particular song 
	 * in the database with â€œINSERTâ€� statements to the â€œAlbumSongâ€� table after a connection 
	 * using the JDBC DriverManager is established. Insertion will also be surrounded by 
	 * Try, Catch blocks to ensure a minimum level of error handling. Function will return 
	 * â€œTrueâ€� if addition is successful and â€œFalseâ€� otherwise.
	 */
	public boolean likeSong(String song_id, String user_id) {
		Connection conn = null;
		Statement st = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		boolean result = false;
		try {
			Class.forName(SQL_DRIVER_CLASS);
			conn = DriverManager.getConnection(DATABASE_CONNECTION_URL);
			ps = conn.prepareStatement(
					"INSERT INTO SongLike (song_id, "

					+ "user_id) VALUES ('" 
					+ song_id + "', '" 

					+ user_id + "');");
			result = ps.execute();
		} catch (SQLException sqle) {
			System.out.println("sqle: " + sqle.getMessage());
		} catch (ClassNotFoundException cnfe) {
			System.out.println("cnfe: " + cnfe.getMessage());
		} finally {
			// You always need to close the connection to the database
			try {
				if (rs != null) {
					rs.close();
				}
				if (st != null) {
					st.close();
				}
				if (conn != null) {
					conn.close();
				}
			} catch(SQLException sqle) {
				System.out.println("sqle closing error: " + sqle.getMessage());
			}
		}
		return result;
	}

	/*
	 * This function will be responsible for deleting the relationship of the user liking 
	 * the song permanently using the â€œDELETEâ€� statement after a connection using the JDBC 
	 * DriverManager is established. Deletion will also be surrounded by Try, Catch blocks 
	 * to ensure a minimum level of error handling. Function will return â€œTrueâ€� if 
	 * relationship is successfully deleted and â€œFalseâ€� otherwise.
	 */
	public boolean unlikeSong(String song_id, String user_id) {
		Connection conn = null;
		Statement st = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		boolean result = false;
		try {
			Class.forName(SQL_DRIVER_CLASS);
			conn = DriverManager.getConnection(DATABASE_CONNECTION_URL);
			// not sure how to delete based off two parameters
			
			ps = conn.prepareStatement(
					"DELETE FROM SongLike WHERE song_id = '" + song_id + "' AND " + "user_id = '" + user_id + "';");
			result = ps.execute();
		} catch (SQLException sqle) {
			System.out.println("sqle: " + sqle.getMessage());
		} catch (ClassNotFoundException cnfe) {
			System.out.println("cnfe: " + cnfe.getMessage());
		} finally {
			// You always need to close the connection to the database
			try {
				if (rs != null) {
					rs.close();
				}
				if (st != null) {
					st.close();
				}
				if (conn != null) {
					conn.close();
				}
			} catch(SQLException sqle) {
				System.out.println("sqle closing error: " + sqle.getMessage());
			}
		}
		return result;
	}

	/*
	 * This function will be responsible for deleting existing songs, the â€œAlbumSongâ€� 
	 * relationships,and all posts that included those songs inside the album from the 
	 * database permanently using the â€œDELETEâ€� statement after a connection using the JDBC 
	 * DriverManager is established. Deletion will also be surrounded by Try, Catch blocks 
	 * to ensure a minimum level of error handling. Function will return â€œTrueâ€� if song is 
	 * successfully deleted and â€œFalseâ€� otherwise.
	 */
	public boolean deleteSong(String song_id) {
		Connection conn = null;
		Statement st = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		boolean result = false;
		try {
			Class.forName(SQL_DRIVER_CLASS);
			conn = DriverManager.getConnection(DATABASE_CONNECTION_URL);
			ps = conn.prepareStatement(
					"DELETE FROM Song WHERE song_id=?");
			ps.setString(1,  song_id);
			result = ps.execute();

			ps = conn.prepareStatement(
					"DELETE FROM SongLike WHERE song_id=?");
			ps.setString(1,  song_id);
			ps.execute();

		} catch (SQLException sqle) {
			System.out.println("sqle: " + sqle.getMessage());
		} catch (ClassNotFoundException cnfe) {
			System.out.println("cnfe: " + cnfe.getMessage());
		} finally {
			// You always need to close the connection to the database
			try {
				if (rs != null) {
					rs.close();
				}
				if (st != null) {
					st.close();
				}
				if (conn != null) {
					conn.close();
				}
			} catch(SQLException sqle) {
				System.out.println("sqle closing error: " + sqle.getMessage());
			}
		}
		return result;
	}

	/*
	 * This function will be responsible for adding a new post in the database with 
	 * â€œINSERTâ€� statements after a connection using the JDBC DriverManager is 
	 * established (and also updates the â€œPostAlbumâ€� or â€œPostSongâ€� table if required). 
	 * Insertion will also be surrounded by Try, Catch blocks to ensure a minimum level 
	 * of error handling. Function will return â€œTrueâ€� if post is successfully added and 
	 * â€œFalseâ€� otherwise.
	 */
	public int addPost(Post newPost) {
		// time stamp needs to figured out here
		Connection conn = null;
		Statement st = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		int result = -1;
		try {
			Class.forName(SQL_DRIVER_CLASS);
			conn = DriverManager.getConnection(DATABASE_CONNECTION_URL);
			ps = conn.prepareStatement(
					"INSERT INTO Post ("
					+ "post_timestamp, "
					+ "post_type, "
					+ "user_id, "
					+ "song_id, "
					+ "album_id, "
					+ "post_message) VALUES ('" 
					+ newPost.getPostTimeStamp().toString() + "', '" 
					+ newPost.getPostType().toString() + "', '" 
					+ newPost.getPostUserId() + "', '" 
					+ newPost.getPostSongId() + "', '" 
					+ newPost.getPostAlbumId() + "', '" 
					+ newPost.getPostMessage() + "');");
			ps.execute();
			
			ResultSet userRs = null;
			PreparedStatement userPs = null;
			Connection userConn = null;

			try {
				Class.forName(SQL_DRIVER_CLASS);
				userConn = DriverManager.getConnection(DATABASE_CONNECTION_URL);
				userPs = userConn.prepareStatement(
						"SELECT p.post_id from Post p WHERE "
						+ "p.user_id = '" + newPost.getPostUserId() 
						+ "' AND p.post_timestamp = '" + newPost.getPostTimeStamp().toString()
						+ "' AND p.post_message = '" + newPost.getPostMessage() + "';");
				userRs = userPs.executeQuery();
				
				if(!userRs.next()) {
					
					System.out.println("Can't get the post id wtf");
					
				} else {
					
					userRs.beforeFirst();
					while(userRs.next()) {
						result = userRs.getInt("post_id");
					}
					
				}
			} catch (SQLException sqle) {
				System.out.println("sqle: " + sqle.getMessage());
			} catch (ClassNotFoundException cnfe) {
				System.out.println("cnfe: " + cnfe.getMessage());
			} finally {
				// You always need to close the connection to the database
				try {
					if (userRs != null) {
						userRs.close();
					}
					if (userPs != null) {
						userPs.close();
					}
					if (userConn != null) {
						userConn.close();
					}
				} catch(SQLException sqle) {
					System.out.println("sqle closing error: " + sqle.getMessage());
				}
			}

			/*
			 * SAM'S JUNK
			 */
//			ps = conn.prepareStatement("select max(post_id) as postID from Post");
//			rs = ps.executeQuery();
//			rs.next();
//			result = rs.getInt("postID");

			// insert into post song id table
			//			if(newPost.getPostSongId() != null) {
			//				ps = conn.prepareStatement("INSERT INTO PostSong(song_id, "
			//						+ "post_id) VALUES ('"
			//						+ newPost.getPostSongId() + "', '" 
			//						+ newPost.getPostId() + "');");
			//				
			//			}
			//			else { // insert into post album id table
			//				ps = conn.prepareStatement("INSERT INTO PostAlbum(album_id, "
			//						+ "post_id) VALUES ('"
			//						+ newPost.getPostAlbumId() + "', '" 
			//						+ newPost.getPostId() + "');");
			//			}


		} catch (SQLException sqle) {
			System.out.println("sqle: " + sqle.getMessage());
		} catch (ClassNotFoundException cnfe) {
			System.out.println("cnfe: " + cnfe.getMessage());
		} finally {
			// You always need to close the connection to the database
			try {
				if (rs != null) {
					rs.close();
				}
				if (ps != null) {
					ps.close();
				}
				if (conn != null) {
					conn.close();
				}
			} catch(SQLException sqle) {
				System.out.println("sqle closing error: " + sqle.getMessage());
			}
		}
		return result;
	}

	/*
	 * This function will be responsible for retrieving the posts from the database 
	 * with â€œSELECTâ€� statements after a connection using the JDBC DriverManager is 
	 * established. Retrieval will also be surrounded by Try, Catch blocks to ensure 
	 * a minimum level of error handling. Function will return an array of Post objects 
	 * and null if no posts are found.
	 */
	public ArrayList<Post> getPosts (String user_id) {

		//"SELECT f.follower_id FROM Follow f WHERE f.user_id = '" + user_id + "';"
		Connection conn = null;
		Statement st = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		ArrayList<Post> tempRes = new ArrayList<Post>(); 
		
		try {
			Class.forName(SQL_DRIVER_CLASS);
			conn = DriverManager.getConnection(DATABASE_CONNECTION_URL);
			// not sure how to delete based off two parameters
			ps = conn.prepareStatement(
					"SELECT * from Post WHERE user_id= '" + user_id + "';");
			//ps.setString(1, "%" + user_id + "%");

			rs = ps.executeQuery();
			while(rs.next()){
				Post tempPost = new Post();

				String tempPostId = rs.getString("post_id");
				String tempPostType = rs.getString("post_type");
				String tempPostTimeStamp = rs.getString("post_timestamp");
				String tempUserId = rs.getString("user_id");
				String tempPostMessage = rs.getString("post_message");
				String tempPostSongId = rs.getString("song_id");
				String tempPostAlbumId = rs.getString("album_id");


				tempPost.setPostId(tempPostId);
				tempPost.setPostType(tempPostType);
				tempPost.setPostTimeStamp(tempPostTimeStamp);
				tempPost.setPostUserId(tempUserId);
				tempPost.setPostMessage(tempPostMessage);
				tempPost.setPostSongId(tempPostSongId);
				tempPost.setPostAlbumId(tempPostAlbumId);

				/*
	    		  PreparedStatement ps2 = conn.prepareStatement(
	    				  "SELECT * from PostAlbum WHERE user_id LIKE?");
	    		  ps2.setString(1, "%" + user_id + "%");
	    		  ResultSet rs2 = ps2.executeQuery();

	    		  PreparedStatement ps3 = conn.prepareStatement(
	    				  "SELECT * from SongAlbum WHERE user_id LIKE?");
	    		  ps3.setString(1, "%" + user_id + "%");
	    		  ResultSet rs3 = ps3.executeQuery();

	    		  if(ps2 != null) {
	    			  tempPost.setPostAlbumId(rs2.getString("album_id"));
	    		  }
	    		  else {
	    			  tempPost.setPostAlbumId(rs2.getString(null));
	    		  }

	    		  if(ps3 != null) {
	    			  tempPost.setPostSongId(rs3.getString("song_id"));
	    		  }
	    		  else {
	    			  tempPost.setPostSongId(rs3.getString(null));
	    		  }*/
				tempRes.add(tempPost);
			}
		} catch (SQLException sqle) {
			System.out.println("sqle: " + sqle.getMessage());
		} catch (ClassNotFoundException cnfe) {
			System.out.println("cnfe: " + cnfe.getMessage());
		} finally {
			// You always need to close the connection to the database
			try {
				if (rs != null) {
					rs.close();
				}
				if (st != null) {
					st.close();
				}
				if (conn != null) {
					conn.close();
				}
			} catch(SQLException sqle) {
				System.out.println("sqle closing error: " + sqle.getMessage());
			}
		}
		return tempRes;
	}

	/*
	 * This function will be responsible for retrieving the posts from the users 
	 * that the user specified is following through the database with â€œSELECTâ€� 
	 * statements after a connection using the JDBC DriverManager is established. 
	 * Retrieval will also be surrounded by Try, Catch blocks to ensure a minimum 
	 * level of error handling. Function will return an array of Post objects and 
	 * null if no posts are found.
	 */
	public ArrayList<Post> getFeed(String user_id) {
		Connection conn = null;
		Statement st = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		ArrayList<Post> tempRes = new ArrayList<Post>(); 
		try {
			Class.forName(SQL_DRIVER_CLASS);
			conn = DriverManager.getConnection(DATABASE_CONNECTION_URL);
			// first select the users that the target user is following
			ps = conn.prepareStatement("SELECT * FROM Follow f WHERE f.follower_id = '" + user_id + "';");
			//ps.setString(1, "%" + user_id + "%");

			rs = ps.executeQuery();
			ArrayList<String> following = new ArrayList<String>();
			while(rs.next()) {
				following.add(rs.getString("user_id"));
			}

			// do we have to reset rs, ps, etc. as null
			// iterate through the users that the target user is following 
			// add posts accordingly
			for(int i = 0; i < following.size() + 1; ++i) {
				if(i == following.size()) {
					ps = conn.prepareStatement(
							"SELECT * from Post WHERE user_id= '" + user_id + "';");
				} else {
					ps = conn.prepareStatement(
							"SELECT * from Post WHERE user_id= '" + following.get(i) + "';");
				}
				//ps.setString(1, "%" + following.get(i) + "%");
				rs = ps.executeQuery();
				while(rs.next()){
					Post tempPost = new Post();

					String tempPostId = rs.getString("post_id");
					String tempPostType = rs.getString("post_type");
					String tempPostTimeStamp = rs.getString("post_timestamp");
					String tempUserId = rs.getString("user_id");
					String tempPostMessage = rs.getString("post_message");
					String tempPostSongId = rs.getString("song_id");
					String tempPostAlbumId = rs.getString("album_id");

					ResultSet userRs = null;
					PreparedStatement userPs = null;
					Connection userConn = null;

					try {
						Class.forName(SQL_DRIVER_CLASS);
						userConn = DriverManager.getConnection(DATABASE_CONNECTION_URL);
						userPs = userConn.prepareStatement(
								"SELECT * from User WHERE user_id= '" + tempUserId + "';");
						userRs = userPs.executeQuery();
						
						if(!userRs.next()) {
							tempPost.setPostUserDisplayname("Can't be Found");
							tempPost.setPostUserImageurl("Can't be Found");
							tempPost.setPostUserLogintimestamp("Can't be Found");
						} else {
							userRs.beforeFirst();
							while(userRs.next()) {
								tempPost.setPostUserDisplayname(userRs.getString("user_displayname"));
								tempPost.setPostUserImageurl(userRs.getString("user_imageurl"));
								tempPost.setPostUserLogintimestamp(userRs.getString("user_logintimestamp"));	
							}
						}
					} catch (SQLException sqle) {
						System.out.println("sqle: " + sqle.getMessage());
					} catch (ClassNotFoundException cnfe) {
						System.out.println("cnfe: " + cnfe.getMessage());
					} finally {
						// You always need to close the connection to the database
						try {
							if (userRs != null) {
								userRs.close();
							}
							if (userPs != null) {
								userPs.close();
							}
							if (userConn != null) {
								userConn.close();
							}
						} catch(SQLException sqle) {
							System.out.println("sqle closing error: " + sqle.getMessage());
						}
					}

					tempPost.setPostId(tempPostId);
					tempPost.setPostType(tempPostType);
					tempPost.setPostTimeStamp(tempPostTimeStamp);
					tempPost.setPostUserId(tempUserId);
					tempPost.setPostMessage(tempPostMessage);
					tempPost.setPostSongId(tempPostSongId);
					tempPost.setPostAlbumId(tempPostAlbumId);

					/*
		    		  PreparedStatement ps2 = conn.prepareStatement(
		    				  "SELECT * from PostAlbum WHERE user_id LIKE?");
		    		  ps2.setString(1, "%" + user_id + "%");
		    		  ResultSet rs2 = ps2.executeQuery();

		    		  PreparedStatement ps3 = conn.prepareStatement(
		    				  "SELECT * from SongAlbum WHERE user_id LIKE?");
		    		  ps3.setString(1, "%" + user_id + "%");
		    		  ResultSet rs3 = ps3.executeQuery();

		    		  if(ps2 != null) {
		    			  tempPost.setPostAlbumId(rs2.getString("album_id"));
		    		  }
		    		  else {
		    			  tempPost.setPostAlbumId(rs2.getString(null));
		    		  }

		    		  if(ps3 != null) {
		    			  tempPost.setPostSongId(rs3.getString("song_id"));
		    		  }
		    		  else {
		    			  tempPost.setPostSongId(rs3.getString(null));
		    		  }*/
					tempRes.add(tempPost);
				}
			}

		} catch (SQLException sqle) {
			System.out.println("sqle: " + sqle.getMessage());
		} catch (ClassNotFoundException cnfe) {
			System.out.println("cnfe: " + cnfe.getMessage());
		} finally {
			// You always need to close the connection to the database
			try {
				if (rs != null) {
					rs.close();
				}
				if (st != null) {
					st.close();
				}
				if (conn != null) {
					conn.close();
				}
			} catch(SQLException sqle) {
				System.out.println("sqle closing error: " + sqle.getMessage());
			}
		}
		return tempRes;
	}

	/*
	 * This function will be responsible for tracking which users like a particular 
	 * post in the database with â€œINSERTâ€� statements to the â€œPostLikeâ€� table after 
	 * a connection using the JDBC DriverManager is established. Insertion will also 
	 * be surrounded by Try, Catch blocks to ensure a minimum level of error handling. 
	 * Function will return â€œTrueâ€� if addition is successful and â€œFalseâ€� otherwise.
	 */
	public boolean likePost(String post_id, String user_id) {
		// time stamp needs to figured out here
		Connection conn = null;
		Statement st = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		boolean result = false;
		try {
			Class.forName(SQL_DRIVER_CLASS);
			conn = DriverManager.getConnection(DATABASE_CONNECTION_URL);
			ps = conn.prepareStatement(
					"INSERT INTO PostLike (post_id, "
							+ "user_id) VALUES ('" 

					+ post_id + "', '" 
					+ user_id + "');");
			result = ps.execute();
		} catch (SQLException sqle) {
			System.out.println("sqle: " + sqle.getMessage());
		} catch (ClassNotFoundException cnfe) {
			System.out.println("cnfe: " + cnfe.getMessage());
		} finally {
			// You always need to close the connection to the database
			try {
				if (rs != null) {
					rs.close();
				}
				if (st != null) {
					st.close();
				}
				if (conn != null) {
					conn.close();
				}
			} catch(SQLException sqle) {
				System.out.println("sqle closing error: " + sqle.getMessage());
			}
		}
		return result;
	}

	/*
	 * This function will be responsible for deleting the relationship of the user 
	 * liking the post permanently using the â€œDELETEâ€� statement after a connection 
	 * using the JDBC DriverManager is established. Deletion will also be surrounded 
	 * by Try, Catch blocks to ensure a minimum level of error handling. Function will 
	 * return â€œTrueâ€� if relationship is successfully deleted and â€œFalseâ€� otherwise.
	 */
	public boolean unlikePost(String post_id, String user_id) {
		Connection conn = null;
		Statement st = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		boolean result = false;
		try {
			
			Class.forName(SQL_DRIVER_CLASS);
			conn = DriverManager.getConnection(DATABASE_CONNECTION_URL);
			ps = conn.prepareStatement(
					"DELETE FROM PostLike WHERE post_id = '" + post_id + "' AND user_id = '" + user_id + "';");
			result = ps.execute();
		} catch (SQLException sqle) {
			System.out.println("sqle: " + sqle.getMessage());
		} catch (ClassNotFoundException cnfe) {
			System.out.println("cnfe: " + cnfe.getMessage());
		} finally {
			// You always need to close the connection to the database
			try {
				if (rs != null) {
					rs.close();
				}
				if (st != null) {
					st.close();
				}
				if (conn != null) {
					conn.close();
				}
			} catch(SQLException sqle) {
				System.out.println("sqle closing error: " + sqle.getMessage());
			}
		}
		return result;
	}

	/*
	 * This function will be responsible for tracking which users shared a particular 
	 * post in the database with â€œINSERTâ€� statements to the â€œPostShareâ€� table and also 
	 * adds the same post to â€œPostâ€� table (but under current user) after a connection 
	 * using the JDBC DriverManager is established. Insertion will also be surrounded by 
	 * Try, Catch blocks to ensure a minimum level of error handling. Function will return 
	 * â€œTrueâ€� if addition is successful and â€œFalseâ€� otherwise.
	 */
	public boolean sharePost(int post_id, String user_id, String timeStamp) {
		// ? look at this

		// time stamp needs to figured out here
		Connection conn = null;
		Statement st = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		boolean result = false;
		try {
			Class.forName(SQL_DRIVER_CLASS);
			conn = DriverManager.getConnection(DATABASE_CONNECTION_URL);
			ps = conn.prepareStatement(
					"SELECT * from Post WHERE post_id = '" + post_id + "';");
			rs = ps.executeQuery(); 

			String postMessage = rs.getString("post_message");

			ps = conn.prepareStatement(
					"INSERT INTO Post (post_id, "
							+ "post_timestamp, "
							+ "user_id, "
							+ "post_message) VALUES ('" 

					+ post_id + "', '" 
					+ timeStamp.toString() + "', '" 
					+ user_id + "', '" 
					+ postMessage + "');");
			result = ps.execute();

			ps = conn.prepareStatement(
					"INSERT INTO PostShare (post_id, "
							+ "user_id) VALUES ('" 

					+ post_id + "', '" 
					+ user_id + "');");
			result = ps.execute();


		} catch (SQLException sqle) {
			System.out.println("sqle: " + sqle.getMessage());
		} catch (ClassNotFoundException cnfe) {
			System.out.println("cnfe: " + cnfe.getMessage());
		} finally {
			// You always need to close the connection to the database
			try {
				if (rs != null) {
					rs.close();
				}
				if (st != null) {
					st.close();
				}
				if (conn != null) {
					conn.close();
				}
			} catch(SQLException sqle) {
				System.out.println("sqle closing error: " + sqle.getMessage());
			}
		}
		return result;
	}

	public Post getPost(int post_id) {
		Connection conn = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		Post ret = new Post();
		try {
			Class.forName(SQL_DRIVER_CLASS);
			conn = DriverManager.getConnection(DATABASE_CONNECTION_URL);
			// not sure how to delete based off two parameters
			ps = conn.prepareStatement(
					"SELECT * from Post p WHERE p.post_id= '" + post_id + "';");
			rs = ps.executeQuery();
			while(rs.next()){
				String tempPostId = rs.getString("post_id");
				String tempPostType = rs.getString("post_type");
				String tempPostTimeStamp = rs.getString("post_timestamp");
				String tempUserId = rs.getString("user_id");
				String tempPostMessage = rs.getString("post_message");
				String tempPostSongId = rs.getString("song_id");
				String tempPostAlbumId = rs.getString("album_id");
	
	
				ret.setPostId(tempPostId);
				ret.setPostType(tempPostType);
				ret.setPostTimeStamp(tempPostTimeStamp);
				ret.setPostUserId(tempUserId);
				ret.setPostMessage(tempPostMessage);
				ret.setPostSongId(tempPostSongId);
				ret.setPostAlbumId(tempPostAlbumId);
			}

		} catch (SQLException sqle) {
			System.out.println("sqle: " + sqle.getMessage());
		} catch (ClassNotFoundException cnfe) {
			System.out.println("cnfe: " + cnfe.getMessage());
		} finally {
			// You always need to close the connection to the database
			try {
				if (rs != null) {
					rs.close();
				}
				if (ps != null) {
					ps.close();
				}
				if (conn != null) {
					conn.close();
				}
			} catch(SQLException sqle) {
				System.out.println("sqle closing error: " + sqle.getMessage());
			}
		}
		return ret;
	}
	/* 
	 * This function will be responsible for deleting existing songs, the â€œAlbumSongâ€� 
	 * relationships,and all posts that included those songs inside the album from the 
	 * database permanently using the â€œDELETEâ€� statement after a connection using the 
	 * JDBC DriverManager is established. Deletion will also be surrounded by Try, Catch 
	 * blocks to ensure a minimum level of error handling. Function will return â€œTrueâ€� 
	 * if song is successfully deleted and â€œFalseâ€� otherwise.
	 */
	public boolean deletePost(String post_id) {
		Connection conn = null;
		Statement st = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		boolean result = false;
		try {
			Class.forName(SQL_DRIVER_CLASS);
			conn = DriverManager.getConnection(DATABASE_CONNECTION_URL);
			ps = conn.prepareStatement(
					"DELETE FROM Post WHERE post_id = '" + post_id + "';");
			result = ps.execute();

			ps = conn.prepareStatement(
					"DELETE FROM PostLike WHERE post_id = '" + post_id + "';");
			ps.execute();

			ps = conn.prepareStatement(
					"DELETE FROM PostShare WHERE post_id = '" + post_id + "';");
			ps.execute();

			/*
			ps = conn.prepareStatement(
					"DELETE FROM PostSong WHERE post_id=" + post_id);
			ps.execute();

			ps = conn.prepareStatement(
					"DELETE FROM PostAlbum WHERE post_id=" + post_id);
			ps.execute();*/
		} catch (SQLException sqle) {
			System.out.println("sqle: " + sqle.getMessage());
		} catch (ClassNotFoundException cnfe) {
			System.out.println("cnfe: " + cnfe.getMessage());
		} finally {
			// You always need to close the connection to the database
			try {
				if (rs != null) {
					rs.close();
				}
				if (st != null) {
					st.close();
				}
				if (conn != null) {
					conn.close();
				}
			} catch(SQLException sqle) {
				System.out.println("sqle closing error: " + sqle.getMessage());
			}
		}
		return result;
	}
	
	public String getUserImg(String user_id) {
		Connection conn = null;
		Statement st = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		String userProfilePic = "";
		
		try {
			Class.forName(SQL_DRIVER_CLASS);
			conn = DriverManager.getConnection(DATABASE_CONNECTION_URL);
			// not sure how to delete based off two parameters
			ps = conn.prepareStatement(
					"SELECT user_imageurl from User u WHERE u.user_id= '" + user_id + "';");
			rs = ps.executeQuery();
			while(rs.next()){
				userProfilePic = rs.getString("user_imageurl");
			}

		} catch (SQLException sqle) {
			System.out.println("sqle: " + sqle.getMessage());
		} catch (ClassNotFoundException cnfe) {
			System.out.println("cnfe: " + cnfe.getMessage());
		} finally {
			// You always need to close the connection to the database
			try {
				if (rs != null) {
					rs.close();
				}
				if (ps != null) {
					ps.close();
				}
				if (conn != null) {
					conn.close();
				}
			} catch(SQLException sqle) {
				System.out.println("sqle closing error: " + sqle.getMessage());
			}
		}
		return userProfilePic;
	}
	
	public String getUserDisplayName(String user_id) {
		Connection conn = null;
		Statement st = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		String userDisplayName= "";
		
		try {
			Class.forName(SQL_DRIVER_CLASS);
			conn = DriverManager.getConnection(DATABASE_CONNECTION_URL);
			// not sure how to delete based off two parameters
			ps = conn.prepareStatement(
					"SELECT user_displayname from User u WHERE u.user_id= '" + user_id + "';");
			rs = ps.executeQuery();
			while(rs.next()){
				userDisplayName = rs.getString("user_displayname");
			}

		} catch (SQLException sqle) {
			System.out.println("sqle: " + sqle.getMessage());
		} catch (ClassNotFoundException cnfe) {
			System.out.println("cnfe: " + cnfe.getMessage());
		} finally {
			// You always need to close the connection to the database
			try {
				if (rs != null) {
					rs.close();
				}
				if (ps != null) {
					ps.close();
				}
				if (conn != null) {
					conn.close();
				}
			} catch(SQLException sqle) {
				System.out.println("sqle closing error: " + sqle.getMessage());
			}
		}
		return userDisplayName;
	}
		
		
}
