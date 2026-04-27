import cv2
import mediapipe as mp
import time
import numpy as np
import os
import json
from ultralytics import YOLO
import threading
import speech_recognition as sr
import win32com.client  # Direct SAPI5 TTS
import pythoncom # Required for COM in threads
import mediapipe.python.solutions.hands as mp_hands
import mediapipe.python.solutions.drawing_utils as mp_draw
import face_recognition
import serial
from flask import Flask, jsonify    

# Global Serial Variables (Initialized to clear warnings)
ser = None
serial_active = False
serial_lock = threading.Lock()

# Configure Serial Communication with Reconnect Logic
def connect_serial():
    global ser, serial_active
    try:
        if ser is not None and ser.is_open:
            ser.close()
        ser = serial.Serial('COM5', 9600, timeout=1)
        time.sleep(2)
        serial_active = True
        print("\n[SERIAL] Connected to ESP8266 on COM5")
        return True
    except Exception as e:
        serial_active = False
        return False

connect_serial()


def send_command(cmd):
    global serial_active
    if not serial_active:
        if not connect_serial():
            print(f"[SERIAL] Port still blocked. Cannot send: {cmd.strip()}")
            return
        
    with serial_lock:
        try:
            full_cmd = cmd.strip() + "\n"
            ser.write(full_cmd.encode())
            print(f">>> Serial Sent: {full_cmd.strip()}")
            time.sleep(0.05)
        except Exception as e:
            print(f"!!! [SERIAL] Write error: {e} !!!")
            serial_active = False

# Initialize Flask
app = Flask(__name__)

@app.route('/')
def home():
    return "Slick Sync Backend Running"

@app.route('/rock/on')
def rock_on():
    print("API Command: Rock On (A1)")
    send_command("A1")
    return jsonify({"status": "Rock Light On"})

@app.route('/rock/off')
def rock_off():
    print("API Command: Rock Off (A0)")
    send_command("A0")
    return jsonify({"status": "Rock Light Off"})

@app.route('/moon/on')
def moon_on():
    print("API Command: Moon On (B1)")
    send_command("B1")
    return jsonify({"status": "Moon Light On"})

@app.route('/moon/off')
def moon_off():
    print("API Command: Moon Off (B0)")
    send_command("B0")
    return jsonify({"status": "Moon Light Off"})

@app.route('/dog/on')
def dog_on():
    print("API Command: Dog On (C1)")
    send_command("C1")
    return jsonify({"status": "Dog Light On"})

@app.route('/dog/off')
def dog_off():
    print("API Command: Dog Off (C0)")
    send_command("C0")
    return jsonify({"status": "Dog Light Off"})

@app.route('/fan/on')
def fan_on():
    print("API Command: Fan On (D1)")
    send_command("D1")
    return jsonify({"status": "Fan On"})

@app.route('/fan/off')
def fan_off():
    print("API Command: Fan Off (D0)")
    send_command("D0")
    return jsonify({"status": "Fan Off"})

@app.route('/status')
def status():
    return jsonify({"status": "online", "serial_active": serial_active})



# Initialize MediaPipe Hand module
mp_hands = mp.solutions.hands
hands = mp_hands.Hands(
    static_image_mode=False,
    max_num_hands=1,  # Detect up to two hands
    min_detection_confidence=0.7
)
mp_draw = mp.solutions.drawing_utils

# Load known face encodings from directory
known_face_dir = r"D:\projects\Slick_Sync\known_faces"
known_faces = []
for root, _, files in os.walk(known_face_dir):
    for file in files:
        if file.lower().endswith(('.jpg', '.jpeg', '.png')):
            img_path = os.path.join(root, file)
            img = face_recognition.load_image_file(img_path)
            encodings = face_recognition.face_encodings(img)
            if encodings:
                known_faces.append(encodings[0])

# Load YOLOv8 face detection model
yolo_model = YOLO(r'D:\projects\Slick_Sync\face.pt')

# Initialize MediaPipe Face Detection for robust feature tracking
mp_face = mp.solutions.face_detection
face_detection = mp_face.FaceDetection(model_selection=0, min_detection_confidence=0.5)

# Persistence counters to prevent flickering
auth_status = {"known_face": False, "eyes_detected": False}
persistence_counters = {"face": 0, "eyes": 0}
MAX_PERSISTENCE = 45  # ~1.5 seconds at 30fps — very stable, no flickering

# Optimization: Only run expensive face_recognition every N frames
recognition_frame_skip = 5
frame_count_recognition = 0


# Flag to indicate if the wake word was detected
wake_word_detected = False

# Locks for thread synchronization
lock = threading.Lock()

def is_finger_up(hand_landmarks, finger_tip, finger_pip, finger_mcp):
    # A finger is considered 'up' if the tip is above the PIP AND the PIP is above the MCP.
    # This two-point check makes the detection much more robust against accidental movements.
    return hand_landmarks.landmark[finger_tip].y < hand_landmarks.landmark[finger_pip].y and \
           hand_landmarks.landmark[finger_pip].y < hand_landmarks.landmark[finger_mcp].y


def detect_face_and_eyes(frame):
    global persistence_counters, auth_status, frame_count_recognition
    
    rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    
    # 1. Faster Detection with YOLO (Slightly higher confidence for stability)
    results = yolo_model.predict(source=frame, conf=0.6, verbose=False)
    face_currently_visible = False
    
    for result in results:
        boxes = result.boxes
        if boxes is not None and len(boxes) > 0:
            face_currently_visible = True
            for box in boxes:
                x1, y1, x2, y2 = map(int, box.xyxy[0])
                
                # 2. Identify Face (Only run recognition on active detections)
                is_this_box_authenticated = False
                frame_count_recognition += 1
                
                # Run recognition every N frames OR if we aren't sure who this is yet
                if persistence_counters["face"] <= 0 or frame_count_recognition % recognition_frame_skip == 0:
                    face_location = [(y1, x2, y2, x1)]
                    encodings = face_recognition.face_encodings(rgb_frame, face_location)
                    
                    if encodings:
                        matches = face_recognition.compare_faces(known_faces, encodings[0])
                        if True in matches:
                            persistence_counters["face"] = 30 # ~1 second persistence
                            auth_status["known_face"] = True
                            is_this_box_authenticated = True
                elif auth_status["known_face"]:
                    # If we were recently authenticated and YOLO is still seeing a face here, assume it's the same person
                    is_this_box_authenticated = True
                
                # 3. Robust Feature Detection (Eyes) with MediaPipe
                if is_this_box_authenticated:
                    # Draw face box ONLY for the authenticated person
                    cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)
                    cv2.putText(frame, "Authenticated", (x1, y1 - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
                    
                    # Check eyes using MediaPipe
                    mp_results = face_detection.process(rgb_frame)
                    if mp_results.detections:
                        detection = mp_results.detections[0]
                        persistence_counters["eyes"] = 30
                        auth_status["eyes_detected"] = True
                        
                        # Draw eye markers
                        for id in [0, 1]: 
                            kp = mp_face.get_key_point(detection, mp_face.FaceKeyPoint(id))
                            ex, ey = int(kp.x * frame.shape[1]), int(kp.y * frame.shape[0])
                            cv2.circle(frame, (ex, ey), 4, (255, 0, 0), -1)

                if is_this_box_authenticated: break # Stop after finding the first valid authorized user

    # 4. Handle Persistence (Decrement counters)
    if persistence_counters["face"] > 0: persistence_counters["face"] -= 1
    else: auth_status["known_face"] = False
    
    if persistence_counters["eyes"] > 0: persistence_counters["eyes"] -= 1
    else: auth_status["eyes_detected"] = False

    # CRITICAL: Only allow gestures if a face is ACTUALLY in the frame right now
    if not face_currently_visible:
        return False

    return auth_status["known_face"] and auth_status["eyes_detected"]

def speak(text):
    try:
        pythoncom.CoInitialize()
        speaker = win32com.client.Dispatch("SAPI.SpVoice")
        speaker.Rate = 2  # slightly faster than default
        speaker.Speak(text)
    except Exception as e:
        print(f"[TTS Error] {e}")

def voice_control_thread():
    pythoncom.CoInitialize()
    global wake_word_detected
    recognizer = sr.Recognizer()
    microphone = sr.Microphone()
    


    print("\n[Voice Control] Active. Say 'hello don' to give commands.")

    with microphone as source:
        # Calibrate once at the start
        recognizer.adjust_for_ambient_noise(source)
        
        while True:
            with lock:
                wake = wake_word_detected

            if not wake:
                try:
                    audio = recognizer.listen(source, timeout=1)
                    speech = recognizer.recognize_google(audio, language='en-IN').lower()
                    if "hello don" in speech:
                        print("[Voice Control] Wake word detected! Listening for command for 5 seconds...")
                        speak("Yes")
                        with lock: wake_word_detected = True
                except Exception:
                    continue
            else:
                try:
                    # Give them exactly 5 seconds to start and finish their command
                    audio = recognizer.listen(source, timeout=5, phrase_time_limit=5)
                    speech = recognizer.recognize_google(audio, language='en-IN').lower().strip()
                    process_voice_command(speech)
                except sr.WaitTimeoutError:
                    print("[Voice Control] Timeout (5s exceeded). Command ignored.")
                except sr.UnknownValueError:
                    print("[Voice Control] Could not understand the audio.")
                except Exception as e:
                    print(f"[Voice Control] Error: {e}")
                finally:
                    with lock: wake_word_detected = False
                    print("\n[Voice Control] Ready. Say 'hello don' to give commands.")

def process_voice_command(speech):
    speech = speech.lower().strip()
    found_command = False
    
    # Define keywords for actions
    on_keywords = ["on", "chalu", "start", "open"]
    off_keywords = ["off", "band", "stop", "close", "shut"]
    
    devices = {
        "rock": "A",
        "moon": "B",
        "dog": "C",
        "fan": "D"
    }
    
    # 1. Global Commands (Everything / All)
    if "everything" in speech or "all" in speech or "sab" in speech:
        if any(kw in speech for kw in on_keywords):
            print("Voice Command Executed: EVERYTHING ON")
            for relay_id in devices.values():
                send_command(f"{relay_id}1")
            speak("Turning on everything.")
            found_command = True
        elif any(kw in speech for kw in off_keywords):
            print("Voice Command Executed: EVERYTHING OFF")
            for relay_id in devices.values():
                send_command(f"{relay_id}0")
            speak("Turning off everything.")
            found_command = True

    # 2. Keyword-based Individual/Multiple Device Commands
    if not found_command:
        # Detect which devices are mentioned in the sentence
        mentioned_devices = [name for name in devices if name in speech]
        
        if mentioned_devices:
            if any(kw in speech for kw in on_keywords):
                for name in mentioned_devices:
                    send_command(f"{devices[name]}1")
                    print(f"Voice Command Executed: {name.upper()} ON")
                speak(f"Turning on {', '.join(mentioned_devices)}.")
                found_command = True
            elif any(kw in speech for kw in off_keywords):
                for name in mentioned_devices:
                    send_command(f"{devices[name]}0")
                    print(f"Voice Command Executed: {name.upper()} OFF")
                speak(f"Turning off {', '.join(mentioned_devices)}.")
                found_command = True
    
    if not found_command:
        print(f"[Voice Control] No valid action/device found in: '{speech}'")
        speak("I did not understand the command.")

def camera_control_thread():
    cap = cv2.VideoCapture(0)
    # Track committed states to avoid redundant commands
    # Index -> Rock (A), Middle -> Moon (B), Ring -> Dog (C), Pinky -> Fan (D)
    relay_states = {"A": False, "B": False, "C": False, "D": False}
    
    # Time-based debounce: finger must be held for HOLD_DURATION seconds before command fires
    HOLD_DURATION = 1.0  # 1 second hold required
    # Tracks when a new (different) state was first detected for each finger
    pending_change_start = {"A": None, "B": None, "C": None, "D": None}
    device_names = {"A": "Rock", "B": "Moon", "C": "Dog", "D": "Fan"}

    while cap.isOpened():
        ret, frame = cap.read()
        if not ret: break
        frame = cv2.flip(frame, 1)

        if detect_face_and_eyes(frame):
            rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            results = hands.process(rgb_frame)

            if results.multi_hand_landmarks and results.multi_handedness:
                for idx, hand_landmarks in enumerate(results.multi_hand_landmarks):
                    # Only accept gestures from the RIGHT hand
                    hand_label = results.multi_handedness[idx].classification[0].label
                    if hand_label != 'Right':
                        continue

                    # Define finger landmarks for easier processing
                    fingers = {
                        "A": (mp_hands.HandLandmark.INDEX_FINGER_TIP, mp_hands.HandLandmark.INDEX_FINGER_PIP, mp_hands.HandLandmark.INDEX_FINGER_MCP),
                        "B": (mp_hands.HandLandmark.MIDDLE_FINGER_TIP, mp_hands.HandLandmark.MIDDLE_FINGER_PIP, mp_hands.HandLandmark.MIDDLE_FINGER_MCP),
                        "C": (mp_hands.HandLandmark.RING_FINGER_TIP, mp_hands.HandLandmark.RING_FINGER_PIP, mp_hands.HandLandmark.RING_FINGER_MCP),
                        "D": (mp_hands.HandLandmark.PINKY_TIP, mp_hands.HandLandmark.PINKY_PIP, mp_hands.HandLandmark.PINKY_MCP)
                    }

                    now = time.time()

                    for key, (tip, pip, mcp) in fingers.items():
                        # Get real-time reading
                        is_up = is_finger_up(hand_landmarks, tip, pip, mcp)
                        
                        # Time-based Debouncing Logic
                        if is_up != relay_states[key]:
                            # A different state is being detected
                            if pending_change_start[key] is None:
                                # First frame of this new state — start the timer
                                pending_change_start[key] = now
                            elif (now - pending_change_start[key]) >= HOLD_DURATION:
                                # Held for the full duration — commit the change
                                relay_states[key] = is_up
                                send_command(f"{key}1" if is_up else f"{key}0")
                                print(f"Gesture Confirmed: {device_names[key]} {'ON' if is_up else 'OFF'}")
                                pending_change_start[key] = None
                        else:
                            # Reading matches current committed state — cancel any pending change
                            pending_change_start[key] = None

                    mp_draw.draw_landmarks(frame, hand_landmarks, mp_hands.HAND_CONNECTIONS)
                    
                    # Display status on screen (including pending hold indicators)
                    parts = []
                    for key, name in device_names.items():
                        state = 'ON' if relay_states[key] else 'OFF'
                        if pending_change_start[key] is not None:
                            held_for = now - pending_change_start[key]
                            pct = min(int((held_for / HOLD_DURATION) * 100), 99)
                            parts.append(f"{name}:{state}({pct}%)")
                        else:
                            parts.append(f"{name}:{state}")
                    status_text = " | ".join(parts)
                    cv2.putText(frame, status_text, (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)

        cv2.imshow('Gesture Control', frame)
        if cv2.waitKey(1) & 0xFF == ord('q'): break

    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    # Start voice control thread
    voice_thread = threading.Thread(target=voice_control_thread, daemon=True)
    voice_thread.start()

    # Start camera control thread
    camera_thread = threading.Thread(target=camera_control_thread, daemon=True)
    camera_thread.start()

    # Start serial reader thread
    def serial_reader():
        global serial_active
        while True:
            if serial_active:
                try:
                    if ser.in_waiting > 0:
                        line = ser.readline().decode('utf-8', errors='ignore').strip()
                        if line:
                            print(f"[ESP8266 says]: {line}")
                except Exception as e:
                    print(f"Serial Read Error: {e}")
                    time.sleep(1)
            time.sleep(0.01)

    reader_thread = threading.Thread(target=serial_reader, daemon=True)
    reader_thread.start()

    flask_thread = threading.Thread(
        target=lambda: app.run(host='0.0.0.0', port=5000, debug=False),
        daemon=True
    )
    flask_thread.start()

    try:
        # Keep main thread alive while background threads run
        while camera_thread.is_alive():
            camera_thread.join(timeout=1.0)
    except KeyboardInterrupt:
        print("Exiting...")