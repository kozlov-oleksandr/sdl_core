package com.ford.avarsdl.requests;

import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import android.util.Log;

import com.ford.avarsdl.business.MainApp;
import com.ford.avarsdl.responses.GetNativeLocalPresetsResponse;
import com.ford.avarsdl.responses.ResponseCommand;
import com.ford.avarsdl.util.Const;
import com.ford.avarsdl.util.Logger;

import org.apache.commons.lang.StringUtils;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;

/**
 * Created with Android Studio.
 * Author: Chernyshov Yuriy - Mobile Development
 * Date: 12/6/13
 * Time: 1:04 PM
 */
public class GetNativeLocalPresetsCommand implements RequestCommand {

    @Override
    public void execute(int id, JSONObject jsonParameters) {
        SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(
                MainApp.getInstance());
        String presetsValue = sharedPreferences.getString(Const.SHARED_PREF_NATIVE_LOCAL_PRESETS,
                Const.DEFAULT_RADIO_STATIONS_PRESETS);
        if (StringUtils.isNotEmpty(presetsValue)) {
            JSONObject jsonObject = new JSONObject();
            try {
                JSONArray jsonArray = new JSONArray(presetsValue);
                jsonObject.put(Const.JSON_KEY_CUSTOM_PRESETS, jsonArray);

                ResponseCommand command = new GetNativeLocalPresetsResponse();
                command.execute(id, jsonObject.toString());
            } catch (JSONException e) {
                Logger.e(getClass().getSimpleName() + " execute JSONException", e);
            } catch (IOException e) {
                Logger.e(getClass().getSimpleName() + " execute IOException", e);
            }
        }
    }
}