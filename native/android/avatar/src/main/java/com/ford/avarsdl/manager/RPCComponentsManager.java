package com.ford.avarsdl.manager;

import android.util.Log;

import com.ford.avarsdl.jsoncontroller.JSONBackendController;
import com.ford.avarsdl.jsoncontroller.JSONController;
import com.ford.avarsdl.jsoncontroller.JSONRateController;
import com.ford.avarsdl.jsoncontroller.JSONRevSDLController;
import com.ford.avarsdl.jsoncontroller.JSONVideoController;
import com.ford.avarsdl.jsonserver.JSONServer;
import com.ford.avarsdl.rater.AppRater;
import com.ford.avarsdl.views.AvatarActivity;

import java.io.IOException;

/**
 * Created with Android Studio.
 * Author: Chernyshov Yuriy - Mobile Development
 * Date: 12/9/13
 * Time: 12:27 PM
 */
public class RPCComponentsManager {

    public static interface RPCComponentsManagerCallback {
        void onComplete();
        void onError(String message);
    }

    private static final String TAG = "RPCComponentsManager";

    private RPCComponentsManagerCallback mCallback;
    private AvatarActivity mAvatarActivity;
    private AppRater mAppRater;
    private JSONServer mServerThread;
    private JSONBackendController mBackendController;
    private JSONVideoController mVideoController;
    private JSONRateController mRateController;
    private JSONRevSDLController mRevSDLController;

    public RPCComponentsManager() {

    }

    public void setCallback(RPCComponentsManagerCallback mCallback) {
        this.mCallback = mCallback;
    }

    public void init(AvatarActivity context) {

        // TODO: Temporary solution until RPCComponentsManager will be set in Service
        close();

        if (mCallback == null) {
            throw new NullPointerException("RPCComponentsManager -> RPCComponentsManagerCallback" +
                    "must be set before call 'init()'");
        }

        mAvatarActivity = context;
        mAppRater = new AppRater(mAvatarActivity);

        mServerThread = new JSONServer();
        mServerThread.setName("ServerThread");
        mServerThread.setCallback(new JSONServer.JSONServerCallback() {
            @Override
            public void onComplete() throws IOException {
                startBackendController();
            }

            @Override
            public void onError(String message) {
                mCallback.onError("JSONServer " + message);
            }
        });
        mServerThread.start();
    }

    public boolean close() {
        try {
            if (mServerThread != null) {
                mServerThread.close();
                mServerThread = null;
            }
            if (mBackendController != null) {
                mBackendController.close();
                mBackendController = null;
            }
            if (mVideoController != null) {
                mVideoController.close();
                mVideoController = null;
            }
            if (mRateController != null) {
                mRateController.close();
                mRateController = null;
            }
            return true;
        } catch (IOException e) {
            Log.e(TAG, "Close: " + e.getMessage());
            return false;
        }
    }

    public void setVideoControllerDuration(int value) {
        if (mVideoController != null) {
            mVideoController.setVideoDuration(value);
        }
    }

    /**
     * TODO: Reconsider this method, it is bad practise to return an object
     * @return
     */
    public JSONBackendController getBackendController() {
        return mBackendController;
    }

    public void sendPositionNotificationToVideoController(int value) {
        if (mVideoController != null) {
            mVideoController.sendPositionNotification(value);
        }
    }

    private void startBackendController() throws IOException {
        Log.i(TAG, "Start Backend controller");
        mBackendController = new JSONBackendController(mAvatarActivity);
        mBackendController.setCallback(new JSONController.JSONControllerCallback() {
            @Override
            public void onRegister() throws IOException {
                startVideoController();
            }

            @Override
            public void onError(String message) {
                mCallback.onError("Backend controller " + message);
            }
        });
        mBackendController.register(27);
    }

    private void startVideoController() throws IOException {
        Log.i(TAG, "Start Video controller");
        mVideoController = new JSONVideoController(mAvatarActivity);
        mVideoController.setCallback(new JSONController.JSONControllerCallback() {
            @Override
            public void onRegister() throws IOException {
                startRateController();
            }

            @Override
            public void onError(String message) {
                mCallback.onError("Video controller" + message);
            }
        });
        mVideoController.register(28);
    }

    private void startRateController() throws IOException {
        Log.i(TAG, "Start Rate controller");
        mRateController = new JSONRateController(mAppRater);
        mRateController.setCallback(new JSONController.JSONControllerCallback() {
            @Override
            public void onRegister() throws IOException {
                startRevSDLController();
            }

            @Override
            public void onError(String message) {
                mCallback.onError("Rate controller" + message);
            }
        });
        mRateController.register(29);
    }

    private void startRevSDLController() throws IOException {
        Log.i(TAG, "Start RevSDL controller");
        mRevSDLController = new JSONRevSDLController();
        mRevSDLController.setCallback(new JSONController.JSONControllerCallback() {
            @Override
            public void onRegister() throws IOException {
                mCallback.onComplete();
            }

            @Override
            public void onError(String message) {
                mCallback.onError("RevSDL controller" + message);
            }
        });
        mRevSDLController.register(30);
    }
}