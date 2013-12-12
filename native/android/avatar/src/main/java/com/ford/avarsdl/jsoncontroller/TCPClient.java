package com.ford.avarsdl.jsoncontroller;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.Socket;
import java.net.SocketAddress;

public class TCPClient implements ITCPClient {

    private static final int TIMEOUT = 0;
    private Socket mSocket = null;
    private BufferedReader mSocketReader = null;
    private BufferedWriter mSocketWriter = null;

	public TCPClient() {
		mSocket = new Socket();
	}
	
	@Override
	public void connect(SocketAddress socketAddress) throws IOException {
        mSocket.setTcpNoDelay(true);
        mSocket.connect(socketAddress, TIMEOUT);
        mSocketReader = new BufferedReader(new InputStreamReader(mSocket.getInputStream()));
        mSocketWriter = new BufferedWriter(new OutputStreamWriter(mSocket.getOutputStream()));
	}

	@Override
	public void sendMsg(String msg) throws IOException {
        mSocketWriter.write(msg);
        mSocketWriter.flush();
	}

	@Override
	public String receiveMsg() throws IOException {
		String response = null;
        if (mSocketReader.ready()) {
            response = mSocketReader.readLine();
        }
		return response;
	}

	@Override
	public void disconnect() throws IOException {
		mSocketReader.close();
        mSocketWriter.close();
        mSocket.close();
	}

    @Override
    public boolean isConnected() {
        return mSocket.isConnected();
    }
}