package com.ford.avarsdl.jsonserver;

import com.ford.avarsdl.util.Logger;
import com.ford.avarsdl.util.RPCConst;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.InterruptedIOException;
import java.io.OutputStreamWriter;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.Vector;

public class JSONServer extends Thread {

    public static interface JSONServerCallback {
        void onComplete() throws IOException;
        void onError(String message);
    }
	
	public JSONServer() {
		this(RPCConst.TCP_SERVER_PORT);
	}
	
	public JSONServer(int port) {
		mPort = port;
		//instantiate MessageBrokerWrapper
		mMsgBroker = createMessageBrokerWrapper();
		mMsgBroker.start(this);
		this.setPriority(Thread.MIN_PRIORITY);
	}
	
	@Override
	public void run() {
		super.run();
		//run thread to listen socket for new connections
		listenSocket();
		//read buffers of clients for messages
		waitMessages();
		//close server
		try {
			close();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

    public void setCallback(JSONServerCallback mCallback) {
        this.mCallback = mCallback;
    }

    // =====================================================
	// private section
	// =====================================================
	private MBWrapper mMsgBroker = null;
	private int mPort = -1;
    private JSONServerCallback mCallback;
	private Vector<Socket> mClientsSocketsPool = new Vector<Socket>();
	private Vector<BufferedReader> mClientsReadersPool = new Vector<BufferedReader>();
	private Vector<BufferedWriter> mClientsWritersPool = new Vector<BufferedWriter>();

    protected ServerSocket createSocket() throws IOException {
        Logger.i(getClass().getSimpleName() + " Create server socket, port: " + mPort);
        return new ServerSocket(mPort);
    }

    protected MBWrapper createMessageBrokerWrapper() {
        Logger.i(getClass().getSimpleName() + " Create Message Broker wrapper");
        MBWrapper wrapper = MBWrapper.CreateMessageBroker();
        Logger.i(getClass().getSimpleName() + " Wrapper is: " + wrapper.toString());
        return wrapper;
    }
	
	private void listenSocket() {
        Logger.i(getClass().getSimpleName() + " Start new thread for socket listener");
		//start server
		Thread socketListenerThread = new Thread(new Runnable() {
			
			public void run() {
				ServerSocket serverSocket;
				try {
					serverSocket = createSocket();
					// wait for connection
					if (mCallback != null) {
                        mCallback.onComplete();
                    }
					while(true) {
						Socket connectionSocket = serverSocket.accept();
						connectionSocket.setSoTimeout(0);
						connectionSocket.setTcpNoDelay(true);
						//put socket info in clients vectors
						mClientsSocketsPool.add(connectionSocket);
						mClientsWritersPool.add(new BufferedWriter(new OutputStreamWriter(
								connectionSocket.getOutputStream())));
						mClientsReadersPool.add(new BufferedReader(new InputStreamReader(
								connectionSocket.getInputStream())));
					}
				} catch (InterruptedIOException e) {
					//e.printStackTrace();
                    if (mCallback != null) {
                        mCallback.onError(e.getMessage());
                    }
				} catch (IOException e) {
					//e.printStackTrace();
                    if (mCallback != null) {
                        mCallback.onError(e.getMessage());
                    }
				}
			}//run()
		});//new Thread
		socketListenerThread.setName("ServerListenerThread");
		socketListenerThread.start();
	}
	
	private void waitMessages() {
        Logger.i(getClass().getSimpleName() + " Wait for messages");
		//read msg and send it to MsgBroker
		while (true) {
			try {
				Thread.sleep(100);
			} catch (InterruptedException e1) {
				e1.printStackTrace();
			}
            processSocketsConnection();
            //go through all clients readers and try to read msg
            if (mClientsReadersPool != null) {
                for (int i = 0; i < mClientsReadersPool.size(); i++) {
                    // receive a message
                    String incomingMsg = null;
                    try {
                        if (mClientsReadersPool.get(i).ready())
                            incomingMsg = mClientsReadersPool.get(i).readLine();
                        if (incomingMsg != null) //redirect message to MB
                            mMsgBroker.onMsgReceived(i + 1, incomingMsg);
                    }
                    catch (IOException e) {
                        incomingMsg = null;
                        Logger.e(getClass().getSimpleName() + " waitMessages: " + e);
                    }
                }
            }
		}
	}

    private void processSocketsConnection() {
        /*boolean result = true;
        for (Socket socket : mClientsSocketsPool) {
            Logger.w(getClass().getSimpleName() + " Socket: " + socket.isConnected() + " " + socket.isClosed());
            if (!socket.isConnected() || socket.isClosed()) {
                result = false;
                break;
            }
        }
        if (!result) {
            Logger.w(getClass().getSimpleName() + " Socket disconnected");
        }*/
    }
	
	//method for sending messages from native code
	private int Send(int ctrlIndex, String data) {
        Logger.d(getClass().getSimpleName() + " Send message to client: " + data);
		try {
			mClientsWritersPool.get(ctrlIndex-1).write(data);
			mClientsWritersPool.get(ctrlIndex-1).flush();
		} catch (IOException e) {
			e.printStackTrace();
		} catch (Exception e1) {
			e1.printStackTrace();
		}
		return data.length();
	}

    public void close() throws IOException {
        for (BufferedReader aMClientsReadersPool : mClientsReadersPool) {
            aMClientsReadersPool.close();
        }
        mClientsReadersPool.clear();
        for (BufferedWriter aMClientsWritersPool : mClientsWritersPool) {
            aMClientsWritersPool.close();
        }
        mClientsWritersPool.clear();
        for (Socket aMClientsSocketsPool : mClientsSocketsPool) {
            aMClientsSocketsPool.close();
        }
        mClientsSocketsPool.clear();

        // TODO: Call these methods cause unit tests to fail (because of the native errors)
        // Commit these methods call for a wild

        //mMsgBroker.stop();
        //mMsgBroker.destroy();
    }

    public boolean isAnyConnection() {
        return mClientsReadersPool.size() > 0 ||
                mClientsWritersPool.size() > 0 ||
                mClientsSocketsPool.size() > 0;
    }
}