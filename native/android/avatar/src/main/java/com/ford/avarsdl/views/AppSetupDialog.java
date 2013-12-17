package com.ford.avarsdl.views;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.DialogFragment;
import android.bluetooth.BluetoothAdapter;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.View;
import android.widget.EditText;
import android.widget.RadioGroup;

import com.ford.avarsdl.R;
import com.ford.avarsdl.service.SDLService;
import com.ford.avarsdl.util.Const;
import com.ford.avarsdl.util.Logger;

/**
 * Created with Android Studio.
 * Author: Chernyshov Yuriy - Mobile Development
 * Date: 11/28/13
 * Time: 4:11 PM
 */
public class AppSetupDialog extends DialogFragment {

    private static final String TITLE_KEY = "dialog_title";
    private static final int REQUEST_ENABLE_BT = 100;
    private boolean isDeviceSupportBluetooth = false;
    private boolean isBluetoothEnabled = false;

    public static AppSetupDialog newInstance(int title) {
        AppSetupDialog appSetupDialog = new AppSetupDialog();
        Bundle bundle = new Bundle();
        bundle.putInt(TITLE_KEY, title);
        appSetupDialog.setArguments(bundle);
        return appSetupDialog;
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        /*if (resultCode == Activity.RESULT_CANCELED && requestCode == REQUEST_ENABLE_BT) {
            SafeToast.showToastAnyThread(getString(R.string.bluetooth_not_enabled));
            return;
        }*/
        if (resultCode == Activity.RESULT_OK && requestCode == REQUEST_ENABLE_BT) {
            processBluetoothEnabledOnDevice();
        }
    }

    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        int title = getArguments().getInt(TITLE_KEY);
        View dialogView = getActivity().getLayoutInflater().inflate(R.layout.sdl_settings, null);
        final EditText ipAddressText = (EditText) dialogView.findViewById(R.id.sdl_ipAddr);
        final EditText tcpPortText = (EditText) dialogView.findViewById(R.id.sdl_tcpPort);
        final RadioGroup transportGroup =
                (RadioGroup) dialogView.findViewById(R.id.selectprotocol_radioGroupTransport);

        ipAddressText.setEnabled(false);
        tcpPortText.setEnabled(false);

        final SharedPreferences prefs = getActivity().getSharedPreferences(Const.PREFS_NAME, 0);
        String ipAddressString = prefs.getString(Const.PREFS_KEY_IPADDR, Const.PREFS_DEFAULT_IPADDR);
        int tcpPortInt = prefs.getInt(Const.PREFS_KEY_TCPPORT, Const.PREFS_DEFAULT_TCPPORT);
        final int[] transportType = {prefs.getInt(
                Const.PREFS_KEY_TRANSPORT_TYPE,
                Const.PREFS_DEFAULT_TRANSPORT_TYPE)};

        ipAddressText.setText(ipAddressString);
        tcpPortText.setText(String.valueOf(tcpPortInt));

        transportGroup.check(transportType[0] == Const.KEY_TCP ? R.id.selectprotocol_radioWiFi :
                R.id.selectprotocol_radioBT);
        transportGroup
                .setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
                    @Override
                    public void onCheckedChanged(RadioGroup group, int checkedId) {
                        boolean isWiFiEnabled = checkedId == R.id.selectprotocol_radioWiFi;
                        ipAddressText.setEnabled(isWiFiEnabled);
                        tcpPortText.setEnabled(isWiFiEnabled);
                        if (!isWiFiEnabled) {
                            transportType[0] = Const.KEY_BLUETOOTH;
                            processBluetoothEnabledOnDevice();
                        } else {
                            transportType[0] = Const.KEY_TCP;
                        }
                    }
                });

        if (transportType[0] == Const.KEY_BLUETOOTH) {
            processBluetoothEnabledOnDevice();
        }

        return new AlertDialog.Builder(getActivity())
                .setTitle(title)
                .setCancelable(false)
                .setPositiveButton(android.R.string.ok,
                        new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                if (transportType[0] == Const.KEY_BLUETOOTH &&
                                        !isDeviceSupportBluetooth) {
                                    SafeToast.showToastAnyThread(getString(
                                            R.string.bluetooth_not_supported));
                                    return;
                                }

                                if (transportType[0] == Const.KEY_BLUETOOTH &&
                                        !isBluetoothEnabled) {
                                    SafeToast.showToastAnyThread(getString(
                                            R.string.bluetooth_not_enabled));
                                    return;
                                }

                                String ipAddressString = ipAddressText.getText().toString();
                                int tcpPortInt;
                                try {
                                    tcpPortInt = Integer.parseInt(tcpPortText.getText().toString());
                                } catch (NumberFormatException e) {
                                    Logger.i("Couldn't parse port number", e);
                                    tcpPortInt = Const.PREFS_DEFAULT_TCPPORT;
                                }
                                int transportType = transportGroup.getCheckedRadioButtonId() ==
                                        R.id.selectprotocol_radioWiFi ? Const.KEY_TCP :
                                        Const.KEY_BLUETOOTH;

                                SharedPreferences.Editor prefsEditor =
                                        getActivity().getSharedPreferences(Const.PREFS_NAME, 0).edit();
                                prefsEditor.putString(Const.PREFS_KEY_IPADDR, ipAddressString);
                                prefsEditor.putInt(Const.PREFS_KEY_TCPPORT, tcpPortInt);
                                prefsEditor.putInt(Const.PREFS_KEY_TRANSPORT_TYPE, transportType);
                                prefsEditor.commit();

                                Intent intent = new Intent(getActivity().getApplicationContext(),
                                        SDLService.class);
                                getActivity().startService(intent);
                            }
                        }
                )
                .setView(dialogView)
                .create();
    }

    private void processBluetoothEnabledOnDevice() {
        BluetoothAdapter mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        if (mBluetoothAdapter == null) {
            // Bluetooth is not supported by device
            isDeviceSupportBluetooth = false;
        } else {
            isDeviceSupportBluetooth = true;
            if (!mBluetoothAdapter.isEnabled()) {
                // Bluetooth is not enable
                Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
                startActivityForResult(enableBtIntent, REQUEST_ENABLE_BT);
            } else {
                isBluetoothEnabled = true;
            }
        }
    }
}