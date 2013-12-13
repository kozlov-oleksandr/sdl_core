package com.ford.avarsdl.requests;

import android.content.SharedPreferences;
import android.preference.PreferenceManager;

import com.ford.avarsdl.business.MainApp;
import com.ford.avarsdl.util.Const;
import com.ford.avarsdl.util.Logger;

import org.apache.commons.lang.StringUtils;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * Created with Android Studio.
 * Author: Chernyshov Yuriy - Mobile Development
 * Date: 12/6/13
 * Time: 1:04 PM
 */
public class SetNativeLocalPresetsCommand implements RequestCommand {

    @Override
    public void execute(int id, JSONObject jsonParameters) {
        String presetsValue = "";
        try {
            presetsValue = jsonParameters.get(Const.JSON_KEY_CUSTOM_PRESETS).toString();
        } catch (JSONException e) {
            Logger.e(getClass().getSimpleName() + " execute", e);
        }

        if (StringUtils.isEmpty(presetsValue)) {
            Logger.w(getClass().getSimpleName() + " can not get presets from parameters");
            return;
        }

        SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(
                MainApp.getInstance());
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(Const.SHARED_PREF_NATIVE_LOCAL_PRESETS, presetsValue);
        editor.commit();

        Logger.i(getClass().getSimpleName() + " Presets: " + presetsValue + "" +
                "are successfully stored");
    }
}