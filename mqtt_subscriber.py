import paho.mqtt.client as mqtt
import psycopg2
import csv
import os
from datetime import datetime

conn = psycopg2.connect(
    host="localhost",
    database="thermodb",
    user="thermouser",
    password="thermopass"
)

CSV_FILE = "/home/thermosmart/ThermoSmart/readings.csv"

if not os.path.exists(CSV_FILE):
    with open(CSV_FILE, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["timestamp", "topic", "value"])

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("Connected to Mosquitto!")
        client.subscribe("thermosmart/#")
    else:
        print(f"Connection failed with code {rc}")

def on_message(client, userdata, msg):
    topic = msg.topic
    value = msg.payload.decode()
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"Received -> topic: {topic} | Value: {value}")

    try:
        cur = conn.cursor()

        if topic == "thermosmart/temperature":
            cur.execute(
                "INSERT INTO readings (temp) VALUES (%s)",
                (float(value),)
            )
        elif topic == "thermosmart/setpoint":
            cur.execute(
                "INSERT INTO readings (setpoint) VALUES (%s)",
                (float(value),)
            )

        conn.commit()
        cur.close()
        print("Saved to PostgreSQL!")

        with open(CSV_FILE, "a", newline="") as f:
            writer = csv.writer(f)
            writer.writerow([timestamp, topic, value])
        print("Saved to CSV!")

    except Exception as e:
        print(f"Error saving to DB: {e}")

client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message

client.connect("localhost", 1883)
client.loop_forever()

