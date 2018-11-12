package server;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Vector;

import javax.websocket.OnClose;
import javax.websocket.OnError;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;


@ServerEndpoint (value="/endpoint")
public class TCWebSocket {
	
	//Store users and their sessions
	//private static Map<String, Session> sessionUser = new HashMap<String, Session>();
	
	//Session vector
	private static Vector<Session> sessionVector = new Vector<Session>();


	//Called when swift client connects
	@OnOpen 
	public void open(Session session) {
		System.out.println("onOpen:: " + session.getId());
		sessionVector.add(session);
		
	}
	//Called when a connection is closed
	@OnClose
	public void close (Session session) {
		System.out.println("onClose:: " + session.getId());
		
	}
	
	//Called when message is recieved by client
	@OnMessage
	public void onMessage (String message, Session session) {
		System.out.println("onMessage::From= " + session.getId() + "Message= " + message);
		try {
			session.getBasicRemote().sendText("Hello TrackChanges Client " + session.getId() + "!");
			
		}catch(IOException ioe)
		{
			ioe.printStackTrace();
		}
	}
	
   @OnError
    public void onError(Throwable t) {
        System.out.println("onError::" + t.getMessage());
    }

	
	
}
