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

# Configure Serial Communication
try:
    ser = serial.Serial('COM5', 9600, timeout=1)
    time.sleep(2)
    serial_active = True
except Exception as e:
    print(f"Error opening serial port: {e}")
    serial_active = False

serial_lock = threading.Lock()

def send_command(cmd):
    global serial_active
    if not serial_active:
        print("\n!!! [FATAL ERROR] Cannot send command to ESP8266 !!!")
        print("!!! The USB Port (COM5) is blocked by the Arduino Serial Monitor !!!\n")
        return
        
    with serial_lock:
        try:
            ser.write((cmd + "\n").encode())
            time.sleep(0.03)
        except Exception as e:
            print(f"Serial write error: {e}")
            serial_active = False

# Initialize MediaPipe Hand module
mp_hands = mp.solutions.hands
hands = mp_hands.Hands(
    static_image_mode=False,
    max_num_hands=1,
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

# Load Haar cascade for eye detection
eye_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_eye.xml')

# Flag to indicate if the wake word was detected
wake_word_detected = False

# Locks for thread synchronization
lock = threading.Lock()

def is_finger_up(hand_landmarks, finger_tip, finger_pip):
    return hand_landmarks.landmark[finger_tip].y < hand_landmarks.landmark[finger_pip].y

def detect_face_and_eyes(frame):
    known_face_detected = False
    both_eyes_detected = False
    rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    
    results = yolo_model.predict(source=frame, conf=0.5, verbose=False)

    for result in results:
        boxes = result.boxes
        if boxes is not None and len(boxes) > 0:
            for box in boxes:
                x1, y1, x2, y2 = map(int, box.xyxy[0])
                
                face_location = [(y1, x2, y2, x1)]
                encodings = face_recognition.face_encodings(rgb_frame, face_location)
                
                if encodings:
                    matches = face_recognition.compare_faces(known_faces, encodings[0])
                    if True in matches:
                        known_face_detected = True
                        face_frame = frame[y1:y2, x1:x2]
                        if face_frame.size > 0:
                            gray_face = cv2.cvtColor(face_frame, cv2.COLOR_BGR2GRAY)
                            gray_face = cv2.equalizeHist(gray_face)
                            eyes = eye_cascade.detectMultiScale(gray_face, scaleFactor=1.1, minNeighbors=3)
            
                            if len(eyes) >= 2:
                                both_eyes_detected = True
                                for (ex, ey, ew, eh) in eyes[:2]:
                                    cv2.rectangle(face_frame, (ex, ey), (ex + ew, ey + eh), (255, 0, 0), 2)
                                
                        cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)
                        cv2.putText(frame, "Known Face", (x1, y1 - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.9, (0, 255, 0), 2)
                        break
                
                if known_face_detected:
                    break
    
    return known_face_detected and both_eyes_detected

def speak(text):
    try:
        pythoncom.CoInitialize()
        speaker = win32com.client.Dispatch("SAPI.SpVoice")
        speaker.Rate = 2
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
    commands = {
        "turn on rock": "A1\n", "rock on": "A1\n", "rock on karo": "A1\n",
        "turn off rock": "A0\n", "rock off": "A0\n", "rock off karo": "A0\n",
        "turn on moon": "B1\n", "moon on": "B1\n", "moon on karo": "B1\n",
        "turn off moon": "B0\n", "moon off": "B0\n", "moon off karo": "B0\n",
        "turn on dog": "C1\n", "dog on": "C1\n", "dog on karo": "C1\n",
        "turn off dog": "C0\n", "dog off": "C0\n", "dog off karo": "C0\n"
    }
    
    cmd = commands.get(speech)
    if cmd:
        print(f"Voice Command Executed: {cmd.strip()}")
        send_command(cmd.strip())
        speak("Command executed.")
    else:
        print(f"[Voice Control] Unknown command: '{speech}'")
        speak("I did not understand the command.")

def camera_control_thread():
    cap = cv2.VideoCapture(0)
    
    # Track states to avoid redundant commands
    # Index -> Rock (A), Middle -> Moon (B), Ring -> Dog (C)
    relay_states = {"A": False, "B": False, "C": False}

    while cap.isOpened():
        ret, frame = cap.read()
        if not ret: break
        frame = cv2.flip(frame, 1)

        if detect_face_and_eyes(frame):
            rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            results = hands.process(rgb_frame)

            if results.multi_hand_landmarks and results.multi_handedness:
                for idx, hand_landmarks in enumerate(results.multi_hand_landmarks):
                    # Check Index, Middle, Ring fingers
                    index_up = is_finger_up(hand_landmarks, mp_hands.HandLandmark.INDEX_FINGER_TIP, mp_hands.HandLandmark.INDEX_FINGER_PIP)
                    middle_up = is_finger_up(hand_landmarks, mp_hands.HandLandmark.MIDDLE_FINGER_TIP, mp_hands.HandLandmark.MIDDLE_FINGER_PIP)
                    ring_up = is_finger_up(hand_landmarks, mp_hands.HandLandmark.RING_FINGER_TIP, mp_hands.HandLandmark.RING_FINGER_PIP)

                    # Update Relay A (Rock) based on Index
                    if index_up != relay_states["A"]:
                        relay_states["A"] = index_up
                        send_command("A1" if index_up else "A0")
                        print(f"Gesture: Rock {'ON' if index_up else 'OFF'}")

                    # Update Relay B (Moon) based on Middle
                    if middle_up != relay_states["B"]:
                        relay_states["B"] = middle_up
                        send_command("B1" if middle_up else "B0")
                        print(f"Gesture: Moon {'ON' if middle_up else 'OFF'}")

                    # Update Relay C (Dog) based on Ring
                    if ring_up != relay_states["C"]:
                        relay_states["C"] = ring_up
                        send_command("C1" if ring_up else "C0")
                        print(f"Gesture: Dog {'ON' if ring_up else 'OFF'}")

                    mp_draw.draw_landmarks(frame, hand_landmarks, mp_hands.HAND_CONNECTIONS)
                    
                    # Display status on screen
                    status_text = f"Rock: {'ON' if relay_states['A'] else 'OFF'} | Moon: {'ON' if relay_states['B'] else 'OFF'} | Dog: {'ON' if relay_states['C'] else 'OFF'}"
                    cv2.putText(frame, status_text, (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)

        cv2.imshow('Gesture Control', frame)
        if cv2.waitKey(1) & 0xFF == ord('q'): break

    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    voice_thread = threading.Thread(target=voice_control_thread, daemon=True)
    voice_thread.start()

    camera_thread = threading.Thread(target=camera_control_thread, daemon=True)
    camera_thread.start()

    try:
        while camera_thread.is_alive():
            camera_thread.join(timeout=1.0)
    except KeyboardInterrupt:
        print("Exiting...")
