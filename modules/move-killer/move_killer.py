import serial
import re
import os
import time


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
                    os.system('''(cd /root/notif/ && ./ping admins "ALERT: move")''')
                    alert = 1
                    # time.sleep(5)

        # Маленькая пауза, чтобы не загружать процессор
        time.sleep(0.1)

except serial.SerialException as e:
    print(f"Ошибка при подключении к порту: {e}")

except KeyboardInterrupt:
    print("\nПрограмма прервана пользователем")
