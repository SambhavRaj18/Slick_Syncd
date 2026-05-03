// File: relay_test_floating.ino
const int RELAY_PIN = 14; // D5
const int LED_PIN = 2;    // On-board LED (D4)

void setup() {
  Serial.begin(115200);
  pinMode(LED_PIN, OUTPUT);
  Serial.println("\n--- Floating Logic Test Started ---");
}

void loop() {
  // 1. FORCE ON (Pull to Ground)
  Serial.println("Relay ON (Pulling to GND)");
  digitalWrite(LED_PIN, LOW); // LED ON
  pinMode(RELAY_PIN, OUTPUT);
  digitalWrite(RELAY_PIN, LOW); 
  delay(2000);
  
  // 2. FORCE OFF (Let it Float to 5V)
  Serial.println("Relay OFF (Floating/Input Mode)");
  digitalWrite(LED_PIN, HIGH); // LED OFF
  pinMode(RELAY_PIN, INPUT); // This "lets go" of the pin so the relay sees its own 5V
  delay(2000);
}
