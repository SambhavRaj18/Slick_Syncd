/*
 * Slick Sync - Final Stable Firmware
 * Logic: Floating/High-Impedance for 5V Relay Compatibility
 */

#define RELAY_1 14  // D5 - Rock
#define RELAY_2 12  // D6 - Moon
#define RELAY_3 13  // D7 - Dog
#define RELAY_4 5   // D1 - Fan

void setRelayState(int pin, bool isOn) {
  if (isOn) {
    // To turn ON: Pull to GND
    pinMode(pin, OUTPUT);
    digitalWrite(pin, LOW);
  } else {
    // To turn OFF: Let it float (High Impedance)
    // This allows the relay's internal 5V to take over
    pinMode(pin, INPUT);
  }
}

void setup() {
  Serial.begin(9600); // Matches Python's speed
  
  // Initialize all as OFF (Input mode)
  setRelayState(RELAY_1, false);
  setRelayState(RELAY_2, false);
  setRelayState(RELAY_3, false);
  setRelayState(RELAY_4, false);
  
  Serial.println("Slick Sync Ready. Floating-Logic Active.");
}

void loop() {
  if (Serial.available() > 0) {
    String command = Serial.readStringUntil('\n');
    command.trim();
    
    if (command.length() >= 2) {
      char device = command[0]; // A, B, C, or D
      char state = command[1];  // 1 (ON) or 0 (OFF)
      
      int targetPin = -1;
      String deviceName = "";

      if (device == 'A') { targetPin = RELAY_1; deviceName = "Rock"; }
      else if (device == 'B') { targetPin = RELAY_2; deviceName = "Moon"; }
      else if (device == 'C') { targetPin = RELAY_3; deviceName = "Dog"; }
      else if (device == 'D') { targetPin = RELAY_4; deviceName = "Fan"; }

      if (targetPin != -1) {
        bool turnOn = (state == '1');
        setRelayState(targetPin, turnOn);
        
        Serial.print(deviceName); 
        Serial.println(turnOn ? " ON" : " OFF");
      }
    }
  }
}
