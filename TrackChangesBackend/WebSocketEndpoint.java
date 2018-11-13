package TrackChangesBackend;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.nio.ByteBuffer;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

import javax.websocket.OnClose;
import javax.websocket.OnError;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;

import org.json.simple.JSONObject;


@ServerEndpoint ("/ws")

public class WebSocketEndpoint {
		
	//Store users and their sessions in the map
	private static final Map<String, Session> sessions = new HashMap<String, Session>();
	//private static Application application = new Application();
	private static Lock lock = new ReentrantLock();
	
	
	//Called when swift client connects
	@OnOpen 
	public void open(Session session) {
		lock.lock(); 
		System.out.println("onOpen:: " + session.getId());
		sessions.put(session.getId(), session);
		lock.unlock();
	}
	
	//Called when a connection is closed
	@OnClose
	public void close(Session session) {
		lock.lock();
		System.out.println("onClose:: " + session.getId());	
		if (sessions.get(session.getId()) != null)
		{
			//TO-DO: write Application.java 
			//application.removeSession(session));
			sessions.remove(session.getId());
		}
		lock.unlock();
	}
	
//	//Called when a message is received by the client
//	@OnMessage
//	public void onMessage (byte[] b, Session session) {
//		lock.lock();
//		String printMe ="";
//		
//		try {
//			printMe = new String(b, "US-ASCII");
//		}catch(UnsupportedEncodingException uee) {
//			uee.printStackTrace();
//		}
//		//JSONObject json = null; //need a way to parse incoming JSON
//		//application.parseMessage(json, session, this);
//		
//		lock.unlock();
//		// System.out.println("onMessage::From= " + session.getId() + "Message= " + message);
//	
//	}
	
	  @OnMessage
	    public void onMessage(String message, Session session) {
	        System.out.println("onMessage::From=" + session.getId() + " Message=" + message);
	        
	        try {
	            session.getBasicRemote().sendText("Hello Client " + session.getId() + "!");
	        } catch (IOException e) {
	            e.printStackTrace();
	        }
	    }
   @OnError
    public void onError(Throwable e) {
       	e.printStackTrace();
    }
   
//   public void sendToSession(Session session, byte[] data) {
//	   
//	   lock.lock();
//	   try {
//		   ByteBuffer tobeSent = ByteBuffer.wrap(data);
//		   session.getBasicRemote().sendBinary(tobeSent);
//		   
//	   }catch(IOException ioe) {
//		   sessions.remove(session.getId());   
//	   }
//	   lock.unlock();
//	   
//   }
//   
//   public void sendToAllSessions(Session session, byte[] data) {
//	 
//	   lock.lock();
//	   try {
//		   ByteBuffer tobeSent = ByteBuffer.wrap(data);
//		   //loop through sessions
//		   for (String key : sessions.keySet()) {
//			    if (sessions.get(key)!=session) {
//			    	sessions.get(key).getBasicRemote().sendBinary(tobeSent);
//			    }
//			}		   
//	   }catch(IOException ioe) {   
//		   ioe.printStackTrace();
//	   }
//	   lock.unlock();
//	   
//   }
   
  	
}
