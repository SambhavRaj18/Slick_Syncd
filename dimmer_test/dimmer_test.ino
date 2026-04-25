volatile long pulses = 0;

void ICACHE_RAM_ATTR countPulse() {
  pulses++;
}

void setup() {
  Serial.begin(9600);
  pinMode(5, INPUT_PULLUP); // D1
  attachInterrupt(digitalPinToInterrupt(5), countPulse, FALLING);
  Serial.println("Starting Heartbeat Test...");
}

void loop() {
  pulses = 0;
  delay(1000); // Wait 1 second
  Serial.print("AC Heartbeat pulses detected: ");
  Serial.println(pulses);
  
  if (pulses == 0) {
    Serial.println("Verdict: The Zero-Cross sensor is DEAD.");
  } else {
    Serial.println("Verdict: IT'S ALIVE! The sensor is working.");
  }
}
