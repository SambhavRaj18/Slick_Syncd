/*
 * Slick Sync 3-Relay Setup (NC Wiring Logic)
 * 
 * Pins:
 * Bulb 1 -> D5 (GPIO 14)
 * Bulb 2 -> D6 (GPIO 12)
 * Bulb 3 -> D7 (GPIO 13)
 */

#define RELAY_1 14  // D5
#define RELAY_2 12  // D6
#define RELAY_3 13  // D7

void turnRelayOn(int pin) {
  // Normally Closed (NC) hack: UN-ENERGIZE to let electricity flow through
  pinMode(pin, INPUT);
}

void turnRelayOff(int pin) {
  // Normally Closed (NC) hack: ENERGIZE the relay to break the connection
  pinMode(pin, OUTPUT);
  digitalWrite(pin, LOW);
}

void setup() {
  Serial.begin(9600);
  
  turnRelayOff(RELAY_1); 
  turnRelayOff(RELAY_2); 
  turnRelayOff(RELAY_3); 
  
  Serial.println("Slick Sync Ready. Listening for 3 Bulbs...");
}

void loop() {
  if (Serial.available() > 0) {
    String command = Serial.readStringUntil('\n');
    command.trim();
    
    if (command.length() > 0) {
      
      // BULB 1 (A1/A0 or Keyboard 1/0)
      if (command == "A1" || command == "1") {
        turnRelayOn(RELAY_1);
        Serial.println("Bulb 1 ON");
      } else if (command == "A0" || command == "0") {
        turnRelayOff(RELAY_1);
        Serial.println("Bulb 1 OFF");
      }
      
      // BULB 2 (B1/B0 or Keyboard 2)
      else if (command == "B1" || command == "2") {
        turnRelayOn(RELAY_2);
        Serial.println("Bulb 2 ON");
      } else if (command == "B0") {
        turnRelayOff(RELAY_2);
        Serial.println("Bulb 2 OFF");
      }
      
      // BULB 3 (C1/C0 or Keyboard 3)
      else if (command == "C1" || command == "3") {
        turnRelayOn(RELAY_3);
        Serial.println("Bulb 3 ON");
      } else if (command == "C0") {
        turnRelayOff(RELAY_3);
        Serial.println("Bulb 3 OFF");
      }
    }
  }
}
