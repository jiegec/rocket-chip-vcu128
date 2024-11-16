#!/usr/bin/env python3

import sys
import os
import struct
import serial
import select
import time
import getopt
import tqdm

try:
    optlist, args = getopt.getopt(sys.argv[1:], 's')

    timeout = 0.01
    n = 1024
    slow = False

    for o, a in optlist:
        if o == "-s":
            slow = True
            n = 16
            print('Running in slow mode')

    out = serial.Serial(args[1], 115200, timeout=timeout)

    size = os.path.getsize(args[0])
    out.write(struct.pack('>I', size))
    with open(args[0], 'rb') as f:
        data = f.read()
        for i in tqdm.tqdm(range(0, len(data), n)):
            out.write(data[i:i+n])
            if slow:
                time.sleep(timeout)

    out.close()
    os.execlp('screen', 'screen', '-L', args[1], '115200')
except getopt.GetoptError as err:
    print(str(err))
    print('Usage: send.py [-s] file tty')
