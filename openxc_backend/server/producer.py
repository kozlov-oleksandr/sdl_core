#!/usr/bin/env python

""" A TLS server that spits out random md5 hashes every half second. """

import os
import socket
import ssl
import sys
from hashlib import md5
import logging
import subprocess
from threading import Thread
import fcntl
from openxc.tools import dump

from tornado.ioloop import IOLoop, PeriodicCallback
from tornado.iostream import PipeIOStream
from tornado.tcpserver import TCPServer
from tornado import options
from tornado.websocket import WebSocketHandler

log = logging.getLogger(__name__)
port = 4443
ssl_options = {
    'ssl_version': ssl.PROTOCOL_TLSv1,
    'certfile': os.path.join(os.path.dirname(__file__), 'server.crt'),
    'keyfile': os.path.join(os.path.dirname(__file__), 'server.key')
}


class RandomServer(TCPServer):
    def handle_stream(self, stream, address):
        SpitRandomStuff(stream, address)


class SpitRandomStuff(object):
    def __init__(self, stream, address):
        log.info('Received connection from %s', address)
        self.address = address
        self.stream = stream
        self.i = 0
        self.stream.set_close_callback(self._on_close)

        mysql_process = subprocess.Popen(
        ['openxc-dump'],
        stdin=sys.stdin,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE)

        thread = Thread(target=self.log_worker, args=[mysql_process.stdout])
        thread.daemon = True
        thread.start()

        mysql_process.wait()
        thread.join(timeout=1)

    def log_worker(self, stdout):
        while True:
            output = stdout.non_block_read(stdout).strip()
            if output:
                print output

    def non_block_read(self, output):
        fd = output.fileno()
        fl = fcntl.fcntl(fd, fcntl.F_GETFL)
        fcntl.fcntl(fd, fcntl.F_SETFL, fl | os.O_NONBLOCK)
        try:
            return output.read()
        except:
            return ''

    def _on_close(self):
        log.info('Closed connection from %s', self.address)
        self.writer.stop()

    def _random_stuff(self):
        #output = os.urandom(60)
        self.i += 1
        self.stream.write(dump.main() + "\n")

if __name__ == '__main__':
    options.parse_command_line()
    server = RandomServer(ssl_options=ssl_options)
    server.listen(port)
    log.info('Listening on port %d...', port)
    # To test from command-line:
    # $ openssl s_client -connect localhost:<port>
    IOLoop.instance().start()