/*
 * Slick Sync 4-Device Setup (3 Relays + 1 Fan/DC Control)
 */

#define RELAY_1 14  // D5 - Rock
#define RELAY_2 12  // D6 - Moon
#define RELAY_3 13  // D7 - Dog
#define FAN_PIN 5   // D1 - Fan (Changed from D8)

void setup() {
  Serial.begin(9600);
  
  pinMode(RELAY_1, OUTPUT); digitalWrite(RELAY_1, LOW); 
  pinMode(RELAY_2, OUTPUT); digitalWrite(RELAY_2, LOW); 
  pinMode(RELAY_3, OUTPUT); digitalWrite(RELAY_3, LOW); 
  pinMode(FAN_PIN, OUTPUT); digitalWrite(FAN_PIN, LOW); // Default OFF
  
  Serial.println("Slick Sync Ready. 4-Device Control Active (Active-HIGH).");
}

void loop() {
  if (Serial.available() > 0) {
    String command = Serial.readStringUntil('\n');
    command.trim();
    
    if (command.length() > 0) {
      // ROCK (A)
      if (command == "A1") {
        digitalWrite(RELAY_1, HIGH); Serial.println("Rock ON");
      } else if (command == "A0") {
        digitalWrite(RELAY_1, LOW); Serial.println("Rock OFF");
      }
      
      // MOON (B)
      else if (command == "B1") {
        digitalWrite(RELAY_2, HIGH); Serial.println("Moon ON");
      } else if (command == "B0") {
        digitalWrite(RELAY_2, LOW); Serial.println("Moon OFF");
      }
      
      // DOG (C)
      else if (command == "C1") {
        digitalWrite(RELAY_3, HIGH); Serial.println("Dog ON");
      } else if (command == "C0") {
        digitalWrite(RELAY_3, LOW); Serial.println("Dog OFF");
      }

      // FAN (D)
      else if (command == "D1") {
        digitalWrite(FAN_PIN, HIGH); Serial.println("Fan ON");
      } else if (command == "D0") {
        digitalWrite(FAN_PIN, LOW); Serial.println("Fan OFF");
      }
    }
  }
}
