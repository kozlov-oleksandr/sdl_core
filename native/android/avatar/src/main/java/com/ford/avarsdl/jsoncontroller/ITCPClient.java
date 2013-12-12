package com.ford.avarsdl.jsoncontroller;

import java.io.IOException;
import java.net.SocketAddress;

public interface ITCPClient {
	public void sendMsg(String msg) throws IOException;
	public String receiveMsg() throws IOException;
	public void connect(SocketAddress socketAddress) throws IOException;
	public void disconnect() throws IOException;
    public boolean isConnected();
}