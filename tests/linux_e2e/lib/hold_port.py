#!/usr/bin/env python3
"""Occupies TCP+UDP <port> on 0.0.0.0 (forces a LAN Link start failure: "address already in use"). Usage: hold_port.py <port>; kill it to free the port."""
import socket, sys, time
p = int(sys.argv[1]); s = []
for t in (socket.SOCK_STREAM, socket.SOCK_DGRAM):
    k = socket.socket(socket.AF_INET, t); k.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 0); k.bind(("0.0.0.0", p)); s.append(k)
    if t == socket.SOCK_STREAM: k.listen(5)
time.sleep(10**6)
