

import sys
import socket
import pygame
import numpy as np
import binascii

pygame.init()

screen = pygame.display.set_mode((320, 320))

UDP_IP = "127.0.0.1"
UDP_PORT = 8888

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind((UDP_IP, UDP_PORT))

while True:
    data, addr = sock.recvfrom(768)
    # strip newline
    print type(data)
    data = data.strip()
    print "received {} bytes from {}:{}".format(len(data), addr[0], addr[1])
    print "received data:"
    r = bytearray(data[2::3])
    g = bytearray(data[1::3])
    b = bytearray(data[0::3])
    for j in range(16):
        for i in range(16):
            if (j*16 + i) < len(r) and (j*16 + i) < len(g) and (j*16 + i) < len(b):
                pygame.draw.circle(screen, pygame.Color(r[16*j+i], g[16*j+i], b[16*j+i]), (i*20+10, 320-j*20-10), 5)
                print "{:s} ".format(binascii.hexlify(bytearray((r[16*j+i], g[16*j+i], b[16*j+i])))),
            else:
                pygame.draw.circle(screen, pygame.Color(30, 30, 30), (i*20+10, 320-j*20-10), 5)
        print ""
    pygame.display.update()
