package com.ford.avarsdl.jsoncontroller;

import com.ford.avarsdl.requests.RequestCommand;
import com.ford.avarsdl.requests.SetNativeLocalPresetsCommand;
import com.ford.avarsdl.views.AvatarActivity;
import com.ford.avarsdl.util.Logger;
import com.ford.avarsdl.util.RPCConst;

import java.io.IOException;
import java.util.Hashtable;

public class JSONAVAController extends JSONController {

    private final Hashtable<String, RequestCommand> commandsHashTable =
            new Hashtable<String, RequestCommand>();
    private String mJSComponentName = null;
    private AvatarActivity mActivity;

    public JSONAVAController(AvatarActivity activity, String cname) throws IOException {
        super(RPCConst.CN_AVATAR);
        mActivity = activity;
        mJSComponentName = cname;
    }

    public JSONAVAController(String cname, ITCPClient client) throws IOException {
        super(RPCConst.CN_AVATAR, client);
        mJSComponentName = cname;
    }

    protected void processRequest(String request) {
        processNotification(request);
    }

    protected String processNotification(String notification) {
        Logger.d(getClass().getSimpleName() + " Process notification: " + notification);
        mJSONParser.putJSONObject(notification);
        final String func = "FFW.WebSocketSimulator.receive('" + mJSComponentName
                + "','" + notification + "')";
        Logger.d(getClass().getSimpleName() + " Send notification to JS");
        mActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                mActivity.getWebView().loadUrl("javascript:" + func);
            }
        });
        return null;
    }

    protected void processResponse(String response) {
        if (!processRegistrationResponse(response)) {
            final String func = "FFW.WebSocketSimulator.receive('" + mJSComponentName
                    + "','" + response + "')";
            Logger.d(getClass().getSimpleName() + " : " + func);
            mActivity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    mActivity.getWebView().loadUrl("javascript:" + func);
                }
            });
        }
    }

    public void sendJSMessage(String cName, String jsonMsg) {
        Logger.d(getClass().getSimpleName() + " SendJSMessage : " + jsonMsg);
        mJSONParser.putJSONObject(jsonMsg);
        if (mJSONParser.getId() >= 0 &&
                mJSONParser.getResult() == null &&
                mJSONParser.getError() == null) {
            mJSComponentName = cName;
        }

        String method = mJSONParser.getMethod();
        method = method.substring(method.indexOf('.') + 1, method.length());
        RequestCommand requestCommand = commandsHashTable.get(method);
        if (requestCommand != null) {
            requestCommand.execute(mJSONParser.getId(), mJSONParser.getParams());
        } /*else {
            Logger.w(getClass().getSimpleName() + " unknown request: " + method);
        }*/

        jsonMsg += System.getProperty("line.separator");
        sendJSONMsg(jsonMsg);
    }

    private void initializeCommandsTable() {
        SetNativeLocalPresetsCommand setNativeLocalPresetsCommand = new SetNativeLocalPresetsCommand();
        commandsHashTable.put(RPCConst.SetNativeLocalPresets, setNativeLocalPresetsCommand);
    }
}