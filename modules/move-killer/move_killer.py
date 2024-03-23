from hashlib import sha256
from random import choice
from shlex import quote
import serial
import re
import os
import time
from os import environ

from json import JSONDecodeError, dumps as json_dumps
from json import loads as json_loads
from ssl import CERT_NONE, SSLContext
from websocket import WebSocket


ssl_context = SSLContext()
ssl_context.check_hostname = False
ssl_context.verify_mode = CERT_NONE

token = environ["homeassistant_token"]


last_ring = 0.0

sounds_dir = environ["SOUNDS_DIR"]


def ring():
    global last_ring
    if time.time() - last_ring < 3:
        return
    last_ring = time.time()
    ws = WebSocket(sslopt={"cert_reqs": CERT_NONE})
    # ws.connect("wss://homeassistant.lo.f0rth.space/api/websocket")
    ws.connect(
        "wss://10.0.24.60/api/websocket",
        host="homeassistant.lo.f0rth.space",
        timeout=1,
    )
    ws.recv()  # recv auth request
    ws.send(json_dumps({"type": "auth", "access_token": token}))  # auth
    message = json_loads(ws.recv())  # get auth status
    if message["type"] != "auth_ok":
        print(f"Failed auth: {message}")
        exit(1)
    ws.send(
        json_dumps(
            {
                "type": "call_service",
                "domain": "switch",
                "service": "turn_on",
                "service_data": {"entity_id": "switch.bell_bell_switch"},
                "id": 1,
            }
        )
    )  # enable ring
    time.sleep(1)
    ws.send(
        json_dumps(
            {
                "type": "call_service",
                "domain": "switch",
                "service": "turn_off",
                "service_data": {"entity_id": "switch.bell_bell_switch"},
                "id": 2,
            }
        )
    )  # disable ring
    ws.close()


def play_sound():
    file = os.path.join(sounds_dir, choice(os.listdir(sounds_dir)))
    os.system(f"aplay {quote(file)}")


os.system("amixer sset 'Master' 0%")
play_sound()  # захватываем контроль над пайпвайром под рутом
os.system("amixer sset 'Master' 70%")

# time.sleep(60)

# Параметры порта
port = "/dev/ttyUSB0"
baudrate = 9600

# Регулярное выражение для разбора данных
xyz_data_pattern = re.compile(r"X: ([-\d.]+)\s+Y: ([-\d.]+)\s+Z: ([-\d.]+)")
button_data_pattern = re.compile(r"Button: (HIGH|LOW)")

last_button_state = None
last_xyz_alert_time = 0
last_steady_recheck = time.time()
last_play_sound = 60

steady_x, steady_y, steady_z = None, None, None


def check_acc(steady: float, value: float) -> bool:
    return abs(steady - value) > 0.03


# Устанавливаем соединение с портом
try:
    ser = serial.Serial(port, baudrate, timeout=1)
    # Открываем порт, если он не открыт
    if not ser.is_open:
        ser.open()

    print(f"Подключено к: {ser.portstr}")

    # Читаем данные из порта
    alert = 0

    while True:
        if ser.in_waiting > 0 or True:
            line = ser.readline().decode("utf-8", errors="replace").strip()
            # print(f"Line: {line}")

            try:
                data = json_loads(line)
            except JSONDecodeError:
                print(f"Invalid JSON: {line}")
                continue

            if "type" not in data:
                print(f"Invalid data: {data}")
                continue

            if data["type"] == "ver":
                h = sha256(data["c"].encode()).hexdigest()
                if h != environ["hash"]:
                    msg = f"ALERT: hash mismatch, orig data: {h}"
                    print(msg)
                    os.system(f"notif admins {quote(msg)}")
                    exit(1)

            if data["type"] == "acc":
                x: float = data["x"]
                y: float = data["y"]
                z: float = data["z"]

                if steady_x is None:
                    steady_x, steady_y, steady_z = x, y, z

                if time.time() - last_steady_recheck > 30:
                    # print("Reassing steady values")
                    steady_x, steady_y, steady_z = x, y, z
                    last_steady_recheck = time.time()

                if any(
                    [
                        check_acc(steady_x, x),
                        check_acc(steady_y, y),
                        check_acc(steady_z, z),
                    ]
                ):
                    if time.time() - last_xyz_alert_time > 10:
                        print(f"XYZ ALERT: f{x}, {y}, {z}")
                        os.system(f'notif admins "ALERT: move {x}, {y}, {z}"')
                        ring()
                        if time.time() - last_play_sound > 60:
                          play_sound()
                          last_play_sound = time.time()
                          
                        last_xyz_alert_time = time.time()

            if data["type"] == "btn":
                button_state: bool = data["s"]

                if (
                    last_button_state is not None
                    and last_button_state != button_state
                    and button_state is False
                ):
                    print("BUTTON ALERT")
                    os.system('notif admins "ALERT: button"')
                    ring()
                    if time.time() - last_play_sound > 60:
                      play_sound()
                      last_play_sound = time.time()

                last_button_state = button_state

except serial.SerialException as e:
    print(f"Ошибка при подключении к порту: {e}")
    msg = f"ALERT: serial error: {e}"
    os.system(f"notif admins {quote(msg)}")

except KeyboardInterrupt:
    print("\nПрограмма прервана пользователем")
    os.system("notif admins 'ALERT: user interrupt'")
