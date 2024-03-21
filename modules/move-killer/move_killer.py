import serial
import re
import os
import time
from os import environ

from json import dumps as json_dumps
from json import loads as json_loads
from ssl import CERT_NONE, SSLContext
from websocket import WebSocket


ssl_context = SSLContext()
ssl_context.check_hostname = False
ssl_context.verify_mode = CERT_NONE

token = environ["homeassistant_token"]


def ring():
    ws = WebSocket(sslopt={"cert_reqs": CERT_NONE})
    # ws.connect("wss://homeassistant.lo.f0rth.space/api/websocket")
    ws.connect(
        "wss://10.0.24.60/api/websocket",
        host="homeassistant.lo.f0rth.space",
    )
    ws.recv()  # recv auth request
    ws.send(json_dumps({"type": "auth", "access_token": token}))  # auth
    message = json_loads(ws.recv())  # get auth status
    if message["type"] != "auth_ok":
        print(f"Failed auth: {message}")
        exit(1)
    for _ in range(3):
      ws.send(
          json_dumps(
              {
                  "type": "call_service",
                  "domain": "button",
                  "service": "press",
                  "service_data": {"entity_id": "button.bell_bell_ring"},
                  "id": 43,
              }
          )
      )  # call ring
      time.sleep(0.4)
    ws.close()
# time.sleep(60)

# Параметры порта
port = "/dev/ttyUSB0"
baudrate = 115200

# Регулярное выражение для разбора данных
data_pattern = re.compile(r'X: ([-\d.]+)\s+Y: ([-\d.]+)\s+Z: ([-\d.]+)')

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
            line = ser.readline().decode('utf-8').strip()
            # print(line)  # Для отладки: выводим сырую строку

            # Используем регулярные выражения для разбора строки
            match = data_pattern.search(line)
            if match:
                # Преобразуем извлеченные строки в числа с плавающей точкой
                x = float(match.group(1))
                y = float(match.group(2))
                z = float(match.group(3))
                # print(f"X: {x}, Y: {y}, Z: {z}")  # Теперь у вас есть переменные x, y, z в формате float

                if x > 1 or x < -1 or y > 1 or y < -1 or z > 12 or z < 11:
                    if alert > 0:
                        alert += 1

                        if alert == 10:
                            alert = 0

                        continue

                    print("ALERT")
                    ring()
                    os.system('ping admins "ALERT: move"')
                    alert = 1
                    # time.sleep(5)

        # Маленькая пауза, чтобы не загружать процессор
        time.sleep(0.1)

except serial.SerialException as e:
    print(f"Ошибка при подключении к порту: {e}")

except KeyboardInterrupt:
    print("\nПрограмма прервана пользователем")
