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

# Load Haar cascade for eye detection
eye_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_eye.xml')


# Flag to indicate if the wake word was detected
wake_word_detected = False

# Locks for thread synchronization
lock = threading.Lock()

def map_range(value, in_min, in_max, out_min, out_max):
    return int(max(min((value - in_min) * (out_max - out_min) / (in_max - in_min) + out_min, out_max), out_min))

def get_hand_openness(hand_landmarks, normalization_factor):
    finger_tips = [
        mp_hands.HandLandmark.THUMB_TIP,
        mp_hands.HandLandmark.INDEX_FINGER_TIP,
        mp_hands.HandLandmark.MIDDLE_FINGER_TIP,
        mp_hands.HandLandmark.RING_FINGER_TIP,
        mp_hands.HandLandmark.PINKY_TIP
    ]
    finger_bases = [
        mp_hands.HandLandmark.THUMB_CMC,
        mp_hands.HandLandmark.INDEX_FINGER_MCP,
        mp_hands.HandLandmark.MIDDLE_FINGER_MCP,
        mp_hands.HandLandmark.RING_FINGER_MCP,
        mp_hands.HandLandmark.PINKY_MCP
    ]
    distances = []
    for tip, base in zip(finger_tips, finger_bases):
        tip_pos = np.array([hand_landmarks.landmark[tip].x, hand_landmarks.landmark[tip].y])
        base_pos = np.array([hand_landmarks.landmark[base].x, hand_landmarks.landmark[base].y])
        distance = np.linalg.norm(tip_pos - base_pos) / normalization_factor
        distances.append(distance)

    return np.mean(distances) if distances else 0


def save_calibration(min_openness, max_openness):
    with open('calibration_data.json', 'w') as f:
        json.dump({'min_openness': min_openness, 'max_openness': max_openness}, f)

def load_calibration():
    if os.path.exists('calibration_data.json'):
        with open('calibration_data.json', 'r') as f:
            data = json.load(f)
        return data['min_openness'], data['max_openness']
    return None, None

def calibrate_openness(cap):
    min_openness, max_openness = load_calibration()
    if min_openness is not None and max_openness is not None:
        return min_openness, max_openness

    print("Calibration needed. Please fully open and close your right hand.")
    min_openness = float('inf')
    max_openness = float('-inf')
    frame_count = 0

    while frame_count < 100:
        ret, frame = cap.read()
        if not ret: break
        frame = cv2.flip(frame, 1)
        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = hands.process(rgb_frame)

        if results.multi_hand_landmarks and results.multi_handedness:
            for idx, hand_landmarks in enumerate(results.multi_hand_landmarks):
                if results.multi_handedness[idx].classification[0].label == 'Right':
                    wrist = np.array([hand_landmarks.landmark[mp_hands.HandLandmark.WRIST].x,
                                      hand_landmarks.landmark[mp_hands.HandLandmark.WRIST].y])
                    middle_mcp = np.array([hand_landmarks.landmark[mp_hands.HandLandmark.MIDDLE_FINGER_MCP].x,
                                           hand_landmarks.landmark[mp_hands.HandLandmark.MIDDLE_FINGER_MCP].y])
                    normalization_factor = np.linalg.norm(wrist - middle_mcp)
                    openness = get_hand_openness(hand_landmarks, normalization_factor)
                    min_openness = min(min_openness, openness)
                    max_openness = max(max_openness, openness)
                    frame_count += 1
                    mp_draw.draw_landmarks(frame, hand_landmarks, mp_hands.HAND_CONNECTIONS)
                    cv2.imshow('Calibration', frame)
        if cv2.waitKey(1) & 0xFF == ord('q'): break

    cv2.destroyAllWindows()
    save_calibration(min_openness, max_openness)
    return min_openness, max_openness

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
                
                # Check if this face is the known face
                face_location = [(y1, x2, y2, x1)]
                encodings = face_recognition.face_encodings(rgb_frame, face_location)
                
                if encodings:
                    matches = face_recognition.compare_faces(known_faces, encodings[0])
                    if True in matches:
                        known_face_detected = True
                        
                        # Only detect eyes if it's a known face
                        face_frame = frame[y1:y2, x1:x2]
                        if face_frame.size > 0:
                            gray_face = cv2.cvtColor(face_frame, cv2.COLOR_BGR2GRAY)
                            # Apply histogram equalization to improve contrast for better detection in low/uneven light
                            gray_face = cv2.equalizeHist(gray_face)
                            
                            # Lowered minNeighbors from 4 to 3 to make eye detection more sensitive
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
    min_openness, max_openness = calibrate_openness(cap)
    cap = cv2.VideoCapture(0) # Re-init for main loop
    last_dimmer_value = -1

    while cap.isOpened():
        ret, frame = cap.read()
        if not ret: break
        frame = cv2.flip(frame, 1)

        if detect_face_and_eyes(frame):
            rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            results = hands.process(rgb_frame)
            command = ""

            if results.multi_hand_landmarks and results.multi_handedness:
                for idx, hand_landmarks in enumerate(results.multi_hand_landmarks):
                    label = results.multi_handedness[idx].classification[0].label

                    if label == 'Right':
                        wrist = np.array([hand_landmarks.landmark[mp_hands.HandLandmark.WRIST].x, hand_landmarks.landmark[mp_hands.HandLandmark.WRIST].y])
                        m_mcp = np.array([hand_landmarks.landmark[mp_hands.HandLandmark.MIDDLE_FINGER_MCP].x, hand_landmarks.landmark[mp_hands.HandLandmark.MIDDLE_FINGER_MCP].y])
                        norm = np.linalg.norm(wrist - m_mcp)
                        openness = get_hand_openness(hand_landmarks, norm)
                        dimmer_value = max(0, min(100, map_range(openness, min_openness, max_openness, 0, 100)))
                        
                        if abs(dimmer_value - last_dimmer_value) > 3:
                            command = f"D{dimmer_value}"
                            send_command(command)
                            last_dimmer_value = dimmer_value
                            
                        cv2.putText(frame, f'Dog: {dimmer_value}%', (10, 70), cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 0, 0), 2)

                    mp_draw.draw_landmarks(frame, hand_landmarks, mp_hands.HAND_CONNECTIONS)

            if command:
                print(f"Gesture Command Executed: {command}")

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

    try:
        # Keep main thread alive while background threads run
        while camera_thread.is_alive():
            camera_thread.join(timeout=1.0)
    except KeyboardInterrupt:
        print("Exiting...")