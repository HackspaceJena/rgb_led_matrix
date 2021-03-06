#include <SPI.h>
#include <Ethernet.h>
#include <EthernetUdp.h>
#include "Adafruit_NeoPixel.h"

#define PIN 6
#define WIDTH 16
#define HEIGHT 16

#define UDP_PACKET_MAX_SIZE 768
#define PIXEL_OFFSET 0x80

// Parameter 1 = number of pixels in strip
// Parameter 2 = pin number (most are valid)
// Parameter 3 = pixel type flags, add together as needed:
//   NEO_RGB     Pixels are wired for RGB bitstream
//   NEO_GRB     Pixels are wired for GRB bitstream
//   NEO_KHZ400  400 KHz bitstream (e.g. FLORA pixels)
//   NEO_KHZ800  800 KHz bitstream (e.g. High Density LED strip)
Adafruit_NeoPixel strip = Adafruit_NeoPixel(WIDTH * HEIGHT, PIN, NEO_GRB + NEO_KHZ800);

// Network configuration
byte mac[] = {0xFE, 0xED, 0x0D, 0xA0, 0x1E, 0xD5};
IPAddress ip(172, 22, 239, 182);
unsigned int localPort = 8888;

// buffers for receiving and sending data
char packetBuffer[UDP_PACKET_MAX_SIZE]; // buffer to hold incoming packet

// Create EthernetUDP instance to send and receive packets over UDP
EthernetUDP Udp;

void setup() {
  // initialize ethernet device
  Ethernet.begin(mac, ip);
  // Start UDP
  Udp.begin(localPort);
  strip.begin();  
  // Initialize all pixels to 'off'
  for (int i=0; i<256; i++) {
    strip.setPixelColor(i, strip.Color(0, 0, 0));
  }
  strip.show();
}

void loop() {
  // if there is data available, read a packet
  int packetSize = Udp.parsePacket();

  if (packetSize) {
    // read the packet into packet buffer
    Udp.read(packetBuffer, UDP_PACKET_MAX_SIZE);
    
    for (int i = 0; i < packetSize; i = i + 3) {
      strip.setPixelColor(i / 3, packetBuffer[i+2], packetBuffer[i+1], packetBuffer[i]);
    }
    strip.show();
  }
}

