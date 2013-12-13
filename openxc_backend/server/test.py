import os
import sys
import fcntl
import subprocess
from threading import Thread


def non_block_read(output):
    fd = output.fileno()
    fl = fcntl.fcntl(fd, fcntl.F_GETFL)
    fcntl.fcntl(fd, fcntl.F_SETFL, fl | os.O_NONBLOCK)
    try:
        line = output.read()
        print line
        return line
    except:
        return ''


def log_worker(args):
    while True:
        output = non_block_read(args).strip()
        if output:
            print output

if __name__ == '__main__':

    process = subprocess.Popen(
        ['openxc-dump'],
        stdin=sys.stdin,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE)

    thread = Thread(target=log_worker, args=[process.stdout])
    thread.daemon = True
    thread.start()

    process.wait()
    thread.join(timeout=1)