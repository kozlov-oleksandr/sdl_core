package com.ford.avarsdl.jsoncontroller;

import android.util.Log;

import com.ford.avarsdl.jsonparser.EMBMethods;
import com.ford.avarsdl.jsonparser.JSONParser;
import com.ford.avarsdl.util.Const;
import com.ford.avarsdl.util.RPCConst;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.net.SocketAddress;
import java.util.HashMap;

public abstract class JSONController {

    public static interface JSONControllerCallback {
        void onRegister() throws IOException;
        void onError(String message);
    }

	public JSONController(String name, ITCPClient tcpStub) throws IOException {
        // create client with connection to server
        if (tcpStub != null) {
            mTCPClient = tcpStub;
        } else {
            mTCPClient = new TCPClient();
        }
        SocketAddress socketAddress = new InetSocketAddress(RPCConst.LOCALHOST, RPCConst.TCP_SERVER_PORT);
        mTCPClient.connect(socketAddress);

        mJSONParser = new JSONParser();
		mName = name;
		mWaitResponseQueue = new HashMap<Integer, String>();

		// start listen server socket
		listenSocket();
	}

	public JSONController(String name) throws IOException {
		this(name, null);
	}

	public void register(int initId) {
		String method = RPCConst.CN_MESSAGE_BROKER + "."
				+ EMBMethods.registerComponent.toString();
		JSONObject jsonParams = new JSONObject();
		try {
			jsonParams.put("componentName", mName);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		mJSONParser.putEmptyJSONRPCObject();
		String jsonMsg = mJSONParser.createJSONServerRequest(method,
				jsonParams, initId);
		mWaitResponseQueue.put(initId, method);
		sendJSONMsg(jsonMsg);
	}

	public void unregister(int initId) {
		String method = RPCConst.CN_MESSAGE_BROKER + "."
				+ EMBMethods.unregisterComponent.toString();
		JSONObject jsonParams = new JSONObject();
		try {
			jsonParams.put("componentName", mName);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		mJSONParser.putEmptyJSONRPCObject();
		String jsonMsg = mJSONParser.createJSONServerRequest(method,
				jsonParams, initId);
		mWaitResponseQueue.put(initId, method);
		sendJSONMsg(jsonMsg);
	}

	public void sendRequest(String method, String jsonParams) {
		int id = getPackageId();
		mJSONParser.putEmptyJSONRPCObject();
		String jsonMsg = mJSONParser.createJSONServerRequest(method,
				jsonParams, id);
		mWaitResponseQueue.put(id, method);
		sendJSONMsg(jsonMsg);
	}

	public void sendNotification(String method, String jsonParams) {
		mJSONParser.putEmptyJSONRPCObject();
		String jsonMsg = mJSONParser.createJSONNotification(method, jsonParams);
		sendJSONMsg(jsonMsg);
	}

	public void close() throws IOException {
		mStopListening = true;
		while (!mListeningIsStoped) {
			try {
				Thread.sleep(10);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
		mTCPClient.disconnect();
		mWaitResponseQueue.clear();
	}

    public boolean isConnected() {
        return mTCPClient.isConnected() && mWaitResponseQueue.size() > 0;
    }

	public String getResponse() {
		if (mRequestResponse != null) {
			String retVal = mRequestResponse;
			mRequestResponse = null;
			return retVal;
		}
		return mRequestResponse;
	}

    public void setCallback(JSONControllerCallback mCallback) {
        this.mCallback = mCallback;
    }

    // ==================================================================
	// protected and private section
	// ==================================================================
	private final boolean DEBUG = true;
	private final String TAG_NAME = "JSONController";
	private String mName = null;
	private ITCPClient mTCPClient = null;
	private int mMaxPackageId = 0;
	private int mMinPackageId = 0;
	private int mPackageId = 0;
    private JSONControllerCallback mCallback;
	private volatile boolean mStopListening = false; // indicates stop listening
														// intension
	private volatile boolean mListeningIsStoped = false; // indicates stop
															// listening action
	protected HashMap<Integer, String> mWaitResponseQueue; // map of <ID,METHOD>
															// to recognize
															// responses
	protected String mRequestResponse = null;
	protected JSONParser mJSONParser;

	protected void sendResponse(int id, String result) {
		mJSONParser.putEmptyJSONRPCObject();
		String jsonMsg = mJSONParser.createJSONResponse(id, result);
		logMsg("id = " + String.valueOf(id) + "; msg = " + jsonMsg);
		sendJSONMsg(jsonMsg);
	}

	protected void removeFromResponseQueue(int key) {
		mWaitResponseQueue.remove(key);
	}

	protected void sendJSONMsg(String jsonMsg) {
        try {
            mTCPClient.sendMsg(jsonMsg);
            logMsg(" JSON message sent: " + jsonMsg);
        } catch (IOException e) {
            e.printStackTrace();
        }
	}

	/**
	 * Process incoming RPC request
	 * 
	 * @param request
	 *            : JSON request as a string
	 */
	protected void processRequest(String request) {
	}

	/**
	 * Process incoming RPC notification
	 * 
	 * @param notification
	 *            : JSON notification as a string
	 * 
	 * @return JSON object result as a string or null if it was a notification
	 */
	protected String processNotification(String notification) {
		return null;
	}

	protected boolean processRegistrationResponse(String response) {
		mJSONParser.putJSONObject(response);
		// if it is a registration response
		String method = mWaitResponseQueue.get(mJSONParser.getId());
		// get method name without component name
		if (method != null) {
			// get method name without component name
			method = method.substring(method.indexOf(".") + 1, method.length());
			try {
				switch (EMBMethods.valueOf(method)) {
				case registerComponent:
					int minVal = Integer.parseInt(mJSONParser.getResult());
					processRegistrationResponse(minVal);
					return true;
				case unregisterComponent:
					processUnregistrationResponse();
					return true;
				case subscribeTo:
					logMsg("Component subscribed");
					return true;
				case unsubscribeFrom:
					logMsg("Component unsubscribed");
					return true;
				default:
					return false;
				}// switch
			} catch (IllegalArgumentException e) {
				// its not a MB method
				return false;
			}
		}
		return false;

	}

	/**
	 * Process response on RPC request of the controller
	 * 
	 * @param response
	 *            : JSON response as a string
	 */
	protected void processResponse(String response) {
	}

	private int getPackageId() {
		if (++mPackageId > mMaxPackageId)
			mPackageId = mMinPackageId;
		return mPackageId;
	}

	protected void subscribeTo(String propertyName) {
		String method = RPCConst.CN_MESSAGE_BROKER + "."
				+ EMBMethods.subscribeTo.toString();
		JSONObject jsonParams = new JSONObject();
		try {
			jsonParams.put("propertyName", propertyName);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		sendRequest(method, jsonParams.toString());
	}

	protected void unsubscribeFrom(String propertyName) {
		String method = RPCConst.CN_MESSAGE_BROKER + "."
				+ EMBMethods.unsubscribeFrom.toString();
		JSONObject jsonParams = new JSONObject();
		try {
			jsonParams.put("propertyName", propertyName);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		sendRequest(method, jsonParams.toString());
	}

	protected void subscribeToProperties() {
		// should be overwritten for each component, that want to subscribe to
	}

	// ==============================================================================

	private void processServerMsg(String msg) {
		mJSONParser.putJSONObject(msg);
		// check if it is a json-rpc 2.0
		String version = mJSONParser.getJSONVersion();
		if (version.compareTo(RPCConst.TAG_JSONRPC_VERSION_VALUE) == 0) {
			if (mJSONParser.getId() < 0)
				processNotification(msg);
			else if (mJSONParser.getMethod() != null)
				processRequest(msg);
			else {
				processResponse(msg);
				removeFromResponseQueue(mJSONParser.getId());
			}
		} else
			logMsg("Received message is not JSON message");
	}

	private void processRegistrationResponse(int minVal) {
		try {
			mMinPackageId = minVal;
			mMaxPackageId = mMinPackageId + RPCConst.ID_RANGE;
			mPackageId = mMinPackageId;

            if (mCallback != null) {
                mCallback.onRegister();
            }

			subscribeToProperties();
		} catch (NumberFormatException e) {
			e.printStackTrace();
		} catch (IOException e) {
            if (mCallback != null) {
                mCallback.onError(e.getMessage());
            }
        }
    }

	private void processUnregistrationResponse() {
		mMinPackageId = 0;
		mMaxPackageId = 0;
		mPackageId = 0;
	}

	private void listenSocket() {
		// start listening in new thread
		Thread socketListenerThread = new Thread(new Runnable() {

			public void run() {
				logMsg("Start reading input buffer");
				while (!mStopListening) {
					try {
						Thread.sleep(100);
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
                    String serverMsg = null;

                    // TODO: Reconsider this case
                    try {
                        serverMsg = mTCPClient.receiveMsg();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }

                    if (serverMsg != null)
						processServerMsg(serverMsg);
				}
				mListeningIsStoped = true;
			}// run()
		});// new Thread
		socketListenerThread.setName("ClientListenerThread");
		socketListenerThread.setPriority(Thread.MIN_PRIORITY);
		socketListenerThread.start();
	}

	private void logMsg(String msg) {
		if (DEBUG && Const.DEBUG) {
			Log.i(TAG_NAME, msg);
		}
	}

}
