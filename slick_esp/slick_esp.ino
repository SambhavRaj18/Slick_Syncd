/*
 * Slick Sync 3-Relay Setup (Standard Active-Low Logic)
 */

#define RELAY_1 14  // D5
#define RELAY_2 12  // D6
#define RELAY_3 13  // D7

void setup() {
  Serial.begin(9600);
  
  // Most relays are Active-Low (LOW = ON, HIGH = OFF)
  pinMode(RELAY_1, OUTPUT); digitalWrite(RELAY_1, HIGH); 
  pinMode(RELAY_2, OUTPUT); digitalWrite(RELAY_2, HIGH); 
  pinMode(RELAY_3, OUTPUT); digitalWrite(RELAY_3, HIGH); 
  
  Serial.println("Slick Sync Ready. Listening for commands...");
}

void loop() {
  if (Serial.available() > 0) {
    String command = Serial.readStringUntil('\n');
    command.trim();
    
    if (command.length() > 0) {
      // BULB 1
      if (command == "A1") {
        digitalWrite(RELAY_1, LOW); // ON
        Serial.println("Bulb 1 ON");
      } else if (command == "A0") {
        digitalWrite(RELAY_1, HIGH); // OFF
        Serial.println("Bulb 1 OFF");
      }
      
      // BULB 2
      else if (command == "B1") {
        digitalWrite(RELAY_2, LOW); // ON
        Serial.println("Bulb 2 ON");
      } else if (command == "B0") {
        digitalWrite(RELAY_2, HIGH); // OFF
        Serial.println("Bulb 2 OFF");
      }
      
      // BULB 3
      else if (command == "C1") {
        digitalWrite(RELAY_3, LOW); // ON
        Serial.println("Bulb 3 ON");
      } else if (command == "C0") {
        digitalWrite(RELAY_3, HIGH); // OFF
        Serial.println("Bulb 3 OFF");
      }
    }
  }
}
