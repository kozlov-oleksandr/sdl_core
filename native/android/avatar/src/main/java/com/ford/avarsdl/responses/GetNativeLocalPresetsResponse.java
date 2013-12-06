package com.ford.avarsdl.responses;

import com.ford.avarsdl.jsoncontroller.JSONController;
import com.ford.avarsdl.util.Logger;
import com.ford.avarsdl.util.RPCConst;

/**
 * Created with Android Studio.
 * Author: Chernyshov Yuriy - Mobile Development
 * Date: 12/6/13
 * Time: 2:49 PM
 */
public class GetNativeLocalPresetsResponse extends JSONController implements ResponseCommand {

    public GetNativeLocalPresetsResponse() {
        super(RPCConst.CN_REVSDL);
    }

    @Override
    public void execute(int id, String result) {
        Logger.d(getClass().getSimpleName() + " id: " + id + ", result: " + result);
        sendResponse(id, result);
    }
}